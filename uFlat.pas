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
    fdtmInsMeasurer: TFDMemTable;
    alFlat: TActionList;
    alChoiсeMeasurer: TAction;
    alChangeMeasurer: TAction;
    fdmtInsMValue: TFDMemTable;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure alChoiсeMeasurerExecute(Sender: TObject);
    procedure alChangeMeasurerExecute(Sender: TObject);
  private
    { Private declarations }
    FID_new_measurer : String;
    FMeasurers: TfrmMeasurers;
    FCallingForm : TForm;

    procedure TryUpdateMeasurer(var Message: TMessage); message WM_CHOICE_MEASURER;
    procedure TryCloseMeasurers(var Message: TMessage); message WM_CLOSE_MEASURERS;
  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
    procedure Init(const ACallingForm : TForm; const AFactory_Numbers : TStrings; const AFlatsDataSource : TDataSource);
  end;

implementation

{$R *.dfm}

uses DM, System.UITypes;

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
      frmDM.DBExecuteSQL(sqlChangeMeasurer, ChMParams, fdtmInsMeasurer, nil,
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
      frmDM.DBExecuteSQL(sqlInsMeasureValue, InsMVParams, fdmtInsMValue, nil,
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
    Name := 'frmFreeMeasurers';
    //окно открывается как диалог
    //выбираются неустановленные счетчики
    Init(self, True, kmFree);
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
//Проверим открыт ли диалог выбора счетчика
  if Assigned(FMeasurers) then
  begin
    MessageDlg('Это окно нельзя закрыть пока открыто окно выбора счетчика', mtWarning, [mbOk], 0);
    CanClose := False;
    FMeasurers.SetFocus;
  end;
end;

//Масштабирование формы
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

//Инициализация формы
procedure TfrmFlats.Init(const ACallingForm: TForm;
  const AFactory_Numbers: TStrings; const AFlatsDataSource: TDataSource);
begin
  FCallingForm := ACallingForm;
  dbeStreet.DataSource := AFlatsDataSource;
  dbeHouse.DataSource := AFlatsDataSource;
  dbeFlat.DataSource := AFlatsDataSource;
  //Скопируем список заводских номеров счетчиков, установленных в квартире
  if Assigned(AFactory_Numbers) then
  with cbFactory_numbers do
  begin
    Items.Assign(AFactory_Numbers);
    ItemIndex := 0;
  end;
end;

procedure TfrmFlats.TryCloseMeasurers(var Message: TMessage);
begin
//Диалог закрыт - обнулим указатель FMeasurers
  FMeasurers := nil;
end;

procedure TfrmFlats.TryUpdateMeasurer(var Message: TMessage);
var AParams : TFDParams;
begin
  //Счетчик выбран, то есть диалог закрыт - обнулим указатель FMeasurers
  FMeasurers := nil;
  //указатель на список параметров нового счетчика передается в параметре сообщения
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
