object Form1: TForm1
  Left = 192
  Top = 124
  Width = 1085
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
  OnDestroy = destroy
  OnMouseDown = mys_dole
  OnMouseMove = mys_poh
  OnMouseUp = mys_hore
  OnResize = resize
  PixelsPerInch = 96
  TextHeight = 13
  object TrackBar1: TTrackBar
    Left = 904
    Top = 24
    Width = 150
    Height = 45
    Orientation = trHorizontal
    Frequency = 1
    Position = 2
    SelEnd = 0
    SelStart = 0
    TabOrder = 0
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnChange = ambi
  end
  object Button1: TButton
    Left = 16
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 120
    Top = 8
  end
end
