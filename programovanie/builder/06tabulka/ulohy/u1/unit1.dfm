object Form1: TForm1
  Left = 214
  Top = 114
  Width = 870
  Height = 640
  Caption = 'Form1'
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
  object StringGrid1: TStringGrid
    Left = 208
    Top = 80
    Width = 320
    Height = 120
    Options = [goFixedVertLine, goFixedHorzLine, goRangeSelect, goDrawFocusSelected, goEditing]
    TabOrder = 0
    OnDrawCell = aaa
  end
  object Button1: TButton
    Left = 120
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
end
