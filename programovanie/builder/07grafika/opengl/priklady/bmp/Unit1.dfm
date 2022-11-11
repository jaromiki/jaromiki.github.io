object Form1: TForm1
  Left = 192
  Top = 124
  Width = 558
  Height = 428
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
  OnResize = resize
  PixelsPerInch = 96
  TextHeight = 13
  object Timer1: TTimer
    Interval = 20
    OnTimer = Timer1Timer
    Left = 64
    Top = 56
  end
end
