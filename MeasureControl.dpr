program MeasureControl;

uses
  Vcl.Forms,
  uMeasureValues in 'uMeasureValues.pas' {frmMeasureValues},
  DM in 'DM.pas' {frmDM: TDataModule},
  uFirstLoading in 'uFirstLoading.pas',
  uQueryThread in 'uQueryThread.pas',
  uPassWord in 'uPassWord.pas' {dlgPassword},
  uMeasureValue in 'uMeasureValue.pas' {frmMeasureValue},
  uMain in 'uMain.pas' {frmMain},
  uLog in 'uLog.pas' {frmLog},
  uList in 'uList.pas' {frmList},
  uMeasurers in 'uMeasurers.pas' {frmMeasurers},
  uMeasurer in 'uMeasurer.pas' {frmMeasurer},
  uFlat in 'uFlat.pas' {frmFlats},
  uUsers in 'uUsers.pas' {frmUsers},
  uDBSettings in 'uDBSettings.pas' {frmDBSettings},
  uUser in 'uUser.pas' {frmUser},
  uMessage in 'uMessage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmDM, frmDM);
  Application.Run;
end.
