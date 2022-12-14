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
    alChoiñeMeasurer: TAction;
    alChangeMeasurer: TAction;
    fdmtInsMValue: TFDMemTable;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure alChoiñeMeasurerExecute(Sender: TObject);
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
      //Çàïèøåì çíà÷åíèå ïàðàìåòðîâ
      with ChMParams do
      begin
        Add('STREET', Variant(dbeStreet.Text), ptInput);
        Add('HOUSE_NUMBER', Variant(dbeHouse.Text), ptInput);
        Add('FLAT_NUMBER', Variant(dbeFlat.Text), ptInput);
        Add('INSTALL_DATE', Variant(Date), ptInput);
        Add('FACTORY_NUMBER_OLD', Variant(cbFactory_Numbers.Text), ptInput);
        Add('FACTORY_NUMBER_NEW', Variant(eFactory_Number.Text), ptInput);
      end;
      frmMain.SetThreadStatus('Èçìåíåíèå õàðàêòåðèñòèê ñ÷åò÷èêà');
     //Çàìåíèì ñ÷åò÷èê
      frmDM.DBExecuteSQL(sqlChangeMeasurer, ChMParams, fdtmInsMeasurer, nil,
      'ChangeMeasurer', True);

      //Îïðåäåëèì ïàðàìåòðû äëÿ ââîäà ïîêàçàíèé ñ÷åò÷èêà
      MValue := StrToFloat(eMeasureValue.Text);
      with InsMVParams do
      begin
        Add('IDMEASURER$STR', Variant(FID_new_measurer), ptInput);
        Add('MEASURE$DATE',Variant(Date),ptInput);
        Add('MEASURE$VALUE', MValue, ptInput);
      end;
      //Çàâåäåì ïîêàçàíèÿ ñ÷åò÷èêà
      sqlInsMeasureValue := 'select * from measure$value$new(:idmeasurer$str,' +
        ':measure$date, :measure$value)';
      frmMain.SetThreadStatus('Âñòàâêà ïîêàçàíèé ñ÷åò÷èêà');
      frmDM.DBExecuteSQL(sqlInsMeasureValue, InsMVParams, fdmtInsMValue, nil,
        'InsMValue', True);
    except
      on E: Exception do
      begin
        Application.MessageBox(PChar('Îøèáêà : ' +
        e.Message), 'Îøèáêà', 0);
      end;
    end;
  finally
    Close;
  end;
end;

procedure TfrmFlats.alChoiñeMeasurerExecute(Sender: TObject);
begin
  //Âûâåäåì ñïèñîê ïîâåðåííûõ ñ÷åò÷èêîâ, íå óñòàíîâëåííûõ â êâàðòèðàõ
  FMeasurers := TfrmMeasurers.Create(Application);

  with FMeasurers do
  begin
    FormScale(frmMain.Scale_M,frmMain.Scale_N);
    Name := 'frmFreeMeasurers';
    //îêíî îòêðûâàåòñÿ êàê äèàëîã
    //âûáèðàþòñÿ íåóñòàíîâëåííûå ñ÷åò÷èêè
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
//Ïðîâåðèì îòêðûò ëè äèàëîã âûáîðà ñ÷åò÷èêà
  if Assigned(FMeasurers) then
  begin
    MessageDlg('Ýòî îêíî íåëüçÿ çàêðûòü ïîêà îòêðûòî îêíî âûáîðà ñ÷åò÷èêà', mtWarning, [mbOk], 0);
    CanClose := False;
    FMeasurers.SetFocus;
  end;
end;

//Ìàñøòàáèðîâàíèå ôîðìû
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

//Èíèöèàëèçàöèÿ ôîðìû
procedure TfrmFlats.Init(const ACallingForm: TForm;
  const AFactory_Numbers: TStrings; const AFlatsDataSource: TDataSource);
begin
  FCallingForm := ACallingForm;
  dbeStreet.DataSource := AFlatsDataSource;
  dbeHouse.DataSource := AFlatsDataSource;
  dbeFlat.DataSource := AFlatsDataSource;
  //Ñêîïèðóåì ñïèñîê çàâîäñêèõ íîìåðîâ ñ÷åò÷èêîâ, óñòàíîâëåííûõ â êâàðòèðå
  if Assigned(AFactory_Numbers) then
  with cbFactory_numbers do
  begin
    Items.Assign(AFactory_Numbers);
    ItemIndex := 0;
  end;
end;

procedure TfrmFlats.TryCloseMeasurers(var Message: TMessage);
begin
//Äèàëîã çàêðûò - îáíóëèì óêàçàòåëü FMeasurers
  FMeasurers := nil;
end;

procedure TfrmFlats.TryUpdateMeasurer(var Message: TMessage);
var AParams : TFDParams;
begin
  //Ñ÷åò÷èê âûáðàí, òî åñòü äèàëîã çàêðûò - îáíóëèì óêàçàòåëü FMeasurers
  FMeasurers := nil;
  //óêàçàòåëü íà ñïèñîê ïàðàìåòðîâ íîâîãî ñ÷åò÷èêà ïåðåäàåòñÿ â ïàðàìåòðå ñîîáùåíèÿ
  AParams := TFDParams(Message.LParam);
  try
    //Çàïèøåì õàðàêòåðèñòèêè íîâîãî ñ÷åò÷èêà
    FID_new_measurer := AParams.FindParam('ID').AsString;
    eFactory_Number.Text := AParams.FindParam('FACTORY_NUMBER').AsString;

  finally
    if Assigned(AParams) then
      AParams.Free;
  end;
end;

end.
