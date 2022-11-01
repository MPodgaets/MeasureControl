object dlgPassword: TdlgPassword
  Left = 245
  Top = 108
  BorderStyle = bsDialog
  Caption = #1040#1074#1090#1086#1088#1080#1079#1072#1094#1080#1103
  ClientHeight = 120
  ClientWidth = 327
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = True
  Position = poMainFormCenter
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 32
    Width = 72
    Height = 13
    Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
  end
  object Label2: TLabel
    Left = 8
    Top = 60
    Width = 37
    Height = 13
    Caption = #1055#1072#1088#1086#1083#1100
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 221
    Height = 13
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '#1080' '#1074#1074#1077#1076#1080#1090#1077' '#1087#1072#1088#1086#1083#1100' '
  end
  object OKBtn: TButton
    Left = 62
    Top = 88
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 182
    Top = 88
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    OnClick = CancelBtnClick
  end
  object ePassword: TEdit
    Left = 104
    Top = 56
    Width = 217
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
  end
  object cbUserName: TComboBox
    Left = 104
    Top = 28
    Width = 217
    Height = 21
    Style = csDropDownList
    TabOrder = 0
  end
end
