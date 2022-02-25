object BreaksFrm: TBreaksFrm
  Left = 538
  Top = 256
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'EASy68K Advanced Break Points'
  ClientHeight = 496
  ClientWidth = 671
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
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
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object debugLabel1: TLabel
    Left = 672
    Top = 8
    Width = 62
    Height = 13
    Caption = 'debugLabel1'
  end
  object debugLabel2: TLabel
    Left = 672
    Top = 24
    Width = 62
    Height = 13
    Caption = 'debugLabel2'
  end
  object debugLabel3: TLabel
    Left = 672
    Top = 40
    Width = 62
    Height = 13
    Caption = 'debugLabel3'
  end
  object debugLabel4: TLabel
    Left = 672
    Top = 56
    Width = 62
    Height = 13
    Caption = 'debugLabel4'
  end
  object debugLabel5: TLabel
    Left = 672
    Top = 72
    Width = 62
    Height = 13
    Caption = 'debugLabel5'
  end
  object debugLabel6: TLabel
    Left = 672
    Top = 88
    Width = 62
    Height = 13
    Caption = 'debugLabel6'
  end
  object debugLabel7: TLabel
    Left = 672
    Top = 104
    Width = 62
    Height = 13
    Caption = 'debugLabel7'
  end
  object RegGroupBox: TGroupBox
    Left = 5
    Top = 5
    Width = 284
    Height = 238
    Caption = 'Registers'
    TabOrder = 0
    object RegStringGrid: TStringGrid
      Left = 8
      Top = 16
      Width = 265
      Height = 177
      RowCount = 50
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowMoving, goColMoving, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 6
      OnClick = RegStringGridClick
      OnColumnMoved = RegColumnMoved
      OnDblClick = RegStringGridDblClick
      OnRowMoved = RegRowMoved
      OnTopLeftChanged = RegTopLeftChanged
      RowHeights = (
        24
        24
        24
        24
        24
        24
        23
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24)
    end
    object RegSelectCombo: TComboBox
      Left = 43
      Top = 42
      Width = 46
      Height = 21
      ItemHeight = 13
      TabOrder = 3
      Text = 'PC'
      Visible = False
      Items.Strings = (
        'D0'
        'D1'
        'D2'
        'D3'
        'D4'
        'D5'
        'D6'
        'D7'
        'A0'
        'A1'
        'A2'
        'A3'
        'A4'
        'A5'
        'A6'
        'A7'
        'PC')
    end
    object RegOperatorCombo: TComboBox
      Left = 93
      Top = 42
      Width = 44
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Text = '=='
      Visible = False
      Items.Strings = (
        '=='
        '!='
        '>'
        '>='
        '<'
        '<=')
    end
    object RegValueMaskEdit: TMaskEdit
      Left = 142
      Top = 43
      Width = 73
      Height = 21
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 5
      Visible = False
      OnKeyPress = RegValueKeyPress
    end
    object RegSetButton: TButton
      Left = 8
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Set'
      Enabled = False
      TabOrder = 0
      OnClick = RegSetButtonClick
    end
    object RegClearButton: TButton
      Left = 64
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Clear'
      Enabled = False
      TabOrder = 1
      OnClick = RegClearButtonClick
    end
    object RegClearAllButton: TButton
      Left = 120
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Clear All'
      Enabled = False
      TabOrder = 2
      OnClick = RegClearAllButtonClick
    end
    object RegSizeCombo: TComboBox
      Left = 216
      Top = 40
      Width = 49
      Height = 21
      ItemHeight = 13
      TabOrder = 7
      Text = 'L'
      Visible = False
      Items.Strings = (
        'B'
        'W'
        'L')
    end
  end
  object AddrGroupBox: TGroupBox
    Left = 296
    Top = 5
    Width = 369
    Height = 238
    Caption = 'Memory'
    TabOrder = 1
    object AddrStringGrid: TStringGrid
      Left = 8
      Top = 16
      Width = 353
      Height = 177
      ColCount = 6
      RowCount = 50
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowMoving, goColMoving, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 7
      OnClick = AddrStringGridClick
      OnColumnMoved = AddrColumnMoved
      OnDblClick = AddrStringGridDblClick
      OnRowMoved = AddrRowMoved
      OnTopLeftChanged = AddrTopLeftChanged
      ColWidths = (
        64
        64
        64
        64
        64
        64)
      RowHeights = (
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24)
    end
    object AddrSelectMaskEdit: TMaskEdit
      Left = 42
      Top = 44
      Width = 73
      Height = 21
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 3
      Visible = False
      OnKeyPress = AddrSelectKeyPress
    end
    object AddrValueMaskEdit: TMaskEdit
      Left = 165
      Top = 43
      Width = 73
      Height = 21
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 5
      Visible = False
      OnKeyPress = AddrValueKeyPress
    end
    object AddrOperatorCombo: TComboBox
      Left = 117
      Top = 42
      Width = 44
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Text = '=='
      Visible = False
      Items.Strings = (
        '=='
        '!='
        '>'
        '>='
        '<'
        '<='
        'N/A')
    end
    object AddrReadWriteCombo: TComboBox
      Left = 296
      Top = 40
      Width = 57
      Height = 21
      ItemHeight = 13
      TabOrder = 6
      Text = 'R/W'
      Visible = False
      Items.Strings = (
        'R/W'
        'Read'
        'Write'
        'N/A')
    end
    object AddrSetButton: TButton
      Left = 8
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Set'
      Enabled = False
      TabOrder = 0
      OnClick = AddrSetButtonClick
    end
    object AddrClearButton: TButton
      Left = 64
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Clear'
      Enabled = False
      TabOrder = 1
      OnClick = AddrClearButtonClick
    end
    object AddrClearAllButton: TButton
      Left = 120
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Clear All'
      Enabled = False
      TabOrder = 2
      OnClick = AddrClearAllButtonClick
    end
    object AddrSizeCombo: TComboBox
      Left = 240
      Top = 40
      Width = 49
      Height = 21
      ItemHeight = 13
      TabOrder = 8
      Text = 'L'
      Visible = False
      Items.Strings = (
        'B'
        'W'
        'L')
    end
  end
  object ExprGroupBox: TGroupBox
    Left = 5
    Top = 248
    Width = 660
    Height = 241
    Caption = 'Expression Builder'
    TabOrder = 2
    object ExprStringGrid: TStringGrid
      Left = 8
      Top = 16
      Width = 641
      Height = 177
      ColCount = 4
      RowCount = 50
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      TabOrder = 7
      OnClick = ExprStringGridClick
      OnColumnMoved = ExprColumnMoved
      OnDblClick = ExprStringGridDblClick
      OnRowMoved = ExprRowMoved
      OnTopLeftChanged = ExprTopLeftChanged
      RowHeights = (
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24
        24)
    end
    object ExprEnabledCombo: TComboBox
      Left = 96
      Top = 40
      Width = 57
      Height = 21
      ItemHeight = 13
      TabOrder = 4
      Text = 'ON'
      Visible = False
      Items.Strings = (
        'ON'
        'OFF')
    end
    object ExprSetButton: TButton
      Left = 8
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Set'
      Enabled = False
      TabOrder = 0
      OnClick = ExprSetButtonClick
    end
    object ExprClearButton: TButton
      Left = 64
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Clear'
      Enabled = False
      TabOrder = 1
      OnClick = ExprClearButtonClick
    end
    object ExprClearAllButton: TButton
      Left = 120
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Clear All'
      Enabled = False
      TabOrder = 2
      OnClick = ExprClearAllButtonClick
    end
    object ExprRegAppendButton: TButton
      Left = 200
      Top = 200
      Width = 50
      Height = 25
      Caption = 'PC/Reg'
      Enabled = False
      TabOrder = 5
      OnClick = ExprRegAppendButtonClick
    end
    object ExprAddrAppendButton: TButton
      Left = 288
      Top = 200
      Width = 50
      Height = 25
      Caption = 'Memory'
      Enabled = False
      TabOrder = 6
      OnClick = ExprAddrAppendButtonClick
    end
    object ExprRegMaskEdit: TMaskEdit
      Left = 256
      Top = 200
      Width = 23
      Height = 21
      EditMask = '99;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 2
      ParentFont = False
      TabOrder = 3
    end
    object ExprAddrMaskEdit: TMaskEdit
      Left = 344
      Top = 200
      Width = 25
      Height = 21
      EditMask = '99;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 2
      ParentFont = False
      TabOrder = 8
    end
    object ExprAndAppendButton: TButton
      Left = 392
      Top = 200
      Width = 30
      Height = 25
      Caption = 'AND'
      Enabled = False
      TabOrder = 9
      OnClick = ExprAndAppendButtonClick
    end
    object ExprOrAppendButton: TButton
      Left = 432
      Top = 200
      Width = 30
      Height = 25
      Caption = 'OR'
      Enabled = False
      TabOrder = 10
      OnClick = ExprOrAppendButtonClick
    end
    object ExprBackspaceButton: TButton
      Left = 568
      Top = 200
      Width = 75
      Height = 25
      Caption = 'Backspace'
      Enabled = False
      TabOrder = 11
      OnClick = ExprBackspaceButtonClick
    end
    object ExprExprEdit: TEdit
      Left = 152
      Top = 40
      Width = 481
      Height = 21
      Enabled = False
      TabOrder = 12
      Visible = False
    end
    object ExprCountMaskEdit: TMaskEdit
      Left = 550
      Top = 62
      Width = 49
      Height = 21
      EditMask = '99;0;0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 2
      ParentFont = False
      TabOrder = 13
      Visible = False
      OnKeyPress = ExprCountKeyPress
    end
    object ExprLParenAppendButton: TButton
      Left = 480
      Top = 200
      Width = 25
      Height = 25
      Caption = '('
      Enabled = False
      TabOrder = 14
      OnClick = ExprLParenAppendButtonClick
    end
    object ExprRParenAppendButton: TButton
      Left = 512
      Top = 200
      Width = 25
      Height = 25
      Caption = ')'
      Enabled = False
      TabOrder = 15
      OnClick = ExprRParenAppendButtonClick
    end
  end
end
