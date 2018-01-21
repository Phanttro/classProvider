object DMPrincipal: TDMPrincipal
  OldCreateOrder = False
  Height = 394
  Width = 568
  object FDConnection1: TFDConnection
    Params.Strings = (
      'DriverID=Ora')
    LoginPrompt = False
    Left = 504
    Top = 616
  end
  object SQLConnection: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Database=C:\Sistemas\RV2\DB\MASTER.FDB'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Left = 184
    Top = 16
  end
end
