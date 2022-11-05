unit uMeasureValues;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.AppEvnts, Vcl.Menus, Vcl.Mask,
  Vcl.DBCtrls, uMessage, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Actions,
  Vcl.ActnList;

type
  TfrmMeasureValues = class(TForm)
    pData: TPanel;
    PMeasurers: TPanel;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    pFlats: TPanel;
    dbgFlats: TDBGrid;
    pmMeasureValues: TPopupMenu;
    N1: TMenuItem;
    gbAddress: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    bUpdate: TButton;
    eHouse_number: TEdit;
    eStreet: TEdit;
    N2: TMenuItem;
    N3: TMenuItem;
    gbMeasureValue: TGroupBox;
    dbgMeasureValue: TDBGrid;
    pHistory: TPanel;
    gbHistory: TGroupBox;
    dbgHistory: TDBGrid;
    dsFlats: TDataSource;
    qFlats: TFDMemTable;
    alMeasureValues: TActionList;
    mmMeasureValues: TMainMenu;
    aInsertMeasureValue: TAction;
    aChangeMeasurerHistory: TAction;
    aChangeMeasurer: TAction;
    dsMeasureValue: TDataSource;
    qMeasureValue: TFDMemTable;
    dsChangeMeasureHistory: TDataSource;
    qChangeMeasureHistory: TFDMemTable;
    qProcResult: TFDMemTable;
    nEdit: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bUpdateClick(Sender: TObject);
    procedure eHouse_numberKeyPress(Sender: TObject; var Key: Char);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure qFlatsAfterScroll(DataSet: TDataSet);
    procedure aChangeMeasurerHistoryExecute(Sender: TObject);
    procedure aChangeMeasurerExecute(Sender: TObject);
    procedure aInsertMeasureValueExecute(Sender: TObject);
    procedure qProcResultAfterScroll(DataSet: TDataSet);
  private
    FUpdatePermit: Boolean;
    { Private declarations }
    procedure TryInsertMeasureValue(var Message: TMessage); message WM_MEASURE_VALUE_INPUT;
    procedure SetUpdatePermit(const Value: Boolean);
    procedure ReadInifile;
    procedure WriteInifile;
    procedure UpdateMeasureValue(const idflataddress: string);
  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
    procedure UpdateFlats;
  end;

//var frmMeasureValues: TfrmMeasureValues;

implementation

{$R *.dfm}

uses DM, System.IniFiles, Datasnap.DBClient,  System.UITypes,
uMain, uMeasureValue, uFlat;

procedure TfrmMeasureValues.aChangeMeasurerExecute(Sender: TObject);
var frmFlats: TfrmFlats;
  Factory_Numbers : TStringList;
  idmeasurer : String;
begin
  frmFlats := TfrmFlats.Create(Application);
  frmFlats.FormScale(frmMain.Scale_M, frmMain.Scale_N);

  Factory_Numbers := TStringList.Create;
  try
    with qMeasureValue do
    begin
      idmeasurer := FieldByName('idmeasurer').AsString;
      DisableControls;
      First;
      while not Eof do
      begin
        Factory_Numbers.Add(FieldByName('FACTORY_NUMBER').AsString);
        Next;
      end;
      Locate('idmeasurer',idmeasurer);
      EnableControls;
    end;
    frmFlats.SetFactory_Numbers(Factory_Numbers);
  finally
    if Assigned(Factory_Numbers) then
      Factory_Numbers.Free;
  end;
end;

procedure TfrmMeasureValues.aChangeMeasurerHistoryExecute(Sender: TObject);
var
  sqlHistory : String;
  BParams : TFDParams;
begin
  //История установки счетчиков в квартире
  sqlHistory := 'SELECT F.IDMEASURER, F.FACTORY$NUMBER, F.DATE$INSTALL,' +
  ' F.MEASURER$NUMBER FROM ' +
  ' GET$HISTORY$MEASURER$FLAT(:STREET, :HOUSE_NUMBER, :FLAT_NUMBER) AS F' +
  ' ORDER BY F.MEASURER$NUMBER';

  if aChangeMeasurerHistory.Checked then
  begin
    BParams := TFDParams.Create;
    try
      BParams.Add('STREET', qFlats.FieldByName('STREET').AsVariant, ptInput);
      BParams.Add('HOUSE_NUMBER', qFlats.FieldByName('HOUSE_NUMBER').AsVariant, ptInput);
      BParams.Add('FLAT_NUMBER', qFlats.FieldByName('FLAT_NUMBER').AsVariant, ptInput);

      frmDM.DBExecuteSQL(sqlHistory, BParams, qChangeMeasureHistory, nil,
        'History', True);
      //Покажем историю замен счетчика
      self.pHistory.Visible := aChangeMeasurerHistory.Checked;
    finally
      if Assigned(BParams) then BParams.Free;
    end;
  end;
end;

procedure TfrmMeasureValues.aInsertMeasureValueExecute(Sender: TObject);
var frmMeasureValue: TfrmMeasureValue;
begin
  if qMeasureValue.RecordCount > 0 then
  begin
    frmMeasureValue:= TfrmMeasureValue.Create(Application);
    with frmMeasureValue do
    try
      CallingForm := self;
      FormScale(frmMain.Scale_M, frmMain.Scale_N);
      //Определим источник данных
      dbeStreet.DataSource := dsFlats;
      dbeHouse.DataSource := dsFlats;
      dbeFlat.DataSource := dsFlats;
      dbeOldDate.DataSource := dsMeasureValue;
      dbeOldValue.DataSource := dsMeasureValue;
      Idmeasurer := qMeasureValue.FieldByName('idmeasurer').AsString;
      eMeasureValue.SetFocus;
    except
      on E: Exception do
      begin
        Application.MessageBox(PChar('Ошибка : ' +
        e.Message), 'Ошибка', 0);
      end;
    end;
  end;
