unit uMeasurers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Menus,
  FireDAC.Stan.Param, uMessage, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Actions, Vcl.ActnList,
  uMeasurer, Vcl.StdActns;

type
  TKindMeasurer = (kmInstalled, kmFree);

  TfrmMeasurers = class(TForm)
    dbgMeasurers: TDBGrid;
    gbFilter: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    cbFactory_number: TCheckBox;
    cbCheck_Date: TCheckBox;
    cbNext_Check_Date: TCheckBox;
    eFactory_number: TEdit;
    eBCheck_Date: TDateTimePicker;
    eECheck_date: TDateTimePicker;
    eBNext_Check_Date: TDateTimePicker;
    eENext_Check_date: TDateTimePicker;
    bUpdate: TButton;
    pBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    pmMeasurers: TPopupMenu;
    qMeasurers: TFDMemTable;
    dsMeasurers: TDataSource;
    qProcResult: TFDMemTable;
    mmMeasures: TMainMenu;
    alMeasurers: TActionList;
    aInsertMeasurer: TAction;
    nEdit: TMenuItem;
    nInsertMeasurer: TMenuItem;
    alUpdate: TAction;
    nInsert: TMenuItem;
    nCopy: TMenuItem;
    EditCopyMeasurers: TEditCopy;
    nCopyMeasurers: TMenuItem;
    nUpdateMeasurers: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbFactory_numberClick(Sender: TObject);
    procedure cbCheck_DateClick(Sender: TObject);
    procedure cbNext_Check_DateClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure eBCheck_DateChange(Sender: TObject);
    procedure eBNext_Check_DateChange(Sender: TObject);
    procedure NCopyClick(Sender: TObject);
    procedure aInsertMeasurerExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure alUpdateExecute(Sender: TObject);
    procedure aCopyExecute(Sender: TObject);
    procedure EditCopyMeasurersExecute(Sender: TObject);
  private
    { Private declarations }
    FUpdatePermit : Boolean;
    FMeasurer: TfrmMeasurer;
    FCallingForm: TForm;
    FIsDialog: Boolean;
    FKindMeasurers: TKindMeasurer;

    procedure TryInsertMeasurer(var Message: TMessage); message WM_NEW_MEASURER;
    procedure TryCloseMeasurer(var Message: TMessage); message WM_CLOSE_MEASURER;
    procedure InsertMeasurer(AParams: TFDParams);
    procedure SetIsDialog(const Value: Boolean);

  protected
    procedure ReadInifile;
    procedure WriteInifile;

  public
    { Public declarations }
    procedure UpdateMeasurers;
    procedure FormScale(const M, N : Integer);
    procedure Init(const ACallingForm: TForm; const AIsDialog: Boolean; const AKindMeasurers: TKindMeasurer);
  end;

//var frmMeasurers: TfrmMeasurers;

implementation

{$R *.dfm}

uses DM, uMain, uFlat, System.IniFiles, Vcl.Clipbrd, System.UITypes;

procedure TfrmMeasurers.aCopyExecute(Sender: TObject);
  var
  SelectedItems, FieldNames :TStringList;
  i : Integer;
begin
  SelectedItems := TStringList.Create;
  FieldNames := TStringList.Create;
  try
    //Список полей
    for i := 0 to dbgMeasurers.Columns.Count - 1 do
    FieldNames.Add(dbgMeasurers.Columns[i].FieldName);
    //Выбранные строки сетки записываются в TStringList (SelectedItems)
    frmMain.BuildListFromDBGrid(dbgMeasurers, FieldNames, SelectedItems);
    Clipboard.AsText := SelectedItems.Text;
  finally
    SelectedItems.Free;
    FieldNames.Free;
  end;
end;

procedure TfrmMeasurers.aInsertMeasurerExecute(Sender: TObject);
begin
//Добавление нового счетчика
  FMeasurer := TfrmMeasurer.Create(Application);
  with FMeasurer do
  begin
    CallingForm := self;
    FormScale(frmMain.Scale_M, frmMain.Scale_N);
  end;
end;

procedure TfrmMeasurers.alUpdateExecute(Sender: TObject);
begin
  UpdateMeasurers;
end;

procedure TfrmMeasurers.btnCancelClick(Sender: TObject);
begin
  //Отправим сообщение о закрытии диалога
  if Assigned(FCallingForm) then
    PostMessage(FCallingForm.Handle, WM_CLOSE_MEASURERS, 0, 0);
  Close;
end;

