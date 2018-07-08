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

unit DebugBreakpointEditForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DbgpWinSocket, NppDockingForm;

type
  TDebugBreakpointEditForm1 = class(TNppDockingForm)
    Label1: TLabel;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    CheckBox1: TCheckBox;
    Edit4: TEdit;
    Edit5: TEdit;
    ComboBox3: TComboBox;
    Label10: TLabel;
    Label11: TLabel;
    Button1: TButton;
    Button2: TButton;
    Edit6: TEdit;
    Label12: TLabel;
    Edit7: TEdit;
    Label13: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    breakpoint: TBreakpoint;
    procedure SetBreakpoint(bp: TBreakpoint);
  end;

var
  DebugBreakpointEditForm1: TDebugBreakpointEditForm1;

implementation

{$R *.dfm}

procedure TDebugBreakpointEditForm1.Button1Click(Sender: TObject);
begin
  if (self.ComboBox1.Text = 'line') then self.breakpoint.breakpointtype := btLine;
  if (self.ComboBox1.Text = 'call') then self.breakpoint.breakpointtype := btCall;
  if (self.ComboBox1.Text = 'return') then self.breakpoint.breakpointtype := btReturn;
  if (self.ComboBox1.Text = 'exception') then self.breakpoint.breakpointtype := btException;
  if (self.ComboBox1.Text = 'conditional') then self.breakpoint.breakpointtype := btConditional;
  if (self.ComboBox1.Text = 'watch') then self.breakpoint.breakpointtype := btWatch;
  if (self.ComboBox2.Text = 'Enabled') then self.breakpoint.state := true;
  if (self.ComboBox2.Text = 'Disabled') then self.breakpoint.state := false;

  self.breakpoint.filename := self.Edit1.Text;
  try self.breakpoint.lineno := StrToInt(self.Edit2.Text); except on EConvertError do self.breakpoint.lineno := 0; end;
  self.breakpoint.functionname := self.Edit3.Text;
  self.breakpoint.classname := self.Edit6.Text;
  self.breakpoint.temporary := self.CheckBox1.Checked;
  self.breakpoint.exception := self.Edit4.Text;
  try self.breakpoint.hit_value := StrToInt(self.Edit5.Text); except on EConvertError do self.breakpoint.hit_value := 0; end;

  self.breakpoint.hit_condition := self.ComboBox3.Text;
  self.breakpoint.expression := self.Edit7.Text;

  { do I need to "return" mrOk? }
end;

procedure TDebugBreakpointEditForm1.ComboBox1Change(Sender: TObject);
begin
  { mask shit }
  self.ComboBox1.Enabled := false; {self.ComboBox2.Enabled := false;}
  {self.ComboBox3.Enabled := false;}
  self.Edit1.Enabled := false; self.Edit2.Enabled := false; self.Edit3.Enabled := false;
  self.Edit4.Enabled := false; {self.Edit5.Enabled :=} self.Edit6.Enabled := false;
  self.CheckBox1.Enabled := false;
  self.Edit7.Enabled := false;

  if (self.ComboBox1.Text = 'line') or (self.ComboBox1.Text = 'conditional') then
  begin
    self.Edit1.Enabled := true; self.Edit2.Enabled := true; // filename // line
    self.Edit7.Enabled := true; // expression
  end
  else
  if (self.ComboBox1.Text = 'call') or (self.ComboBox1.Text = 'return')  then
  begin
    self.Edit3.Enabled := true; self.Edit6.Enabled := true; // function // class
  end
  else
  if (self.ComboBox1.Text = 'exception') then
  begin
    self.Edit4.Enabled := true; // exception
  end
  else
  if (self.ComboBox1.Text = 'watch') then
  begin
    self.Edit7.Enabled := true; // expression
  end;

  if (self.breakpoint.id = '') then
  begin
    self.ComboBox1.Enabled := true; // type
    self.CheckBox1.Enabled := true; // temporary
  end;
  self.Button1.Enabled := true;
end;

procedure TDebugBreakpointEditForm1.SetBreakpoint(bp: TBreakpoint);
begin
  self.breakpoint := bp;

  case (bp.breakpointtype) of
  btLine: self.ComboBox1.ItemIndex := 0;//.Text := 'line';
  btCall: self.ComboBox1.ItemIndex := 1;//.Text := 'call';
  btReturn: self.ComboBox1.ItemIndex := 2;//.Text := 'return';
  btException: self.ComboBox1.ItemIndex := 3;//.Text := 'exception';
  end;
  if (bp.state) then self.ComboBox2.ItemIndex := 0;//.Text := 'Enabled';
  if (not bp.state) then self.ComboBox2.ItemIndex := 1;//.Text := 'Disabled';
  self.Edit1.Text := self.breakpoint.filename;
  self.Edit2.Text := IntToStr(self.breakpoint.lineno);
  self.Edit3.Text := self.breakpoint.functionname;
  self.Edit6.Text := self.breakpoint.classname;
  self.CheckBox1.Checked := self.breakpoint.temporary;
  self.Edit4.Text := self.breakpoint.exception;
  self.Edit5.Text := IntToStr(self.breakpoint.hit_value);
  self.ComboBox3.Text := self.breakpoint.hit_condition;
  self.Edit7.Text := self.breakpoint.expression;
  if (self.breakpoint.id <> '') then self.Label11.Caption := self.breakpoint.id;

  self.ComboBox1Change(nil);
end;

end.
