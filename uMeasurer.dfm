object frmMeasurer: TfrmMeasurer
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1057#1095#1077#1090#1095#1080#1082
  ClientHeight = 138
  ClientWidth = 382
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
  object pBottom: TPanel
    Left = 0
    Top = 102
    Width = 382
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TButton
      Left = 48
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 232
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 382
    Height = 102
    Align = alClient
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 87
      Height = 13
      Caption = #1047#1072#1074#1086#1076#1089#1082#1086#1081' '#1085#1086#1084#1077#1088
    end
    object Label2: TLabel
      Left = 8
      Top = 40
      Width = 71
      Height = 13
      Caption = #1044#1072#1090#1072' '#1087#1086#1074#1077#1088#1082#1080
    end
    object Label3: TLabel
      Left = 8
      Top = 68
      Width = 134
      Height = 13
      Caption = #1044#1072#1090#1072' '#1089#1083#1077#1076#1091#1102#1097#1077#1081' '#1087#1086#1074#1077#1088#1082#1080
    end
    object eFactory_number: TEdit
      Left = 184
      Top = 8
      Width = 163
      Height = 21
      TabOrder = 0
    end
    object dCheck_date: TDateTimePicker
      Left = 184
      Top = 36
      Width = 163
      Height = 21
      Date = 44815.000000000000000000
      Time = 0.002914097225584555
      TabOrder = 1
      OnChange = dCheck_dateChange
    end
    object dNext_Check_Date: TDateTimePicker
      Left = 184
      Top = 64
      Width = 163
      Height = 21
      Date = 44815.000000000000000000
      Time = 0.002957222219265532
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
  end
end
