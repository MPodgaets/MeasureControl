object frmMeasurers: TfrmMeasurers
  Left = 0
  Top = 0
  Caption = #1057#1095#1077#1090#1095#1080#1082#1080
  ClientHeight = 332
  ClientWidth = 546
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  Menu = mmMeasures
  OldCreateOrder = False
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object dbgMeasurers: TDBGrid
    Left = 0
    Top = 105
    Width = 546
    Height = 191
    Align = alClient
    DataSource = dsMeasurers
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
    PopupMenu = pmMeasurers
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'FACTORY_NUMBER'
        Title.Caption = #1047#1072#1074#1086#1076#1089#1082#1086#1081' '#1085#1086#1084#1077#1088
        Width = 161
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'CHECK_DATE'
        Title.Caption = #1044#1072#1090#1072' '#1087#1086#1074#1077#1088#1082#1080
        Width = 125
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NEXT_CHECK_DATE'
        Title.Caption = #1044#1072#1090#1072' '#1089#1083#1077#1076#1091#1102#1097#1077#1081' '#1087#1086#1074#1077#1088#1082#1080
        Width = 159
        Visible = True
      end>
  end
  object gbFilter: TGroupBox
    Left = 0
    Top = 0
    Width = 546
    Height = 105
    Align = alTop
    Caption = '  '#1060#1080#1083#1100#1090#1088#1086#1074#1072#1090#1100' '#1087#1086'  '
    TabOrder = 1
    object Label6: TLabel
      Left = 245
      Top = 52
      Width = 12
      Height = 13
      Caption = #1087#1086
    end
    object Label7: TLabel
      Left = 305
      Top = 80
      Width = 12
      Height = 13
      Caption = #1087#1086
    end
    object cbFactory_number: TCheckBox
      Left = 8
      Top = 24
      Width = 137
      Height = 17
      Caption = #1079#1072#1074#1086#1076#1089#1082#1086#1084#1091' '#1085#1086#1084#1077#1088#1091
      TabOrder = 0
      OnClick = cbFactory_numberClick
    end
    object cbCheck_Date: TCheckBox
      Left = 8
      Top = 52
      Width = 113
      Height = 17
      Caption = #1076#1072#1090#1077' '#1087#1086#1074#1077#1088#1082#1080'  c'
      TabOrder = 1
      OnClick = cbCheck_DateClick
    end
    object cbNext_Check_Date: TCheckBox
      Left = 8
      Top = 80
      Width = 170
      Height = 17
      Caption = #1076#1072#1090#1077' '#1089#1083#1077#1076#1091#1102#1097#1077#1081' '#1087#1086#1074#1077#1088#1082#1080'  c'
      TabOrder = 2
      OnClick = cbNext_Check_DateClick
    end
    object eFactory_number: TEdit
      Left = 160
      Top = 20
      Width = 275
      Height = 21
      Enabled = False
      TabOrder = 3
    end
    object eBCheck_Date: TDateTimePicker
      Left = 120
      Top = 50
      Width = 105
      Height = 21
      Date = 44814.000000000000000000
      Time = 44814.000000000000000000
      Enabled = False
      TabOrder = 4
      OnChange = eBCheck_DateChange
    end
    object eECheck_date: TDateTimePicker
      Left = 270
      Top = 50
      Width = 105
      Height = 21
      Date = 44814.000000000000000000
      Time = 0.492749189812457200
      Enabled = False
      TabOrder = 5
    end
    object eBNext_Check_Date: TDateTimePicker
      Left = 180
      Top = 78
      Width = 105
      Height = 21
      Date = 44814.000000000000000000
      Time = 0.493295694446715100
      Enabled = False
      TabOrder = 6
      OnChange = eBNext_Check_DateChange
    end
    object eENext_Check_date: TDateTimePicker
      Left = 330
      Top = 78
      Width = 105
      Height = 21
      Date = 44814.000000000000000000
      Time = 0.493295694446715100
      Enabled = False
      TabOrder = 7
    end
    object bUpdate: TButton
      Left = 441
      Top = 47
      Width = 75
      Height = 25
      Action = alUpdate
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 296
    Width = 546
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    Visible = False
    object btnOK: TButton
      Left = 103
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 330
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object pmMeasurers: TPopupMenu
    Left = 32
    Top = 168
    object nInsert: TMenuItem
      Action = aInsertMeasurer
    end
    object nCopy: TMenuItem
      Action = EditCopyMeasurers
    end
  end
  object qMeasurers: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 222
    Top = 152
  end
  object dsMeasurers: TDataSource
    DataSet = qMeasurers
    Left = 206
    Top = 224
  end
  object qProcResult: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 144
    Top = 184
  end
  object mmMeasures: TMainMenu
    Left = 376
    Top = 152
    object nEdit: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
      GroupIndex = 10
      object nInsertMeasurer: TMenuItem
        Action = aInsertMeasurer
        GroupIndex = 10
      end
      object nCopyMeasurers: TMenuItem
        Action = EditCopyMeasurers
        GroupIndex = 10
      end
      object nUpdateMeasurers: TMenuItem
        Action = alUpdate
        GroupIndex = 10
      end
    end
  end
  object alMeasurers: TActionList
    Left = 368
    Top = 224
    object aInsertMeasurer: TAction
      Category = 'Edit'
      Caption = '&'#1053#1086#1074#1099#1081' '#1089#1095#1077#1090#1095#1080#1082
      ShortCut = 16462
      OnExecute = aInsertMeasurerExecute
    end
    object alUpdate: TAction
      Caption = '&'#1054#1073#1085#1086#1074#1080#1090#1100
      Hint = #1054#1073#1085#1086#1074#1083#1077#1085#1080#1077' '#1089#1087#1080#1089#1082#1072' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
      ShortCut = 16469
      OnExecute = alUpdateExecute
    end
    object EditCopyMeasurers: TEditCopy
      Category = 'Edit'
      Caption = '&'#1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      Hint = 
        #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100'|'#1050#1086#1087#1080#1088#1091#1077#1090' '#1074#1099#1073#1088#1072#1085#1085#1099#1077' '#1089#1090#1088#1086#1082#1080' '#1080' '#1087#1086#1084#1077#1097#1072#1077#1090' '#1080#1093' '#1074' '#1075#1083#1086#1073#1072#1083#1100#1085#1099#1081' ' +
        #1073#1091#1092#1077#1088
      ImageIndex = 1
      ShortCut = 16451
      OnExecute = EditCopyMeasurersExecute
    end
  end
end
