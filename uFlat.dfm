object frmFlats: TfrmFlats
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1050#1074#1072#1088#1090#1080#1088#1072
  ClientHeight = 265
  ClientWidth = 464
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object pBottom: TPanel
    Left = 0
    Top = 228
    Width = 464
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TButton
      Left = 96
      Top = 8
      Width = 75
      Height = 25
      Action = alChangeMeasurer
      Default = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
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
  object gbAddress: TGroupBox
    Left = 0
    Top = 0
    Width = 464
    Height = 78
    Align = alTop
    Caption = ' '#1040#1076#1088#1077#1089' '
    TabOrder = 1
    object Label1: TLabel
      Left = 6
      Top = 24
      Width = 31
      Height = 13
      Caption = #1059#1083#1080#1094#1072
    end
    object Label2: TLabel
      Left = 6
      Top = 50
      Width = 20
      Height = 13
      Caption = #1044#1086#1084
    end
    object Label3: TLabel
      Left = 152
      Top = 50
      Width = 49
      Height = 13
      Caption = #1050#1074#1072#1088#1090#1080#1088#1072
    end
    object dbeStreet: TDBEdit
      Left = 48
      Top = 20
      Width = 281
      Height = 21
      DataField = 'STREET'
      ReadOnly = True
      TabOrder = 0
    end
    object dbeHouse: TDBEdit
      Left = 46
      Top = 48
      Width = 85
      Height = 21
      DataField = 'HOUSE_NUMBER'
      ReadOnly = True
      TabOrder = 1
    end
    object dbeFlat: TDBEdit
      Left = 216
      Top = 46
      Width = 67
      Height = 21
      DataField = 'FLAT_NUMBER'
      ReadOnly = True
      TabOrder = 2
    end
  end
  object gbMeasurer: TGroupBox
    Left = 0
    Top = 78
    Width = 464
    Height = 78
    Align = alTop
    Caption = #1057#1090#1072#1088#1099#1081' '#1089#1095#1077#1090#1095#1080#1082
    TabOrder = 2
    object Label4: TLabel
      Left = 150
      Top = 20
      Width = 87
      Height = 13
      Caption = #1047#1072#1074#1086#1076#1089#1082#1086#1081' '#1085#1086#1084#1077#1088
    end
    object cbFactory_numbers: TComboBox
      Left = 255
      Top = 16
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object rbChange: TRadioButton
      Tag = 1
      Left = 8
      Top = 20
      Width = 113
      Height = 17
      Caption = #1047#1072#1084#1077#1085#1072' '#1089#1095#1077#1090#1095#1080#1082#1072
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object rbNew: TRadioButton
      Tag = 1
      Left = 8
      Top = 48
      Width = 113
      Height = 17
      Caption = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077
      TabOrder = 2
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 156
    Width = 464
    Height = 75
    Align = alTop
    Caption = #1053#1086#1074#1099#1081' '#1089#1095#1077#1090#1095#1080#1082
    TabOrder = 3
    object Label5: TLabel
      Left = 10
      Top = 20
      Width = 87
      Height = 13
      Caption = #1047#1072#1074#1086#1076#1089#1082#1086#1081' '#1085#1086#1084#1077#1088
    end
    object Label7: TLabel
      Left = 10
      Top = 48
      Width = 54
      Height = 13
      Caption = #1055#1086#1082#1072#1079#1072#1085#1080#1103
    end
    object eFactory_Number: TEdit
      Left = 113
      Top = 16
      Width = 200
      Height = 21
      TabOrder = 0
    end
    object btnMeasurer: TButton
      Left = 320
      Top = 14
      Width = 25
      Height = 25
      Action = alChoiсeMeasurer
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object eMeasureValue: TEdit
      Left = 113
      Top = 43
      Width = 122
      Height = 21
      TabOrder = 2
    end
  end
  object qProcResult: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 384
    Top = 24
  end
  object alFlat: TActionList
    Left = 400
    Top = 166
    object alChoiсeMeasurer: TAction
      Caption = ' ... '
      Hint = #1042#1099#1073#1086#1088' '#1089#1074#1086#1073#1086#1076#1085#1086#1075#1086' '#1089#1095#1077#1090#1095#1080#1082#1072' '#1076#1083#1103' '#1091#1089#1090#1072#1085#1086#1074#1082#1080' '#1074' '#1082#1074#1072#1088#1090#1080#1088#1077
      OnExecute = alChoiсeMeasurerExecute
    end
    object alChangeMeasurer: TAction
      Caption = 'OK'
      Hint = #1047#1072#1084#1077#1085#1072' '#1089#1095#1077#1090#1095#1080#1082#1072
      OnExecute = alChangeMeasurerExecute
    end
  end
end
