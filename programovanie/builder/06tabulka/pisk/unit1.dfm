object Form1: TForm1
  Left = 146
  Top = 99
  Width = 532
  Height = 397
  Caption = 'Pi'#353'kvorky'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 376
    Top = 136
    Width = 7
    Height = 38
    Caption = ' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -32
    Font.Name = 'Light Script'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object sg1: TStringGrid
    Left = 8
    Top = 8
    Width = 345
    Height = 345
    Color = clSkyBlue
    ColCount = 20
    DefaultColWidth = 16
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 20
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goTabs]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    OnClick = tah
  end
  object Button1: TButton
    Left = 384
    Top = 288
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 384
    Top = 328
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 2
    OnClick = Button2Click
  end
end
