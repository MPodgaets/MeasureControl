object frmUser: TfrmUser
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'frmUser'
  ClientHeight = 108
  ClientWidth = 365
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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pBottom: TPanel
    Left = 0
    Top = 71
    Width = 365
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TButton
      Left = 80
      Top = 6
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 365
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 72
      Height = 13
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100
    end
    object Label2: TLabel
      Left = 8
      Top = 40
      Width = 37
      Height = 13
      Caption = #1055#1072#1088#1086#1083#1100
    end
    object Label3: TLabel
      Left = 8
      Top = 96
      Width = 19
      Height = 13
      Caption = #1048#1084#1103
      Visible = False
    end
    object Label4: TLabel
      Left = 8
      Top = 124
      Width = 49
      Height = 13
      Caption = #1054#1090#1095#1077#1089#1090#1074#1086
      Visible = False
    end
    object Label6: TLabel
      Left = 8
      Top = 68
      Width = 44
      Height = 13
      Caption = #1060#1072#1084#1080#1083#1080#1103
      Visible = False
    end
    object eUser: TEdit
      Left = 96
      Top = 8
      Width = 200
      Height = 21
      TabOrder = 0
    end
    object ePassword: TEdit
      Left = 96
      Top = 36
      Width = 200
      Height = 21
      TabOrder = 1
    end
    object eLastName: TEdit
      Left = 96
      Top = 64
      Width = 200
      Height = 21
      TabOrder = 2
      Visible = False
    end
    object eFirstName: TEdit
      Left = 96
      Top = 92
      Width = 200
      Height = 21
      TabOrder = 3
      Visible = False
    end
    object eMiddleName: TEdit
      Left = 96
      Top = 120
      Width = 200
      Height = 21
      TabOrder = 4
      Visible = False
    end
  end
end
