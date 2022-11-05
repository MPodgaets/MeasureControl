unit DM;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,  Vcl.Forms, FireDAC.Phys.IB,
  Winapi.Windows, Winapi.Messages, FireDAC.Phys.IBDef, FireDAC.Phys.IBBase,
  FireDAC.Phys.IBWrapper, FireDAC.Moni.Base, FireDAC.Moni.FlatFile,
  uList, uMeasureValues, uMain, uQueryThread, uMessage;

const max_dif_value = 20; //максимальная прибавка показаний счетчика за месяц

type
  TfrmDM = class(TDataModule)
    fdcMeasureControl: TFDConnection;
    fbSecurity: TFDIBSecurity;
    fdUsers: TFDMemTable;
    dsUsers: TDataSource;
    fdConnectManager: TFDManager;
    FBServerDriverLink: TFDPhysFBDriverLink;

    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure fdUsersAfterOpen(DataSet: TDataSet);

  private
    { Private declarations }
    FEmbedded: Boolean; //embedded режим работы firebird
    FQueryLst : TStringList;  //список нитей для запросов к БД

    procedure QueryThread_OnTerminate(Sender: TObject);
    procedure SetEmbedded(const Value: Boolean);
    procedure CloseThreads;

  public
    { Public declarations }
    function GetSQLMeasurers(aSql : String; const AParams : TFDParams; var BParams : array of Variant):String;
    procedure GetUsers(const aUsers : TStrings);
    procedure CloseConnection;
    function GetConnectionStr : String;
    procedure InsertUser(AParams : TFDParams);
    procedure ModifyUser(AParams : TFDParams);

    procedure DBExecuteSQL(const Asql : string; const AParams : TFDParams; const AMemTable : TFDMemTable; const ALog : TStrings; const AQuery_Name : String; AQueryResult : Boolean = True);

    property Embedded : Boolean read FEmbedded write SetEmbedded;
  end;

var
  frmDM: TfrmDM;

implementation

uses Vcl.Controls, System.DateUtils,Vcl.Dialogs,
System.UITypes, uLog, uDBSettings;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{procedure TfrmDM.ChangeMeasurer(AParams: TFDParams);
var sqlChangeMeasurer : String;
FQueryThread_ChangeMeasurer : TQueryThread;
  ind : Integer;
begin
  //Изменение счетчика
  sqlChangeMeasurer := 'select * from change$measurer(:street,' +
    ' :house_number, :flat_number, :install_date, :factory_number_old,' +
    ' :factory_number_new, null, null)';
  try
    if FQueryLst.IndexOf('ChangeMeasurer') = -1 then
    begin
      //Создадим нить в остановленном состоянии
      FQueryThread_ChangeMeasurer := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('ChangeMeasurer',FQueryThread_ChangeMeasurer);
        with FQueryThread_ChangeMeasurer do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlChangeMeasurer, AParams,
            'qProcResult1', nil) then
          begin

            Start;
          end;
        end;
      except
       on E: Exception do   // on EConvertError do
        begin
         FQueryThread_ChangeMeasurer.Free;
         ind := FQueryLst.IndexOf('ChangeMeasurer');
         if ind > -1 then
          FQueryLst.Delete(ind);
         Application.MessageBox(PChar('Ошибка : ' +
         E.Message), 'Ошибка', 0);
        end;
      end;
    end;
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end;  }

procedure TfrmDM.CloseConnection;
begin
  //Завершим работу нитей
  CloseThreads;
  //Закроем соединение
  if fdcMeasureControl.Connected then
    fdcMeasureControl.Close;
end;

//Завершение работы нитей, выполняющих запросы к БД
procedure TfrmDM.CloseThreads;
var i : Integer;
  pQueryThread : TQueryThread;
