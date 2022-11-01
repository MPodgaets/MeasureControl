unit uReadMeasureControl;

interface

uses
  System.Classes, Datasnap.DBClient, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TReadMeasureControl = class(TThread)
  private
    { Private declarations }
    FProc : TFDStoredProc;
    FConnect : TFDConnection;
    FLog : TStrings;
    FQry: TFDQuery;
    Fsql : string;
    FParams : TFDParams;
    FMemTable : TFDMemTable; //ссылка на MemTable из главной нити, которая получает результаты запроса

  protected
    procedure Execute; override;

  public
    function Init(const AConnect : TFDConnection; const Asql : string; const AParams: array of Variant; const AMemTable : TFDMemTable; const ALog : TStrings):boolean;

    property Qry : TFDQuery read FQry;
    property MemTable : TFDMemTable read FMemTable;
  end;

implementation

uses System.SysUtils, System.DateUtils, DM, Vcl.Forms;

{ ReadMeasureControl }

procedure TReadMeasureControl.Execute;
begin
  try
    if FQry.Active then
      FQry.Close;
  //Проверим подключение к БД
    if not FConnect.Connected then
      FConnect.Open();
    //Очистим лог
    FLog.Clear;
    //
    FConnect.StartTransaction;
    //Выполним запрос
    try
      if FQry.SQL.Text <> '' then
        FQry.Open;
    except
      on e: EDatabaseError do
      Synchronize(
        procedure
        begin
         Application.MessageBox(PChar('Ошибка доступа к базе данных: ' +
         e.Message), 'Ошибка', 0);
        end);
    end;
    FConnect.Commit;
  except
    if FConnect.InTransaction then
      FConnect.Rollback;
    raise;
  end;
end;

function TReadMeasureControl.Init(const AConnect: TFDConnection;
  const Asql: string; const AParams : array of Variant; const AMemTable : TFDMemTable; const ALog: TStrings): boolean;
var i : integer;
begin
  Result := False;
  try
    if Assigned(AMemTable) then
      FMemTable := AMemTable;

    if Assigned(ALog) then
      FLog := ALog;
    if Assigned(AConnect) then
    begin
      FConnect := TFDConnection(AConnect.CloneConnection);
      FConnect.LoginPrompt := False;
      FQry := TFDQuery.Create(nil);
      FQry.Connection := FConnect;
      if Trim(Asql) <> '' then
      begin
        FQry.SQL.Text := Trim(Asql);
        FQry.Prepare;
        //Скопируем параметры запроса
        for i := 0 to Length(AParams) - 1 do
          FQry.Params[i].Value := AParams[i];
      end;

    end;
  except
    on e: EDatabaseError do
      Synchronize(
        procedure
        begin
          Application.MessageBox('Ошибка доступа к базе данных','Ошибка!', 0);
        end);
  end;
end;

end.
