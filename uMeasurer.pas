unit uMeasurer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, uMessage;

type
  TfrmMeasurer = class(TForm)
    pBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    pTop: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    eFactory_number: TEdit;
    dCheck_date: TDateTimePicker;
    dNext_Check_Date: TDateTimePicker;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure dCheck_dateChange(Sender: TObject);
  private
    FCallingForm: TForm;
    procedure SetCallingForm(const Value: TForm);
    { Private declarations }
  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
    property CallingForm : TForm read FCallingForm write SetCallingForm;
  end;

//var frmMeasurer: TfrmMeasurer;

implementation

{$R *.dfm}

uses DM, FireDAC.Stan.Param, Data.DB, uMeasurers;

procedure TfrmMeasurer.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMeasurer.btnOKClick(Sender: TObject);
var LParams : TFDParams;
begin
  try
    LParams := TFDParams.Create;
    try
      //Запишем значение параметров
      LParams.Add('FACTORY_NUMBER', eFactory_number.Text, ptInput);
      LParams.Add('CHECK_DATE', TDateTime(Trunc(dCheck_date.DateTime)), ptInput);
      LParams.Add('NEXT_CHECK_DATE',TDateTime(Trunc(dNext_Check_date.DateTime)), ptInput);

      //Отправим сообщение - завести характеристики счетчика
      if Assigned(FCallingForm) then
        PostMessage(FCallingForm.Handle, WM_NEW_MEASURER, 0, Integer(LParams));
    except
      On E : Exception do
        Application.MessageBox(PChar('Ошибка : ' +
           E.Message), 'Ошибка', 0);
    end;
  finally
    Close;
  end;
end;

procedure TfrmMeasurer.dCheck_dateChange(Sender: TObject);
begin
  dCheck_date.DateTime := dCheck_date.DateTime + 356*3 + 1;
end;

procedure TfrmMeasurer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FCallingForm) then
    PostMessage(FCallingForm.Handle, WM_CLOSE_MEASURER, 0, 0);
  Action := caFree;
end;

procedure TfrmMeasurer.FormScale(const M, N: Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

procedure TfrmMeasurer.SetCallingForm(const Value: TForm);
begin
  FCallingForm := Value;
end;

end.
