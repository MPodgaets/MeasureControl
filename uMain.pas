unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.Menus, uFirstLoading, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  Vcl.AppEvnts, uMessage, Vcl.StdActns;

type
  TfrmMain = class(TForm)
    alMeasureControl: TActionList;
    mmMeasureControl: TMainMenu;
    aChangeMeasurerHistory: TAction;
    aNotVerificMeasurers: TAction;
    aDBSettings: TAction;
    aConnectDB1: TMenuItem;
    N1: TMenuItem;
    nMeasurers: TMenuItem;
    N4: TMenuItem;
    nNotVerificMeasurers: TMenuItem;
    aMeasureValues: TAction;
    aFirstLoading: TAction;
    aShowLog: TAction;
    N7: TMenuItem;
    nLog: TMenuItem;
    nMeasureValues: TMenuItem;
    N9: TMenuItem;
    aMeasurers: TAction;
    aFlats: TAction;
    nMenuEdit: TMenuItem;
    nMenuEdit1: TMenuItem;
    nMenuEdit2: TMenuItem;
    nMenuEdit3: TMenuItem;
    nUsers: TMenuItem;
    aShowUsers: TAction;
    nShowUsers: TMenuItem;
    aCopyToClipboard: TAction;
    sbLog: TStatusBar;
    nCreateUser: TMenuItem;
    nModifyUser: TMenuItem;
    nDeleteUser: TMenuItem;
    WindowClose1: TWindowClose;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowTileVertical1: TWindowTileVertical;
    WindowMinimizeAll1: TWindowMinimizeAll;
    WindowArrange1: TWindowArrange;
    procedure aMeasureValuesExecute(Sender: TObject);
    procedure aFirstLoadingExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure aNotVerificMeasurersExecute(Sender: TObject);
    procedure aMeasurersExecute(Sender: TObject);
    procedure aShowUsersExecute(Sender: TObject);
    procedure aDBSettingsExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure WindowCascade1Execute(Sender: TObject);
    procedure WindowArrange1Execute(Sender: TObject);
    procedure WindowClose1Execute(Sender: TObject);
    procedure WindowMinimizeAll1Execute(Sender: TObject);

  private
    { Private declarations }
    FFirstLoading_Thread : TFirstLoading;
    FFirstLoading_Run : boolean;
    FLoginCount: Integer; // количество попыток входа в систему
    FIsSysdba: Boolean;  //Признак входа под Sysdba
    FM: Integer;
    FN: Integer;
    FDatabaseStr: String;
    FLog : TStringList;

    procedure SetLoginCount(const Value: Integer);
    procedure SetIsSysdba(const Value: Boolean);
    procedure SetM(const Value: Integer);
    procedure SetN(const Value: Integer);
    procedure SetDatabaseStr(const Value: String);
    procedure ReadInifile;
    procedure WriteInifile;
    procedure FirstLoading_OnTerminate(Sender: TObject);

    procedure TryLogin(var Message: TMessage); message WM_LOGIN;
    procedure Reconnect(var Message: TMessage); message WM_RECONNECT;

  public
    { Public declarations }
    procedure FormScale(const M, N : Integer);
    procedure BuildListFromDBGrid(const aDBGrid: TDBGrid; const aFieldNames: TStrings; aSelStrings :TStrings);
    procedure CloseDBGridForms;
    procedure SetThreadStatus(const AStatus : String);
    function IsFormExist(const AForm : TForm) : Boolean;

    property LoginCount : Integer read FLoginCount write SetLoginCount;
    property IsSysdba : Boolean read FIsSysdba write SetIsSysdba;
    property Scale_M : Integer read FM write SetM;
    property Scale_N : Integer read FN write SetN;
    property DatabaseStr : String read FDatabaseStr write SetDatabaseStr;
    property Log : TStringList read FLog;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses System.UITypes, FireDAC.Stan.Param, FireDAC.Phys.IBWrapper,
 System.IniFiles, FireDAC.Stan.Error,
uLog, DM, uList, uDBSettings, uPASSWORD,
uFlat, uUsers, uUser, uMeasureValues, uMeasurers;       //frmMain.sbLog.Panels[0].Text

procedure TfrmMain.aDBSettingsExecute(Sender: TObject);
var  frmDBSettings: TfrmDBSettings;
begin
  frmDBSettings := TfrmDBSettings.Create(Application);
  frmDBSettings.Show;
end;

procedure TfrmMain.aFirstLoadingExecute(Sender: TObject);
var frmLog: TfrmLog;
begin
  if not FFirstLoading_Run then
  begin
    FFirstLoading_Run := True;
    frmLog := TfrmLog.Create(Application);

    FFirstLoading_Thread := TFirstLoading.Create(True); { Create suspended-second process does not run yet. }
    try
      with FFirstLoading_Thread do
      begin
        FreeOnTerminate := True;
        OnTerminate := FirstLoading_OnTerminate;
        Priority := tpLower;  { Set the priority to lower than normal. }
        //Инициализация переменных нити
        if Init(frmDM.fdcMeasureControl, frmLog.mLog.Lines) then
          Start; { now run the thread }
      end;
    except

    end;
  end
  else
    MessageDlg('This thread is still running. You are going to hurt yourself!',
    mtInformation, [mbOk], 0);