begin
//Если работает нить чтения-записи в БД, то дождемся окончания ее работы
  if FQueryLst.Count > 0 then
  begin
    for i := 0 to FQueryLst.Count - 1 do
    begin
      if Assigned(FQueryLst.Objects[i]) and
      (FQueryLst.Objects[i] is TQueryThread) then
      begin
        pQueryThread := FQueryLst.Objects[i] as TQueryThread;
        //Если нить работает, то подождем окончания ее работы
        pQueryThread.WaitFor;
        pQueryThread.Free;
      end;
      FQueryLst.Delete(i);
    end;
  end;
end;

procedure TfrmDM.DataModuleCreate(Sender: TObject);
var frmDBSettings : TfrmDBSettings;
begin
  FQueryLst := TStringList.Create;
  SetEmbedded(True);

  FBServerDriverLink.VendorLib := ExtractFilePath(Application.ExeName) +
  'fbclient.dll';

  with fbSecurity do
  begin
    Protocol := TIBProtocol.ipTCPIP;
    Host := '127.0.0.1';
    UserName := 'SYSDBA';
    Password := 'sa123';
  end;

  fdConnectManager.ConnectionDefFileName := ExtractFilePath(Application.ExeName) +
  'FDConnectionDefs.ini';
  fdConnectManager.ConnectionDefFileAutoLoad := True;
  //Покажем окно настроек
  frmDBSettings := TfrmDBSettings.Create(Application);
  frmDBSettings.Show;
end;

procedure TfrmDM.DataModuleDestroy(Sender: TObject);
begin
  //Завершим работу нитей, отправляющих запросы к БД и закроем подключение
  CloseConnection;
  FQueryLst.Free;
end;

procedure TfrmDM.DBExecuteSQL(const Asql: string; const AParams: TFDParams;
  const AMemTable: TFDMemTable; const ALog: TStrings; const AQuery_Name : String;
  AQueryResult: Boolean);
var
  AQueryThread : TQueryThread;
  ind : Integer;
begin
  if FQueryLst.IndexOf(AQuery_Name) = -1 then
  begin
    //Создадим нить в остановленном состоянии
    AQueryThread := TQueryThread.Create(True);
    try
      FQueryLst.AddObject(AQuery_Name, AQueryThread);
      with AQueryThread do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, Asql, AParams, AMemTable, ALog, AQueryResult) then
            Start;
        end;
    except
      on E: Exception do   // on EConvertError do
      begin
        ind := FQueryLst.IndexOf(AQuery_Name);
        if ind > -1 then
        FQueryLst.Delete(ind);
        AQueryThread.Free;
        Application.MessageBox(PChar('Ошибка : ' + e.Message), 'Ошибка', 0);
      end;
    end;
  end;
end;

procedure TfrmDM.fdUsersAfterOpen(DataSet: TDataSet);
var i : Integer;
begin
  //Отредактируем заголовки столбцов
  fdUsers.Fields[0].DisplayLabel := 'Пользователь';
  fdUsers.Fields[1].DisplayLabel := 'Пароль';
  for i := 2 to fdUsers.FieldCount - 1 do
    fdUsers.Fields[i].Visible := False;
end;

