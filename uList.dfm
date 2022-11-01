object frmList: TfrmList
  Left = 0
  Top = 0
  Caption = #1057#1095#1077#1090#1095#1080#1082#1080' '#1089' '#1080#1089#1090#1077#1082#1096#1080#1084' '#1089#1088#1086#1082#1086#1084' '#1087#1086#1074#1077#1088#1082#1080
  ClientHeight = 261
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object dbgList: TDBGrid
    Left = 0
    Top = 57
    Width = 584
    Height = 204
    Align = alClient
    DataSource = dsNotVerificMeasurers
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'FLAT_NUMBER'
        Title.Caption = #1053#1086#1084#1077#1088' '#1082#1074#1072#1088#1090#1080#1088#1099
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FACTORY_NUMBER'
        Title.Caption = #1047#1072#1074#1086#1076#1089#1082#1086#1081' '#1085#1086#1084#1077#1088
        Width = 200
        Visible = True
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 584
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 35
      Width = 31
      Height = 13
      Caption = #1059#1083#1080#1094#1072
    end
    object Label2: TLabel
      Left = 336
      Top = 35
      Width = 59
      Height = 13
      Caption = #1053#1086#1084#1077#1088' '#1076#1086#1084#1072
    end
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 473
      Height = 13
      Caption = 
        #1044#1083#1103' '#1087#1086#1083#1091#1095#1077#1085#1080#1103' '#1089#1087#1080#1089#1082#1072' '#1089#1095#1077#1090#1095#1080#1082#1086#1074' '#1089' '#1080#1089#1090#1077#1082#1096#1080#1084' '#1089#1088#1086#1082#1086#1084' '#1087#1086#1074#1077#1088#1082#1080' '#1074#1099#1073#1077#1088#1080#1090 +
        #1077' '#1091#1083#1080#1094#1091' '#1080' '#1085#1086#1084#1077#1088' '#1076#1086#1084#1072'.'
    end
    object cbStreets: TComboBox
      Left = 50
      Top = 31
      Width = 265
      Height = 21
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbStreetsChange
    end
    object cbHouse_numbers: TComboBox
      Left = 401
      Top = 31
      Width = 65
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
    object btShowList: TButton
      Left = 488
      Top = 27
      Width = 75
      Height = 25
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100
      TabOrder = 2
      OnClick = btShowListClick
    end
  end
  object qNotVerificMeasurers: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 216
    Top = 112
  end
  object dsNotVerificMeasurers: TDataSource
    DataSet = qNotVerificMeasurers
    Left = 216
    Top = 176
  end
  object qStreets: TFDMemTable
    AfterOpen = qStreetsAfterOpen
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 88
    Top = 88
  end
  object qHouse_numbers: TFDMemTable
    AfterOpen = qHouse_numbersAfterOpen
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 88
    Top = 160
  end
end
