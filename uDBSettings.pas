unit uDBSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, uMessage;

type
  TfrmDBSettings = class(TForm)
    pBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    rgServerType: TRadioGroup;
    gbDatabase: TGroupBox;
    opDatabase: TOpenDialog;
    eDatabaseName: TEdit;
    btnDatabase: TButton;
    eServer: TEdit;
    procedure btnDatabaseClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure rgServerTypeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var  frmDBSettings: TfrmDBSettings;

implementation

{$R *.dfm}

uses uMain, DM;

procedure TfrmDBSettings.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDBSettings.btnDatabaseClick(Sender: TObject);
begin
  with opDatabase do
  begin
    InitialDir := ExtractFileDir(Application.ExeName);
    if Execute then
      eDatabaseName.Text := FileName;
  end;
  //eDatabaseName.SetFocus;
  btnDatabase.SetFocus;
end;

procedure TfrmDBSettings.btnOKClick(Sender: TObject);
begin
  frmMain.DatabaseStr := eDatabaseName.Text;
  frmDM.Embedded := Boolean(rgServerType.ItemIndex = 0);
  frmDM.fbSecurity.Host := eServer.Text;
  //Отправим сообщение главному окну о переподкючении
  if Assigned(Owner) and (Owner is TForm) then
    PostMessage((Owner as TForm).Handle,WM_RECONNECT,0,0);
  Close;
end;

procedure TfrmDBSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmDBSettings.FormCreate(Sender: TObject);
begin
  eDatabaseName.Text := frmMain.DatabaseStr;
end;

procedure TfrmDBSettings.rgServerTypeClick(Sender: TObject);
begin
  eServer.Enabled := Boolean(rgServerType.ItemIndex = 1);
end;

end.
