unit uPassWord;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, uMain, uMessage;

const MAX_LOGIN_COUNT = 5;

type
  TdlgPassword = class(TForm)
    Label1: TLabel;
    OKBtn: TButton;
    CancelBtn: TButton;
    Label2: TLabel;
    ePassword: TEdit;
    Label3: TLabel;
    cbUserName: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
  end;

//var dlgPassword: TdlgPassword;

implementation

{$R *.dfm}

uses DM, FireDAC.Stan.Consts, FireDAC.Stan.Error, FireDAC.Phys.IBWrapper;

procedure TdlgPassword.CancelBtnClick(Sender: TObject);
begin
 frmMain.LoginCount := MAX_LOGIN_COUNT;
 self.Close;
end;

procedure TdlgPassword.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TdlgPassword.FormCreate(Sender: TObject);
begin
  frmMain.LoginCount := frmMain.LoginCount + 1;
  ePassword.PasswordChar := '*';
end;

procedure TdlgPassword.FormDestroy(Sender: TObject);
begin
  //Попробуем подключиться еще раз
  if Assigned(Application.MainForm) then
    PostMessage(Application.MainForm.Handle,WM_LOGIN,0,0);
end;

procedure TdlgPassword.FormScale(const M, N: Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

procedure TdlgPassword.OKBtnClick(Sender: TObject);
var ConnectStr : String;
begin
try
  ConnectStr := frmDM.GetConnectionStr + 'User_Name=' + cbUserName.Text +
  ';Password=' + ePassword.Text + ';';

  if AnsiUpperCase(cbUserName.Text) = 'SYSDBA' then frmMain.IsSysdba := True
  else ConnectStr := ConnectStr + 'RoleName=METR;';
  //Попробуем подкючиться
  frmDM.fdcMeasureControl.Open(ConnectStr);
except
  on E: EIBNativeException do
    case E.Kind of
    ekUserPwdInvalid:
      Application.MessageBox(PChar('Ошибка доступа к базе данных: ' +
    'Неправильное имя пользователя или пароль.'), 'Ошибка', 0); // user name or password are incorrect e.Message

    ekUserPwdExpired:
      Application.MessageBox(PChar('Ошибка доступа к базе данных: ' +
    'У имени пользователя или пароля истек срок годности.'), 'Ошибка', 0); // user password is expired
    ekServerGone:
      Application.MessageBox(PChar('Ошибка доступа к базе данных: ' +
    'СУБД недоступна по какой-то причине'), 'Ошибка', 0);     // DBMS is not accessible due to some reason
    else                // другие причины
      Application.MessageBox(PChar('Ошибка доступа к базе данных: ' +
    E.Message), 'Ошибка', 0);
  end;
end;
  //Закроем диалоговое окно
  Close;
end;

end.

