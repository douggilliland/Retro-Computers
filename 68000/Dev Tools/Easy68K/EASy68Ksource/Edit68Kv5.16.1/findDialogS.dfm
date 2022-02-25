object findDialogFrm: TfindDialogFrm
  Left = 1118
  Top = 457
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Find'
  ClientHeight = 98
  ClientWidth = 352
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
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
    Top = 48
    Width = 109
    Height = 13
    Caption = 'Match &whole word only'
    FocusControl = wholeWordChk
  end
  object Label3: TLabel
    Left = 32
    Top = 72
    Width = 56
    Height = 13
    Caption = 'Match &case'
    FocusControl = matchCaseChk
  end
  object findText: TEdit
    Left = 72
    Top = 8
    Width = 193
    Height = 21
    TabOrder = 0
    OnChange = findTextChange
  end
  object findNextBtn: TButton
    Left = 272
    Top = 8
    Width = 73
    Height = 25
    Caption = 'Find  (F3)'
    Default = True
    Enabled = False
    TabOrder = 1
    OnClick = findNextBtnClick
  end
  object cancelBtn: TButton
    Left = 272
    Top = 40
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = cancelBtnClick
  end
  object wholeWordChk: TCheckBox
    Left = 8
    Top = 48
    Width = 17
    Height = 17
    TabOrder = 3
  end
  object matchCaseChk: TCheckBox
    Left = 8
    Top = 72
    Width = 17
    Height = 17
    Caption = 'CheckBox1'
    TabOrder = 4
  end
end
