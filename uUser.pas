unit uUser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfrmUser = class(TForm)
    pBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    eUser: TEdit;
    Label6: TLabel;
    ePassword: TEdit;
    eLastName: TEdit;
    eFirstName: TEdit;
    eMiddleName: TEdit;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FIsCreateUser: Boolean;
    procedure SetIsCreateUser(const Value: Boolean);
    { Private declarations }
  public
    { Public declarations }
    property IsCreateUser : Boolean read FIsCreateUser write SetIsCreateUser;
  end;

//var frmUser: TfrmUser;

implementation

{$R *.dfm}

{ TfrmUser }

uses FireDAC.Stan.Param, Data.DB, uMessage, uUsers;

procedure TfrmUser.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmUser.btnOKClick(Sender: TObject);
var LParams : TFDParams;
  Comp_Form : TComponent;
  hw : HWND;
begin
  //
  try
    LParams := TFDParams.Create;
    try
      //Запишем значение параметров
      LParams.Add('user$name', eUser.Text, ptInput);
      LParams.Add('user$password', ePassword.Text, ptInput);
      {LParams.Add('first$name', eFirstName.Text, ptInput);
      LParams.Add('middle$name', eMiddleName.Text, ptInput);
      LParams.Add('last$name', eLastName.Text, ptInput);
      LParams.Add('user$role', 'METR', ptInput); }

      //Отправим сообщение - завести пользователя
      Comp_Form := Application.FindComponent('frmUsers');
      if Assigned(Comp_Form) and (Comp_Form is TfrmUsers) then
      begin
        hw := (Comp_Form AS TfrmUsers).Handle;
        if self.IsCreateUser then
          PostMessage(hw, WM_CREATE_USER, 0, Integer(LParams))
          else
          PostMessage(hw, WM_MODIFY_USER, 0, Integer(LParams));
      end;
    except
      On E : Exception do
        Application.MessageBox(PChar('Ошибка : ' +
           E.Message), 'Ошибка', 0);
    end;
  finally
    Close;
  end;
end;

procedure TfrmUser.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmUser.FormCreate(Sender: TObject);
begin
  SetIsCreateUser(True);
end;

procedure TfrmUser.SetIsCreateUser(const Value: Boolean);
begin
  FIsCreateUser := Value;
  if FIsCreateUser then
  begin
    Caption := 'Ввод пользователя';
  end
  else
  begin
    Caption := 'Изменение пароля';
    eUser.ReadOnly := True;
  end;
end;

end.
