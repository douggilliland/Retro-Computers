object findDialogFrm: TfindDialogFrm
  Left = 1159
  Top = 362
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Find'
  ClientHeight = 98
  ClientWidth = 272
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
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
  object findText: TEdit
    Left = 72
    Top = 8
    Width = 193
    Height = 21
    TabOrder = 0
    OnChange = findTextChange
  end
  object findNextBtn: TButton
    Left = 192
    Top = 32
    Width = 73
    Height = 25
    Caption = 'Find  (F3)'
    Default = True
    Enabled = False
    TabOrder = 1
    OnClick = findNextBtnClick
  end
  object cancelBtn: TButton
    Left = 192
    Top = 64
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = cancelBtnClick
  end
end
