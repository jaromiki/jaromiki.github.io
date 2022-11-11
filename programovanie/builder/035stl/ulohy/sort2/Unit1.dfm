object Form1: TForm1
  Left = 192
  Top = 125
  Width = 1044
  Height = 540
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
  object Memo1: TMemo
    Left = 24
    Top = 16
    Width = 185
    Height = 321
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 248
    Top = 16
    Width = 75
    Height = 25
    Caption = 'abecedne'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo2: TMemo
    Left = 352
    Top = 16
    Width = 185
    Height = 321
    Lines.Strings = (
      'Memo2')
    TabOrder = 2
  end
  object Button2: TButton
    Left = 248
    Top = 56
    Width = 75
    Height = 25
    Caption = 'vysledok'
    TabOrder = 3
    OnClick = Button2Click
  end
end
