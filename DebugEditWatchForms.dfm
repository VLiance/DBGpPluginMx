inherited DebugEditWatchForm: TDebugEditWatchForm
  Left = 248
  Top = 143
  AutoScroll = False
  Caption = 'Add watch'
  ClientHeight = 66
  Constraints.MaxHeight = 100
  Constraints.MinHeight = 100
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 54
    Height = 13
    Caption = 'Expression:'
  end
  object Expression: TEdit
    Left = 64
    Top = 8
    Width = 273
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object Button1: TButton
    Left = 264
    Top = 40
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 184
    Top = 40
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
