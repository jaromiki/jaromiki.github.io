object Form1: TForm1
  Left = 192
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
  OnMouseDown = dole
  OnMouseMove = pohyb
  OnMouseUp = hore
  PixelsPerInch = 96
  TextHeight = 13
  object TrackBar1: TTrackBar
    Left = 560
    Top = 568
    Width = 150
    Height = 45
    Max = 0
    Min = -100
    Orientation = trHorizontal
    Frequency = 1
    Position = -50
    SelEnd = 0
    SelStart = 0
    TabOrder = 0
    TickMarks = tmBottomRight
    TickStyle = tsAuto
  end
  object Timer1: TTimer
    Interval = 20
    OnTimer = Timer1Timer
    Left = 816
    Top = 48
  end
end
