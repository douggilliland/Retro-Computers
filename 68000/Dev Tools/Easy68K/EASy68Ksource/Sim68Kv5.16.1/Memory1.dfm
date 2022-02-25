object MemoryFrm: TMemoryFrm
  Left = 626
  Top = 386
  Width = 640
  Height = 450
  Cursor = crIBeam
  Caption = '68000 Memory'
  Color = clWhite
  Constraints.MaxWidth = 640
  Constraints.MinHeight = 200
  Constraints.MinWidth = 200
  DefaultMonitor = dmDesktop
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Courier New'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000888807000000000000000000000000008888070000000000000000
    0000070000888807000000000000000000080070008888070000807000000000
    0088800000888800000888070000000008888808888888888088888070000000
    0088888888888888888888070000000000088888888888888888807000000000
    0000888888000088888807000000000000008888807770088888070000000000
    0000888807000000888800000000000888888888070000008888888880700008
    8888888070000000088888888070000888888880700000000888888880700008
    8888888807000000888888888070000000008888070000008888000000000000
    0000888880777008888807000000000000008888880000888888070000000000
    0008888888888888888880700000000000888888888888888888880700000000
    0888880888888888808888807000000000888000008888000008880700000000
    0008007000888807000080700000000000000700008888070000000000000000
    0000000000888807000000000000000000000000008888070000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000FFFF
    FFFFFFF807FFFFF807FFFF3807FFFE18070FFC080607F8000003F0000003F800
    0007FC00000FFE00001FFE00001FC000E000C001E000C003F000C001E000C001
    E000C000C000FE00001FFE00000FFC000007F8000003F0000003F0000007F808
    060FFC18071FFF3807FFFFF807FFFFF807FFFFFFFFFFFFFFFFFFFFFFFFFF}
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnMouseDown = FormMouseDown
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 16
  object Panel2: TPanel
    Left = 592
    Top = 41
    Width = 32
    Height = 370
    Cursor = crArrow
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object Label2: TLabel
      Left = 0
      Top = 24
      Width = 21
      Height = 15
      Alignment = taCenter
      Caption = 'Row'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 1
      Top = 128
      Width = 28
      Height = 15
      Alignment = taCenter
      Caption = 'Page'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
    end
    object Label8: TLabel
      Left = 4
      Top = 248
      Width = 28
      Height = 15
      Alignment = taCenter
      Caption = 'Live'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
    end
    object RowSpin: TCSpinButton
      Left = 8
      Top = 48
      Width = 20
      Height = 49
      DownGlyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000C40E0000C40E00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
        3333333333307333333333333300033333333333330007333333333330000033
        3333333330000073333333330000000333333333000000073333333000000000
        3333333000000000733333000000000003333300000000000733300000000000
        0033300000000000007300000000000000030000000000000003}
      TabOrder = 0
      UpGlyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000C40E0000C40E00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
        0000300000000000000033000000000000073300000000000003333000000000
        0073333000000000003333330000000007333333000000000333333330000000
        7333333330000000333333333300000733333333330000033333333333300073
        3333333333300033333333333333073333333333333303333333}
      OnDownClick = RowSpinDownClick
      OnUpClick = RowSpinUpClick
    end
    object PageSpin: TCSpinButton
      Left = 8
      Top = 152
      Width = 20
      Height = 49
      DownGlyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000C40E0000C40E00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
        3333333333307333333333333300033333333333330007333333333330000033
        3333333330000073333333330000000333333333000000073333333000000000
        3333333000000000733333000000000003333300000000000733300000000000
        0033300000000000007300000000000000030000000000000003}
      TabOrder = 1
      UpGlyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        04000000000080000000C40E0000C40E00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
        0000300000000000000033000000000000073300000000000003333000000000
        0073333000000000003333330000000007333333000000000333333330000000
        7333333330000000333333333300000733333333330000033333333333300073
        3333333333300033333333333333073333333333333303333333}
      OnDownClick = PageSpinDownClick
      OnUpClick = PageSpinUpClick
    end
    object LiveCheckBox: TCheckBox
      Left = 8
      Top = 264
      Width = 17
      Height = 17
      TabOrder = 2
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 41
    Cursor = crArrow
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 13
      Top = 10
      Width = 65
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Caption = 'Address:'
      WordWrap = True
    end
    object Label4: TLabel
      Left = 80
      Top = 0
      Width = 40
      Height = 16
      Alignment = taCenter
      Caption = 'From:'
      WordWrap = True
    end
    object Label5: TLabel
      Left = 336
      Top = 0
      Width = 48
      Height = 16
      Alignment = taCenter
      Caption = 'Bytes:'
      WordWrap = True
    end
    object Label6: TLabel
      Left = 216
      Top = 0
      Width = 24
      Height = 16
      Alignment = taCenter
      Caption = 'To:'
      WordWrap = True
    end
    object Label7: TLabel
      Left = 80
      Top = 24
      Width = 521
      Height = 17
      AutoSize = False
      Caption = '00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 0123456789ABCDEF'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object Label24: TLabel
      Left = 0
      Top = 8
      Width = 9
      Height = 17
      AutoSize = False
      Caption = '$'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      Layout = tlBottom
    end
    object Label9: TLabel
      Left = 120
      Top = 0
      Width = 9
      Height = 17
      AutoSize = False
      Caption = '$'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      Layout = tlBottom
    end
    object Label10: TLabel
      Left = 240
      Top = 0
      Width = 9
      Height = 17
      AutoSize = False
      Caption = '$'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      Layout = tlBottom
    end
    object Label11: TLabel
      Left = 384
      Top = 0
      Width = 9
      Height = 17
      AutoSize = False
      Caption = '$'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      Layout = tlBottom
    end
    object Save: TSpeedButton
      Left = 592
      Top = 0
      Width = 25
      Height = 25
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000FF00FF00FF00
        FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000FF00FF00FF00FF000000
        0000007B7B00007B7B0000000000000000000000000000000000000000000000
        0000FF00FF00FF00FF0000000000007B7B0000000000FF00FF00FF00FF000000
        0000007B7B00007B7B0000000000000000000000000000000000000000000000
        0000FF00FF00FF00FF0000000000007B7B0000000000FF00FF00FF00FF000000
        0000007B7B00007B7B0000000000000000000000000000000000000000000000
        0000FF00FF00FF00FF0000000000007B7B0000000000FF00FF00FF00FF000000
        0000007B7B00007B7B0000000000000000000000000000000000000000000000
        0000000000000000000000000000007B7B0000000000FF00FF00FF00FF000000
        0000007B7B00007B7B00007B7B00007B7B00007B7B00007B7B00007B7B00007B
        7B00007B7B00007B7B00007B7B00007B7B0000000000FF00FF00FF00FF000000
        0000007B7B00007B7B0000000000000000000000000000000000000000000000
        00000000000000000000007B7B00007B7B0000000000FF00FF00FF00FF000000
        0000007B7B0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF0000000000007B7B0000000000FF00FF00FF00FF000000
        0000007B7B0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF0000000000007B7B0000000000FF00FF00FF00FF000000
        0000007B7B0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF0000000000007B7B0000000000FF00FF00FF00FF000000
        0000007B7B0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF0000000000007B7B0000000000FF00FF00FF00FF000000
        0000007B7B0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF00000000000000000000000000FF00FF00FF00FF000000
        0000007B7B0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF0000000000FF00FF0000000000FF00FF00FF00FF000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
        FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
      OnClick = SaveClick
    end
    object Copy: TButton
      Left = 472
      Top = 0
      Width = 41
      Height = 21
      Caption = 'Copy'
      TabOrder = 0
      OnClick = CopyClick
    end
    object Fill: TButton
      Left = 528
      Top = 0
      Width = 41
      Height = 21
      Caption = 'Fill'
      TabOrder = 1
      OnClick = FillClick
    end
    object Panel3: TPanel
      Left = -1
      Top = 24
      Width = 74
      Height = 17
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 2
      object Label18: TLabel
        Left = 0
        Top = 0
        Width = 17
        Height = 17
        Align = alCustom
        AutoSize = False
        Caption = '00'
        Color = clMedGray
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
      end
      object Address1: TMaskEdit
        Left = 17
        Top = 0
        Width = 55
        Height = 17
        AutoSelect = False
        AutoSize = False
        BorderStyle = bsNone
        EditMask = 'aaaaaa;0;0'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        MaxLength = 6
        ParentFont = False
        TabOrder = 0
        OnChange = Address1Change
        OnKeyDown = Address1KeyDown
        OnKeyPress = AddrKeyPress
        OnKeyUp = Address1KeyUp
      end
    end
    object FromPanel: TPanel
      Left = 127
      Top = 0
      Width = 74
      Height = 17
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 3
      object Label15: TLabel
        Left = 0
        Top = 0
        Width = 17
        Height = 17
        Align = alCustom
        AutoSize = False
        Caption = '00'
        Color = clMedGray
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
      end
      object From: TMaskEdit
        Left = 16
        Top = 0
        Width = 55
        Height = 17
        AutoSelect = False
        AutoSize = False
        BorderStyle = bsNone
        EditMask = 'aaaaaa;0;0'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        MaxLength = 6
        ParentFont = False
        TabOrder = 0
        OnKeyPress = AddrKeyPress
      end
    end
    object Panel4: TPanel
      Left = 247
      Top = 0
      Width = 74
      Height = 17
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 4
      object Label16: TLabel
        Left = 0
        Top = 0
        Width = 17
        Height = 17
        Align = alCustom
        AutoSize = False
        Caption = '00'
        Color = clMedGray
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
      end
      object To: TMaskEdit
        Left = 17
        Top = 0
        Width = 55
        Height = 17
        AutoSelect = False
        AutoSize = False
        BorderStyle = bsNone
        EditMask = 'aaaaaa;0;0'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Pitch = fpFixed
        Font.Style = []
        MaxLength = 6
        ParentFont = False
        TabOrder = 0
        OnKeyPress = AddrKeyPress
      end
    end
    object Bytes: TMaskEdit
      Left = 392
      Top = 0
      Width = 71
      Height = 17
      AutoSelect = False
      AutoSize = False
      Ctl3D = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 5
      OnKeyPress = AddrKeyPress
    end
  end
  object prompt: TTimer
    Enabled = False
    Interval = 500
    OnTimer = promptTimer
    Left = 600
    Top = 248
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'bin'
    Left = 544
    Top = 56
  end
end
