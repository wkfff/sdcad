object JingTanTongJiForm: TJingTanTongJiForm
  Left = 366
  Top = 311
  BorderStyle = bsDialog
  Caption = #38745#25506#32479#35745#21442#25968#34920
  ClientHeight = 216
  ClientWidth = 439
  Color = clBtnFace
  Constraints.MinHeight = 50
  Constraints.MinWidth = 130
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btn_cancel: TBitBtn
    Left = 266
    Top = 177
    Width = 82
    Height = 25
    Hint = #36820#22238
    Cancel = True
    Caption = #36820#22238
    ModalResult = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    Glyph.Data = {
      66010000424D6601000000000000760000002800000014000000140000000100
      040000000000F000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDDDD0000777777777777777DDDD7000077777777777777FDFD7700007777
      777777777F3F37770000444444077777FFF4444D0000DDDDD450777F3FF4DDDD
      0000DDDDD45507FFFFF4DDDD0000DDDDD45550FFFFF4DDDD0000DDD0045550FF
      FFF4DDDD0000DDD0A05550FFFFF4DDDD00000000EA0550FFFEF4DDDD00000EAE
      AEA050FFFFF4DDDD00000AEAEAEA00FEFEF4DDDD00000EAEAEA050FFFFF4DDDD
      00000000EA0550FEFEF4DDDD0000DDD0A05550EFEFE4DDDD0000DDD0045550FE
      FEF4DDDD0000DDDDD45550EFEFE4DDDD0000DDDDD44444444444DDDD0000DDDD
      DDDDDDDDDDDDDDDD0000}
  end
  object btn_Print: TBitBtn
    Left = 162
    Top = 177
    Width = 82
    Height = 25
    Caption = #25171#21360#39044#35272
    TabOrder = 1
    OnClick = btn_PrintClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      77777700000000000777707777777770707700000000000007070777777BBB77
      0007077777788877070700000000000007700777777777707070700000000007
      0700770FFFFFFFF070707770F00000F000077770FFFFFFFF077777770F00000F
      077777770FFFFFFFF07777777000000000777777777777777777}
  end
  object btnTongJi: TBitBtn
    Left = 58
    Top = 177
    Width = 82
    Height = 25
    Caption = #24320#22987#32479#35745
    TabOrder = 2
    OnClick = btnTongJiClick
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00337000000000
      73333337777777773F333308888888880333337F3F3F3FFF7F33330808089998
      0333337F737377737F333308888888880333337F3F3F3F3F7F33330808080808
      0333337F737373737F333308888888880333337F3F3F3F3F7F33330808080808
      0333337F737373737F333308888888880333337F3F3F3F3F7F33330808080808
      0333337F737373737F333308888888880333337F3FFFFFFF7F33330800000008
      0333337F7777777F7F333308000E0E080333337F7FFFFF7F7F33330800000008
      0333337F777777737F333308888888880333337F333333337F33330888888888
      03333373FFFFFFFF733333700000000073333337777777773333}
    NumGlyphs = 2
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 33
    Width = 409
    Height = 135
    Caption = #27880#24847#20107#39033
    Font.Charset = GB2312_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 360
      Height = 84
      Caption = 
        #22312#24320#22987#32479#35745#20043#21069#65292#35201#20808#36827#34892#22303#20998#26512#20998#23618#24635#34920#20013#30340#22303#26679#25968#25454#35745#31639#65292#13#10#21542#21017#32479#35745#32467#26524#20250#19981#27491#30830#12290#13#10#22914#26524#19979#21015#25968#25454#26377#25913#21464#65292#35831#37325#26032#36827#34892#32479#35745#65292#21542#21017#25171 +
        #21360#30340#25968#25454#20250#19981#27491#30830#12290#13#10'   1'#65306#38075#23380#30340#26631#39640#21644#28145#24230#65292#38075#23380#30340#21024#38500#12290#13#10'   2'#65306#24037#31243#30340#22303#23618#25968#25454#12290#13#10'   3'#65306#38075#23380#30340#20998#23618#25968#25454#12290' '#13#10 +
        '   4'#65306#38745#21147#35302#25506#25968#25454#12290
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
  end
  object frReport1: TfrReport
    InitialZoom = pzDefault
    PreviewButtons = [pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbHelp, pbExit]
    ReportType = rtMultiple
    RebuildPrinter = False
    OnGetValue = frReport1GetValue
    Left = 284
    Top = 80
    ReportForm = {19000000}
  end
  object frDBTeZhengShu: TfrDBDataSet
    DataSource = DSTeZhengShu
    Left = 316
    Top = 136
  end
  object DSTeZhengShu: TDataSource
    DataSet = tblTeZhengShu
    Left = 316
    Top = 104
  end
  object DSSampleValue: TDataSource
    DataSet = tblSampleValue
    Left = 356
    Top = 104
  end
  object frDBSampleValue: TfrDBDataSet
    DataSource = DSSampleValue
    Left = 356
    Top = 136
  end
  object DSStratumMaster: TDataSource
    DataSet = qryStratum
    Left = 396
    Top = 104
  end
  object frDBStratumMaster: TfrDBDataSet
    DataSource = DSStratumMaster
    Left = 396
    Top = 136
  end
  object tblTeZhengShu: TADOTable
    CacheSize = 500
    Connection = MainDataModule.ADOConnection1
    MasterSource = DSStratumMaster
    TableDirect = True
    Left = 316
    Top = 64
  end
  object tblSampleValue: TADOTable
    CacheSize = 500
    Connection = MainDataModule.ADOConnection1
    MasterSource = DSStratumMaster
    TableDirect = True
    Left = 356
    Top = 64
  end
  object qryStratum: TADOQuery
    Connection = MainDataModule.ADOConnection1
    Parameters = <>
    Left = 396
    Top = 64
  end
end
