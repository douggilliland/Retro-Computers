object replaceDialogFrm: TreplaceDialogFrm
  Left = 1117
  Top = 268
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Replace'
  ClientHeight = 136
  ClientWidth = 351
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 16
    Width = 49
    Height = 13
    Caption = 'Fi&nd what:'
    FocusControl = findText
  end
  object Label2: TLabel
    Left = 32
    Top = 80
    Width = 109
    Height = 13
    Caption = 'Match &whole word only'
    FocusControl = wholeWordChk
  end
  object Label3: TLabel
    Left = 32
    Top = 104
    Width = 56
    Height = 13
    Caption = 'Match &case'
    FocusControl = matchCaseChk
  end
  object Label4: TLabel
    Left = 8
    Top = 48
    Width = 62
    Height = 13
    Caption = 'Re&place with'
    FocusControl = replaceText
  end
  object findText: TEdit
    Left = 80
    Top = 8
    Width = 185
    Height = 21
    TabOrder = 0
    OnChange = findTextChange
  end
  object wholeWordChk: TCheckBox
    Left = 8
    Top = 80
    Width = 17
    Height = 17
    TabOrder = 1
  end
  object matchCaseChk: TCheckBox
    Left = 8
    Top = 104
    Width = 17
    Height = 17
    Caption = 'CheckBox1'
    TabOrder = 2
  end
  object replaceText: TEdit
    Left = 80
    Top = 40
    Width = 185
    Height = 21
    TabOrder = 3
  end
  object findNextBtn: TButton
    Left = 272
    Top = 8
    Width = 73
    Height = 25
    Caption = '&Find Next'
    Default = True
    Enabled = False
    TabOrder = 4
    OnClick = findNextBtnClick
  end
  object cancelBtn: TButton
    Left = 272
    Top = 104
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = cancelBtnClick
  end
  object replaceBtn: TButton
    Left = 272
    Top = 40
    Width = 73
    Height = 25
    Caption = '&Replace'
    Default = True
    Enabled = False
    TabOrder = 6
    OnClick = replaceBtnClick
  end
  object replaceAllBtn: TButton
    Left = 272
    Top = 72
    Width = 73
    Height = 25
    Caption = 'Replace &All'
    Default = True
    Enabled = False
    TabOrder = 7
    OnClick = replaceAllBtnClick
  end
end
