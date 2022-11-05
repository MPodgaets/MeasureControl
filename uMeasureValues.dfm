object frmMeasureValues: TfrmMeasureValues
  Left = 0
  Top = 0
  Caption = #1055#1086#1082#1072#1079#1072#1085#1080#1103' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
  ClientHeight = 367
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  Menu = mmMeasureValues
  OldCreateOrder = False
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pData: TPanel
    Left = 0
    Top = 73
    Width = 614
    Height = 294
    Align = alClient
    TabOrder = 0
    object Splitter2: TSplitter
      Left = 333
      Top = 1
      Height = 292
      Align = alRight
      ExplicitLeft = 320
      ExplicitTop = 160
      ExplicitHeight = 100
    end
    object PMeasurers: TPanel
      Left = 336
      Top = 1
      Width = 277
      Height = 292
      Align = alRight
      TabOrder = 0
      object Splitter3: TSplitter
        Left = 1
        Top = 186
        Width = 275
        Height = 3
        Cursor = crVSplit
        Align = alBottom
        ExplicitTop = 1
        ExplicitWidth = 151
      end
      object gbMeasureValue: TGroupBox
        Left = 1
        Top = 1
        Width = 275
        Height = 185
        Align = alClient
        Caption = #1055#1086#1082#1072#1079#1072#1085#1080#1103' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
        TabOrder = 0
        object dbgMeasureValue: TDBGrid
          Left = 2
          Top = 15
          Width = 271
          Height = 168
          Align = alClient
          DataSource = dsMeasureValue
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -11
          TitleFont.Name = 'Tahoma'
          TitleFont.Style = []
          Columns = <
            item
              Expanded = False
              FieldName = 'factory_number'
              Title.Caption = #1047#1072#1074#1086#1076#1089#1082#1086#1081' '#1085#1086#1084#1077#1088
              Width = 97
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'measure_date'
              Title.Caption = #1044#1072#1090#1072
              Width = 51
              Visible = True
            end
            item
              Expanded = False
              FieldName = 'measure_value'
              Title.Caption = #1047#1085#1072#1095#1077#1085#1080#1077' '#1089#1095#1077#1090#1095#1080#1082#1072
              Width = 100
              Visible = True
            end>
        end
      end
      object pHistory: TPanel
        Left = 1
        Top = 189
        Width = 275
        Height = 102
        Align = alBottom
        BevelOuter = bvNone
        Caption = 'pHistory'
        TabOrder = 1
        Visible = False
        object gbHistory: TGroupBox
          Left = 0
          Top = 0
          Width = 275
          Height = 102
          Align = alClient
          Caption = #1048#1089#1090#1086#1088#1080#1103' '#1079#1072#1084#1077#1085' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
          TabOrder = 0
          object dbgHistory: TDBGrid
            Left = 2
            Top = 15
            Width = 271
            Height = 85
            Align = alClient
            DataSource = dsChangeMeasureHistory
            TabOrder = 0
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'Tahoma'
            TitleFont.Style = []
            Columns = <
              item
                Expanded = False
                FieldName = 'FACTORY$NUMBER'
                Title.Caption = #1047#1072#1074#1086#1076#1089#1082#1086#1081' '#1085#1086#1084#1077#1088
                Width = 123
                Visible = True
              end
              item
                Expanded = False
                FieldName = 'DATE$INSTALL'
                Title.Caption = #1044#1072#1090#1072' '#1091#1089#1090#1072#1085#1086#1074#1082#1080
                Width = 112
                Visible = True
              end>
          end
        end
      end
    end
    object pFlats: TPanel
      Left = 1
      Top = 1
      Width = 332
      Height = 292
      Align = alClient
      Caption = 'pFlats'
      TabOrder = 1
      object dbgFlats: TDBGrid
        Left = 1
        Top = 1
        Width = 330
        Height = 290
        Align = alClient
        DataSource = dsFlats
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        PopupMenu = pmMeasureValues
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'STREET'
            Title.Caption = #1059#1083#1080#1094#1072
            Width = 149
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'HOUSE_NUMBER'
            Title.Caption = #1053#1086#1084#1077#1088' '#1076#1086#1084#1072
            Width = 70
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'FLAT_NUMBER'
            Title.Caption = #1053#1086#1084#1077#1088' '#1082#1074#1072#1088#1090#1080#1088#1099
            Width = 89
            Visible = True
          end>
      end
    end
  end
  object gbAddress: TGroupBox
    Left = 0
    Top = 0
    Width = 614
    Height = 73
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
    object bUpdate: TButton
      Left = 357
      Top = 26
      Width = 75
      Height = 25
      Caption = #1054#1073#1085#1086#1074#1080#1090#1100
      TabOrder = 0
      OnClick = bUpdateClick
    end
    object eHouse_number: TEdit
      Left = 50
      Top = 48
      Width = 65
      Height = 21
      TabOrder = 1
      OnKeyPress = eHouse_numberKeyPress
    end
    object eStreet: TEdit
      Left = 50
      Top = 20
      Width = 265
      Height = 21
      TabOrder = 2
    end
  end
  object pmMeasureValues: TPopupMenu
    Left = 65
    Top = 145
    object N1: TMenuItem
      Caption = #1042#1074#1086#1076' '#1087#1086#1082#1072#1079#1072#1085#1080#1081' '#1089#1095#1077#1090#1095#1080#1082#1072
    end
    object N2: TMenuItem
      Caption = #1047#1072#1084#1077#1085#1080#1090#1100' '#1089#1095#1077#1090#1095#1080#1082
    end
    object N3: TMenuItem
      Action = frmMain.aChangeMeasurerHistory
      AutoCheck = True
    end
  end
  object dsFlats: TDataSource
    DataSet = qFlats
    Left = 152
    Top = 208
  end
  object qFlats: TFDMemTable
    AfterScroll = qFlatsAfterScroll
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 152
    Top = 144
  end
  object alMeasureValues: TActionList
    Left = 233
    Top = 146
    object aInsertMeasureValue: TAction
      Caption = #1042#1074#1086#1076' '#1087#1086#1082#1072#1079#1072#1085#1080#1081' '#1089#1095#1077#1090#1095#1080#1082#1072
      Hint = #1042#1074#1086#1076' '#1087#1086#1082#1072#1079#1072#1085#1080#1081' '#1090#1077#1082#1091#1097#1077#1075#1086' '#1089#1095#1077#1090#1095#1080#1082#1072' '#1074' '#1074#1099#1073#1088#1072#1085#1085#1086#1081' '#1082#1074#1072#1088#1090#1080#1088#1077
      ShortCut = 16457
      OnExecute = aInsertMeasureValueExecute
    end
    object aChangeMeasurerHistory: TAction
      AutoCheck = True
      Caption = #1048#1089#1090#1086#1088#1080#1103' '#1079#1072#1084#1077#1085' '#1089#1095#1077#1090#1095#1080#1082#1086#1074
      Hint = #1055#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1080#1089#1090#1086#1088#1080#1102' '#1080#1079#1084#1077#1085#1077#1085#1080#1081
      ShortCut = 16456
      OnExecute = aChangeMeasurerHistoryExecute
    end
    object aChangeMeasurer: TAction
      Caption = #1047#1072#1084#1077#1085#1080#1090#1100' '#1089#1095#1077#1090#1095#1080#1082
      Hint = #1047#1072#1084#1077#1085#1072' '#1089#1095#1077#1090#1095#1080#1082#1072' '#1074' '#1074#1099#1073#1088#1072#1085#1085#1086#1081' '#1082#1074#1072#1088#1090#1080#1088#1077
      ShortCut = 16461
      OnExecute = aChangeMeasurerExecute
    end
  end
  object mmMeasureValues: TMainMenu
    Left = 241
    Top = 210
    object nEdit: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
      GroupIndex = 10
      object N4: TMenuItem
        Action = aInsertMeasureValue
        GroupIndex = 10
      end
      object N5: TMenuItem
        Action = aChangeMeasurer
        GroupIndex = 10
      end
      object N6: TMenuItem
        Action = aChangeMeasurerHistory
        AutoCheck = True
        GroupIndex = 10
      end
    end
  end
  object dsMeasureValue: TDataSource
    DataSet = qMeasureValue
    Left = 520
    Top = 136
  end
  object qMeasureValue: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 424
    Top = 136
  end
  object dsChangeMeasureHistory: TDataSource
    DataSet = qChangeMeasureHistory
    Left = 528
    Top = 312
  end
  object qChangeMeasureHistory: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 392
    Top = 312
  end
  object qProcResult: TFDMemTable
    AfterScroll = qProcResultAfterScroll
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 40
    Top = 216
  end
end
