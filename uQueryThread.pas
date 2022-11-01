unit uQueryThread;

interface

uses
  System.Classes, Datasnap.DBClient, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client{, FireDAC.Comp.Script};

type
  TQueryThread = class(TThread)
  private
    { Private declarations }
    FConnect : TFDConnection;
    FLog : TStrings;
    FQry: TFDQuery;
    FMemTable : TFDMemTable; //имя MemTable из главной нити, которая получает результаты запроса
    FQueryResult : Boolean;

  protected
    procedure Execute; override;

  public
    function Init(const AConnect : TFDConnection; const Asql : string; const AParams : TFDParams; const AMemTable : TFDMemTable; const ALog : TStrings; AQueryResult: Boolean = True):boolean;
    destructor Destroy; override;

    property Qry : TFDQuery read FQry;
    property MemTable : TFDMemTable read FMemTable;
  end;

implementation

{ TQueryThread }

uses System.SysUtils, System.DateUtils, DM, Vcl.Forms,
FireDAC.Phys.IBWrapper;

destructor TQueryThread.Destroy;
begin
  if Assigned(FQry) then FQry.Free;
  if Assigned(FConnect) then FConnect.Free;
  inherited;
end;

procedure TQueryThread.Execute;
begin
  //Начнем транзакцию
  FConnect.StartTransaction;
  //Выполним запрос
  try
    //Если имя таблицы результатов пустая строка
    if FQueryResult then
     //выполним запрос, возвращающий записи
      FQry.Open
    //выполним запрос без возврата записей
    else FQry.ExecSQL; // FScript.ExecuteAll

    //Подтвердим изменения в БД
    FConnect.Commit;
  except
    on E: EIBNativeException do
    begin
      Synchronize(
        procedure
        var i : Integer;
        begin  //FLog
          for i := 0 to E.ErrorCount - 1 do
          Application.MessageBox(
            PChar('При выполнении запроса к базе данных произошла FireDAC/DBMS ошибка: ' +
            E.Errors[i].Message), 'Ошибка', 0);
          Application.MessageBox(
            PChar('При выполнении запроса к базе данных произошла независимая DBMS ошибка: ' +
            E.Message), 'Ошибка', 0);
        end);

      if FConnect.InTransaction then
      //Отменим все изменения базы данных в текущей транзакции
      FConnect.Rollback;
      raise;
    end;
  end;
end;

function TQueryThread.Init(const AConnect: TFDConnection; const Asql: string;
  const AParams: TFDParams; const AMemTable : TFDMemTable;
  const ALog: TStrings; AQueryResult: Boolean): boolean;
begin
  Result := False;
  try
    FMemTable := AMemTable;
    FQueryResult := AQueryResult;
    if Assigned(ALog) then
      FLog := ALog;
   //
    if Assigned(AConnect) then
    begin
      FConnect := TFDConnection(AConnect.CloneConnection);
      FConnect.LoginPrompt := False;
      FQry := TFDQuery.Create(nil);
      FQry.Connection := FConnect;

      //Параметры создаются автоматически после определения SQL
      FQry.ResourceOptions.ParamCreate := True;
      //Скопируем текст SQL запроса
      if Trim(Asql) <> '' then
      begin
        FQry.SQL.BeginUpdate;
        try
          FQry.SQL.Text := Trim(Asql);
        finally
          FQry.SQL.EndUpdate;
        end;
        //Скопируем параметры запроса
        if Assigned(AParams) then
          FQry.Params.Assign(AParams);
      end;
      //Проверим подключение к БД
      if not FConnect.Connected then
        FConnect.Open();
      Result := True;
    end;
  except
    on E: Exception do
      Synchronize(
        procedure
        begin
          Application.MessageBox(PChar('Ошибка : ' + E.Message), 'Ошибка', 0)
        end)
  end;
end;

end.
