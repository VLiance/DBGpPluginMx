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

unit DebugBreakpointsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvComponentBase, JvDockControlForm, VirtualTrees, DbgpWinSocket,
  Menus, DebugBreakpointEditForm, NppDockingForm, ImgList;

type
  TBreakpointEditCB = procedure(Sender: TComponent; bp: TBreakpoint) of Object;
  TDebugBreakpointsForm1 = class(TNppDockingForm)
    VirtualStringTree1: TVirtualStringTree;
    JvDockClient1: TJvDockClient;
    PopupMenu1: TPopupMenu;
    Addbreakpoint1: TMenuItem;
    Editbreakpoint1: TMenuItem;
    Removebreakpoint1: TMenuItem;
    ImageList1: TImageList;
    Removeallbreakpoints1: TMenuItem;
    procedure Addbreakpoint1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Editbreakpoint1Click(Sender: TObject);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Removebreakpoint1Click(Sender: TObject);
    procedure VirtualStringTree1GetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure Removeallbreakpoints1Click(Sender: TObject);
  private
    { Private declarations }
    FOnBreakpointAdd: TBreakpointEditCB;
    FOnBreakpointEdit: TBreakpointEditCB;
    FOnBreakpointDelete: TBreakpointEditCB;
  public
    { Public declarations }
    breakpoints: TBreakpoints;
    procedure SetBreakpoints(bps: TBreakpoints);
    procedure AddBreakpoint(bp: TBreakpoint);
    procedure RemoveBreakpoint(bp: TBreakpoint);
  published
    property OnBreakpointAdd: TBreakpointEditCB read FOnBreakpointAdd write FOnBreakpointAdd;
    property OnBreakpointEdit: TBreakpointEditCB read FOnBreakpointEdit write FOnBreakpointEdit;
    property OnBreakpointDelete: TBreakpointEditCB read FOnBreakpointDelete write FOnBreakpointDelete;
  end;

var
  DebugBreakpointsForm1: TDebugBreakpointsForm1;

implementation

{$R *.dfm}

uses
  MainForm;

procedure TDebugBreakpointsForm1.SetBreakpoints(bps: TBreakpoints);
var
  i,j: Integer;
  Node: PVirtualNode;
  bp: PBreakpoint;
begin
  // save current sci handlers
  for i:=0 to Length(bps)-1 do
  begin
    for j:=0 to Length(self.breakpoints)-1 do
    begin
      if (bps[i].id = self.breakpoints[j].id) then
      begin
        bps[i].sci_handler := self.breakpoints[j].sci_handler;
        break;
      end;
    end;
  end;

  self.breakpoints := bps;

  self.VirtualStringTree1.Clear;
  self.VirtualStringTree1.BeginUpdate;

  for i:=0 to Length(bps)-1 do
  begin
    Node := self.VirtualStringTree1.AddChild(nil);
    bp := self.VirtualStringTree1.GetNodeData(Node);

    bp^ := bps[i];
  end;
  self.VirtualStringTree1.EndUpdate;
end;

procedure TDebugBreakpointsForm1.FormCreate(Sender: TObject);
begin
  self.VirtualStringTree1.NodeDataSize := SizeOf(TBreakpoint);
  SetLength(self.breakpoints,0);
end;

procedure TDebugBreakpointsForm1.Addbreakpoint1Click(Sender: TObject);
var
  bpf: TDebugBreakpointEditForm1;
  r: integer;
begin
  bpf := TDebugBreakpointEditForm1.Create(self);
  r := bpf.ShowModal;
  if (r = mrOk) then self.AddBreakpoint(bpf.breakpoint);
  if (r = mrOk) and (Assigned(self.FOnBreakpointAdd)) then self.FOnBreakpointAdd(self, bpf.breakpoint);
  bpf.Free;
end;

procedure TDebugBreakpointsForm1.Editbreakpoint1Click(Sender: TObject);
var
  bpf: TDebugBreakpointEditForm1;
  r,i: integer;
  bp: PBreakpoint;