procedure TfrmMeasurers.btnOKClick(Sender: TObject);
var LParams : TFDParams;
begin
  try
    LParams := TFDParams.Create;
    try
      //Запишем значение параметров
      //Память LParams освобождается в процедуре-обработчике сообщения
      with qMeasurers do
      begin
        LParams.Add('ID', FieldByName('ID').AsVariant, ptInput);
        LParams.Add('FACTORY_NUMBER', FieldByName('FACTORY_NUMBER').AsVariant, ptInput);
      end;
     //Отправим сообщение - выбран счетчик
      if Assigned(FCallingForm) then
        PostMessage(FCallingForm.Handle, WM_CHOICE_MEASURER, 0, Integer(LParams));
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

procedure TfrmMeasurers.cbCheck_DateClick(Sender: TObject);
begin
  eBCheck_Date.Enabled := cbCheck_Date.Checked;
  eECheck_Date.Enabled := cbCheck_Date.Checked;
end;

procedure TfrmMeasurers.cbFactory_numberClick(Sender: TObject);
begin
  eFactory_number.Enabled := cbFactory_number.Checked;
end;

procedure TfrmMeasurers.cbNext_Check_DateClick(Sender: TObject);
begin
  eBNext_Check_Date.Enabled := cbNext_Check_Date.Checked;
  eENext_Check_Date.Enabled := cbNext_Check_Date.Checked;
end;

procedure TfrmMeasurers.eBCheck_DateChange(Sender: TObject);
begin
  eECheck_date.DateTime := eBCheck_date.DateTime;
end;

procedure TfrmMeasurers.eBNext_Check_DateChange(Sender: TObject);
begin
  eENext_Check_date.DateTime := eBNext_Check_date.DateTime;
end;

procedure TfrmMeasurers.EditCopyMeasurersExecute(Sender: TObject);
  var
  SelectedItems, FieldNames :TStringList;
  i : Integer;
begin
  SelectedItems := TStringList.Create;
  FieldNames := TStringList.Create;
  try
    //Список полей
    for i := 0 to dbgMeasurers.Columns.Count - 1 do
    FieldNames.Add(dbgMeasurers.Columns[i].FieldName);
    //Выбранные строки сетки записываются в TStringList (SelectedItems)
    frmMain.BuildListFromDBGrid(dbgMeasurers, FieldNames, SelectedItems);
    Clipboard.AsText := SelectedItems.Text;
  finally
    SelectedItems.Free;
    FieldNames.Free;
  end;
end;

procedure TfrmMeasurers.FormActivate(Sender: TObject);
begin
//Не делаем запрос к БД во время создания формы
  if FUpdatePermit then
    UpdateMeasurers;
end;

procedure TfrmMeasurers.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WriteIniFile;
  Action := caFree;
end;

procedure TfrmMeasurers.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FMeasurer) then
  begin
    MessageDlg('Это окно нельзя закрыть пока открыто окно свойств счетчика', mtWarning, [mbOk], 0);
    CanClose := False;
    FMeasurer.SetFocus;
  end;
end;

procedure TfrmMeasurers.FormCreate(Sender: TObject);
begin
  FUpdatePermit := False;
  FKindMeasurers := kmInstalled;
  ReadInifile;
  FMeasurer := nil;
  FIsDialog := False; //справочник, если True - диалог выбора элемента справочника
end;

procedure TfrmMeasurers.FormScale(const M, N: Integer);
begin
  if M > N then
  begin
    self.Width := Trunc(M*self.Width/N);
    self.Height := Trunc(M*self.Height/N);
    self.Scaled := True;
    self.ScaleBy(M,N);
  end;
end;

procedure TfrmMeasurers.Init(const ACallingForm: TForm;
  const AIsDialog: Boolean; const AKindMeasurers: TKindMeasurer);
begin
  //Запишем вид окна: диалог или справочник
  SetIsDialog(AIsDialog);
  //Запишем тип показываемых счетчиков: установленные или свободные
  FKindMeasurers := AKindMeasurers;
  //запишем указатель на форму-создателя
  FCallingForm := ACallingForm;
  //При активизации формы обновим список счетчиков
  UpdateMeasurers;
  //Разрешим обновление списка счетчика при активизации формы
  FUpdatePermit := True;
end;

procedure TfrmMeasurers.InsertMeasurer(AParams: TFDParams);
var sqlInsMeasurer : String;
begin
  //Добавление счетчика
  sqlInsMeasurer := 'select * from measurer$new(:factory_number,' +
    ' :check_date, :next_check_date)';
  frmMain.SetThreadStatus('Добавление счетчика');

  try
    frmDM.DBExecuteSQL(sqlInsMeasurer, AParams, qProcResult, nil,
      'NewMeasurer', True);
  finally
    //Освободим память для списка параметров
    if Assigned(AParams) then AParams.Free;
  end;
end;

procedure TfrmMeasurers.NCopyClick(Sender: TObject);
var
  SelectedItems, FieldNames :TStringList;
  i : Integer;