end;

procedure TfrmMeasureValues.bUpdateClick(Sender: TObject);
begin
  //Покажем список квартир
  UpdateFlats;
end;

procedure TfrmMeasureValues.eHouse_numberKeyPress(Sender: TObject;
  var Key: Char);
begin
   if ((Key < '0') or (Key > '9')) and not(Key = #10)
   and not(Key =  Chr(vkDelete)) and not(Key = Chr(vkBack)) then
   Key := #0;
end;

procedure TfrmMeasureValues.FormActivate(Sender: TObject);
begin
  //Покажем список квартир
  UpdateFlats;
end;

procedure TfrmMeasureValues.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteIniFile;
  Action := caFree;
end;

procedure TfrmMeasureValues.FormCreate(Sender: TObject);
begin
  ReadInifile;
end;

procedure TfrmMeasureValues.FormScale(const M, N: Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

procedure TfrmMeasureValues.qFlatsAfterScroll(DataSet: TDataSet);
var idflataddress : String;
  house_number, street, flat_number : String;
begin
  //После выбора другой квартиры обновим информацию о показаниях счетчиков
  if not qFlats.ReadOnly and qFlats.Active and not qFlats.Eof then
  begin
    idflataddress := qFlats.FieldByName('ID').AsString;
    street := qFlats.FieldByName('street').AsString;
    house_number := qFlats.FieldByName('house_number').AsString;
    flat_number := qFlats.FieldByName('flat_number').AsString;
    UpdateMeasureValue(idflataddress);
  end;
end;

procedure TfrmMeasureValues.qProcResultAfterScroll(DataSet: TDataSet);
//var idflataddress : String;
begin
  //После выбора другой квартиры обновим информацию о показаниях счетчиков
 { if qFlats.Active and not qFlats.Eof then
  begin
    idflataddress := qFlats.FieldByName('ID').AsString;
    UpdateMeasureValue(idflataddress);
  end;  }
end;

procedure TfrmMeasureValues.UpdateMeasureValue(const idflataddress: string);
var sqlMeasureValues : String;
  BParams : TFDParams;
begin
//Выберем показания счетчиков, которые установлены в квартире
  sqlMeasureValues := 'SELECT V.idmeasurer, V.factory_number,' +
  ' V.measure_date, V.measure_value FROM vwmeasure$values AS V' +
  ' WHERE V.idflataddress$ = char_to_uuid(:IDFLATADDRESS)';

  frmMain.SetThreadStatus('Запрос списка показаний счетчиков');
  BParams := TFDParams.Create;
  try
    BParams.Add('IDFLATADDRESS', idflataddress, ptInput);
    frmDM.DBExecuteSQL(sqlMeasureValues, BParams, qMeasureValue, nil,
      'MeasureValue', True);
  finally
    if Assigned(BParams) then BParams.Free;
  end;
end;

procedure TfrmMeasureValues.ReadInifile;
var
   Ini: TIniFile;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
   try
     Height := Ini.ReadInteger( self.Name, 'Height', 440 );
     Width := Ini.ReadInteger( self.Name, 'Width', 630 );

     if Ini.ReadBool( self.Name, 'InitMax', false ) then
       WindowState := wsMaximized
     else
       WindowState := wsNormal;
   finally
     Ini.Free;
   end;
end;

procedure TfrmMeasureValues.SetUpdatePermit(const Value: Boolean);
begin
  FUpdatePermit := Value;
end;

procedure TfrmMeasureValues.TryInsertMeasureValue(var Message: TMessage);
var AParams : TFDParams;
  sqlInsMeasureValue : String;
begin
  AParams := TFDParams(Message.LParam);
  //Добавим показания счетчика
  sqlInsMeasureValue := 'select * from measure$value$new(:idmeasurer$str,' +
    ':measure$date, :measure$value)';
  try
    frmMain.SetThreadStatus('Вставка показаний счетчика');
    frmDM.DBExecuteSQL(sqlInsMeasureValue, AParams, qProcResult, nil,
      'InsMValue', True);
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end;

procedure TfrmMeasureValues.UpdateFlats;
var LParams : TFDParams;
  sqlFlats, sqlWhere : String;
begin
  LParams := TFDParams.Create;
  //Выберем квартиры
  sqlFlats := 'SELECT F.ID, F.STREET, F.HOUSE_NUMBER, F.FLAT_NUMBER' +
    ' FROM VWADDRESSES AS F';
  try
    sqlWhere := '';
    if eStreet.Text <> '' then
    begin
      LParams.Add('STREET', eStreet.Text, ptInput);
      sqlWhere := '(F.STREET LIKE ''%'' '+'||:STREET ||' + ' ''%'' )';
    end;
    if eHouse_number.Text <> '' then
    begin
      LParams.Add('HOUSE_NUMBER', StrToInt(eHouse_number.Text), ptInput);
      if sqlWhere <> '' then sqlWhere := sqlWhere + ' AND ';
        sqlWhere := sqlWhere + '(F.HOUSE_NUMBER = :HOUSE_NUMBER)';
    end;
    if sqlWhere <> '' then
      sqlFlats := sqlFlats + ' WHERE ' + sqlWhere;

    frmMain.SetThreadStatus('Запрос списка квартир');
    frmDM.DBExecuteSQL(sqlFlats, LParams, qFlats, nil,
      'Flat', True);
  finally
    if Assigned(LParams) then LParams.Free;
  end;
end;

procedure TfrmMeasureValues.WriteInifile;
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
