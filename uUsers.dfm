object frmUsers: TfrmUsers
  Left = 0
  Top = 0
  Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
  ClientHeight = 249
  ClientWidth = 412
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  Menu = mmUsers
  OldCreateOrder = False
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object fbgUsers: TDBGrid
    Left = 0
    Top = 0
    Width = 412
    Height = 249
    Align = alClient
    DataSource = frmDM.dsUsers
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    PopupMenu = pmUsers
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object pmUsers: TPopupMenu
    Left = 152
    Top = 32
    object N1: TMenuItem
      Action = CreateUser
    end
    object N2: TMenuItem
      Action = ModifyUser
    end
    object N3: TMenuItem
      Action = DeleteUser
    end
  end
  object mmUsers: TMainMenu
    Left = 296
    Top = 56
    object nEdit: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
      GroupIndex = 10
      object nInsertUser: TMenuItem
        Action = CreateUser
        GroupIndex = 10
      end
      object nModifyUser: TMenuItem
        Action = ModifyUser
        GroupIndex = 10
      end
      object nDeleteUser: TMenuItem
        Action = DeleteUser
        GroupIndex = 10
      end
    end
  end
  object alUsers: TActionList
    Left = 296
    Top = 120
    object CreateUser: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      Hint = #1057#1086#1079#1076#1072#1085#1080#1077' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103' '#1074' Security4.fdb '
      ShortCut = 16469
      OnExecute = CreateUserExecute
    end
    object ModifyUser: TAction
      Caption = #1048#1079#1084#1077#1085#1077#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100
      Hint = #1048#1079#1084#1077#1085#1077#1085#1080#1077' '#1087#1072#1088#1086#1083#1103' '#1074#1099#1073#1088#1072#1085#1085#1086#1075#1086' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      ShortCut = 16464
      OnExecute = ModifyUserExecute
    end
    object DeleteUser: TAction
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      Hint = #1059#1076#1072#1083#1077#1085#1080#1077' '#1074#1099#1073#1088#1072#1085#1085#1086#1075#1086' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      ShortCut = 16452
      OnExecute = DeleteUserExecute
    end
  end
end
