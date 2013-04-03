object FormMenu: TFormMenu
  Left = 183
  Top = 71
  Width = 1143
  Height = 657
  Caption = 'FormMenu'
  Color = clHotLight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object NumberOfPlayersLabel: TLabel
    Left = 8
    Top = 16
    Width = 127
    Height = 18
    Caption = 'Anzahl der Spieler'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWhite
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object NumberOfPlayersEdit: TEdit
    Left = 144
    Top = 16
    Width = 17
    Height = 18
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
    Text = '2'
  end
end