begin
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  bp := self.VirtualStringTree1.GetNodeData(self.VirtualStringTree1.FocusedNode);

  bpf := TDebugBreakpointEditForm1.Create(self);
  bpf.SetBreakpoint(bp^);
  r := bpf.ShowModal;
  if (r = mrOK) and (Assigned(self.FOnBreakpointEdit)) then
  begin
    bp^ := bpf.breakpoint; // prepisi?
    // izoliraj genericno kodo - update breakpoint
    for i:=0 to Length(self.breakpoints)-1 do
    begin
      if (bpf.breakpoint.id <> self.breakpoints[i].id) then continue;
      self.breakpoints[i] := bpf.breakpoint;
      break;
    end;
    self.FOnBreakpointEdit(self, bpf.breakpoint);
  end;
  bpf.Free;
end;

procedure TDebugBreakpointsForm1.Removebreakpoint1Click(Sender: TObject);
var
  bp: PBreakpoint;
  bp2: TBreakpoint;
begin
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  bp := self.VirtualStringTree1.GetNodeData(self.VirtualStringTree1.FocusedNode);
  bp2 := bp^;
  self.RemoveBreakpoint(bp2);
  if (Assigned(self.FOnBreakpointDelete)) then self.FOnBreakpointDelete(self, bp2);
end;

procedure TDebugBreakpointsForm1.AddBreakpoint(bp: TBreakpoint);
begin
  SetLength(self.breakpoints, Length(self.breakpoints)+1);
  if (bp.id = '') then bp.id := IntToStr(Length(self.breakpoints)-1);
  self.breakpoints[Length(self.breakpoints)-1] := bp;
  self.SetBreakpoints(self.breakpoints);
end;

procedure TDebugBreakpointsForm1.VirtualStringTree1GetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
  bp: PBreakpoint;
begin
  bp := PBreakpoint(Sender.GetNodeData(Node));
  //
  case (Column) of
  0: begin
       CellText := '';
       if (bp^.temporary) then CellText := CellText + 'T';
       if (bp^.state) then CellText := CellText + 'E' else CellText := CellText + 'D';
     end;
  1: begin
       case (bp^.breakpointtype) of
       btLine: CellText := 'Line';
       btCall: CellText := 'Call';
       btReturn: CellText := 'Return';
       btException: CellText := 'Exception';
       btConditional: CellText := 'Conditional';
       btWatch: CellText := 'Watch';
       end;
     end;
  2: begin
       case (bp^.breakpointtype) of
       btLine: CellText := bp^.filename+':'+IntToStr(bp^.lineno);
       btCall: CellText := bp^.classname+'::'+bp^.functionname;
       btReturn: CellText := bp^.classname+'::'+bp^.functionname;
       btException: CellText := bp^.exception;
       btConditional: CellText := bp^.expression;
       btWatch: CellText := bp^.expression;
       end;
     end;
  3: CellText := IntToStr(bp^.hit_count);
  end;
end;

procedure TDebugBreakpointsForm1.VirtualStringTree1GetImageIndex(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
var
  bp: PBreakpoint;
begin
  ImageIndex := -1;
  if (Column <> 0) then exit;
  bp := Sender.GetNodeData(Node);
  ImageIndex := 0;
  if (bp^.temporary) then inc(ImageIndex,2);
  if (not bp^.state) then inc(ImageIndex);
end;

procedure TDebugBreakpointsForm1.PopupMenu1Popup(Sender: TObject);
begin
  self.Editbreakpoint1.Enabled := true;
  self.Removebreakpoint1.Enabled := true;
  if (self.VirtualStringTree1.FocusedNode = nil) then
  begin
    self.Editbreakpoint1.Enabled := false;
    self.Removebreakpoint1.Enabled := false;
  end;
end;

procedure TDebugBreakpointsForm1.RemoveBreakpoint(bp: TBreakpoint);
var
  tmp: TBreakpoints;
  i, j: integer;
begin
  SetLength(tmp, Length(self.breakpoints));
  j := 0;
  for i := 0 to Length(self.breakpoints)-1 do
  begin
    if (bp.id = self.breakpoints[i].id) then continue;
    tmp[j] := self.breakpoints[i];
    inc(j);
  end;
  SetLength(tmp, j);
  self.SetBreakpoints(tmp);
end;

procedure TDebugBreakpointsForm1.Removeallbreakpoints1Click(
  Sender: TObject);
var
  bp2: TBreakpoint;
begin
  while (Length(self.breakpoints)>0) do
  begin
    bp2 := self.breakpoints[0];
    self.RemoveBreakpoint(self.breakpoints[0]);
    if (Assigned(self.FOnBreakpointDelete)) then self.FOnBreakpointDelete(self, bp2);
  end;
end;

end.
