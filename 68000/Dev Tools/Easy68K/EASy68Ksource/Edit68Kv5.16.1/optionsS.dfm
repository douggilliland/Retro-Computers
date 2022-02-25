object Options: TOptions
  Left = 420
  Top = 167
  BorderStyle = bsToolWindow
  Caption = 'EASy68K Assembler Options'
  ClientHeight = 394
  ClientWidth = 492
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
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object cmdOK: TButton
    Left = 304
    Top = 360
    Width = 80
    Height = 25
    Hint = 'Save Settings'
    Caption = '&OK'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = cmdOKClick
  end
  object cmdCancel: TButton
    Left = 400
    Top = 360
    Width = 80
    Height = 25
    Caption = 'C&ancel'
    TabOrder = 1
    OnClick = cmdCancelClick
  end
  object PageControl: TPageControl
    Left = 16
    Top = 16
    Width = 465
    Height = 337
    ActivePage = tbsAssOpt
    TabIndex = 0
    TabOrder = 2
    object tbsAssOpt: TTabSheet
      Caption = 'Assembler Options'
      object GroupBox1: TGroupBox
        Left = 24
        Top = 8
        Width = 417
        Height = 113
        Caption = 'Assembler Options'
        TabOrder = 0
        object chkGenList: TCheckBox
          Left = 16
          Top = 24
          Width = 201
          Height = 17
          Hint = 'Generates a list file upon assembly [RECOMMENDED]'
          Caption = 'Generate List File'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 0
        end
        object chkGenSRec: TCheckBox
          Left = 16
          Top = 48
          Width = 177
          Height = 17
          Hint = 'Generate a S-Record file upon assembly  [RECOMENDED]'
          Caption = 'Generate S-Record'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 1
        end
        object chkSave: TCheckBox
          Left = 152
          Top = 24
          Width = 249
          Height = 17
          Hint = 'If checked source will be saved before assembly'
          Caption = 'Auto Save Modified Source Before Assembling'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object chkShowWarnings: TCheckBox
          Left = 16
          Top = 72
          Width = 145
          Height = 17
          Caption = 'Show Warnings'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object chkBitfield: TCheckBox
          Left = 152
          Top = 48
          Width = 169
          Height = 17
          Caption = 'Assemble Bit Field Instructions'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
      end
      object GroupBox2: TGroupBox
        Left = 24
        Top = 136
        Width = 417
        Height = 81
        Caption = 'List File Options'
        TabOrder = 1
        object chkCrossRef: TCheckBox
          Left = 16
          Top = 24
          Width = 105
          Height = 17
          Hint = 'Cross Reference list file'
          Caption = 'Cross Reference'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 0
        end
        object chkMacEx: TCheckBox
          Left = 160
          Top = 48
          Width = 105
          Height = 17
          Hint = 'Expand macros in list file'
          Caption = 'Macros Expanded'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
        object chkConstantsEx: TCheckBox
          Left = 16
          Top = 48
          Width = 121
          Height = 17
          Hint = 'Expand constants in list file'
          Caption = 'Constants Expanded'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
        end
        object chkStrucEx: TCheckBox
          Left = 160
          Top = 24
          Width = 145
          Height = 17
          Hint = 'Expand macros in list file'
          Caption = 'Structured Expanded'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Template'
      ImageIndex = 2
      object Save: TButton
        Left = 368
        Top = 280
        Width = 89
        Height = 25
        Caption = '&Save Template'
        TabOrder = 0
        OnClick = SaveClick
      end
      object Template: TRichEdit
        Left = 8
        Top = 8
        Width = 441
        Height = 265
        PlainText = True
        ScrollBars = ssBoth
        TabOrder = 1
        WantTabs = True
        WordWrap = False
      end
    end
  end
end
