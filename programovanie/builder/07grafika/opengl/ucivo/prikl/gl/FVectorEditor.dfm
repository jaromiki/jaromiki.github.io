object VectorEditorForm: TVectorEditorForm
  Left = 234
  Top = 109
  BorderStyle = bsDialog
  Caption = 'XYZ editor'
  ClientHeight = 122
  ClientWidth = 242
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 32
    Width = 39
    Height = 16
    Caption = 'X axis'
    Font.Charset = ANSI_CHARSET
    Font.Color = clRed
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 64
    Width = 38
    Height = 16
    Caption = 'Y axis'
    Font.Charset = ANSI_CHARSET
    Font.Color = clLime
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 96
    Width = 37
    Height = 16
    Caption = 'Z axis'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object IMx: TImage
    Left = 128
    Top = 32
    Width = 16
    Height = 16
    Picture.Data = {
      07544269746D617076010000424D760100000000000076000000280000002000
      000010000000010004000000000000010000130B0000130B0000100000000000
      0000000000000000800000800000008080008000000080008000808000007F7F
      7F00BFBFBF000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
      FF003333333333333333333333FFFFF3333333333999993333333333F77777FF
      F33333399999999933333337777FF377FF3333993370739993333377FF373F37
      7FF3399993000339993337777F777F3377F3393999707333993337F777373333
      37FF993399933333399377F3777FF333377F993339903333399377F33737FF33
      377F993333707333399377F333377FF3377F993333101933399377F333777FFF
      377F993333000993399377FF3377737FF7733993330009993933373FF3777377
      F7F339993300039999333773FF777F777733339993707339933333773FF7FFF7
      7333333999999999333333377733377733333333399999333333333337777733
      3333}
    Transparent = True
    Visible = False
  end
  object IMy: TImage
    Left = 128
    Top = 64
    Width = 16
    Height = 16
    Picture.Data = {
      07544269746D617076010000424D760100000000000076000000280000002000
      000010000000010004000000000000010000130B0000130B0000100000000000
      0000000000000000800000800000008080008000000080008000808000007F7F
      7F00BFBFBF000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
      FF003333333333333333333333FFFFF3333333333999993333333333F77777FF
      F33333399999999933333337777FF377FF3333993370739993333377FF373F37
      7FF3399993000339993337777F777F3377F3393999707333993337F777373333
      37FF993399933333399377F3777FF333377F993339903333399377F33737FF33
      377F993333707333399377F333377FF3377F993333101933399377F333777FFF
      377F993333000993399377FF3377737FF7733993330009993933373FF3777377
      F7F339993300039999333773FF777F777733339993707339933333773FF7FFF7
      7333333999999999333333377733377733333333399999333333333337777733
      3333}
    Transparent = True
    Visible = False
  end
  object IMz: TImage
    Left = 128
    Top = 96
    Width = 16
    Height = 16
    Picture.Data = {
      07544269746D617076010000424D760100000000000076000000280000002000
      000010000000010004000000000000010000130B0000130B0000100000000000
      0000000000000000800000800000008080008000000080008000808000007F7F
      7F00BFBFBF000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
      FF003333333333333333333333FFFFF3333333333999993333333333F77777FF
      F33333399999999933333337777FF377FF3333993370739993333377FF373F37
      7FF3399993000339993337777F777F3377F3393999707333993337F777373333
      37FF993399933333399377F3777FF333377F993339903333399377F33737FF33
      377F993333707333399377F333377FF3377F993333101933399377F333777FFF
      377F993333000993399377FF3377737FF7733993330009993933373FF3777377
      F7F339993300039999333773FF777F777733339993707339933333773FF7FFF7
      7333333999999999333333377733377733333333399999333333333337777733
      3333}
    Transparent = True
    Visible = False
  end
  object EDx: TEdit
    Left = 56
    Top = 31
    Width = 65
    Height = 21
    TabOrder = 0
    Text = '0'
    OnChange = EDxChange
  end
  object EDy: TEdit
    Left = 56
    Top = 63
    Width = 65
    Height = 21
    TabOrder = 1
    Text = '0'
    OnChange = EDyChange
  end
  object EDz: TEdit
    Left = 56
    Top = 95
    Width = 65
    Height = 21
    TabOrder = 2
    Text = '0'
    OnChange = EDzChange
  end
  object BBok: TBitBtn
    Left = 160
    Top = 32
    Width = 75
    Height = 25
    TabOrder = 3
    Kind = bkOK
  end
  object BBcancel: TBitBtn
    Left = 160
    Top = 64
    Width = 75
    Height = 25
    TabOrder = 4
    Kind = bkCancel
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 242
    Height = 25
    ButtonHeight = 21
    ButtonWidth = 56
    Caption = 'ToolBar'
    EdgeBorders = []
    Flat = True
    ShowCaptions = True
    TabOrder = 5
    object TBx: TToolButton
      Left = 0
      Top = 0
      Caption = 'XVector'
      ImageIndex = 0
      OnClick = TBxClick
    end
    object TBy: TToolButton
      Left = 56
      Top = 0
      Caption = 'YVector'
      ImageIndex = 1
      OnClick = TByClick
    end
    object TBz: TToolButton
      Left = 112
      Top = 0
      Caption = 'ZVector'
      ImageIndex = 2
      OnClick = TBzClick
    end
    object ToolButton5: TToolButton
      Left = 168
      Top = 0
      Width = 12
      Caption = 'ToolButton5'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object TBnull: TToolButton
      Left = 180
      Top = 0
      Caption = 'NullVector'
      ImageIndex = 3
      OnClick = TBnullClick
    end
  end
end
