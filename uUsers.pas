unit uUsers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.Menus, uMessage, System.Actions, Vcl.ActnList, uUser;

type
  TfrmUsers = class(TForm)
    fbgUsers: TDBGrid;
    pmUsers: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    mmUsers: TMainMenu;
    alUsers: TActionList;
    CreateUser: TAction;
    ModifyUser: TAction;
    DeleteUser: TAction;
    nEdit: TMenuItem;
    nInsertUser: TMenuItem;
    nModifyUser: TMenuItem;
    nDeleteUser: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure CreateUserExecute(Sender: TObject);
    procedure ModifyUserExecute(Sender: TObject);
    procedure DeleteUserExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FUser: TfrmUser;
    procedure ReadInifile;
    procedure WriteInifile;
    procedure TryInsertUser(var Message: TMessage); message WM_CREATE_USER;
    procedure TryModifyUser(var Message: TMessage); message WM_MODIFY_USER;
  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
    procedure UpdateUsers;
  end;

//var frmUsers: TfrmUsers;

implementation

{$R *.dfm}

uses DM, System.IniFiles, FireDAC.Stan.Param, uMain;

procedure TfrmUsers.CreateUserExecute(Sender: TObject);
begin
  //Заведем нового пользователя
  if not Assigned(FUser) then
    FUser := TfrmUser.Create(Application)
  else
  MessageDlg('Окно свойств пользователя уже открыто',
    mtWarning, [mbOk], 0);
end;

procedure TfrmUsers.DeleteUserExecute(Sender: TObject);
begin
  try
    with frmDM, fbSecurity do
    begin
      AUserName := fdUsers.FieldByName('username').AsString;
      DeleteUser;
    end;
    //обновим окно пользователей
    UpdateUsers;
  except
    on E: Exception do
         Application.MessageBox(PChar('Ошибка : ' +
         e.Message), 'Ошибка', 0);
  end;
end;

procedure TfrmUsers.FormActivate(Sender: TObject);
var i : Integer;
begin
  UpdateUsers;
  with frmMain, alMeasureControl do
  for i := 0 to ActionCount - 1 do
  if Actions[i].Category = 'Users' then
    Actions[i].Visible := True;
end;

procedure TfrmUsers.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteIniFile;
  Action := caFree;
end;

procedure TfrmUsers.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FUser) then
  begin
    MessageDlg('Это окно нельзя закрыть пока открыт окно свойств пользователя', mtWarning, [mbOk], 0);
    CanClose := False;
  end;
end;

procedure TfrmUsers.FormCreate(Sender: TObject);
begin
  FUser := nil;
  ReadInifile;
end;

procedure TfrmUsers.FormDeactivate(Sender: TObject);
var i : Integer;
begin
  with frmMain, alMeasureControl do
  for i := 0 to ActionCount - 1 do
  if Actions[i].Category = 'Users' then
    Actions[i].Visible := False;
end;

procedure TfrmUsers.FormScale(const M, N: Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

procedure TfrmUsers.ModifyUserExecute(Sender: TObject);
var frmUser: TfrmUser;
begin
  //Поменяем пароль
  if not Assigned(FUser) then
  begin
    frmUser := TfrmUser.Create(Application);
    try
      frmUser.IsCreateUser := False;
    except
      on E: Exception do
           Application.MessageBox(PChar('Ошибка : ' +
           e.Message), 'Ошибка', 0);
    end;
  end
  else
  MessageDlg('Окно свойств пользователя уже открыто',
    mtWarning, [mbOk], 0);
end;

procedure TfrmUsers.ReadInifile;
var
   Ini: TIniFile;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
   try
     Height := Ini.ReadInteger( self.Name, 'Height', 290 );
     Width := Ini.ReadInteger( self.Name, 'Width', 430 );

     if Ini.ReadBool( self.Name, 'InitMax', false ) then
       WindowState := wsMaximized
     else
       WindowState := wsNormal;
   finally
     Ini.Free;
   end;
end;

procedure TfrmUsers.WriteInifile;
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

procedure TfrmUsers.TryInsertUser(var Message: TMessage);
var AParams : TFDParams;
begin
  AParams := TFDParams(Message.LParam);
  //Добавим нового пользователя в базу данных
  frmDM.InsertUser(AParams);
  UpdateUsers;
  FUser := nil;
end;

procedure TfrmUsers.TryModifyUser(var Message: TMessage);
  var AParams : TFDParams;
begin
  AParams := TFDParams(Message.LParam);
  //Добавим нового пользователя в базу данных
  frmDM.ModifyUser(AParams);
  UpdateUsers;
  FUser := nil;
end;

procedure TfrmUsers.UpdateUsers;
begin
  frmDM.GetUsers(nil);
  //Создадим столбцы
  //fbgUsers.Columns.RebuildColumns;
end;

end.
