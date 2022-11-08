object frmMeasureValue: TfrmMeasureValue
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1042#1074#1086#1076' '#1087#1086#1082#1072#1079#1072#1085#1080#1081' '#1089#1095#1077#1090#1095#1080#1082#1072
  ClientHeight = 208
  ClientWidth = 341
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
  PixelsPerInch = 96
  TextHeight = 13
  object gbAddress: TGroupBox
    Left = 0
    Top = 0
    Width = 341
    Height = 73
    Align = alTop
    Caption = ' '#1040#1076#1088#1077#1089' '
    TabOrder = 0
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
  object GroupBox1: TGroupBox
    Left = 0
    Top = 73
    Width = 341
    Height = 49
    Align = alTop
    Caption = #1055#1088#1077#1076#1099#1076#1091#1097#1080#1077' '#1087#1086#1082#1072#1079#1072#1085#1080#1103' '#1089#1095#1077#1090#1095#1080#1082#1072' '
    TabOrder = 1
    object Label4: TLabel
      Left = 6
      Top = 24
      Width = 26
      Height = 13
      Caption = #1044#1072#1090#1072
    end
    object Label5: TLabel
      Left = 152
      Top = 24
      Width = 48
      Height = 13
      Caption = #1047#1085#1072#1095#1077#1085#1080#1077
    end
    object dbeOldValue: TDBEdit
      Left = 208
      Top = 20
      Width = 121
      Height = 21
      DataField = 'measure_value'
      TabOrder = 0
    end
    object dbeOldDate: TDBEdit
      Left = 48
      Top = 20
      Width = 83
      Height = 21
      DataField = 'measure_date'
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 122
    Width = 341
    Height = 49
    Align = alTop
    Caption = #1053#1086#1074#1099#1077' '#1087#1086#1082#1072#1079#1072#1085#1080#1103' '#1089#1095#1077#1090#1095#1080#1082#1072' '
    TabOrder = 2
    object Label6: TLabel
      Left = 6
      Top = 24
      Width = 26
      Height = 13
      Caption = #1044#1072#1090#1072
    end
    object Label7: TLabel
      Left = 152
      Top = 24
      Width = 48
      Height = 13
      Caption = #1047#1085#1072#1095#1077#1085#1080#1077
    end
    object eMeasureValue: TEdit
      Left = 208
      Top = 20
      Width = 122
      Height = 21
      TabOrder = 0
    end
    object eMeasureDate: TDateTimePicker
      Left = 48
      Top = 20
      Width = 83
      Height = 21
      Date = 44815.000000000000000000
      Time = 0.002914097225584555
      TabOrder = 1
    end
  end
  object btOK: TButton
    Left = 56
    Top = 177
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btOKClick
  end
  object btCancel: TButton
    Left = 208
    Top = 177
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 4
    OnClick = btCancelClick
  end
end
