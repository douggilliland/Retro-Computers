object EditorOptionsForm: TEditorOptionsForm
  Left = 741
  Top = 207
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'EASy68K Editor Options'
  ClientHeight = 336
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000088888888888888888888888888888800844
    4444444444444444444444444480084444444444444444444444444444800844
    444444444444444444444444448008CCCCCCCCCCCCCCCCCCCCCCCCC4448008C8
    8888888888888888888888C4448008C88888888888888888888888C4448008CF
    FFFFFFFFFFFFFFFFFFFFFFC4448008CFFFFFFFFFFFFFFFFFFFFFFFC4448008CF
    07FF07FF0007FFF0007FFFC4448008CF07FF07F07FF07F07FF07FFC4448008CF
    07FF07F07FF07F07FF07FFC4448008CFF0707FF07FF07F07FF07FFC4448008CF
    FF07FFF00007FFF0007FFFC4448008CFF0707FF07FFFFF07FF07FFC4448008CF
    07FF07F07FFFFF07FF07FFC4448008CF07FF07F07FF07F07FF07FFC4448008CF
    07FF07FF0007FFF0007FFFC4448008CFFFFFFFFFFFFFFFFFFFFFFFC4448008CF
    FFFFFFFFFFFFFFFFFFFFFFC4448008CCCCCCCCCCCCCCCCCC88CC99C4448008CC
    CCCCCCCCCCCCCCCCCC8899C4448008CCCCCCCCCCCCCCCCCCCCCCCCC444800888
    8888888888888888888888888880088888888888888888888888888888800777
    7777777777777777777777777770077777777777777777777777777777700CCC
    CCCCCCCCCCCCCCCCCCCC88CC99C00CCCCCCCCCCCCCCCCCCCCCCCCC8899C00CCC
    CCCCCCCCCCCCCCCCCCCCCCCCCCC0000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cmdOK: TButton
    Left = 200
    Top = 304
    Width = 73
    Height = 25
    Caption = '&OK'
    Default = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 280
    Top = 304
    Width = 73
    Height = 25
    Caption = '&Cancel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = cmdCancelClick
  end
  object cmdHelp: TButton
    Left = 360
    Top = 304
    Width = 73
    Height = 25
    Caption = '&Help'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = cmdHelpClick
  end
  object OptionsTabs: TPageControl
    Left = 0
    Top = 0
    Width = 433
    Height = 297
    ActivePage = Colors
    TabIndex = 1
    TabOrder = 3
    object General: TTabSheet
      Caption = 'General'
      object NewSettings: TGroupBox
        Left = 8
        Top = 8
        Width = 209
        Height = 169
        Caption = 'New File Settings'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object Label1: TLabel
          Left = 48
          Top = 28
          Width = 49
          Height = 13
          Alignment = taRightJustify
          Caption = 'New Font:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label2: TLabel
          Left = 25
          Top = 60
          Width = 72
          Height = 13
          Alignment = taRightJustify
          Caption = 'New Font Size:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label5: TLabel
          Left = 24
          Top = 92
          Width = 73
          Height = 13
          Alignment = taRightJustify
          Caption = 'Fixed Tab Size:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object cbFont: TComboBox
          Left = 104
          Top = 20
          Width = 97
          Height = 21
          ItemHeight = 13
          TabOrder = 0
          Text = 'Courier New'
          OnChange = cbFontChange
          Items.Strings = (
            'Courier'
            'Courier New'
            'Fixedsys')
        end
        object cbSize: TComboBox
          Left = 104
          Top = 52
          Width = 65
          Height = 21
          ItemHeight = 13
          TabOrder = 1
          Text = '10'
          Items.Strings = (
            '8'
            '10'
            '11'
            '12'
            '14'
            '16'
            '18')
        end
        object FixedTabSize: TCSpinEdit
          Left = 104
          Top = 83
          Width = 41
          Height = 22
          Increment = 4
          MaxValue = 20
          MinValue = 4
          TabOrder = 2
          Value = 4
        end
        object AssemblyTabs: TRadioButton
          Left = 96
          Top = 120
          Width = 105
          Height = 17
          Caption = 'Assembly Tabs'
          TabOrder = 3
        end
        object FixedTabs: TRadioButton
          Left = 96
          Top = 144
          Width = 97
          Height = 17
          Caption = 'Fixed Tabs'
          Checked = True
          TabOrder = 4
          TabStop = True
        end
      end
      object ActiveInfo: TGroupBox
        Left = 224
        Top = 8
        Width = 193
        Height = 169
        Caption = 'Current File Info'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        object Label3: TLabel
          Left = 67
          Top = 28
          Width = 30
          Height = 13
          Alignment = taRightJustify
          Caption = 'Font:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label4: TLabel
          Left = 40
          Top = 60
          Width = 58
          Height = 13
          Alignment = taRightJustify
          Caption = 'Font Size:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label6: TLabel
          Left = 8
          Top = 92
          Width = 89
          Height = 13
          Alignment = taRightJustify
          Caption = 'Fixed Tab Size:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label7: TLabel
          Left = 40
          Top = 124
          Width = 59
          Height = 13
          Alignment = taRightJustify
          Caption = 'Tab Type:'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object CurrentFont: TLabel
          Left = 104
          Top = 28
          Width = 61
          Height = 13
          Caption = 'Courier  New'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object CurrentFontSize: TLabel
          Left = 104
          Top = 60
          Width = 12
          Height = 13
          Caption = '10'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object CurrentTabSize: TLabel
          Left = 104
          Top = 92
          Width = 6
          Height = 13
          Caption = '4'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object CurrentTabType: TLabel
          Left = 104
          Top = 124
          Width = 25
          Height = 13
          Caption = 'Fixed'
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
      end
      object Environment: TGroupBox
        Left = 8
        Top = 184
        Width = 209
        Height = 81
        Caption = 'Environment'
        TabOrder = 2
        object AutoIndent: TCheckBox
          Left = 32
          Top = 16
          Width = 153
          Height = 25
          Caption = 'Auto Indent'
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = AutoIndentClick
          OnKeyPress = AutoIndentKeyPress
        end
        object RealTabs: TCheckBox
          Left = 32
          Top = 40
          Width = 153
          Height = 25
          Caption = 'Real Tabs'
          TabOrder = 1
          OnClick = RealTabsClick
          OnKeyPress = RealTabsKeyPress
        end
      end
    end
    object Colors: TTabSheet
      Caption = 'Colors'
      ImageIndex = 1
      object Label8: TLabel
        Left = 8
        Top = 0
        Width = 38
        Height = 13
        Caption = '&Element'
        FocusControl = Element
      end
      object Label9: TLabel
        Left = 312
        Top = 16
        Width = 62
        Height = 13
        Caption = 'Color &Presets'
        FocusControl = SyntaxCombo
      end
      object Label10: TLabel
        Left = 160
        Top = 112
        Width = 38
        Height = 13
        Caption = 'Preview'
        FocusControl = Element
      end
      object ColorBos: TGroupBox
        Left = 8
        Top = 112
        Width = 145
        Height = 153
        Caption = '&Color'
        TabOrder = 0
        TabStop = True
        object StaticText1: TStaticText
          Left = 8
          Top = 16
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clBlack
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText2: TStaticText
          Left = 40
          Top = 16
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clMaroon
          ParentColor = False
          TabOrder = 1
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText3: TStaticText
          Left = 72
          Top = 16
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clGreen
          ParentColor = False
          TabOrder = 2
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText4: TStaticText
          Left = 104
          Top = 16
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clOlive
          ParentColor = False
          TabOrder = 3
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText5: TStaticText
          Left = 8
          Top = 48
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clNavy
          ParentColor = False
          TabOrder = 4
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText6: TStaticText
          Left = 40
          Top = 48
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clPurple
          ParentColor = False
          TabOrder = 5
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText7: TStaticText
          Left = 72
          Top = 48
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clTeal
          ParentColor = False
          TabOrder = 6
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText8: TStaticText
          Left = 104
          Top = 48
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clGray
          ParentColor = False
          TabOrder = 7
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText9: TStaticText
          Left = 8
          Top = 80
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clMedGray
          ParentColor = False
          TabOrder = 8
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText10: TStaticText
          Left = 40
          Top = 80
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clRed
          ParentColor = False
          TabOrder = 9
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText11: TStaticText
          Left = 72
          Top = 80
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clLime
          ParentColor = False
          TabOrder = 10
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText12: TStaticText
          Left = 104
          Top = 80
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clYellow
          ParentColor = False
          TabOrder = 11
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText13: TStaticText
          Left = 8
          Top = 112
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clBlue
          ParentColor = False
          TabOrder = 12
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText14: TStaticText
          Left = 40
          Top = 112
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clFuchsia
          ParentColor = False
          TabOrder = 13
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText15: TStaticText
          Left = 72
          Top = 112
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clAqua
          ParentColor = False
          TabOrder = 14
          TabStop = True
          OnClick = StaticTextClick
        end
        object StaticText16: TStaticText
          Left = 104
          Top = 112
          Width = 33
          Height = 33
          AutoSize = False
          BevelInner = bvLowered
          BevelKind = bkSoft
          BevelOuter = bvRaised
          BorderStyle = sbsSingle
          Color = clWhite
          ParentColor = False
          TabOrder = 15
          TabStop = True
          OnClick = StaticTextClick
        end
      end
      object Element: TListBox
        Tag = 1
        Left = 8
        Top = 16
        Width = 145
        Height = 89
        ItemHeight = 13
        Items.Strings = (
          'Code'
          'Comment'
          'Directive'
          'Label'
          'Macro/Other'
          'Structured'
          'Structure Error'
          'Text'
          'Background')
        TabOrder = 1
        OnClick = ElementClick
      end
      object TextAttributes: TGroupBox
        Left = 168
        Top = 16
        Width = 129
        Height = 73
        Caption = 'Text Attributes'
        TabOrder = 2
        TabStop = True
        object Bold: TCheckBox
          Left = 8
          Top = 16
          Width = 97
          Height = 17
          Caption = '&Bold'
          TabOrder = 0
          OnClick = BoldClick
        end
        object Italic: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = '&Italic'
          TabOrder = 1
          OnClick = ItalicClick
        end
        object Underline: TCheckBox
          Left = 8
          Top = 48
          Width = 97
          Height = 17
          Caption = '&Underline'
          TabOrder = 2
          OnClick = UnderlineClick
        end
      end
      object Panel1: TPanel
        Left = 160
        Top = 128
        Width = 257
        Height = 129
        BevelInner = bvLowered
        BevelOuter = bvLowered
        Color = clWhite
        TabOrder = 3
        object commentLbl: TLabel
          Left = 8
          Top = 5
          Width = 161
          Height = 19
          AutoSize = False
          Caption = '* Syntax Highlight'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
        end
        object labelLbl: TLabel
          Left = 8
          Top = 24
          Width = 49
          Height = 19
          AutoSize = False
          Caption = 'START'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clPurple
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
        end
        object errorLbl: TLabel
          Left = 32
          Top = 81
          Width = 113
          Height = 19
          AutoSize = False
          Caption = 'of <NE> tehn'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
        end
        object codeLbl: TLabel
          Left = 64
          Top = 24
          Width = 113
          Height = 19
          AutoSize = False
          Caption = 'MOVE.B #1,D0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
        end
        object structuredLbl: TLabel
          Left = 32
          Top = 62
          Width = 113
          Height = 19
          AutoSize = False
          Caption = 'if <NE> then'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clMaroon
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
        end
        object otherLbl: TLabel
          Left = 64
          Top = 43
          Width = 161
          Height = 19
          AutoSize = False
          Caption = 'Macro/Other'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clOlive
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
        end
        object directiveLbl: TLabel
          Left = 64
          Top = 100
          Width = 41
          Height = 19
          AutoSize = False
          Caption = 'DC.B'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGreen
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
        end
        object textLbl: TLabel
          Left = 104
          Top = 100
          Width = 65
          Height = 19
          AutoSize = False
          Caption = #39'HELLO'#39
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clTeal
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
        end
      end
      object SyntaxCombo: TComboBox
        Left = 312
        Top = 32
        Width = 105
        Height = 21
        ItemHeight = 13
        TabOrder = 4
        Text = 'Color1'
        OnChange = SyntaxComboChange
        Items.Strings = (
          'Color1'
          'Color2'
          'No Color'
          'Custom'
          'Disabled')
      end
      object PrintBlack: TCheckBox
        Left = 312
        Top = 72
        Width = 97
        Height = 17
        Caption = 'Print w/Black'
        Checked = True
        Enabled = False
        State = cbChecked
        TabOrder = 5
      end
    end
  end
end
