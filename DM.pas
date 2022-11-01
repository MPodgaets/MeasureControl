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
  //  procedure UpdateFlats(AParams : TFDParams);
   // procedure UpdateMeasurers(AParams : TFDParams);
  //  procedure UpdateFreeMeasurers(AParams : TFDParams);
 //   procedure InsertMeasureValue(AParams : TFDParams);
    //procedure InsertMeasurer(AParams : TFDParams);
   // procedure ChangeMeasurer(AParams : TFDParams);
    //procedure GetNotVerificMeasurers(AParams : TFDParams);
   // procedure GetStreets;
    //procedure GetHouse_numbers(const aStreet : string);
    //procedure GetChangeMeasurerHistory;
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

{procedure TfrmDM.GetHouse_numbers(const aStreet: string);
var sqlHouse_numbers : string;
  FQueryThread_House : TQueryThread;
  ind : Integer;
  BParams : TFDParams;
begin
  //Выберем номера домов для выбранной улицы
  sqlHouse_numbers := 'SELECT DISTINCT F.HOUSE_NUMBER FROM VWFLATS AS F' +
  ' WHERE F.STREET LIKE :STREET';
  if FQueryLst.IndexOf('House') = -1 then
  begin
    BParams := TFDParams.Create;
    try
      //Создадим нить в остановленном состоянии
      FQueryThread_House := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('House',FQueryThread_House);
        with FQueryThread_House do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          BParams.Add('STREET', aStreet, ptInput);
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlHouse_numbers, BParams, 'qHouse_numbers',
            nil) then
          begin
            frmMain.SetThreadStatus('Запрос списка домов для ' + aStreet);
            Start;
          end;
        end;
      except
         on E: Exception do   // on EConvertError do
          begin
           FQueryThread_House.Free;
           ind := FQueryLst.IndexOf('House');
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
end; }

{procedure TfrmDM.GetNotVerificMeasurers(AParams : TFDParams);
var sqlMeasurers : string;
  ind : Integer;
  FQueryThread_NotVerific : TQueryThread;
begin
  //Выберем счетчики с истекшим сроком поверки
  sqlMeasurers := 'SELECT IDMEASURER, FLAT_NUMBER, FACTORY_NUMBER ' +
    ' FROM GET$NOT$VERIFIC$MEASURERS(:STREET, :HOUSE_NUMBER)';
  try
    if FQueryLst.IndexOf('NotVerific') = -1 then
    begin
      //Создадим нить в остановленном состоянии
      FQueryThread_NotVerific := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('NotVerific',FQueryThread_NotVerific);
        with FQueryThread_NotVerific do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlMeasurers, AParams,
            'qNotVerificMeasurers', nil) then
          begin
            frmMain.SetThreadStatus('Запрос списка счетчиков с истекшим сроком поверки');
            Start;
          end;
        end;
      except
         on E: Exception do   // on EConvertError do
          begin
           FQueryThread_NotVerific.Free;
           ind := FQueryLst.IndexOf('NotVerific');
           if ind > -1 then
            FQueryLst.Delete(ind);
           Application.MessageBox(PChar('Ошибка : ' +
           e.Message), 'Ошибка', 0);
          end;
      end;
    end;
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end;  }

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

{procedure TfrmDM.GetStreets;
var sqlStreets : string;
  ind : Integer;
  FQueryThread_Street : TQueryThread;
begin
  //Выберем улицы
  sqlStreets := 'SELECT DISTINCT F.STREET FROM VWFLATS AS F';
  if FQueryLst.IndexOf('Street') = -1 then
  begin
    //Создадим нить в остановленном состоянии
    FQueryThread_Street := TQueryThread.Create(True);
    try
      //Сохраняем нить в списке нитей
      FQueryLst.AddObject('Street',FQueryThread_Street);
      with FQueryThread_Street do
      begin
        FreeOnTerminate := True;
        OnTerminate := QueryThread_OnTerminate;
        Priority := tpLower;
        //Инициализация переменных нити
        if Init(fdcMeasureControl, sqlStreets, nil, 'qStreets',
          nil) then
        begin
          frmMain.SetThreadStatus('Запрос списка улиц');
          Start;
        end;
      end;
    except
       on E: Exception do   // on EConvertError do
        begin
         FQueryThread_Street.Free;
         ind := FQueryLst.IndexOf('Street');
         if ind > -1 then
          FQueryLst.Delete(ind);
         Application.MessageBox(PChar('Ошибка : ' +
         e.Message), 'Ошибка', 0);
        end;
    end;
  end;
end; }

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

