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

unit DebugStackForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, JvDockTree, JvDockControlForm, JvDockVCStyle,
  JvComponentBase, JvDockVIDStyle, JvDockVSNetStyle, DbgpWinSocket, Menus, NppDockingForm;

type
  TGetContextCB = procedure(Sender: TObject; Depth: Integer) of Object;
  TStackSelectCB = procedure(Sender: TObject; filename: String; lineno: integer; Depth: Integer) of Object;
  TDebugStackForm1 = class(TNppDockingForm)
    VirtualStringTree1: TVirtualStringTree;
    JvDockClient1: TJvDockClient;
    PopupMenu1: TPopupMenu;
    GetContext1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure VirtualStringTree1DblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GetContext1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  private
    { Private declarations }
    FOnGetContext: TGetContextCB;
    FOnStackSelect: TStackSelectCB;
  public
    { Public declarations }
    procedure SetStack(Stack: TStackList);
    procedure ClearStack;
  published
    property OnGetContext: TGetContextCB read FOnGetContext write FOnGetContext;
    property OnStackSelect: TStackSelectCB read FOnStackSelect write FOnStackSelect;
  end;

var
  DebugStackForm1: TDebugStackForm1;

implementation

uses
  MainForm;
{$R *.dfm}

procedure TDebugStackForm1.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  //MessageBeep(0);
end;

procedure TDebugStackForm1.SetStack(Stack: TStackList);
var
  i: Integer;
  Node: PVirtualNode;
  StackItem: PStackItem;
begin
  //
  self.VirtualStringTree1.Clear;
  self.VirtualStringTree1.BeginUpdate;

  for i:=0 to Length(Stack)-1 do
  begin
    Node := self.VirtualStringTree1.AddChild(nil);
    //self.VirtualStringTree1.NodeDataSize := SizeOf(TStackItem);
    StackItem := self.VirtualStringTree1.GetNodeData(Node);
    StackItem^.level := Stack[i].level;
    StackItem^.stacktype := Stack[i].stacktype;
    StackItem^.filename := Stack[i].filename;
    StackItem^.lineno := Stack[i].lineno;
    StackItem^.where := Stack[i].where;
 end;

  self.VirtualStringTree1.EndUpdate;
end;

procedure TDebugStackForm1.VirtualStringTree1GetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: WideString);
var
  si: PStackItem;
begin
  si := PStackItem(Sender.GetNodeData(Node));
  //
  case (Column) of
  0: CellText := IntToStr(si^.level);
  1: CellText := si^.filename;
  2: CellText := IntToStr(si^.lineno);
  3: CellText := si^.where;
  4: CellText := si^.stacktype;
  end;
end;

procedure TDebugStackForm1.VirtualStringTree1DblClick(Sender: TObject);
var
  si: PStackItem;
begin
//  self.VirtualStringTree1.se
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  si := self.VirtualStringTree1.GetNodeData(self.VirtualStringTree1.FocusedNode);

  if (Assigned(self.FOnStackSelect)) then self.FOnStackSelect(self, si^.filename, si^.lineno, si^.level);
end;

procedure TDebugStackForm1.FormCreate(Sender: TObject);
begin
  self.VirtualStringTree1.NodeDataSize := SizeOf(TStackItem);
end;

procedure TDebugStackForm1.ClearStack;
begin
  self.VirtualStringTree1.Clear;
end;

procedure TDebugStackForm1.GetContext1Click(Sender: TObject);
var
  si: PStackItem;
begin
//  self.VirtualStringTree1.se
  if (self.VirtualStringTree1.FocusedNode = nil) then exit;
  si := self.VirtualStringTree1.GetNodeData(self.VirtualStringTree1.FocusedNode);

  if (Assigned(self.FOnGetContext)) then
  begin
    self.FOnGetContext(self, si^.level);
  end;
end;

procedure TDebugStackForm1.PopupMenu1Popup(Sender: TObject);
begin
  self.GetContext1.Enabled := true;
  if (self.VirtualStringTree1.FocusedNode = nil) then
  begin
    self.GetContext1.Enabled := false;
  end;
end;

end.
