object Form1: TForm1
  Left = 893
  Top = 181
  Width = 692
  Height = 460
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = Timer1Timer
  OnCreate = FormCreate
  OnDestroy = odchod
  OnMouseDown = dole
  OnMouseMove = pohyb
  OnMouseUp = hore
  PixelsPerInch = 96
  TextHeight = 13
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
end