{procedure TfrmDM.InsertMeasurer(AParams: TFDParams);
var sqlInsMeasurer : String;
  FQueryThread_NewMeasurer : TQueryThread;
  ind : Integer;
begin
  //Добавление счетчика
  sqlInsMeasurer := 'select * from measurer$new(:factory_number,' +
    ' :check_date, :next_check_date)';
  try
    if FQueryLst.IndexOf('NewMeasurer') = -1 then
    begin
      //Создадим нить в остановленном состоянии
      FQueryThread_NewMeasurer := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('NewMeasurer',FQueryThread_NewMeasurer);
        with FQueryThread_NewMeasurer do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlInsMeasurer, AParams,
            'qProcResult', nil) then
          begin
            frmMain.SetThreadStatus('Добавление счетчика');
            Start;
          end;
        end;
      except
       on E: Exception do   // on EConvertError do
        begin
         FQueryThread_NewMeasurer.Free;
         ind := FQueryLst.IndexOf('NewMeasurer');
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

{procedure TfrmDM.InsertMeasureValue(AParams: TFDParams);
var sqlInsMeasureValue : String;
  FQueryThread_InsMValue : TQueryThread;
  ind : Integer;
begin
//Вставка показаний счетчика
  sqlInsMeasureValue := 'select * from measure$value$new(:idmeasurer$str,' +
    ':measure$date, :measure$value)';
  try
    if FQueryLst.IndexOf('InsMValue') = -1 then
    begin
      //Создадим нить в остановленном состоянии
      FQueryThread_InsMValue := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('InsMValue',FQueryThread_InsMValue);
        with FQueryThread_InsMValue do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlInsMeasureValue, AParams,
            'qProcResult', nil) then
          begin
            frmMain.SetThreadStatus('Вставка показаний счетчика');
            Start;
          end;
        end;
      except
       on E: Exception do   // on EConvertError do
        begin
         FQueryThread_InsMValue.Free;
         ind := FQueryLst.IndexOf('InsMValue');
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
end;   }

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
var
  ind : Integer;
  BMemTable : TFDMemTable;
begin
  if Sender is TQueryThread then
  try
    BMemTable := (Sender as TQueryThread).MemTable;
    //Если найден MemTable, то скопируем результаты запроса в MemTable
    if Assigned(BMemTable) then
    begin
      with BMemTable do
      begin
        DisableControls;
        //Закроем набор данных и очистим поля
        Close;
        Fields.Clear;  //EmptyDataSet
        //Скопируем результаты запроса в MemTable и откроем его
        AppendData((Sender as TQueryThread).Qry); //набор данных полностью HitEOF=True, default
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

{procedure TfrmDM.UpdateFlats(AParams : TFDParams);
var sqlFlats, sqlWhere : String;
  ind : Integer;
  FQueryThread_Flat : TQueryThread;
begin
  sqlWhere := '';
//Выберем квартиры
  sqlFlats := 'SELECT F.ID, F.STREET, F.HOUSE_NUMBER, F.FLAT_NUMBER' +
    ' FROM VWADDRESSES AS F';
  try
    if FQueryLst.IndexOf('Flat') = -1 then
    begin
      //Создадим нить в остановленном состоянии
      FQueryThread_Flat := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('Flat',FQueryThread_Flat);
        //Если определен параметр "Улица"
        Param1 := AParams.FindParam('STREET');
        if Assigned(Param1) then
        begin
          sqlWhere := '(F.STREET LIKE ''%'' '+'||:STREET ||' + ' ''%'' )';
          SetLength(BParams,1);
          BParams[0] := Variant(Param1.AsString);
        end;
        //Если определены параметр "Номер дома"
        Param1 := AParams.FindParam('HOUSE_NUMBER');
        if Assigned(Param1) then
        begin
          if sqlWhere <> '' then sqlWhere := sqlWhere + ' AND ';
            sqlWhere := sqlWhere + '(F.HOUSE_NUMBER = :HOUSE_NUMBER)';
          ind := Length(BParams);
          SetLength(BParams,ind + 1);
          BParams[ind] := Variant(Param1.AsInteger);
        end;

        if sqlWhere <> '' then
          sqlFlats := sqlFlats + ' WHERE ' + sqlWhere;

        with FQueryThread_Flat do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlFlats, AParams, 'qFlats',
            nil) then
          begin
            frmMain.SetThreadStatus('Запрос списка квартир');
            Start;
          end;
        end;
      except
         on E: Exception do   // on EConvertError do
          begin
           FQueryThread_Flat.Free;
           ind := FQueryLst.IndexOf('Flat');
           if ind > -1 then
            FQueryLst.Delete(ind);
           Application.MessageBox(PChar('Ошибка : ' +
           e.Message), 'Ошибка', 0);
          end;
      end;
    end;
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end;   }

