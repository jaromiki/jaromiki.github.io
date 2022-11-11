object Form1: TForm1
  Left = 192
  Top = 114
  Width = 698
  Height = 480
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = koniec
  OnMouseDown = dole
  OnMouseMove = pohyb
  OnMouseUp = hore
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 584
    Top = 8
    Width = 97
    Height = 281
    Lines.Strings = (
      '+1.0+0.0+0.0'
      '+0.0+1.0+0.0'
      '+0.0+0.0+1.0')
    TabOrder = 0
    OnChange = zmena
  end
  object Button1: TButton
    Left = 584
    Top = 296
    Width = 97
    Height = 33
    Caption = 'Kresli'
    TabOrder = 1
    OnClick = Button1Click
  end
  object RadioGroup1: TRadioGroup
    Left = 8
    Top = 344
    Width = 569
    Height = 97
    Caption = 'RadioGroup1'
    Columns = 5
    ItemIndex = 3
    Items.Strings = (
      'body'
      'usecky'
      'lomena'
      'lomena-zavreta'
      '3-uholnik'
      '3-uholnik-trs'
      '3-uholnik-pas'
      '4-uholnik'
      '4-uholnik-pas'
      'n-uholnik')
    TabOrder = 2
  end
  object TrackBar1: TTrackBar
    Left = 576
    Top = 344
    Width = 113
    Height = 45
    Min = 2
    Orientation = trHorizontal
    Frequency = 1
    Position = 5
    SelEnd = 0
    SelStart = 0
    TabOrder = 3
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = pribliz
  end
  object TrackBar2: TTrackBar
    Left = 576
    Top = 392
    Width = 113
    Height = 45
    Orientation = trHorizontal
    Frequency = 1
    Position = 10
    SelEnd = 0
    SelStart = 0
    TabOrder = 4
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = priesv
  end
end
