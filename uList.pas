unit uList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.DBCtrls, Vcl.ExtCtrls, uMain, uMessage, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.Param;

type
  TfrmList = class(TForm)
    dbgList: TDBGrid;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    cbStreets: TComboBox;
    cbHouse_numbers: TComboBox;
    btShowList: TButton;
    qNotVerificMeasurers: TFDMemTable;
    dsNotVerificMeasurers: TDataSource;
    qStreets: TFDMemTable;
    qHouse_numbers: TFDMemTable;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure cbStreetsChange(Sender: TObject);
    procedure btShowListClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure qStreetsAfterOpen(DataSet: TDataSet);
    procedure qHouse_numbersAfterOpen(DataSet: TDataSet);
  private
    FUpdatePermit: Boolean;
    { Private declarations }
    procedure UpdateStreets;
    procedure UpdateHouse_numbers;
    procedure ReadInifile;
    procedure WriteInifile;
    procedure GetHouse_number;
    procedure GetStreets;
    procedure SetUpdatePermit(const Value: Boolean);
  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
    procedure UpdateNotVerificMeasurers;

    property UpdatePermit : Boolean read FUpdatePermit write SetUpdatePermit;
  end;

//var frmList: TfrmList;

implementation

{$R *.dfm}

uses DM, System.IniFiles;

procedure TfrmList.btShowListClick(Sender: TObject);
begin
  UpdateNotVerificMeasurers;
end;

procedure TfrmList.cbStreetsChange(Sender: TObject);
begin
  GetStreets;
end;

procedure TfrmList.FormActivate(Sender: TObject);
begin
  if FUpdatePermit then
    UpdateNotVerificMeasurers;
end;

procedure TfrmList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteIniFile;
  Action := caFree;
end;

procedure TfrmList.FormCreate(Sender: TObject);
begin
  FUpdatePermit := False;
  GetStreets;
  ReadInifile;
end;

procedure TfrmList.FormScale(const M, N: Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

procedure TfrmList.GetHouse_number;
var sqlHouse_numbers : String;
  BParams : TFDParams;
begin
  //Выберем номера домов для выбранной улицы
  sqlHouse_numbers := 'SELECT DISTINCT F.HOUSE_NUMBER FROM VWFLATS AS F' +
  ' WHERE F.STREET LIKE :STREET';
  BParams := TFDParams.Create;
  frmMain.SetThreadStatus('Запрос списка домов для ' + cbStreets.Text);
  try
    BParams.Add('STREET', cbStreets.Text, ptInput);
    frmDM.DBExecuteSQL(sqlHouse_numbers, BParams, qHouse_numbers, nil,
      'House', True);
  finally
    if Assigned(BParams) then BParams.Free;
  end;
end;

procedure TfrmList.GetStreets;
var sqlStreets : String;
  BParams : TFDParams;
begin
  //Выберем улицы
  sqlStreets := 'SELECT DISTINCT F.STREET FROM VWFLATS AS F';
  BParams := TFDParams.Create;
  frmMain.SetThreadStatus('Запрос списка улиц');
  try
    BParams.Add('STREET', cbStreets.Text, ptInput);
    frmDM.DBExecuteSQL(sqlStreets, BParams, qStreets, nil,
      'Street', True);
  finally
    if Assigned(BParams) then BParams.Free;
  end;
end;

procedure TfrmList.qHouse_numbersAfterOpen(DataSet: TDataSet);
begin
  UpdateHouse_numbers;
end;

procedure TfrmList.qStreetsAfterOpen(DataSet: TDataSet);
begin
  UpdateStreets;
end;

procedure TfrmList.ReadInifile;
var
   Ini: TIniFile;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
   try
     Height := Ini.ReadInteger( self.Name, 'Height', 300 );
     Width := Ini.ReadInteger( self.Name, 'Width', 600 );

     if Ini.ReadBool( self.Name, 'InitMax', false ) then
       WindowState := wsMaximized
     else
       WindowState := wsNormal;
   finally
     Ini.Free;
   end;
end;

procedure TfrmList.SetUpdatePermit(const Value: Boolean);
begin
  FUpdatePermit := Value;
end;

procedure TfrmList.UpdateHouse_numbers;
begin
  with qHouse_numbers do
  begin
    First;
    while not Eof do
    begin
      cbHouse_numbers.Items.Add(FieldByName('HOUSE_NUMBER').AsString);
      Next;
    end;
  end;
  cbHouse_numbers.ItemIndex := 0;
  UpdatePermit := True;
  UpdateNotVerificMeasurers;
end;

procedure TfrmList.UpdateNotVerificMeasurers;
var LParams : TFDParams;
  house_number : Integer;
  sqlMeasurers : String;
begin
  //Выберем счетчики с истекшим сроком поверки
  sqlMeasurers := 'SELECT IDMEASURER, FLAT_NUMBER, FACTORY_NUMBER ' +
    ' FROM GET$NOT$VERIFIC$MEASURERS(:STREET, :HOUSE_NUMBER)';
  //Запишем значения параметров
  LParams := TFDParams.Create;
  try
    house_number := StrToInt(cbHouse_numbers.Text);
    LParams.Add('STREET', Variant(cbStreets.Text), ptInput);
    LParams.Add('HOUSE_NUMBER', Variant(house_number), ptInput);
    //Выведем список счетчиков
    frmDM.DBExecuteSQL(sqlMeasurers, LParams, qNotVerificMeasurers,
      nil, 'NotVerific', True);
  finally
    if Assigned(LParams) then LParams.Free;
  end;

end;

procedure TfrmList.UpdateStreets;
begin
  with qStreets do
  begin
    First;
    while not Eof do
    begin
      cbStreets.Items.Add(FieldByName('STREET').AsString);
      Next;
    end;
  end;
  cbStreets.ItemIndex := 0;
  GetHouse_number;
end;

procedure TfrmList.WriteInifile;
var
   Ini: TIniFile;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
   try
     Ini.WriteInteger( self.Name, 'Height', Height);
     Ini.WriteInteger( self.Name, 'Width', Width);
     Ini.WriteBool( self.Name, 'InitMax', WindowState = wsMaximized );
   finally
     Ini.Free;
   end;
end;

end.