end;

procedure TfrmMain.aMeasurersExecute(Sender: TObject);
var  i : Integer;
    FMeasurers: TfrmMeasurers;
begin
  //Проверим открыт ли уже справочник счетчиков
  for i := 0 to MDIChildCount - 1 do
  if MDIChildren[i].Name = 'frmMeasurers' then
  begin
    //Если справочник счетчиков открыт, то сделаем его активным
    MDIChildren[i].SetFocus;
    Exit;
  end;

  //Откроем справочник счетчиков
  FMeasurers := TfrmMeasurers.Create(Application);
  //try
  with FMeasurers do
  begin
    FormScale(FM,FN);
    //окно открывается как справочник
    //выбираются установленные счетчики
    Init(self, False, kmInstalled);
  end;
end;

procedure TfrmMain.aMeasureValuesExecute(Sender: TObject);
var i : Integer;
  FMeasureValues: TfrmMeasureValues;

begin
  //Проверим открыт ли уже справочник счетчиков
  for i := 0 to MDIChildCount - 1 do
  if MDIChildren[i].Name = 'frmMeasureValues' then
  begin
    //Если справочник счетчиков открыт, то сделаем его активным
    MDIChildren[i].SetFocus;
    Exit;
  end;

  FMeasureValues := TfrmMeasureValues.Create(Application);
  FMeasureValues.FormScale(FM,FN);
end;

procedure TfrmMain.aNotVerificMeasurersExecute(Sender: TObject);
var frmList: TfrmList;
begin
  frmList := TfrmList.Create(self);
  frmList.FormScale(FM,FN);
end;

procedure TfrmMain.aShowUsersExecute(Sender: TObject);
var frmUsers: TfrmUsers;
begin
  frmUsers := TfrmUsers.Create(Application);
  frmUsers.FormScale(FM,FN);
end;

procedure TfrmMain.BuildListFromDBGrid(const aDBGrid: TDBGrid; const aFieldNames: TStrings;
  aSelStrings: TStrings);
var i, j : Integer;
    RowStr : String;
begin
  aSelStrings.Clear();
  with aDBGrid do
     begin
        aSelStrings.BeginUpdate(); // If assocated with a UI control (Listbox, etc), this will prevent any flickering
        DataSource.DataSet.DisableControls();
        try
          for i := 0 to SelectedRows.Count - 1 do
             begin
               Datasource.DataSet.GotoBookmark(TValueBuffer(SelectedRows[i]));
               RowStr := '';
               for j := 0 to aFieldNames.Count - 1 do
               begin
                 RowStr := RowStr +
                  DataSource.DataSet.FieldByName(aFieldNames.Strings[j]).AsString;
                 if j < aFieldNames.Count - 1 then
                   RowStr := RowStr + #9;
               end;
               aSelStrings.Add(RowStr);
             end;
        finally
           DataSource.DataSet.EnableControls();
           aSelStrings.EndUpdate();
        end;
     end;
end;

procedure TfrmMain.CloseDBGridForms;
var i : Integer;
  FormName : String;
begin
  for i := 0 to Application.ComponentCount - 1 do
  begin
    FormName := Application.Components[i].Name;
    if (Application.Components[i] is TForm) and
     not((FormName = 'frmMain') or (FormName = 'frmLog')
      or (FormName = 'frmDM') or (FormName = 'dlgPassword')
      or (FormName = 'frmDBSettings')) then
      (Application.Components[i] as TForm).Close;
  end;
end;

procedure TfrmMain.FirstLoading_OnTerminate(Sender: TObject);
begin
  ShowMessage('Первоначальная загрузка счетчиков и квартир в базу данных завершена.');
  FFirstLoading_Thread.Free;
  FFirstLoading_Thread := nil;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteIniFile;
  //Закроем окна, отображающие результаты запросов к БД
  CloseDBGridForms;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  if FFirstLoading_Run then
  begin
    if MessageDlg('Есть запущенные потоки. Вы хотите закрыть приложение?',
      mtWarning, [mbYes, mbNo], 0) = mrNo then
      CanClose := False
    else
     begin
      //Если работает загрузка, то останавливаем нить
      if FFirstLoading_Run then
        FFirstLoading_Thread.Terminate;
      CanClose := True;
     end;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var dev_W, user_W, dev_H, user_H, i : Integer;