{procedure TfrmDM.UpdateFreeMeasurers(AParams: TFDParams);
var sqlMeasurers, sqlWhere : String;
  FQueryThread_FreeMeasurer : TQueryThread;
  ind : Integer;
begin
  //Запрос списка счетчиков, неустановленных в квартирах
  sqlMeasurers := 'SELECT M.ID, M.FACTORY_NUMBER, M.CHECK_DATE,' +
  ' M.NEXT_CHECK_DATE FROM VWFREE$MEASURERS AS M';
  try
    if FQueryLst.IndexOf('FreeMeasurer') = -1 then
    begin
      //Создадим нить в остановленном состоянии
      FQueryThread_FreeMeasurer := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('FreeMeasurer',FQueryThread_FreeMeasurer);
        SetLength(BParams, AParams.Count);
        sqlWhere := GetSqlMeasurers(sqlMeasurers, AParams, BParams);
        if sqlWhere <> '' then
          sqlMeasurers := sqlMeasurers + ' WHERE ' + sqlWhere;

        with FQueryThread_FreeMeasurer do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlMeasurers, AParams,
            'qFreeMeasurers', nil) then
          begin
            frmMain.SetThreadStatus('Запрос списка счетчиков, неустановленных в квартирах');
            Start;
          end;
        end;
      except
         on E: Exception do   // on EConvertError do
          begin
           FQueryThread_FreeMeasurer.Free;
           ind := FQueryLst.IndexOf('FreeMeasurer');
           if ind > -1 then
            FQueryLst.Delete(ind);
           Application.MessageBox(PChar('Ошибка : ' +
           e.Message), 'Ошибка', 0);
          end;
      end;
    end;
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end;{

{procedure TfrmDM.UpdateMeasurers(AParams : TFDParams);
var sqlMeasurers, sqlWhere : String;
  BParams : array of Variant;
  FQueryThread_Measurer : TQueryThread;
  ind : Integer;

begin
  //Запрос списка установленных счетчиков
  sqlMeasurers := 'SELECT M.ID, M.FACTORY_NUMBER, M.CHECK_DATE,' +
  ' M.NEXT_CHECK_DATE FROM VWMEASURERS AS M';
  try
    if FQueryLst.IndexOf('Measurer') = -1 then
    begin
      //Создадим нить в остановленном состоянии
      FQueryThread_Measurer := TQueryThread.Create(True);
      try
        FQueryLst.AddObject('Measurer',FQueryThread_Measurer);
        SetLength(BParams, AParams.Count);
        sqlWhere := GetSqlMeasurers(sqlMeasurers, AParams, BParams);
        if sqlWhere <> '' then
          sqlMeasurers := sqlMeasurers + ' WHERE ' + sqlWhere;

        with FQueryThread_Measurer do
        begin
          FreeOnTerminate := True;
          OnTerminate := QueryThread_OnTerminate;
          Priority := tpLower;
          //Инициализация переменных нити
          if Init(fdcMeasureControl, sqlMeasurers, AParams, 'qMeasurers',
            nil) then
          begin
            frmMain.SetThreadStatus('Запрос списка установленных счетчиков');
            Start;
          end;
        end;
      except
         on E: Exception do   // on EConvertError do
          begin
           FQueryThread_Measurer.Free;
           ind := FQueryLst.IndexOf('Measurer');
           if ind > -1 then
            FQueryLst.Delete(ind);
           Application.MessageBox(PChar('Ошибка : ' +
           e.Message), 'Ошибка', 0);
          end;
      end;
    end;
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end; }

end.
