object Form1: TForm1
  Left = 192
  Top = 107
  Width = 1684
  Height = 675
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 729
    Height = 600
  end
  object Label1: TLabel
    Left = 752
    Top = 8
    Width = 96
    Height = 13
    Caption = 'Po'#269'et vrcholov 2-50'
  end
  object Edit1: TEdit
    Left = 752
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '5'
  end
  object Button1: TButton
    Left = 928
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Za'#269#237'name'
    TabOrder = 1
    OnClick = Button1Click
  end
  object StringGrid1: TStringGrid
    Left = 744
    Top = 64
    Width = 537
    Height = 529
    DefaultColWidth = 32
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    TabOrder = 2
  end
end
