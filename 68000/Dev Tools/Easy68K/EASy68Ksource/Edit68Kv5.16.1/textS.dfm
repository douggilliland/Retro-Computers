object TextStuff: TTextStuff
  Left = 330
  Top = 387
  Width = 674
  Height = 461
  Caption = 'TextStuff'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  Icon.Data = {
    0000010002002020100000000000E80200002600000010101000000000002801
    00000E0300002800000020000000400000000100040000000000800200000000
    0000000000000000000000000000000000000000800000800000008080008000
    0000800080008080000080808000C0C0C0000000FF0000FF000000FFFF00FF00
    0000FF00FF00FFFF0000FFFFFF00000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000BFF
    FB0000FFFBFFFBFFF0000BFFFBF00FFBFF0000FBFFFBFFFBF0000FFBFFF00BFF
    FBF00BFFFBFFFBFFFB00FBFFFBF00FFBFFFBFFFBFFFBFFFBFFFBFFFBFFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFBFFFBFFFBFFFBFFFBFFFBFFFBFFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFBFFFBFFFBFFFBFFFBFFFBFFFBFFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFB000000000000000000000000FFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFBFFFBFFFBFFFBFFFBFFFBFFFBFFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFB000000000000000000000000FFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFBFFFBFFFBFFFBFFFBFFFBFFFBFFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFB000000000000000000000000FFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFBFFFBFFFBFFFBFFFBFFFBFFFBFFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF00FFBFFFBFFFBFFFBFFFBFFFBFFFBFFF00BFF
    FBFFFBFFFBFFFBFFFBFFFBFFFBF0000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8180
    0301018003000180030000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000008000
    0001FFFFFFFFFFFFFFFFFFFFFFFF280000001000000020000000010004000000
    0000C00000000000000000000000000000000000000000000000000080000080
    00000080800080000000800080008080000080808000C0C0C0000000FF0000FF
    000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0000000000000000000000
    00000000000000000000000000000FB000BFBF000FB00BFBFBFBFBFBFBF00FBF
    BFBFBFBFBFB00BFBFBFBFBFBFBF00F000000000000B00BFBFBFBFBFBFBF00F00
    0000000000B00BFBFBFBFBFBFBF00F000000000000B00BFBFBFBFBFBFBF00FBF
    BFBFBFBFBFB000000000000000000000000000000000FFFF0000FFFF00008811
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000080010000FFFF0000}
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter3: TSplitter
    Left = 0
    Top = 409
    Width = 658
    Height = 9
    Cursor = crVSplit
    Align = alBottom
    Beveled = True
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 390
    Width = 658
    Height = 19
    Constraints.MaxHeight = 19
    Constraints.MinHeight = 19
    Panels = <
      item
        Width = 90
      end
      item
        Width = 60
      end
      item
        Text = 'Insert'
        Width = 50
      end
      item
        Width = 50
      end
      item
        Text = 
          '________________________________________________________________' +
          '^'
        Width = 50
      end>
    SimplePanel = False
  end
  object Messages: TListView
    Left = 0
    Top = 418
    Width = 658
    Height = 5
    Hint = 'double click error to highlight in source'
    Align = alBottom
    Columns = <
      item
        Caption = 'Line '
      end
      item
        AutoSize = True
        Caption = 'Error Message'
      end>
    ColumnClick = False
    Constraints.MinHeight = 5
    Enabled = False
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ParentShowHint = False
    PopupMenu = PopupMenu2
    ShowHint = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = MessagesDblClick
  end
  object ProgressBar: TProgressBar
    Left = 0
    Top = 372
    Width = 658
    Height = 18
    Align = alBottom
    Min = 0
    Max = 100
    TabOrder = 3
    Visible = False
  end
  object SourceText: TRichEditPlus
    Left = 0
    Top = 0
    Width = 658
    Height = 372
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    HideSelection = False
    Lines.Strings = (
      '')
    ParentFont = False
    PlainText = True
    PopupMenu = PopupMenu1
    ScrollBars = ssBoth
    TabOrder = 0
    WantTabs = True
    WordWrap = False
    OnChange = SourceTextChange
    OnKeyDown = SourceTextKeyDown
    OnKeyPress = SourceTextKeyPress
    OnKeyUp = SourceTextKeyUp
    OnMouseDown = SourceTextMouseDown
    OnMouseMove = SourceTextMouseMove
    OnMouseUp = SourceTextMouseUp
    OnProtectChange = SourceTextProtectChange
    OnSelectionChange = SourceTextSelectionChange
    OnVertScroll = SourceTextVertScroll
  end
  object PopupMenu1: TPopupMenu
    Left = 136
    Top = 80
    object Undo1: TMenuItem
      Action = Main.EditUndo
    end
    object Redo1: TMenuItem
      Action = Main.EditRedo
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Cut1: TMenuItem
      Action = Main.EditCut1
    end
    object Copy1: TMenuItem
      Action = Main.EditCopy1
    end
    object Paste1: TMenuItem
      Action = Main.EditPaste1
    end
    object SelectAll1: TMenuItem
      Action = Main.EditSelectAll1
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object CommentSelection1: TMenuItem
      Action = Main.EditCommentAdd1
    end
    object UncommentSelection1: TMenuItem
      Action = Main.EditUncomment1
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object EditorReload1: TMenuItem
      Caption = '&Reload File'
      OnClick = EditorReload1Click
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 84
    Top = 80
    object ClearErrorMessages1: TMenuItem
      Caption = '&Clear Error Messages'
      OnClick = ClearErrorMessages
    end
  end
  object HighlightTimer: TTimer
    Enabled = False
    Interval = 400
    OnTimer = HighlightTimerTimer
    Left = 184
    Top = 80
  end
end
