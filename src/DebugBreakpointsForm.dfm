object DebugBreakpointsForm1: TDebugBreakpointsForm1
  Left = 776
  Top = 112
  AutoScroll = False
  BorderStyle = bsSizeToolWin
  Caption = 'Breakpoints'
  ClientHeight = 172
  ClientWidth = 256
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
  DesignSize = (
    256
    172)
  PixelsPerInch = 96
  TextHeight = 13
  object VirtualStringTree1: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 256
    Height = 172
    Anchors = [akLeft, akTop, akRight, akBottom]
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    HintMode = hmTooltip
    Images = ImageList1
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ShowHint = True
    TabOrder = 0
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toFullRowSelect]
    TreeOptions.StringOptions = [toSaveCaptions]
	OnDblClick = VirtualStringTree1DblClick
    OnGetText = VirtualStringTree1GetText
    OnGetImageIndex = VirtualStringTree1GetImageIndex
    Columns = <
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 25
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 60
        WideText = 'Type'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 2
        Width = 200
        WideText = 'Breakpoint data'
      end
      item
        Options = [coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 3
        Width = 40
        WideText = 'Hits'
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
    Left = 40
    Top = 24
    object Addbreakpoint1: TMenuItem
      Caption = 'Add breakpoint...'
      OnClick = Addbreakpoint1Click
    end
    object Editbreakpoint1: TMenuItem
      Caption = 'Edit breakpoint...'
      OnClick = Editbreakpoint1Click
    end
    object Removebreakpoint1: TMenuItem
      Caption = 'Remove breakpoint'
      OnClick = Removebreakpoint1Click
    end
    object Removeallbreakpoints1: TMenuItem
      Caption = 'Remove all breakpoints'
      OnClick = Removeallbreakpoints1Click
    end
  end
  object ImageList1: TImageList
    Height = 9
    Width = 9
    Left = 72
    Top = 24
    Bitmap = {
      494C010104000900040009000900FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000240000001B0000000100180000000000640B
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001900001900001900001900001900
      0000000000000000000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
      0000000000000000190000190000190000190000190000000000000000000000
      00C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000000000190000FF00
      00FF0000FF0000FF0000FF000019000000000000C0C0C0808080808080808080
      808080808080C0C0C00000000000000000190000FF007F26007F26007F260000
      FF000019000000000000C0C0C0808080808080808080808080808080C0C0C000
      00000000190000FF0000FF0000FF0000FF0000FF0000FF0000FF000019C0C0C0
      808080808080808080808080808080808080808080C0C0C00000190000FF0000
      FF007F2600FF4C007F260000FF0000FF000019C0C0C0808080808080808080C0
      C0C0808080808080808080C0C0C00000190000FF0000FF0000FF0000FF0000FF
      0000FF0000FF000019C0C0C08080808080808080808080808080808080808080
      80C0C0C00000190000FF0000FF007F2621FF00007F260000FF0000FF000019C0
      C0C0808080808080808080C0C0C0808080808080808080C0C0C00000190000FF
      0000FF0000FF0000FF0000FF0000FF0000FF000019C0C0C08080808080808080
      80808080808080808080808080C0C0C00000190000FF0000FF007F2621FF0000
      7F260000FF0000FF000019C0C0C0808080808080808080C0C0C0808080808080
      808080C0C0C00000190000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
      19C0C0C0808080808080808080808080808080808080808080C0C0C000001900
      7F26007F26007F2621FF00007F26007F26007F26000019C0C0C0808080808080
      808080C0C0C0808080808080808080C0C0C00000190000FF0000FF0000FF0000
      FF0000FF0000FF0000FF000019C0C0C080808080808080808080808080808080
      8080808080C0C0C0000019007F2600FF4C00FF4C00FF4C00FF4C00FF4C007F26
      000019C0C0C0808080C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0808080C0C0C00000
      000000190000FF0000FF0000FF0000FF0000FF000019000000000000C0C0C080
      8080808080808080808080808080C0C0C00000000000000000190000FF0000FF
      0000FF0000FF0000FF000019000000000000C0C0C08080808080808080808080
      80808080C0C0C000000000000000000000001900001900001900001900001900
      0000000000000000000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
      0000000000000000190000190000190000190000190000000000000000000000
      00C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000424D3E00000000000000
      3E00000028000000240000001B0000000100010000000000D800000000000000
      00000000000000000000000000000000FFFFFF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000C1E0F0783000000080C0603010000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000080C06030
      10000000C1E0F078300000000000000000000000000000000000000000000000
      0000}
  end
end