begin
  SelectedItems := TStringList.Create;
  FieldNames := TStringList.Create;
  try
    //Список полей
    for i := 0 to dbgMeasurers.Columns.Count - 1 do
    FieldNames.Add(dbgMeasurers.Columns[i].FieldName);
    //Выбранные строки сетки записываются в TStringList (SelectedItems)
    frmMain.BuildListFromDBGrid(dbgMeasurers, FieldNames, SelectedItems);
    Clipboard.AsText := SelectedItems.Text;
  finally
    SelectedItems.Free;
    FieldNames.Free;
  end;
end;

procedure TfrmMeasurers.ReadInifile;
var
   Ini: TIniFile;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.INI' ) );
   try
     Height := Ini.ReadInteger( self.Name, 'Height', 375 );
     Width := Ini.ReadInteger( self.Name, 'Width', 562 );

     if Ini.ReadBool( self.Name, 'InitMax', false ) then
       WindowState := wsMaximized
     else
       WindowState := wsNormal;
   finally
     Ini.Free;
   end;
end;


procedure TfrmMeasurers.SetIsDialog(const Value: Boolean);
begin
  FIsDialog := Value;
  pBottom.Visible := Value;
end;

procedure TfrmMeasurers.TryCloseMeasurer(var Message: TMessage);
begin
  FMeasurer := nil;
end;

procedure TfrmMeasurers.TryInsertMeasurer(var Message: TMessage);
var AParams : TFDParams;
begin
  AParams := TFDParams(Message.LParam);
  //Добавим новый счетчик
  InsertMeasurer(AParams);
  FMeasurer := nil;
end;

procedure TfrmMeasurers.UpdateMeasurers;
var LParams : TFDParams;
  sqlMeasurers, Query_Name, sqlWhere : String;
begin
  //Запишем значения параметров
  LParams := TFDParams.Create;
  try
    if cbFactory_number.Checked then
    begin
      LParams.Add('FACTORY_NUMBER', eFactory_number.Text, ptInput);
      sqlWhere := '(M.factory_number LIKE :FACTORY_NUMBER)';
    end;
    if cbCheck_Date.Checked then
    begin
      LParams.Add('BCHECK_DATE', TDateTime(Trunc(eBCheck_date.DateTime)), ptInput);
      if sqlWhere <> '' then sqlWhere := sqlWhere + ' AND ';
      if Trunc(eBCheck_date.DateTime) <> Trunc(eECheck_date.DateTime) then
      begin
        LParams.Add('ECHECK_DATE', TDateTime(Trunc(eECheck_date.DateTime)), ptInput);
        sqlWhere := sqlWhere + '(M.check_date BETWEEN :BCHECK_DATE and :ECHECK_DATE)';
      end
      else sqlWhere := sqlWhere + '(M.check_date = :BCHECK_DATE)';
    end;
    if cbNext_Check_Date.Checked then
    begin
      LParams.Add('BNEXT_CHECK_DATE', TDateTime(Trunc(eBNext_check_date.DateTime)), ptInput);
      if sqlWhere <> '' then sqlWhere := sqlWhere + ' AND ';
      if Trunc(eBNext_check_date.DateTime) <> Trunc(eENext_check_date.DateTime) then
      begin
        LParams.Add('ENEXT_CHECK_DATE', TDateTime(Trunc(eENext_check_date.DateTime)), ptInput);
        sqlWhere := sqlWhere +
          '(M.next_check_date BETWEEN :BNEXT_CHECK_DATE and :ENEXT_CHECK_DATE)';
      end
      else sqlWhere := sqlWhere + '(M.next_check_date = :BNEXT_CHECK_DATE)';
    end;
    //Запрос списка установленных счетчиков
    sqlMeasurers := 'SELECT M.ID, M.FACTORY_NUMBER, M.CHECK_DATE, M.NEXT_CHECK_DATE';

    if FKindMeasurers = kmInstalled then
    begin
      frmMain.SetThreadStatus('Запрос списка установленных счетчиков');
      Query_Name := 'Measurer';
      //установленные счетчики
      sqlMeasurers := sqlMeasurers + ' FROM VWMEASURERS AS M';
    end
    else
    begin
      frmMain.SetThreadStatus('Запрос списка счетчиков, неустановленных в квартирах');
      Query_Name := 'FreeMeasurer';
      //неустановленные счетчики
      sqlMeasurers := sqlMeasurers + ' FROM VWFREE$MEASURERS AS M';
    end;
    if sqlWhere <> '' then
      sqlMeasurers := sqlMeasurers + ' WHERE ' + sqlWhere;
    frmDM.DBExecuteSQL(sqlMeasurers, LParams, qMeasurers, nil, Query_Name, True);
  finally
    if Assigned(LParams) then LParams.Free;
  end;
end;

procedure TfrmMeasurers.WriteInifile;
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
