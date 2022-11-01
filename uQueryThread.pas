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
    FMemTable : TFDMemTable; //��� MemTable �� ������� ����, ������� �������� ���������� �������
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
  //������ ����������
  FConnect.StartTransaction;
  //�������� ������
  try
    //���� ��� ������� ����������� ������ ������
    if FQueryResult then
     //�������� ������, ������������ ������
      FQry.Open
    //�������� ������ ��� �������� �������
    else FQry.ExecSQL; // FScript.ExecuteAll

    //���������� ��������� � ��
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
            PChar('��� ���������� ������� � ���� ������ ��������� FireDAC/DBMS ������: ' +
            E.Errors[i].Message), '������', 0);
          Application.MessageBox(
            PChar('��� ���������� ������� � ���� ������ ��������� ����������� DBMS ������: ' +
            E.Message), '������', 0);
        end);

      if FConnect.InTransaction then
      //������� ��� ��������� ���� ������ � ������� ����������
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

      //��������� ��������� ������������� ����� ����������� SQL
      FQry.ResourceOptions.ParamCreate := True;
      //��������� ����� SQL �������
      if Trim(Asql) <> '' then
      begin
        FQry.SQL.BeginUpdate;
        try
          FQry.SQL.Text := Trim(Asql);
        finally
          FQry.SQL.EndUpdate;
        end;
        //��������� ��������� �������
        if Assigned(AParams) then
          FQry.Params.Assign(AParams);
      end;
      //�������� ����������� � ��
      if not FConnect.Connected then
        FConnect.Open();
      Result := True;
    end;
  except
    on E: Exception do
      Synchronize(
        procedure
        begin
          Application.MessageBox(PChar('������ : ' + E.Message), '������', 0)
        end)
  end;
end;

end.
