object DebugVarForm: TDebugVarForm
  Left = 353
  Top = 122
  Width = 395
  Height = 326
  BorderStyle = bsSizeToolWin
  Caption = 'Attributes'
  Color = clBtnFace
  DockSite = True
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    387
    292)
  PixelsPerInch = 96
  TextHeight = 13
  object VirtualStringTree1: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 387
    Height = 292
    Anchors = [akLeft, akTop, akRight, akBottom]
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Header.SortColumn = 0
    HintMode = hmTooltip
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ShowHint = True
    TabOrder = 0
    TreeOptions.SelectionOptions = [toFullRowSelect]
    TreeOptions.StringOptions = [toSaveCaptions]
    OnCompareNodes = VirtualStringTree1CompareNodes
    OnDblClick = VirtualStringTree1DblClick
    OnGetText = VirtualStringTree1GetText
    OnPaintText = VirtualStringTree1PaintText
    OnHeaderClick = VirtualStringTree1HeaderClick
    OnInitChildren = VirtualStringTree1InitChildren
    Columns = <
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 100
        WideText = 'Name'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 150
        WideText = 'Value'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 2
        Width = 40
        WideText = 'Type'
      end>
  end
  object JvDockClient1: TJvDockClient
    DirectDrag = False
    EnableCloseButton = False
    LeftDock = False
    TopDock = False
    RightDock = False
    DockStyle = NppDockingForm1.JvDockVSNetStyle1
    CustomDock = False
    Left = 8
    Top = 24
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 8
    Top = 56
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
  end
end
