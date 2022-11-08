unit uMeasureValue;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask,
  Vcl.DBCtrls, Vcl.ComCtrls, Data.DB;

type
  TfrmMeasureValue = class(TForm)
    gbAddress: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    btOK: TButton;
    btCancel: TButton;
    eMeasureValue: TEdit;
    dbeStreet: TDBEdit;
    dbeHouse: TDBEdit;
    dbeFlat: TDBEdit;
    dbeOldValue: TDBEdit;
    dbeOldDate: TDBEdit;
    eMeasureDate: TDateTimePicker;
    procedure btOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btCancelClick(Sender: TObject);
  private
    { Private declarations }
    fIdmeasurer : String;
    FCallingForm : TForm;

  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
    procedure InputMValue;
    procedure Init(const ACallingForm : TForm; const AIdmeasurer : String; const AFlatsDataSource, AMeasureValuesDataSource : TDataSource);
  end;

//var frmInputMeasureValue: TfrmInputMeasureValue;

implementation

{$R *.dfm}

uses DM, FireDAC.Stan.Param, uMain, uMessage;

procedure TfrmMeasureValue.btCancelClick(Sender: TObject);
begin
  //�������� ��������� - ������� ��������� ��������
  if Assigned(FCallingForm) then
    PostMessage(FCallingForm.Handle, WM_CLOSE_MEASURE_VALUE, 0, 0);
  Close;
end;

procedure TfrmMeasureValue.btOKClick(Sender: TObject);
begin
  InputMValue;
end;

procedure TfrmMeasureValue.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

//��������������� �����
procedure TfrmMeasureValue.FormScale(const M, N: Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

//������������� �����
procedure TfrmMeasureValue.Init(const ACallingForm : TForm;  const AIdmeasurer : String; const AFlatsDataSource,
  AMeasureValuesDataSource: TDataSource);
begin
  FCallingForm := ACallingForm;
  fIdmeasurer := AIdmeasurer;
  //��������� ��������� ������
  dbeStreet.DataSource := AFlatsDataSource;
  dbeHouse.DataSource := AFlatsDataSource;
  dbeFlat.DataSource := AFlatsDataSource;
  dbeOldDate.DataSource := AMeasureValuesDataSource;
  dbeOldValue.DataSource := AMeasureValuesDataSource;
  eMeasureValue.SetFocus;
end;

//���� ��������� ��������
procedure TfrmMeasureValue.InputMValue;
var LParams : TFDParams;
  MValue : Single;
  //FormatSettings : TFormatSettings;
begin
  try
    LParams := TFDParams.Create;
    try
      MValue := StrToFloat(eMeasureValue.Text);
      //������� �������� ����������
      with LParams do
      begin
        Add('idmeasurer$str', fIdmeasurer, ptInput);
        Add('measure$date', TDateTime(Trunc(eMeasureDate.DateTime)), ptInput);
        Add('measure$value', MValue, ptInput);
      end;
      //�������� ��������� - ������� ��������� ��������
      if Assigned(FCallingForm) then
        PostMessage(FCallingForm.Handle, WM_MEASURE_VALUE_INPUT,0,Integer(LParams));
     except
      On E : Exception do
        Application.MessageBox(PChar('������ : ' +
           E.Message), '������', 0);  //MB_ICONERROR
    end;
  finally
    Close;
  end;
end;

end.
