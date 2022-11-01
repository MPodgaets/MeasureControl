object frmDM: TfrmDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 135
  Width = 423
  object fdcMeasureControl: TFDConnection
    Params.Strings = (
      'Database=D:\DB\MEASURECONTROL.FDB'
      'Protocol=TCPIP'
      'Server=127.0.0.1'
      'CharacterSet=WIN1251'
      'User_Name=sysdba'
      'Password=sa123'
      'DriverID=FB'
      'SQLDialect=3')
    Left = 40
    Top = 8
  end
  object fbSecurity: TFDIBSecurity
    DriverLink = FBServerDriverLink
    Protocol = ipTCPIP
    Host = '127.0.0.1'
    Left = 24
    Top = 80
  end
  object fdUsers: TFDMemTable
    AfterOpen = fdUsersAfterOpen
    FieldDefs = <
      item
        Name = 'username'
        DataType = ftString
        Size = 50
      end
      item
        Name = 'password'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'lastname'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'firstname'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'middlename'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'rolename'
        DataType = ftString
        Size = 30
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 272
    Top = 8
  end
  object dsUsers: TDataSource
    DataSet = fdUsers
    Left = 272
    Top = 80
  end
  object fdConnectManager: TFDManager
    ConnectionDefFileName = 'D:\Source\MeasureControl\Win32\Debug\FDConnectionDefs.ini'
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 152
    Top = 80
  end
  object FBServerDriverLink: TFDPhysFBDriverLink
    DriverID = 'FBServer'
    Left = 152
    Top = 8
  end
end
