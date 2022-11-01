object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = #1059#1095#1077#1090' '#1087#1086#1082#1072#1079#1072#1085#1080#1081' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
  ClientHeight = 202
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = mmMeasureControl
  OldCreateOrder = False
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object sbLog: TStatusBar
    Left = 0
    Top = 183
    Width = 600
    Height = 19
    Panels = <
      item
        Width = 400
      end
      item
        Alignment = taRightJustify
        Width = 50
      end>
  end
  object alMeasureControl: TActionList
    Left = 168
    Top = 8
    object aDBSettings: TAction
      Category = 'Command'
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1089#1086#1077#1076#1080#1085#1077#1085#1080#1103' '#1089' '#1041#1044
      OnExecute = aDBSettingsExecute
    end
    object aMeasurers: TAction
      Category = 'Ref'
      Caption = #1057#1095#1077#1090#1095#1080#1082#1080
      OnExecute = aMeasurersExecute
    end
    object aMeasureValues: TAction
      Category = 'Ref'
      Caption = #1055#1086#1082#1072#1079#1072#1085#1080#1103' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
      OnExecute = aMeasureValuesExecute
    end
    object aFirstLoading: TAction
      Category = 'Command'
      Caption = #1055#1077#1088#1074#1086#1085#1072#1095#1072#1083#1100#1085#1072#1103' '#1079#1072#1075#1088#1091#1079#1082#1072
      Enabled = False
      OnExecute = aFirstLoadingExecute
    end
    object aShowLog: TAction
      Category = 'Command'
      Caption = #1046#1091#1088#1085#1072#1083' '#1086#1096#1080#1073#1086#1082
    end
    object aNotVerificMeasurers: TAction
      Category = 'Ref'
      Caption = #1057#1095#1077#1090#1095#1080#1082#1080' '#1089' '#1080#1089#1090#1077#1082#1096#1080#1084' '#1089#1088#1086#1082#1086#1084' '#1087#1086#1074#1077#1088#1082#1080
      OnExecute = aNotVerificMeasurersExecute
    end
    object aFlats: TAction
      Category = 'Ref'
      Caption = #1050#1074#1072#1088#1090#1080#1088#1099
    end
    object aChangeMeasurerHistory: TAction
      Category = 'Ref'
      AutoCheck = True
      Caption = #1048#1089#1090#1086#1088#1080#1103' '#1079#1072#1084#1077#1085' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
    end
    object aShowUsers: TAction
      Category = 'Command'
      Caption = #1055#1086#1082#1072#1079#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1077#1081
      OnExecute = aShowUsersExecute
    end
    object aCopyToClipboard: TAction
      Category = 'Command'
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100' '#1074' '#1073#1091#1092#1077#1088
    end
    object WindowClose1: TWindowClose
      Category = 'Window'
      Caption = 'C&lose'
      Enabled = False
      Hint = 'Close'
      OnExecute = WindowClose1Execute
    end
    object WindowCascade1: TWindowCascade
      Category = 'Window'
      Caption = '&Cascade'
      Enabled = False
      Hint = 'Cascade'
      ImageIndex = 17
      OnExecute = WindowCascade1Execute
    end
    object WindowTileHorizontal1: TWindowTileHorizontal
      Category = 'Window'
      Caption = 'Tile &Horizontally'
      Enabled = False
      Hint = 'Tile Horizontal'
      ImageIndex = 15
    end
    object WindowTileVertical1: TWindowTileVertical
      Category = 'Window'
      Caption = '&Tile Vertically'
      Enabled = False
      Hint = 'Tile Vertical'
      ImageIndex = 16
    end
    object WindowMinimizeAll1: TWindowMinimizeAll
      Category = 'Window'
      Caption = '&Minimize All'
      Enabled = False
      Hint = 'Minimize All'
      OnExecute = WindowMinimizeAll1Execute
    end
    object WindowArrange1: TWindowArrange
      Category = 'Window'
      Caption = '&Arrange'
      Enabled = False
      OnExecute = WindowArrange1Execute
    end
  end
  object mmMeasureControl: TMainMenu
    Left = 40
    Top = 8
    object aConnectDB1: TMenuItem
      Action = aDBSettings
    end
    object N1: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082#1080
      GroupIndex = 1
      object nMeasurers: TMenuItem
        Action = aMeasurers
        GroupIndex = 2
      end
    end
    object N4: TMenuItem
      Caption = #1044#1086#1082#1091#1084#1077#1085#1090#1099
      GroupIndex = 3
      object nMeasureValues: TMenuItem
        Action = aMeasureValues
        GroupIndex = 4
      end
      object nNotVerificMeasurers: TMenuItem
        Action = aNotVerificMeasurers
        GroupIndex = 5
      end
      object N7: TMenuItem
        Caption = '-'
        GroupIndex = 5
      end
      object nLog: TMenuItem
        Action = aShowLog
        GroupIndex = 5
      end
    end
    object nMenuEdit: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
      GroupIndex = 10
      Visible = False
      object nMenuEdit1: TMenuItem
        Caption = 'nMenuEdit1'
        GroupIndex = 10
        Visible = False
      end
      object nMenuEdit2: TMenuItem
        Caption = 'nMenuEdit2'
        GroupIndex = 10
        Visible = False
      end
      object nMenuEdit3: TMenuItem
        Caption = 'nMenuEdit3'
        GroupIndex = 10
        Visible = False
      end
    end
    object nUsers: TMenuItem
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
      GroupIndex = 10
      object nShowUsers: TMenuItem
        Action = aShowUsers
      end
      object nCreateUser: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      end
      object nModifyUser: TMenuItem
        Caption = #1048#1079#1084#1077#1085#1077#1085#1080#1090#1100' '#1087#1072#1088#1086#1083#1100
      end
      object nDeleteUser: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1103
      end
    end
    object N9: TMenuItem
      Action = aFirstLoading
      GroupIndex = 10
    end
  end
end