begin
  FLog := TStringList.Create;
  FDatabaseStr := ExtractFileDir(Application.ExeName) + PathDelim + 'MEASURECONTROL.FDB';
  FFirstLoading_Run := False;
  FLoginCount := 0;
  //Пользователи видны только SYSDBA и при подключении к серверу
  nUsers.Visible := False;
  aShowUsers.Enabled := False;
  with frmMain, alMeasureControl do
  for i := 0 to ActionCount - 1 do
  if Actions[i].Category = 'Users' then
  begin
    Actions[i].Visible := False;
    Actions[i].Enabled := False;
  end;
  //
  SetIsSysdba(False);
  ReadInifile;
  //Размеры экрана разработки
  dev_W := 1920;
  dev_H := 1080;
  //Получим текущий размер экрана
  user_W := GetSystemMetrics(SM_CXSCREEN);
  user_H := GetSystemMetrics(SM_CYSCREEN);
  //Вычислим коэффициенты масштабирования
  if (dev_W < user_W) and (dev_H < user_H) then
  begin
    if user_W/dev_W < user_H/dev_H then
    begin
      FM := user_W;
      FN := dev_W;
    end
    else
    begin
      FM := user_H;
      FN := dev_H;
    end;
  end
  else
  begin
    FM := 1;
    FN := 1;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FLog) then
    FLog.Free;
end;

procedure TfrmMain.FormScale(const M, N: Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

function TfrmMain.IsFormExist(const AForm: TForm): Boolean;
var i : Integer;
begin
  i := 0;
  repeat
    Result := self.MDIChildren[i].Equals(AForm);
    Inc(i);
  until Result or (i = self.MDIChildCount);
end;

procedure TfrmMain.ReadInifile;
var
   Ini: TIniFile;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
   try
     Height := Ini.ReadInteger( self.Name, 'Height', 480 );
     Width := Ini.ReadInteger( self.Name, 'Width', 640 );

     if Ini.ReadBool( self.Name, 'InitMax', false ) then
       WindowState := wsMaximized
     else
       WindowState := wsNormal;
   finally
     Ini.Free;
   end;
end;

procedure TfrmMain.Reconnect(var Message: TMessage);
begin
  //Закроем окна, отображающие результаты запросов к БД
  CloseDBGridForms;
  //Завершим работу нитей, отправляющих запросы к БД и закроем подключение
  frmDM.CloseConnection;
  //Заново подключимся к БД
  self.Perform(WM_LOGIN,0,0);
end;

procedure TfrmMain.SetDatabaseStr(const Value: String);
begin
  FDatabaseStr := Value;
end;

procedure TfrmMain.SetIsSysdba(const Value: Boolean);
var UsersVis : Boolean;
  i : Integer;
begin
  FIsSysdba := Value;
  if Assigned(frmDM) then  //
  begin
    UsersVis := (not(frmDM.Embedded) and FIsSysdba);
    nUsers.Visible := UsersVis;
    aShowUsers.Enabled := UsersVis;
    with frmMain, alMeasureControl do
    for i := 0 to ActionCount - 1 do
    if Actions[i].Category = 'Users' then
      Actions[i].Enabled := UsersVis;
  end;
end;

procedure TfrmMain.SetLoginCount(const Value: Integer);
begin
  FLoginCount := Value;
end;

procedure TfrmMain.SetM(const Value: Integer);
begin
  FM := Value;
end;

procedure TfrmMain.SetN(const Value: Integer);
begin
  FN := Value;
end;

procedure TfrmMain.SetThreadStatus(const AStatus: String);
begin
  Log.Add(AStatus);
  sbLog.Panels[0].Text := AStatus;
end;

procedure TfrmMain.TryLogin(var Message: TMessage);
var xLoginPromptDlg : TdlgPassword;
  ConnectStr : String;
begin
  if frmDM.Embedded then
  try
    //frmDM.fdcMeasureControl.ResourceOptions.AutoReconnect := True;
    ConnectStr := frmDM.GetConnectionStr + 'User_Name=SYSDBA;Password=sa123;';
    frmDM.fdcMeasureControl.ConnectionName := ConnectStr;
    {if not frmDM.fdcMeasureControl.Ping then
    begin
      Application.MessageBox(PChar('Ping к серверу не проходит '), 'Ошибка', 0);
      Close;
    end; }
    //Попробуем подкючиться в embedded режиме
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
  end
  else
  begin
    //Вызываем диалог подключения, если еще не подключились
    if not frmDM.fdcMeasureControl.Connected then
    begin
      xLoginPromptDlg := TdlgPassword.Create(Application);
      frmDM.GetUsers(xLoginPromptDlg.cbUserName.Items);
      if frmDM.fdUsers.RecordCount = 0 then
      begin
        ShowMessage('Список пользователей пуст!');
        Exit;
      end;
      if FLoginCount < MAX_LOGIN_COUNT then
      try
        xLoginPromptDlg.cbUserName.ItemIndex := 0;
        //xLoginPromptDlg.Show;
      except
        on E: Exception do
        begin
          Inc(FLoginCount);
          Application.ShowException(E);
        end
      end
      else Exit;
    end;
  end;
end;

procedure TfrmMain.WindowArrange1Execute(Sender: TObject);
begin
  //Arrange;
end;

procedure TfrmMain.WindowCascade1Execute(Sender: TObject);
begin
  Cascade;
end;

procedure TfrmMain.WindowClose1Execute(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.WindowMinimizeAll1Execute(Sender: TObject);
begin
  //MinimizeAll;
end;

procedure TfrmMain.WriteInifile;
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

end.
