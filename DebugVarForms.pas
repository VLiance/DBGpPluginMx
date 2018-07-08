{
    This file is part of DBGP Plugin for Notepad++
    Copyright (C) 2007  Damjan Zobo Cvetko

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit DebugVarForms;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvDockTree, JvDockControlForm, JvDockVIDStyle, JvDockVSNetStyle,
  JvComponentBase, VirtualTrees, DbgpWinSocket, DebugInspectorForm, nppplugin,
  Menus, StrUtils, NppDockingForm, Clipbrd;

type
  TNodeCompareData = record
    FullName: string;
    states: TVirtualNodeStates;
    data: string;
  end;
  PNodeCompareData = ^TNodeCompareData;
  TDebugVarForm = class(TNppDockingForm)
    VirtualStringTree1: TVirtualStringTree;
    JvDockClient1: TJvDockClient;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure VirtualStringTree1DblClick(Sender: TObject);
    procedure VirtualStringTree1PaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType);
    procedure VirtualStringTree1HeaderClick(Sender: TVTHeader;
      Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure VirtualStringTree1CompareNodes(Sender: TBaseVirtualTree;
      Node1, Node2: PVirtualNode; Column: TColumnIndex;
      var Result: Integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure VirtualStringTree1InitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure FormDestroy(Sender: TObject);
  private
    cmplist: TList;
    { Private declarations }
    function SubSetVars(ParentNode: PVirtualNode; list:TPropertyItems; CompareList: TList): Boolean;
    procedure GenerateCompareData(var list: TList; node: PVirtualNode);
    function GetCompareData(FullName: string; list: TList): PNodeCompareData;
  public
    { Public declarations }
    Npp: TNppPlugin;
    procedure SetVars(list: TPropertyItems);
    procedure ClearVars;
  end;
  TPropertyItemEx = record
    p: TPropertyItem;
    changed: boolean;
  end;
  PPropertyItemEx = ^TPropertyItemEx;
var
  DebugVarForm: TDebugVarForm;

implementation

uses
  MainForm;
{$R *.dfm}

procedure TDebugVarForm.FormCreate(Sender: TObject);
begin
  self.VirtualStringTree1.NodeDataSize := SizeOf(TPropertyItemEx);
  self.cmplist := TList.Create;
end;

procedure TDebugVarForm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  for i:=0 to cmplist.Count-1 do
  begin
    Dispose(cmplist[i]);
  end;
  cmplist.Destroy;
end;

// insane

function TDebugVarForm.GetCompareData(FullName: string; list: TList): PNodeCompareData;
var
  i: integer;
begin
  for i:=0 to list.Count-1 do
  begin
    Result := list[i];
    if (Result^.FullName = FullName) then exit;
  end;
  Result := nil;
end;

procedure TDebugVarForm.GenerateCompareData(var list: TList; node: PVirtualNode);
var
  node1: PVirtualNode;
  data: PNodeCompareData;
  Item: PPropertyItem;
begin
  if (node = nil) then exit;
  node1 := node.FirstChild;
  while (node1 <> nil) do
  begin
    New(data);
    Item := self.VirtualStringTree1.GetNodeData(node1);
    data^.FullName := Item^.fullname;
    data^.states := [];
    if (vsExpanded in node1.States) then Include(data^.states, vsExpanded);
    data^.data := Item^.data;
    list.Add(data);
    self.GenerateCompareData(list, node1);
    node1 := node1.NextSibling;
  end;
end;

procedure TDebugVarForm.SetVars(list: TPropertyItems);
var
  i: integer;
  oldxy: TPoint;

begin
  // save state (expanded)
  // save data for compare
  for i:=0 to cmplist.Count-1 do
  begin
    Dispose(cmplist[i]);
  end;
  cmplist.Clear;
  self.GenerateCompareData(cmplist, self.VirtualStringTree1.RootNode);

  oldxy := self.VirtualStringTree1.OffsetXY;

  self.VirtualStringTree1.Clear;
  self.VirtualStringTree1.BeginUpdate;

  self.SubSetVars(nil, list, cmplist);

  self.VirtualStringTree1.EndUpdate;
  self.VirtualStringTree1.SortTree(self.VirtualStringTree1.Header.SortColumn, self.VirtualStringTree1.Header.SortDirection, False);
  self.VirtualStringTree1.OffsetXY := oldxy;
end;

function TDebugVarForm.SubSetVars(ParentNode: PVirtualNode;
  list: TPropertyItems; CompareList: TList): Boolean;
var
  i: Integer;
  Node: PVirtualNode;
  Item: PPropertyItem;
  ItemEx: PPropertyItemEx;
  CompareData: PNodeCompareData;
  r: Boolean;
begin
  Result := false; // has changed nodes

  for i:=0 to Length(list)-1 do
  begin
    Node := self.VirtualStringTree1.AddChild(ParentNode);
    Item := self.VirtualStringTree1.GetNodeData(Node);
    ItemEx := self.VirtualStringTree1.GetNodeData(Node);

    Item^.name := list[i].name;
    Item^.fullname := list[i].fullname;
    Item^.datatype := list[i].datatype;
    Item^.classname := list[i].classname;
    Item^.constant := list[i].constant;
    Item^.haschildren := list[i].haschildren;
    Item^.size := list[i].size;
    Item^.page := list[i].page;
    Item^.pagesize := list[i].pagesize;
    Item^.address := list[i].address;
    Item^.key := list[i].key;
    Item^.numchildren := list[i].numchildren;
    Item^.data := list[i].data;
    Item^.children := nil;

    if ((Item^.haschildren) and ((list[i].children = nil) or (Length(list[i].children^)=0))) then
      self.VirtualStringTree1.HasChildren[Node] := true;

    ItemEx^.changed := false;
    // get compare data
    CompareData := self.GetCompareData(Item^.fullname, CompareList);
    if (CompareData <> nil) then
    begin
      if (Item^.data <> CompareData^.data) then
      begin
        ItemEx^.changed := true;
        // hilight
        // @todo: to parent
      end;
      if (vsExpanded in CompareData^.states) then Include(Node.States, vsExpanded);
    end
    else
    begin
      ItemEx^.changed := true; // ?
    end;

    // at this point the data has been compared and we can fix it for displaying
    if (Item^.datatype = 'object') then
      Item^.data := Item^.classname
    else
      Item^.data := AnsiReplaceStr(Item^.data, #10, #13+#10);

    if ((list[i].numchildren <> '0') and (list[i].children <> nil)) then
    begin
      r := self.SubSetVars(Node, list[i].children^, CompareList);
      if (r) then ItemEx^.changed := true;
    end;
    if (ItemEx^.changed) then Result := true;
  end;

end;

procedure TDebugVarForm.VirtualStringTree1GetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
  Item: PPropertyItem;
begin
  Item := PPropertyItem(Sender.GetNodeData(Node));

  case Column of
  0: if (Node.Parent <> Sender.RootNode) then CellText := Item^.name else CellText := Item^.fullname;
  1: CellText := Item^.data;
  2: CellText := Item^.datatype;
  end;
end;

procedure TDebugVarForm.VirtualStringTree1PaintText(
  Sender: TBaseVirtualTree; const TargetCanvas: TCanvas;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
var
  ItemEx: PPropertyItemEx;
begin
  ItemEx := Sender.GetNodeData(Node);
  if (ItemEx^.changed) then TargetCanvas.Font.Color := clRed;
end;

// show data
procedure TDebugVarForm.VirtualStringTree1DblClick(Sender: TObject);
var
  Item: PPropertyItem;
  i: TDebugInspectorForm1;
begin
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  Item := PPropertyItem(self.VirtualStringTree1.GetNodeData(self.VirtualStringTree1.FocusedNode));
  if (Item^.datatype = 'array') or (Item^.datatype = 'object') then
  begin
    TNppDockingForm1(self.Owner).DoEval(Item^.fullname);
  end;
  if (Item^.datatype <> 'string') then exit;
  i := TDebugInspectorForm1.Create(self);
  i.Show;
  i.SetData(Item.data);
  //i.AutoSize := true;
  //i.AutoSize := false; // wtf
  // register witn npp?
end;

procedure TDebugVarForm.ClearVars;
begin
  self.VirtualStringTree1.Clear;
end;

procedure TDebugVarForm.VirtualStringTree1HeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if (Column <> self.VirtualStringTree1.Header.SortColumn) then
  begin
    self.VirtualStringTree1.Header.SortColumn := Column;
    self.VirtualStringTree1.Header.SortDirection := sdDescending;
  end;
  if (self.VirtualStringTree1.Header.SortDirection = sdAscending) then
    self.VirtualStringTree1.Header.SortDirection := sdDescending
  else
    self.VirtualStringTree1.Header.SortDirection := sdAscending;
  self.VirtualStringTree1.SortTree(self.VirtualStringTree1.Header.SortColumn, self.VirtualStringTree1.Header.SortDirection, False);
end;

procedure TDebugVarForm.VirtualStringTree1CompareNodes(
  Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
  Column: TColumnIndex; var Result: Integer);
var
  Item1, Item2: PPropertyItem;
  s1,s2: string;
  i1,i2: integer;
begin
  Item1 := PPropertyItem(Sender.GetNodeData(Node1));
  Item2 := PPropertyItem(Sender.GetNodeData(Node2));
  case Column of
  0: begin s1 := Item1.name; s2 := Item2.name; end;
  1: begin s1 := Item1.data; s2 := Item2.data; end;
  2: begin s1 := Item1.datatype; s2 := Item2.datatype; end;
  end;
  try
    i1 := StrToInt(s1);
    i2 := StrToInt(s2);
    if (i1 < i2) then Result := -1 else Result := 1;
  except
    if (s1 < s2) then Result := -1 else Result := 1;
  end;
end;

procedure TDebugVarForm.PopupMenu1Popup(Sender: TObject);
begin
  self.Copy1.Enabled := (self.VirtualStringTree1.FocusedNode <> nil);
end;

procedure TDebugVarForm.Copy1Click(Sender: TObject);
var
  Item: PPropertyItem;
begin
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  Item := PPropertyItem(self.VirtualStringTree1.GetNodeData(self.VirtualStringTree1.FocusedNode));
  if (Item^.data <> '') then Clipboard.SetTextBuf(PChar(Item^.data));
end;

procedure TDebugVarForm.VirtualStringTree1InitChildren(
  Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Item: PPropertyItem;
  list: TPropertyItems;
begin
  Item := self.VirtualStringTree1.GetNodeData(node);
  ChildCount := 0;
  if TNppDockingForm1(self.Owner).sock.state <> DbgpWinSocket.dsBreak then exit;
  TNppDockingForm1(self.Owner).sock.GetPropertyAsync(Item^.fullname, list);
  if ((Length(list)>0) and (list[0].datatype <> 'Error')) then // there should be more correct error handling
  begin
    self.VirtualStringTree1.BeginUpdate;
    SubSetVars(Node, list[0].children^, cmplist);
    self.VirtualStringTree1.EndUpdate;
    self.VirtualStringTree1.SortTree(self.VirtualStringTree1.Header.SortColumn, self.VirtualStringTree1.Header.SortDirection, False);
    ChildCount := Length(list[0].children^);
  end;

end;

end.
