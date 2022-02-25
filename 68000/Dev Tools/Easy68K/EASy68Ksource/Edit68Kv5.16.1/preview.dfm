object PreviewForm: TPreviewForm
  Left = 213
  Top = 120
  Width = 1032
  Height = 748
  Caption = 'EASy68K Print Preview'
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
  OldCreateOrder = False
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object QuickRep1: TQuickRep
    Left = 0
    Top = 24
    Width = 816
    Height = 1056
    Frame.Color = clBlack
    Frame.DrawTop = False
    Frame.DrawBottom = False
    Frame.DrawLeft = False
    Frame.DrawRight = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    Functions.Strings = (
      'PAGENUMBER'
      'COLUMNNUMBER'
      'REPORTTITLE'
      'QRSTRINGSBAND1')
    Functions.DATA = (
      '0'
      '0'
      #39#39
      #39#39)
    Options = [FirstPageHeader, LastPageFooter]
    Page.Columns = 1
    Page.Orientation = poPortrait
    Page.PaperSize = Letter
    Page.Values = (
      127
      2794
      127
      2159
      127
      127
      0)
    PrinterSettings.Copies = 1
    PrinterSettings.Duplex = False
    PrinterSettings.FirstPage = 0
    PrinterSettings.LastPage = 0
    PrinterSettings.OutputBin = Auto
    PrintIfEmpty = True
    SnapToGrid = True
    Units = Inches
    Zoom = 100
    object QRBand1: TQRBand
      Left = 48
      Top = 48
      Width = 720
      Height = 962
      Frame.Color = clBlack
      Frame.DrawTop = False
      Frame.DrawBottom = False
      Frame.DrawLeft = False
      Frame.DrawRight = False
      AlignToBottom = False
      Color = clWhite
      ForceNewColumn = False
      ForceNewPage = False
      Size.Values = (
        2545.29166666667
        1905)
      BandType = rbDetail
      object QRRichText1: TQRRichText
        Left = 0
        Top = 0
        Width = 721
        Height = 962
        Frame.Color = clBlack
        Frame.DrawTop = False
        Frame.DrawBottom = False
        Frame.DrawLeft = False
        Frame.DrawRight = False
        Size.Values = (
          2545.29166666667
          0
          0
          1907.64583333333)
        Alignment = taLeftJustify
        AutoStretch = True
        Color = clWindow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
      end
    end
  end
end
