object Form1: TForm1
  Left = 735
  Top = 396
  Width = 744
  Height = 500
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 600
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
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDefault
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 29
    Width = 736
    Height = 140
    Align = alTop
    Caption = 'Registers'
    TabOrder = 0
    object D0lbl: TLabel
      Left = 8
      Top = 16
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'D0='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object D1lbl: TLabel
      Left = 8
      Top = 40
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'D1='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object D2lbl: TLabel
      Left = 8
      Top = 64
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'D2='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object D3lbl: TLabel
      Left = 8
      Top = 88
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'D3='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object D5lbl: TLabel
      Left = 112
      Top = 40
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'D5='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object D4lbl: TLabel
      Left = 112
      Top = 16
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'D4='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object D6lbl: TLabel
      Left = 112
      Top = 64
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'D6='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object D7lbl: TLabel
      Left = 112
      Top = 88
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'D7='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A0lbl: TLabel
      Left = 216
      Top = 16
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'A0='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A1lbl: TLabel
      Left = 216
      Top = 40
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'A1='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A2lbl: TLabel
      Left = 216
      Top = 64
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'A2='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A3lbl: TLabel
      Left = 216
      Top = 88
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'A3='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A4lbl: TLabel
      Left = 320
      Top = 16
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'A4='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A5lbl: TLabel
      Left = 320
      Top = 40
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'A5='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A6lbl: TLabel
      Left = 320
      Top = 64
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'A6='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A7lbl: TLabel
      Left = 320
      Top = 88
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'A7='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object PClbl: TLabel
      Left = 528
      Top = 88
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'PC='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object A8lbl: TLabel
      Left = 424
      Top = 88
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'SS='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object SRflags: TLabel
      Left = 452
      Top = 15
      Width = 135
      Height = 17
      AutoSize = False
      Caption = 'T S  INT   XNZVC'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object SRlbl: TLabel
      Left = 425
      Top = 33
      Width = 24
      Height = 17
      AutoSize = False
      Caption = 'SR='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label1: TLabel
      Left = 624
      Top = 16
      Width = 48
      Height = 16
      Caption = 'Cycles'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object HeadingsLbl: TLabel
      Left = 24
      Top = 113
      Width = 552
      Height = 16
      Caption = 
        ' Address  --------Code---------   Line -----------Source--------' +
        '--->>'
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object USlbl: TLabel
      Left = 424
      Top = 64
      Width = 25
      Height = 17
      AutoSize = False
      Caption = 'US='
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object regPC: TMaskEdit
      Left = 552
      Top = 88
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 17
      OnChange = regPCChange
      OnDblClick = regPCDblClick
      OnKeyPress = regKeyPress
    end
    object regA8: TMaskEdit
      Left = 448
      Top = 88
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 18
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA8KeyUp
    end
    object regA7: TMaskEdit
      Left = 344
      Top = 88
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 15
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA7KeyUp
    end
    object regA3: TMaskEdit
      Left = 240
      Top = 88
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 11
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA3KeyUp
    end
    object regA6: TMaskEdit
      Left = 344
      Top = 64
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 14
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA6KeyUp
    end
    object regA2: TMaskEdit
      Left = 240
      Top = 64
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 10
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA2KeyUp
    end
    object regA5: TMaskEdit
      Left = 344
      Top = 40
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 13
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA5KeyUp
    end
    object regA1: TMaskEdit
      Left = 240
      Top = 40
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 9
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA1KeyUp
    end
    object regA4: TMaskEdit
      Left = 344
      Top = 16
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 12
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA4KeyUp
    end
    object regA0: TMaskEdit
      Left = 240
      Top = 16
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 8
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regA0KeyUp
    end
    object regD7: TMaskEdit
      Left = 136
      Top = 88
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 7
      OnKeyPress = regKeyPress
    end
    object regD3: TMaskEdit
      Left = 32
      Top = 88
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 3
      OnKeyPress = regKeyPress
    end
    object regD6: TMaskEdit
      Left = 136
      Top = 64
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 6
      OnKeyPress = regKeyPress
    end
    object regD2: TMaskEdit
      Left = 32
      Top = 64
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 2
      OnKeyPress = regKeyPress
    end
    object regD5: TMaskEdit
      Left = 136
      Top = 40
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 5
      OnKeyPress = regKeyPress
    end
    object regD1: TMaskEdit
      Left = 32
      Top = 40
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 1
      OnKeyPress = regKeyPress
    end
    object regD4: TMaskEdit
      Left = 136
      Top = 16
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 4
      OnKeyPress = regKeyPress
    end
    object regD0: TMaskEdit
      Left = 32
      Top = 16
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 0
      OnKeyPress = regKeyPress
    end
    object regSR: TMaskEdit
      Left = 448
      Top = 32
      Width = 137
      Height = 21
      AutoSelect = False
      AutoSize = False
      EditMask = '9999999999999999;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 16
      ParentFont = False
      TabOrder = 16
      OnChange = regSRChange
      OnKeyPress = regSRKeyPress
    end
    object cyclesDisplay: TStaticText
      Left = 589
      Top = 31
      Width = 124
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = '0'
      Color = clBtnFace
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 20
    end
    object ClearCycles: TButton
      Left = 608
      Top = 56
      Width = 81
      Height = 25
      Caption = 'Clear Cycles'
      TabOrder = 19
      OnClick = ClearCyclesClick
    end
    object regUS: TMaskEdit
      Left = 448
      Top = 64
      Width = 73
      Height = 21
      AutoSize = False
      EditMask = 'aaaaaaaa;0;0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 21
      OnDblClick = regDblClick
      OnKeyPress = regKeyPress
      OnKeyUp = regUSKeyUp
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 736
    Height = 29
    Caption = 'ToolBar1'
    Images = ImageList1
    TabOrder = 1
    object ToolOpen: TToolButton
      Left = 0
      Top = 2
      Hint = 'Open'
      Action = Open
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton3: TToolButton
      Left = 23
      Top = 2
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object ToolRun: TToolButton
      Left = 31
      Top = 2
      Hint = 'Run'
      Action = Run
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton7: TToolButton
      Left = 54
      Top = 2
      Width = 8
      Caption = 'ToolButton7'
      ImageIndex = 5
      Style = tbsSeparator
    end
    object ToolRunToCursor: TToolButton
      Left = 62
      Top = 2
      Hint = 'Run To Cursor'
      Action = RunToCursor
      ParentShowHint = False
      ShowHint = True
    end
    object ToolAutoTrace: TToolButton
      Left = 85
      Top = 2
      Hint = 'Auto Trace'
      Action = AutoTrace
      ParentShowHint = False
      ShowHint = True
    end
    object ToolStep: TToolButton
      Left = 108
      Top = 2
      Hint = 'Step Over'
      Action = Step
      ParentShowHint = False
      ShowHint = True
    end
    object ToolTrace: TToolButton
      Left = 131
      Top = 2
      Hint = 'Trace Into'
      Action = Trace
      ParentShowHint = False
      ShowHint = True
    end
    object ToolPause: TToolButton
      Left = 154
      Top = 2
      Hint = 'Pause'
      Action = Pause
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton9: TToolButton
      Left = 177
      Top = 2
      Width = 8
      Caption = 'ToolButton9'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object ToolReset: TToolButton
      Left = 185
      Top = 2
      Hint = 'Rewind Program'
      Action = Rewind
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton1: TToolButton
      Left = 208
      Top = 2
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object ToolReload: TToolButton
      Left = 216
      Top = 2
      Hint = 'Reload Program'
      Action = Reload
      Enabled = False
      ParentShowHint = False
      ShowHint = True
    end
    object ToolButton2: TToolButton
      Left = 239
      Top = 2
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 15
      Style = tbsSeparator
    end
    object ToolLogStart: TToolButton
      Left = 247
      Top = 2
      Hint = 'Log Start'
      Action = LogStart
      ParentShowHint = False
      ShowHint = True
    end
    object ToolLogStop: TToolButton
      Left = 270
      Top = 2
      Hint = 'Log Stop'
      Action = LogStop
      ParentShowHint = False
      ShowHint = True
    end
    object LoggingLbl: TLabel
      Left = 293
      Top = 2
      Width = 57
      Height = 22
      Align = alRight
      Alignment = taCenter
      Caption = 'LOGGING'
      Color = clYellow
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
      Visible = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 169
    Width = 736
    Height = 258
    Align = alClient
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 1
      Top = 193
      Width = 734
      Height = 7
      Cursor = crVSplit
      Align = alBottom
      Beveled = True
    end
    object ScrollBar1: TScrollBar
      Left = 1
      Top = 177
      Width = 734
      Height = 16
      Align = alBottom
      Max = 200
      Min = 1
      PageSize = 0
      Position = 1
      TabOrder = 0
      OnChange = ScrollBar1Change
    end
    object ListBox1: TListBox
      Left = 25
      Top = 1
      Width = 710
      Height = 176
      Cursor = crArrow
      Style = lbOwnerDrawFixed
      Align = alClient
      ExtendedSelect = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Pitch = fpFixed
      Font.Style = []
      ItemHeight = 16
      ParentFont = False
      TabOrder = 3
      OnDblClick = ListBox1DblClick
      OnDrawItem = ListBox1DrawItem
    end
    object Message: TMemo
      Left = 1
      Top = 200
      Width = 734
      Height = 57
      TabStop = False
      Align = alBottom
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      Lines.Strings = (
        '')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 1
      WordWrap = False
    end
    object breakPnl: TPanel
      Left = 1
      Top = 1
      Width = 24
      Height = 176
      Align = alLeft
      BevelOuter = bvLowered
      TabOrder = 2
      object breakP: TPaintBox
        Left = 1
        Top = 1
        Width = 22
        Height = 174
        Align = alClient
        PopupMenu = BreakMenu
        OnMouseDown = breakPMouseDown
        OnPaint = breakPPaint
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 427
    Width = 736
    Height = 19
    Panels = <
      item
        Width = 75
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object ActionList1: TActionList
    Images = ImageList1
    Left = 472
    object Open: TAction
      Caption = '&Open...'
      ImageIndex = 0
      ShortCut = 16463
      OnExecute = OpenExecute
    end
    object OpenData: TAction
      Caption = 'Open &Data...'
      ImageIndex = 0
      OnExecute = OpenDataExecute
    end
    object Close: TAction
      Caption = '&Close'
      ImageIndex = 1
      OnExecute = CloseExecute
    end
    object Exit: TAction
      Caption = 'E&xit'
      ImageIndex = 2
      OnExecute = ExitExecute
    end
    object Run: TAction
      Caption = '&Run'
      ImageIndex = 3
      ShortCut = 120
      OnExecute = RunExecute
    end
    object Step: TAction
      Caption = '&Step Over'
      ImageIndex = 5
      ShortCut = 119
      OnExecute = StepExecute
    end
    object Trace: TAction
      Caption = '&Trace Into'
      ImageIndex = 4
      ShortCut = 118
      OnExecute = TraceExecute
    end
    object Pause: TAction
      Caption = '&Pause'
      ImageIndex = 7
      ShortCut = 117
      OnExecute = PauseExecute
    end
    object Rewind: TAction
      Caption = 'R&ewind Program'
      ImageIndex = 8
      ShortCut = 16497
      OnExecute = RewindExecute
    end
    object Reload: TAction
      Caption = 'Re&load Program'
      ImageIndex = 14
      ShortCut = 16498
      OnExecute = ReloadExecute
    end
    object Help: TAction
      Caption = '&Sim68K Help'
      ImageIndex = 6
      OnExecute = HelpExecute
    end
    object About: TAction
      Caption = '&About...'
      ImageIndex = 6
      OnExecute = AboutExecute
    end
    object FontSource: TAction
      Caption = 'Source Window Font'
      ImageIndex = 9
      OnExecute = FontSourceExecute
    end
    object FontOutput: TAction
      Caption = 'Output Window Font'
      ImageIndex = 9
      OnExecute = FontOutputExecute
    end
    object FontPrinter: TAction
      Caption = 'Printer Font...'
      ImageIndex = 9
      OnExecute = FontPrinterExecute
    end
    object AutoTrace: TAction
      Caption = '&Auto Trace'
      ImageIndex = 12
      ShortCut = 121
      OnExecute = AutoTraceExecute
    end
    object RunToCursor: TAction
      Caption = 'Run To &Cursor'
      ImageIndex = 13
      ShortCut = 16504
      OnExecute = RunToCursorExecute
    end
    object LogStart: TAction
      Caption = 'L&og Start'
      ImageIndex = 16
      ShortCut = 16499
      OnExecute = LogStartExecute
    end
    object LogStop: TAction
      Caption = 'Lo&g Stop'
      ImageIndex = 17
      ShortCut = 16500
      OnExecute = LogStopExecute
    end
    object Search: TAction
      Caption = '&Search'
      ImageIndex = 18
      ShortCut = 16454
      OnExecute = SearchExecute
    end
  end
  object MainMenu1: TMainMenu
    Left = 448
    object File1: TMenuItem
      Caption = '&File'
      SubMenuImages = ImageList1
      ImageIndex = 1
      object Open1: TMenuItem
        Action = Open
        SubMenuImages = ImageList1
      end
      object OpenData1: TMenuItem
        Action = OpenData
        SubMenuImages = ImageList1
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object Close1: TMenuItem
        Action = Close
        SubMenuImages = ImageList1
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object PrinterSetup1: TMenuItem
        Caption = '&Printer Setup...'
        ImageIndex = 15
        OnClick = PrinterSetup1Click
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = Exit
        SubMenuImages = ImageList1
      end
    end
    object Search1: TMenuItem
      Caption = '&Search'
      object Search2: TMenuItem
        Action = Search
        Caption = '&Find...'
      end
      object N13: TMenuItem
        Caption = '-'
      end
      object GotoPC1: TMenuItem
        Caption = '&Go to PC'
        ShortCut = 16455
        OnClick = GotoPC1Click
      end
    end
    object RunMenu: TMenuItem
      Caption = '&Run'
      SubMenuImages = ImageList1
      object Run1: TMenuItem
        Action = Run
        SubMenuImages = ImageList1
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object RunToCursor1: TMenuItem
        Action = RunToCursor
      end
      object AutoTrace1: TMenuItem
        Action = AutoTrace
        SubMenuImages = ImageList1
      end
      object StepOver1: TMenuItem
        Action = Step
        SubMenuImages = ImageList1
      end
      object TraceInto1: TMenuItem
        Action = Trace
        SubMenuImages = ImageList1
      end
      object Pause1: TMenuItem
        Action = Pause
        SubMenuImages = ImageList1
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object Reset1: TMenuItem
        Action = Rewind
      end
      object Reload1: TMenuItem
        Action = Reload
        Enabled = False
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object LogStart1: TMenuItem
        Action = LogStart
      end
      object LogStop1: TMenuItem
        Action = LogStop
      end
    end
    object View1: TMenuItem
      Caption = '&View'
      object OutputWindow1: TMenuItem
        Caption = '&Output Window'
        OnClick = OutputWindow1Click
      end
      object Memory1: TMenuItem
        Caption = '&Memory'
        OnClick = Memory1Click
      end
      object Stack1: TMenuItem
        Caption = '&Stack'
        OnClick = Stack1Click
      end
      object Hardware1: TMenuItem
        Caption = '&Hardware'
        OnClick = Hardware1Click
      end
      object BreakPoints1: TMenuItem
        Caption = '&Break Points'
        OnClick = BreakPoints1Click
      end
      object EASyBIN1: TMenuItem
        Caption = '&EASyBIN'
        OnClick = EASyBIN1Click
      end
    end
    object Options1: TMenuItem
      Caption = '&Options'
      SubMenuImages = ImageList1
      object SourceFont: TMenuItem
        Action = FontSource
        Caption = 'Source Window Font...'
        SubMenuImages = ImageList1
      end
      object OutputFont: TMenuItem
        Action = FontOutput
        Caption = 'Output Window Font...'
        SubMenuImages = ImageList1
      end
      object PrinterFont1: TMenuItem
        Action = FontPrinter
        SubMenuImages = ImageList1
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object LogOutput1: TMenuItem
        Caption = '&Log Output...'
        OnClick = LogOutput1Click
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object ExceptionsEnabled: TMenuItem
        Caption = '&Enable Exceptions'
        OnClick = ExceptionsEnabledClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object SimulatorOptions: TMenuItem
        Caption = '&Auto Trace Options...'
        OnClick = SimulatorOptionsClick
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object mmuFullscreenOptions: TMenuItem
        Caption = '&Fullscreen Options...'
        OnClick = mmuFullscreenOptionsClick
      end
      object N11: TMenuItem
        Caption = '-'
      end
      object BitFieldEnabled: TMenuItem
        Caption = 'Enable &Bit Field Instructions'
        OnClick = BitFieldEnabledClick
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object OutputWindowSize1: TMenuItem
        Caption = 'Output Window &Size'
        object Size640x480: TMenuItem
          Caption = '640x480'
          Checked = True
          RadioItem = True
          OnClick = WindowSizeClick
        end
        object Size800x600: TMenuItem
          Tag = 1
          Caption = '800x600'
          RadioItem = True
          OnClick = WindowSizeClick
        end
        object Size1024x768: TMenuItem
          Tag = 2
          Caption = '1024x768'
          RadioItem = True
          OnClick = WindowSizeClick
        end
        object Size1280x800: TMenuItem
          Tag = 3
          Caption = '1280x800'
          RadioItem = True
          OnClick = WindowSizeClick
        end
        object Size1280x1024: TMenuItem
          Tag = 4
          Caption = '1280x1024'
          RadioItem = True
          OnClick = WindowSizeClick
        end
        object Size1440x900: TMenuItem
          Tag = 5
          Caption = '1440x900'
          RadioItem = True
          OnClick = WindowSizeClick
        end
        object Size1680x1050: TMenuItem
          Tag = 6
          Caption = '1680x1050'
          RadioItem = True
          OnClick = WindowSizeClick
        end
        object Size1920x1080: TMenuItem
          Tag = 7
          Caption = '1920x1080'
          RadioItem = True
          OnClick = WindowSizeClick
        end
        object Size1920x1200: TMenuItem
          Tag = 8
          Caption = '1920x1200'
          RadioItem = True
          OnClick = WindowSizeClick
        end
      end
      object OutputWindowTextWrap1: TMenuItem
        Caption = 'Output Window Text &Wrap'
        OnClick = OutputWindowTextWrap1Click
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      SubMenuImages = ImageList1
      object Help2: TMenuItem
        Action = Help
      end
      object About1: TMenuItem
        Action = About
        Caption = '&About Sim68K'
        SubMenuImages = ImageList1
      end
    end
  end
  object ImageList1: TImageList
    BkColor = clFuchsia
    DrawingStyle = dsTransparent
    Left = 496
    Bitmap = {
      494C010113001800040010001000FF00FF00FF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000006000000001002000000000000060
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      000000000000FF00FF000000000000000000FF00FF00000000000000FF000000
      FF000000FF00FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF00000000
      FF000000FF000000FF00FF00FF00FF00FF000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      0000000000000000000000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000FFFF0000FF00FF000000FF000000FF000000
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000
      FF000000FF000000FF00FF00FF00FF00FF0000000000FFFFFF00000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000FFFF
      FF00000000000000000000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      0000FFFF0000FFFF0000FFFF0000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000FFFF0000FF00FF000000FF000000FF000000
      0000FFFFFF00FFFF0000FFFF0000FFFF0000FFFF00000000FF000000FF000000
      FF00FFFFFF000000FF000000FF00FF00FF0000000000FFFFFF00000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000FFFF
      FF00000000000000000000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      000000000000FFFFFF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000FFFF0000FF00FF000000FF000000FF000000
      0000FFFFFF00FFFFFF0080808000808080000000FF000000FF000000FF00FFFF
      FF00FFFFFF000000FF000000FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFF00000000
      000000FFFF000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000FFFF0000FF00FF000000FF000000FF000000
      0000FFFFFF00FFFF0000FFFF00000000FF000000FF000000FF00FFFF0000FFFF
      0000FFFFFF000000FF000000FF00FF00FF000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000FFFF0000FF00FF000000FF000000FF000000
      0000FFFFFF00FFFFFF000000FF000000FF000000FF008080800080808000FFFF
      FF00FFFFFF000000FF000000FF00FF00FF000000000000000000FFFFFF000000
      00000000000000000000FF00FF000000000000000000FFFFFF00000000000000
      0000000000000000000000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000FFFF0000000000FFFF0000FF00FF000000FF000000FF000000
      0000FFFFFF000000FF000000FF000000FF00FFFF0000FFFF0000FFFF0000FFFF
      0000FFFFFF000000FF000000FF00FF00FF000000000000000000FFFFFF000000
      00000000000000000000FF00FF000000000000000000FFFFFF00000000000000
      0000000000000000000000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000FFFF00000000000000000000FFFF00FFFF
      FF0000FFFF00000000000000000000000000FF00FF000000FF000000FF000000
      00000000FF000000FF000000FF0080808000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF000000FF000000FF00FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF00000000000000FFFF0000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000
      FF000000FF000000FF00FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      00000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000FFFF
      FF00000000000000000000000000FF00FF0000000000FFFFFF00000000000000
      000000000000FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FFFF0000000000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000FF000000
      FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      0000000000000000000000000000FF00FF000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF0000000000FFFFFF0000000000FFFFFF000000000000FFFF000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000FFFFFF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      00000000000000000000FF00FF00FF00FF00FF00FF0000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF00000000007F7F7F000000
      00007F7F7F00000000007F7F7F00000000007F7F7F00000000000000000000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF0000000000FF00FF00FF00
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF0000000000FF00FF00FF00FF00FF00FF0000000000FFFFFF000000
      0000FF00FF00FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF00000000007F7F7F000000
      00007F7F7F00000000007F7F7F00000000007F7F7F0000000000FF00FF000000
      00000000FF0000000000FF00FF00FF00FF00FF00FF00FF00FF0000000000FF00
      FF00000000008080800000000000808080000000000080808000000000008080
      800000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      00000000000000000000FF00FF00FF00FF00FF00FF0000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF00FF0000000000FF00
      FF0000000000FF00FF0000000000FF00FF0000000000FF00FF00FF00FF00FF00
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FF00FF0000000000FF00FF0000000000FF00FF0000000000FF00FF000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF0000000000BDBDBD00BDBDBD00BDBD
      BD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBD
      BD00BDBDBD00BDBDBD00BDBDBD0000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF007B7B7B007B7B7B007B7B7B007B7B
      7B007B7B7B007B7B7B007B7B7B00FF00FF00FF00FF00FF00FF00000000000000
      000000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF0000000000FF00FF00FF00FF0000000000BDBDBD00BDBDBD00BDBD
      BD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBDBD00BDBD
      BD00BDBDBD00BDBDBD00BDBDBD0000000000FF00FF00FF00FF00FF00FF000084
      0000008400000084000000840000008400000084000000840000008400000084
      00000084000000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF0000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000FFFF
      FF000000000000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF0000000000FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF00FF00FF00FF00FF000084
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF0000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF000084000000840000FF00FF00FF00FF007B7B7B007B7B7B007B7B7B007B7B
      7B007B7B7B007B7B7B007B7B7B00FF00FF00FF00FF00FF00FF000000000000FF
      FF00FFFFFF000000000000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C60000FFFF000000000000000000FFFFFF00BDBDBD00FFFF
      FF00BDBDBD00FFFFFF00BDBDBD00FFFFFF00BDBDBD00FFFFFF00BDBDBD00FFFF
      FF00BDBDBD00FFFFFF00BDBDBD0000000000FF00FF00FF00FF00FF00FF000084
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF0000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00008400000084000000840000FF00FF00FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF00FF00FF00FF00FF00FF0000000000FFFF
      FF0000FFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000BDBDBD00FFFFFF00BDBD
      BD00FFFFFF00BDBDBD00FFFFFF00BDBDBD00FFFFFF00BDBDBD00FFFFFF00BDBD
      BD00FFFFFF000000FF00FFFFFF0000000000FF00FF00FF00FF00FF00FF000084
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF0000840000FF00FF00FF00FF00FF00FF00FF00FF00008400000084
      000000840000008400000084000000840000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF00FF00FF00FF00000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF000084000000FF000000840000FFFFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF0000000000FFFFFF00BDBDBD00FFFF
      FF00BDBDBD00FFFFFF00BDBDBD00FFFFFF00BDBDBD00FFFFFF00BDBDBD00FFFF
      FF00BDBDBD00FFFFFF00BDBDBD00000000000084000000840000008400000084
      0000008400000084000000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF0000840000FF00FF00FF00FF00FF00FF00FF00FF0000840000FF00
      FF00008400000084000000840000FF00FF00FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF00FF000000000000FFFF0000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF0000FF00000084000000FF000000FFFF00FFFF
      FF0000840000FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF00FF0000840000008400000084
      00000084000000840000FF00FF00FF00FF0000840000FF00FF00FF00FF00FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF0000840000FF00
      FF000084000000840000FF00FF00FF00FF007B7B7B007B7B7B007B7B7B007B7B
      7B007B7B7B007B7B7B007B7B7B00FF00FF0000000000FFFFFF000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF000084000000FF000000840000000000000000
      000000FF000000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00008400000084
      000000840000FF00FF00FF00FF00FF00FF000084000000840000FF00FF00FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF0000840000FF00
      FF0000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000FFFF00FFFFFF000000
      000000FFFF00FFFFFF0000FFFF0000FF00000084000000FF00000084000000FF
      00000084000000FF000000840000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF0000000000FFFF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000084
      0000FF00FF00FF00FF00FF00FF00FF00FF00008400000084000000840000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF0000840000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF007B7B7B007B7B7B007B7B7B007B7B
      7B007B7B7B007B7B7B007B7B7B00FF00FF0000000000FFFFFF0000FFFF008484
      84000000000000000000000000000084000000FF00000084000000FF00000084
      000000FF00000084000000FF000000840000FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FF00FF00FF00FF00FF00FF000084000000840000008400000084
      0000008400000084000000840000008400000084000000840000008400000084
      0000FF000000FF000000FF000000FF00FF00FF00FF00FF00FF0000840000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF000084000000FF00000084000000FF
      00000084000000FF000000840000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF000000000000000000FFFFFF000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00008400000084000000840000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF0000840000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF007B7B7B007B7B7B007B7B7B007B7B
      7B007B7B7B007B7B7B007B7B7B00FF00FF0000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FF00
      FF0000FF000000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000084000000840000FF00FF00FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF000084000000840000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF00FF00FF00
      FF0000840000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF0000000000BDBDBD00FFFFFF0000000000FFFFFF0000000000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF0000840000FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF007B7B7B007B7B7B007B7B7B007B7B
      7B007B7B7B007B7B7B007B7B7B00FF00FF00FF00FF0000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0084848400000000000000
      0000000000000000000084848400FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      00000000000000000000000000000000000000000000FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF000000FF000000FF000000FF000000FF000000FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000000000000000FF00FF00FF00FF0000000000000000000000
      00000000000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000
      FF000000FF00FF00FF007B7B7B00000000007B7B7B00FF00FF000000FF000000
      FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000
      FF00FF00FF00FF00FF00000000000000000000000000FF00FF00FF00FF000000
      FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00000000007B7B7B00FF00FF00FF00FF00FF00FF00000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00007B0000007B0000007B0000007B0000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF0000007B0000007B0000007B0000007B00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF00FF00
      FF00FF00FF00FF00FF007B7B7B00000000007B7B7B00FF00FF00FF00FF00FF00
      FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF007B7B7B0000000000000000000000000000000000000000000000
      00007B7B7B00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00007B0000007B0000007B0000007B0000007B0000007B0000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF0000007B000000FF000000FF000000FF000000FF0000007B00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF0000000000FF00FF00FF00FF0000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00007B0000007B000000FF000000FF000000FF000000FF0000007B0000007B
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF0000007B000000FF000000FF000000FF000000FF000000FF000000FF000000
      7B00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF0000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00000000007B7B7B00FF00FF0000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00007B0000007B000000FF000000FF000000FF000000FF0000007B0000007B
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF0000007B000000FF000000FF000000FF000000FF000000FF000000FF000000
      7B00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF00FF00FF00FF00
      FF00FF00FF00FF00FF007B7B7B00000000007B7B7B00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF007B7B7B0000000000FF00FF0000000000000000007B7B
      7B00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00007B0000007B000000FF000000FF000000FF000000FF0000007B0000007B
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF0000007B000000FF000000FF000000FF000000FF000000FF000000FF000000
      7B00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF00FF00FF00FF00
      FF00FF00FF00FF00FF0000007B000000000000007B00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF0000000000000000000000000000000000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00007B0000007B000000FF000000FF000000FF000000FF0000007B0000007B
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF0000007B000000FF000000FF000000FF000000FF000000FF000000FF000000
      7B00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF00FF00FF00FF00
      FF00FF00FF00FF00FF00000000000000000000000000FF00FF000000FF000000
      FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF0000000000000000000000000000000000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00007B0000007B0000007B0000007B0000007B0000007B0000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF0000007B000000FF000000FF000000FF000000FF0000007B00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF00FF00
      FF00FF00FF00FF00FF00000000000000000000000000FF00FF00FF00FF000000
      FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF007B7B7B0000000000000000007B7B7B00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00007B0000007B0000007B0000007B0000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF0000007B0000007B0000007B0000007B00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000
      FF00FF00FF00FF00FF00000000000000000000000000FF00FF00FF00FF00FF00
      FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000000000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000
      FF000000FF00FF00FF007B7B7B00000000007B7B7B00FF00FF000000FF000000
      FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF00FF00FF00FF00FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF000000FF000000FF000000FF000000FF000000FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00007B0000FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00007B0000007B0000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00000000000000FF000000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00007B0000007B0000007B0000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF000000FF00000000000000FFFFFF0000000000FF000000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00007B0000007B0000007B0000007B0000007B0000007B0000007B
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF000000FF00FF0000000000FFFFFF0000000000FFFFFF0000000000FF00
      0000FF00FF00FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF007B7B
      7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
      7B007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00007B0000007B0000FF00FF00FF00FF00007B0000007B0000007B0000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      00000000000000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF000000
      0000FF000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00007B
      0000007B0000FF00FF00FF00FF00FF00FF00007B0000007B0000FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF0000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF0000000000FF000000FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00007B
      0000007B0000FF00FF00FF00FF00FF00FF00007B0000FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF00FF0000000000FFFF
      FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000FFFFFF0000000000FF000000FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF000000000000000000FF00FF000000000000000000FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00007B
      0000007B0000007B0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000000000FF000000FFFF000000000000FFFFFF00FF00
      FF00FF00FF000000000000000000FF00FF000000000000000000FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00007B0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00007B0000007B0000007B0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF000000FF000000FF000000FF00FF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF0000000000FFFF000000000000FFFFFF00FF00
      FF00FF00FF000000000000000000FF00FF000000000000000000FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00007B0000007B0000FF00FF00FF00FF00FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00007B0000007B0000007B0000007B0000007B0000007B0000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF000000000000000000FF00FF000000000000000000FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00007B0000007B0000007B
      0000007B0000007B0000007B0000007B0000007B0000007B0000007B0000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00007B0000007B0000007B0000007B0000007B0000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF0000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF000000000000000000FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF000000000000000000FF00FF000000000000000000FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00007B0000007B0000007B
      0000007B0000007B0000007B0000007B0000007B0000007B0000007B0000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00007B0000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00007B0000007B0000FF00FF00FF00FF00FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00007B0000007B0000007B
      0000007B0000007B0000007B0000007B0000007B0000007B0000007B0000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00007B0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00007B0000007B0000007B
      0000007B0000007B0000007B0000007B0000007B0000007B0000007B0000FF00
      FF00FF000000FF000000FF000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00000000000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF007B7B
      7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B007B7B
      7B007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00000000000000000000FF
      FF00BDBDBD0000FFFF00BDBDBD0000FFFF00BDBDBD0000FFFF00BDBDBD0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF0000000000FFFFFF000000
      000000FFFF00BDBDBD0000FFFF00BDBDBD0000FFFF00BDBDBD0000FFFF00BDBD
      BD0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF000000000000FFFF00FFFF
      FF000000000000FFFF00BDBDBD0000FFFF00BDBDBD0000FFFF00BDBDBD0000FF
      FF00BDBDBD0000FFFF0000000000FF00FF00FF00FF00FF00FF0000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF00000000000000000000000000FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF0000000000FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF00FF00FF00FF00FF00FF000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF0000000000000000000000000000000000FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF00000000000000000000000000FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF0000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B0000FFFF000000000000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF000000000000000000FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000000000000000FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
      0000FFFFFF0000FFFF00FFFFFF0000FFFF0000000000FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000000000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF007B7B
      7B00000000000000000000000000000000007B7B7B00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B0000007B0000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF007B7B7B0000000000FFFF0000FF00FF00FF00FF00FF00FF007B7B7B000000
      00000000000000000000000000007B7B7B00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B00FFFF000000007B000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      7B00FFFF0000FFFF00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000000000FF00FF00FF00FF00FF00FF00FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF00FF00FF00FF00FF00FF00FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FF00FF00424D3E000000000000003E000000
      2800000040000000600000000100010000000000000300000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000803FF007FFFF0000001FC003FFFF0000
      0004800307C100000000800307C100000000800107C100000000800101010000
      0000800100010000000080010201000000008001020100000000800180030000
      00078003C1070000001F8003C1070000000F8003E38F00008007B007E38F0000
      8023D007E38F00005577EAAFFFFF0000FFFFFFFFFFFF8001FFFFFFFFE0070000
      FFFFFF01C0030000E003F7FFC0010000EFFBF301C0000000EFFBF101C0000000
      EFFBC0018007000001FBD101000700008371D3010003E007C731D7FF0001E007
      EF11DF010000E0070001DFFF0001E007FF11DF010013E00FFF319FFF0037E01F
      FF7FFF0181FFE03FFFFFFFFF81FFE07FFFFFFFFFFFFFFFFFF83FFFFFFFFFFFFF
      E00FF183FFFFFFFFC447FBC7FFFFFFFF8C63F9C7FC3FFC3F9C73F807F81FF81F
      3FF9FD8FF00FF00F3EF9FC8FF00FF00F3C7FFC8FF00FF00F3C7FFE1FF00FF00F
      3C41FE1FF81FF81F9C61FE1FFC3FFC3F8C71FF3FFFFFFFFFC441FF7FFFFFFFFF
      E00DFFFFFFFFFFFFF83FFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFFF3FFE3F0001
      FFFFFF1FF81F0001FFFFF80FF40F0001FFFFF31FE0071FF1FFFFE73F80031FF1
      FFFFE77F40011931FFFFE3FF00001931FEF1F1F100001931FE71F81180011931
      8011FC11C00319318011FFD1E00F1FF1FE718011F07F1FF1FEF18011F8FF0001
      FFFFFFFFFFFF0001FFFFFFFFFFFF0001FFFFFFFFC007FFFFFFFFFFFFC0070001
      FFFFFFFFC0070001FFFFE007C0070001C00FC007C0071FF18007C007C0071DF1
      8003C007C0071CF18001C007C0071C718001C007C0071C31800FC007C0071C71
      800FC00FC0071CF1801FE07FC0071DF1C0FFE07FC0071FF1C0FFFFFFC0070001
      FFFFFFFFC0070001FFFFFFFFC007000100000000000000000000000000000000
      000000000000}
  end
  object OpenDialog1: TOpenDialog
    Filter = 'EASy68K S-Record (*.S68)|*.S68|All Files (*.*)|*.*'
    Left = 520
  end
  object FontDialogSource: TFontDialog
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Fixedsys'
    Font.Style = []
    MinFontSize = 8
    MaxFontSize = 18
    Options = [fdAnsiOnly, fdEffects, fdFixedPitchOnly, fdLimitSize]
    OnApply = FontDialogSourceApply
    Left = 544
  end
  object BreakMenu: TPopupMenu
    Left = 640
    object ClearAllPCBreakpoints1: TMenuItem
      Caption = 'Clear All PC Breakpoints'
      OnClick = ClearAllPCBreakpoints1Click
    end
  end
  object AutoTraceTimer: TTimer
    Enabled = False
    Interval = 200
    OnTimer = AutoTraceTimerTimer
    Left = 664
  end
  object FontDialogSimIO: TFontDialog
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Fixedsys'
    Font.Style = []
    MinFontSize = 8
    MaxFontSize = 18
    Options = [fdEffects, fdFixedPitchOnly, fdLimitSize]
    OnApply = FontDialogSimIOApply
    Left = 568
  end
  object FontDialogPrinter: TFontDialog
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Options = [fdAnsiOnly, fdEffects]
    Left = 592
  end
  object PrinterSetupDialog1: TPrinterSetupDialog
    Left = 616
  end
  object OpenDialogIO: TOpenDialog
    Left = 392
  end
  object SaveDialogIO: TSaveDialog
    Left = 416
  end
end