{procedure TfrmDM.GetChangeMeasurerHistory;
var sqlHistory : String;
  BParams : TFDParams;
  ind : Integer;
  FQueryThread_History : TQueryThread;

begin
 //История установки счетчиков в квартире
  sqlHistory := 'SELECT F.IDMEASURER, F.FACTORY$NUMBER, F.DATE$INSTALL,' +
  ' F.MEASURER$NUMBER FROM ' +
  ' GET$HISTORY$MEASURER$FLAT(:STREET, :HOUSE_NUMBER, :FLAT_NUMBER) AS F' +
  ' ORDER BY F.MEASURER$NUMBER';

  if FQueryLst.IndexOf('History') = -1 then
  begin
    BParams := TFDParams.Create;
    try
      //Создадим нить в остановленном состоянии
      FQueryThread_History := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('History',FQueryThread_History);
        BParams.Add('STREET', qFlats.FieldByName('STREET').AsVariant, ptInput);
        BParams.Add('HOUSE_NUMBER', qFlats.FieldByName('HOUSE_NUMBER').AsVariant, ptInput);
        BParams.Add('FLAT_NUMBER', qFlats.FieldByName('FLAT_NUMBER').AsVariant, ptInput);
        with FQueryThread_History do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlHistory, BParams,
           'qChangeMeasureHistory', nil) then
          begin
            frmMain.SetThreadStatus('Запрос истории установки счетчиков в квартире' +
            ' по адресу: ' + qFlats.FieldByName('STREET').AsString + ' ' +
            qFlats.FieldByName('HOUSE_NUMBER').AsString + ' - ' +
            qFlats.FieldByName('FLAT_NUMBER').AsString );
            Start;
          end;
        end;
      except
         on E: Exception do   // on EConvertError do
          begin
           FQueryThread_History.Free;
           ind := FQueryLst.IndexOf('History');
           if ind > - 1 then
            FQueryLst.Delete(ind);
           Application.MessageBox(PChar('Ошибка : ' +
           e.Message), 'Ошибка', 0);
          end;
      end;
    finally
      if Assigned(BParams) then BParams.Free;
    end;
  end;
end;   }

function TfrmDM.GetConnectionStr: String;
begin
  //Определим строку для подключения к базе данных
  Result := 'DriverID=FB;Database=' + frmMain.DatabaseStr +
  ';CharacterSet=win1251;SQLDialect=3;CharacterSet=WIN1251;';

  if not FEmbedded then
    Result := Result + 'Protocol=TCPIP;Server=' + fbSecurity.Host + ';';
end;

//Генерация условия where для запроса
function TfrmDM.GetSQLMeasurers(aSql: String; const AParams: TFDParams; var BParams : array of Variant): String;
var sqlWhere : String;
  Param1, Param2 : TFDParam;
  ind : Integer;
begin
  sqlWhere := '';
  ind := 0;
  //Если определен параметр "Заводской номер"
  Param1 := AParams.FindParam('FACTORY_NUMBER');
  if Assigned(Param1) then
  begin
    sqlWhere := '(M.factory_number LIKE :FACTORY_NUMBER)';
    BParams[0] := Variant(Param1.AsString);
    Inc(ind);
  end;
  //Если определены параметры "Дата поверки1" и "Дата поверки2"
  Param1 := AParams.FindParam('BCHECK_DATE');
  Param2 := AParams.FindParam('ECHECK_DATE');
  if Assigned(Param1) and Assigned(Param2) then
  begin
    if sqlWhere <> '' then sqlWhere := sqlWhere + ' AND ';
      sqlWhere := sqlWhere +
      '(M.check_date BETWEEN :BCHECK_DATE and :ECHECK_DATE)';
      BParams[ind] := Variant(Param1.AsDate);
      BParams[ind + 1] := Variant(Param2.AsDate);
      Inc(ind, 2);
  end
  else
  if Assigned(Param1) then
  begin
    if sqlWhere <> '' then sqlWhere := sqlWhere + ' AND ';
    sqlWhere := sqlWhere + '(M.check_date = :BCHECK_DATE)';
    BParams[ind] := Variant(Param1.AsDate);
    Inc(ind);
  end;
  //Если определены параметры "Дата следующей поверки1" и "Дата следующей поверки2"
  Param1 := AParams.FindParam('BNEXT_CHECK_DATE');
  Param2 := AParams.FindParam('ENEXT_CHECK_DATE');
  if Assigned(Param1) and Assigned(Param2) then
  begin
    if sqlWhere <> '' then sqlWhere := sqlWhere + ' AND ';
      sqlWhere := sqlWhere +
      '(M.next_check_date BETWEEN :BNEXT_CHECK_DATE and :ENEXT_CHECK_DATE)';
    BParams[ind] := Variant(Param1.AsDate);
    BParams[ind + 1] := Variant(Param2.AsDate);
   // Inc(ind, 2);
  end
  else
    if Assigned(Param1) then
    begin
      if sqlWhere <> '' then sqlWhere := sqlWhere + ' AND ';
        sqlWhere := sqlWhere + '(M.next_check_date = :BNEXT_CHECK_DATE)';
      BParams[ind] := Variant(Param1.AsDate);
      //(ind);
    end;
  Result := sqlWhere;
