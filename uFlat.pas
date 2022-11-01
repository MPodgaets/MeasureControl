unit uFlat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, Vcl.Mask, Vcl.DBCtrls, uMeasurers, uMain, uMessage,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Actions, Vcl.ActnList;

type
  TfrmFlats = class(TForm)
    pBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    gbAddress: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    dbeStreet: TDBEdit;
    dbeHouse: TDBEdit;
    dbeFlat: TDBEdit;
    gbMeasurer: TGroupBox;
    Label4: TLabel;
    cbFactory_numbers: TComboBox;
    rbChange: TRadioButton;
    rbNew: TRadioButton;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    eFactory_Number: TEdit;
    btnMeasurer: TButton;
    Label7: TLabel;
    eMeasureValue: TEdit;
    qProcResult: TFDMemTable;
    alFlat: TActionList;
    alChoiсeMeasurer: TAction;
    alChangeMeasurer: TAction;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure alChoiсeMeasurerExecute(Sender: TObject);
    procedure alChangeMeasurerExecute(Sender: TObject);
  private
    { Private declarations }
    FID_new_measurer : String;
    FMeasurers: TfrmMeasurers;
    procedure TryUpdateMeasurer(var Message: TMessage); message WM_CHOICE_MEASURER;
  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
    procedure SetFactory_Numbers(const Value: TStrings);
  end;

implementation

{$R *.dfm}

uses DM;

procedure TfrmFlats.alChangeMeasurerExecute(Sender: TObject);
var ChMParams, InsMVParams : TFDParams;
  MValue : Single;
  sqlChangeMeasurer, sqlInsMeasureValue : String;
  //FormatSettings : TFormatSettings;
begin
  sqlChangeMeasurer := 'select * from change$measurer(:street,' +
    ' :house_number, :flat_number, :install_date, :factory_number_old,' +
    ' :factory_number_new, null, null)';
  try
    ChMParams := TFDParams.Create;
    InsMVParams := TFDParams.Create;
    try
      //Запишем значение параметров
      with ChMParams do
      begin
        Add('STREET', Variant(dbeStreet.Text), ptInput);
        Add('HOUSE_NUMBER', Variant(dbeHouse.Text), ptInput);
        Add('FLAT_NUMBER', Variant(dbeFlat.Text), ptInput);
        Add('INSTALL_DATE', Variant(Date), ptInput);
        Add('FACTORY_NUMBER_OLD', Variant(cbFactory_Numbers.Text), ptInput);
        Add('FACTORY_NUMBER_NEW', Variant(eFactory_Number.Text), ptInput);
      end;
      frmMain.SetThreadStatus('Изменение характеристик счетчика');
     //Заменим счетчик
      frmDM.DBExecuteSQL(sqlChangeMeasurer, ChMParams, qProcResult, nil,
      'ChangeMeasurer', True);

      //Определим параметры для ввода показаний счетчика
      MValue := StrToFloat(eMeasureValue.Text);
      with InsMVParams do
      begin
        Add('IDMEASURER$STR', Variant(FID_new_measurer), ptInput);
        Add('MEASURE$DATE',Variant(Date),ptInput);
        Add('MEASURE$VALUE', MValue, ptInput);
      end;
      //Заведем показания счетчика
      sqlInsMeasureValue := 'select * from measure$value$new(:idmeasurer$str,' +
        ':measure$date, :measure$value)';
      frmMain.SetThreadStatus('Вставка показаний счетчика');
      frmDM.DBExecuteSQL(sqlInsMeasureValue, InsMVParams, qProcResult, nil,
        'InsMValue', True);
    except
      on E: Exception do
      begin
        Application.MessageBox(PChar('Ошибка : ' +
        e.Message), 'Ошибка', 0);
      end;
    end;
  finally
    Close;
  end;
end;

procedure TfrmFlats.alChoiсeMeasurerExecute(Sender: TObject);
begin
  //Выведем список поверенных счетчиков, не установленных в квартирах
  FMeasurers := TfrmMeasurers.Create(Application);

  with FMeasurers do
  begin
    FormScale(frmMain.Scale_M,frmMain.Scale_N);
    //окно открывается как диалог
    IsDialog := True;
    Name := 'frmFreeMeasurers';
    //выбираются неустановленные счетчики
    KindMeasurers := kmFree;
    UpdatePermit := True;
    CallingForm := Self;
    //При активизации формы обновим список счетчиков
    UpdateMeasurers;
  end;
end;

procedure TfrmFlats.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmFlats.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmFlats.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FMeasurers) then
  begin
    MessageDlg('Это окно нельзя закрыть пока открыто окно выбора счетчика', mtWarning, [mbOk], 0);
    CanClose := False;
  end;
end;

procedure TfrmFlats.FormScale(const M, N : Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

procedure TfrmFlats.SetFactory_Numbers(const Value: TStrings);
begin
  if Assigned(Value) then
  with cbFactory_numbers do
  begin
    Items.Assign(Value);
    ItemIndex := 0;
  end;
end;

procedure TfrmFlats.TryUpdateMeasurer(var Message: TMessage);
//Счетчик выбран
var AParams : TFDParams;
begin
  AParams := TFDParams(Message.LParam);
  try
    //Запишем характеристики нового счетчика
    FID_new_measurer := AParams.FindParam('ID').AsString;
    eFactory_Number.Text := AParams.FindParam('FACTORY_NUMBER').AsString;
  finally
    if Assigned(AParams) then
      AParams.Free;
  end;
end;

end.
