object Form1: TForm1
  Left = 410
  Top = 350
  Width = 870
  Height = 640
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clHighlightText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = kon
  OnMouseDown = dole
  OnMouseMove = pohyb
  OnMouseUp = hore
  OnPaint = Button1Click
  OnResize = opetovne
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 0
    Top = 0
    Width = 45
    Height = 16
    Caption = 'Text'#250'ra'
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label1: TLabel
    Left = 784
    Top = 0
    Width = 32
    Height = 16
    Caption = 'Body'
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Button1: TButton
    Left = 768
    Top = 568
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 0
    Top = 40
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = '0'
    OnChange = zmena
  end
  object Edit2: TEdit
    Left = 0
    Top = 64
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Text = '0'
    OnChange = zmena
  end
  object Edit3: TEdit
    Left = 0
    Top = 120
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Text = '10'
    OnChange = zmena
  end
  object Edit4: TEdit
    Left = 0
    Top = 144
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Text = '0'
    OnChange = zmena
  end
  object Edit5: TEdit
    Left = 0
    Top = 192
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    Text = '10'
    OnChange = zmena
  end
  object Edit6: TEdit
    Left = 0
    Top = 216
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    Text = '10'
    OnChange = zmena
  end
  object Edit7: TEdit
    Left = 0
    Top = 264
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 7
    Text = '0'
    OnChange = zmena
  end
  object Edit8: TEdit
    Left = 0
    Top = 288
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 8
    Text = '10'
    OnChange = zmena
  end
  object UpDown1: TUpDown
    Left = 57
    Top = 40
    Width = 16
    Height = 21
    Associate = Edit1
    Min = -20
    Max = 20
    Position = 0
    TabOrder = 9
    Wrap = False
  end
  object UpDown2: TUpDown
    Left = 57
    Top = 64
    Width = 16
    Height = 21
    Associate = Edit2
    Min = -20
    Max = 20
    Position = 0
    TabOrder = 10
    Wrap = False
  end
  object UpDown3: TUpDown
    Left = 57
    Top = 120
    Width = 16
    Height = 21
    Associate = Edit3
    Min = -20
    Max = 20
    Position = 10
    TabOrder = 11
    Wrap = False
  end
  object UpDown4: TUpDown
    Left = 57
    Top = 144
    Width = 16
    Height = 21
    Associate = Edit4
    Min = -20
    Max = 20
    Position = 0
    TabOrder = 12
    Wrap = False
  end
  object UpDown5: TUpDown
    Left = 57
    Top = 192
    Width = 16
    Height = 21
    Associate = Edit5
    Min = -20
    Max = 20
    Position = 10
    TabOrder = 13
    Wrap = False
  end
  object UpDown6: TUpDown
    Left = 57
    Top = 216
    Width = 16
    Height = 21
    Associate = Edit6
    Min = -20
    Max = 20
    Position = 10
    TabOrder = 14
    Wrap = False
  end
  object UpDown7: TUpDown
    Left = 57
    Top = 264
    Width = 16
    Height = 21
    Associate = Edit7
    Min = -20
    Max = 20
    Position = 0
    TabOrder = 15
    Wrap = False
  end
  object UpDown8: TUpDown
    Left = 57
    Top = 288
    Width = 16
    Height = 21
    Associate = Edit8
    Min = -20
    Max = 20
    Position = 10
    TabOrder = 16
    Wrap = False
  end
  object Edit9: TEdit
    Left = 784
    Top = 40
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 17
    Text = '-10'
    OnChange = zmena
  end
  object Edit10: TEdit
    Left = 784
    Top = 64
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 18
    Text = '10'
    OnChange = zmena
  end
  object Edit11: TEdit
    Left = 784
    Top = 120
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 19
    Text = '10'
    OnChange = zmena
  end
  object Edit12: TEdit
    Left = 784
    Top = 144
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 20
    Text = '10'
    OnChange = zmena
  end
  object Edit13: TEdit
    Left = 784
    Top = 192
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 21
    Text = '10'
    OnChange = zmena
  end
  object Edit14: TEdit
    Left = 784
    Top = 216
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 22
    Text = '-10'
    OnChange = zmena
  end
  object Edit15: TEdit
    Left = 784
    Top = 264
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 23
    Text = '-10'
    OnChange = zmena
  end
  object Edit16: TEdit
    Left = 784
    Top = 288
    Width = 57
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 24
    Text = '-10'
    OnChange = zmena
  end
  object UpDown9: TUpDown
    Left = 841
    Top = 40
    Width = 16
    Height = 21
    Associate = Edit9
    Min = -20
    Max = 20
    Position = -10
    TabOrder = 25
    Wrap = False
  end
  object UpDown10: TUpDown
    Left = 841
    Top = 64
    Width = 16
    Height = 21
    Associate = Edit10
    Min = -20
    Max = 20
    Position = 10
    TabOrder = 26
    Wrap = False
  end
  object UpDown11: TUpDown
    Left = 841
    Top = 120
    Width = 16
    Height = 21
    Associate = Edit11
    Min = -20
    Max = 20
    Position = 10
    TabOrder = 27
    Wrap = False
  end
  object UpDown12: TUpDown
    Left = 841
    Top = 144
    Width = 16
    Height = 21
    Associate = Edit12
    Min = -20
    Max = 20
    Position = 10
    TabOrder = 28
    Wrap = False
  end
  object UpDown13: TUpDown
    Left = 841
    Top = 192
    Width = 16
    Height = 21
    Associate = Edit13
    Min = -20
    Max = 20
    Position = 10
    TabOrder = 29
    Wrap = False
  end
  object UpDown14: TUpDown
    Left = 841
    Top = 216
    Width = 16
    Height = 21
    Associate = Edit14
    Min = -20
    Max = 20
    Position = -10
    TabOrder = 30
    Wrap = False
  end
  object UpDown15: TUpDown
    Left = 841
    Top = 264
    Width = 16
    Height = 21
    Associate = Edit15
    Min = -20
    Max = 20
    Position = -10
    TabOrder = 31
    Wrap = False
  end
  object UpDown16: TUpDown
    Left = 841
    Top = 288
    Width = 16
    Height = 21
    Associate = Edit16
    Min = -20
    Max = 20
    Position = -10
    TabOrder = 32
    Wrap = False
  end
  object Button2: TButton
    Left = 0
    Top = 576
    Width = 75
    Height = 25
    Caption = 'Full'
    TabOrder = 33
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 88
    Top = 576
    Width = 75
    Height = 25
    Caption = 'Window'
    TabOrder = 34
    OnClick = Button3Click
  end
end
