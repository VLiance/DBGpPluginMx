object DebugEvalForm1: TDebugEvalForm1
  Left = 339
  Top = 111
  ActiveControl = ComboBox1
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Eval'
  ClientHeight = 66
  ClientWidth = 333
  Color = clBtnFace
  Constraints.MaxHeight = 100
  Constraints.MinHeight = 100
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    333
    66)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 160
    Top = 40
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 248
    Top = 40
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 8
    Width = 313
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
  end
  object CheckBoxReuseResult: TCheckBox
    Left = 8
    Top = 40
    Width = 129
    Height = 17
    Caption = 'Open in same window'
    TabOrder = 3
  end
end
