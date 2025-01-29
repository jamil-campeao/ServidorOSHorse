object DMGlobal: TDMGlobal
  OnCreate = DataModuleCreate
  Height = 158
  Width = 171
  object DM: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    BeforeConnect = DMBeforeConnect
    Left = 40
    Top = 32
  end
  object DriverLink: TFDPhysFBDriverLink
    Left = 104
    Top = 32
  end
end
