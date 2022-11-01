object frmDBSettings: TfrmDBSettings
  Left = 0
  Top = 0
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1076#1086#1089#1090#1091#1087#1072' '#1082' '#1073#1072#1079#1077' '#1076#1072#1085#1085#1099#1093
  ClientHeight = 192
  ClientWidth = 460
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pBottom: TPanel
    Left = 0
    Top = 155
    Width = 460
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnOK: TButton
      Left = 96
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 270
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object rgServerType: TRadioGroup
    Left = 0
    Top = 0
    Width = 460
    Height = 101
    Align = alTop
    Caption = ' '#1058#1080#1087' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103' '
    ItemIndex = 0
    Items.Strings = (
      'Embedded'
      'Server')
    TabOrder = 0
    OnClick = rgServerTypeClick
  end
  object gbDatabase: TGroupBox
    Left = 0
    Top = 101
    Width = 460
    Height = 52
    Align = alTop
    Caption = ' '#1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077' '#1092#1072#1081#1083#1072' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093' '
    TabOrder = 2
    DesignSize = (
      460
      52)
    object eDatabaseName: TEdit
      Left = 8
      Top = 20
      Width = 420
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object btnDatabase: TButton
      Left = 434
      Top = 18
      Width = 21
      Height = 25
      Anchors = [akTop, akRight]
      Caption = ' ... '
      TabOrder = 1
      OnClick = btnDatabaseClick
    end
  end
  object eServer: TEdit
    Left = 80
    Top = 65
    Width = 348
    Height = 21
    Enabled = False
    TabOrder = 1
    Text = '127.0.0.1'
  end
  object opDatabase: TOpenDialog
    DefaultExt = 'FDB'
    FileName = 'MEASURECONTROL.FDB'
    Filter = 'firebird database file (*.fdb)|*.FDB|any file (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = #1042#1099#1073#1077#1088#1080#1090#1077' '#1092#1072#1081#1083' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
    Left = 256
    Top = 9
  end
end