end;

procedure TfrmDM.GetUsers(const aUsers: TStrings);
begin
  try
    fdUsers.DisableControls;
    if fdUsers.Active then fdUsers.Close;
    fbSecurity.DisplayUsers;
    fdUsers.AttachTable(fbSecurity.Users, nil);
    fdUsers.Open;
    if Assigned(aUsers) then
      with fdUsers do
      begin
        First;
        while not Eof do
        begin
          aUsers.Add(Fields[0].AsString);
          Next;
        end;
      end;
    fdUsers.EnableControls;
  except
    on E : EIBNativeException do
    Application.MessageBox(PChar('Ошибка доступа к базе данных: ' +
         e.Message), 'Ошибка', 0);
  end;
end;

procedure TfrmDM.InsertUser(AParams: TFDParams);
begin
  try
    with fbSecurity do
      begin
        AUserName := AParams.ParamByName('user$name').AsString;
        APassword := AParams.ParamByName('user$password').AsString;
        //AFirstName := AParams.ParamByName('first$name').AsString;
        //AMiddleName := AParams.ParamByName('middle$name').AsString;
        //ALastName := AParams.ParamByName('last$name').AsString;
       // ARoleName := strUserRole;
        AddUser;
      end;
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end;

procedure TfrmDM.ModifyUser(AParams: TFDParams);
begin
  try
    with fbSecurity do
    begin
      AUserName := AParams.ParamByName('user$name').AsString;
      APassword := AParams.ParamByName('user$password').AsString;;
      ModifyUser;
    end;
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end;

//Нить закончила работу
procedure TfrmDM.QueryThread_OnTerminate(Sender: TObject);
var   ind : Integer;
  BMemTable : TFDMemTable;
  field1_name : String;
  field1_value : Variant;
begin
  field1_name := '';
  field1_value := '';
  if Sender is TQueryThread then
  try
    BMemTable := (Sender as TQueryThread).MemTable;
    //Если найден MemTable, то скопируем результаты запроса в MemTable
    if Assigned(BMemTable) then
    begin
      with BMemTable do
      begin
        //Запомним имя и значение первого столбца текущей строки
        if not IsEmpty then
        begin
          field1_name := Fields[0].FieldName;
          field1_value := Fields[0].Value;
        end;
        DisableControls;
        //Закроем набор данных и очистим поля
        Close;
        Fields.Clear;  //EmptyDataSet
        ReadOnly := True;
        //Скопируем результаты запроса в MemTable и откроем его
        AppendData((Sender as TQueryThread).Qry); //набор данных полностью HitEOF=True, default
        ReadOnly := False;
        if field1_name <> '' then
        //Установим текущую строку с помощью имени и значения первого столбца
          Locate(field1_name, field1_value, [])
        else First;

        EnableControls;
      end;
    end;
    //Найдем нить в списке нитей
    ind := FQueryLst.IndexOfObject(Sender);
    //Удалим нить из списка
    if ind > -1 then
      FQueryLst.Delete(ind);
    frmMain.SetThreadStatus('');
  except
     on E: Exception do
         Application.MessageBox(PChar('Ошибка : ' +
         e.Message), 'Ошибка', 0);
  end;
end;

procedure TfrmDM.SetEmbedded(const Value: Boolean);
var UsersVis : Boolean;
  i : Integer;
begin
  FEmbedded := Value;
  if Assigned(frmMain) then
  begin
    UsersVis := (not(FEmbedded) and frmMain.IsSysdba);

    frmMain.aShowUsers.Enabled := UsersVis;
    with frmMain, alMeasureControl do
    for i := 0 to ActionCount - 1 do
    if Actions[i].Category = 'Users' then
      Actions[i].Enabled := UsersVis;
  end;
end;

end.
