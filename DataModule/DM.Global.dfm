object DMGlobal: TDMGlobal
  Height = 250
  Width = 374
  object DM: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=sysdba'
      'Password=masterkey')
    BeforeConnect = DMBeforeConnect
    Left = 64
    Top = 56
  end
  object DriverLink: TFDPhysFBDriverLink
    Left = 160
    Top = 56
  end
end