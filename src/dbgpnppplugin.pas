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

unit dbgpnppplugin;
{
  This file "extends" the NppPlugin unit and implemets
  the startup routines... The main dll handler calls these routines...
}
interface

uses
  NppPlugin,
  MainForm, nppdockingform,
  ConfigForm, Forms, SciSupport,
  Classes, Dialogs, IniFiles, DbgpWinSocket, Messages, AboutForm;

const
  MARKER_ARROW = 3;
  MARKER_BREAK = 4;
type
  TDbgpNppPluginConfig = record
    maps: TMaps;
    refresh_local: boolean;
    refresh_global: boolean;
    use_source: boolean;
    local_setup: boolean;
    start_closed: boolean;
    break_first_line: boolean;
    max_depth: integer;
    max_children: integer;
    listen_port: integer;
    max_data: integer;
  end;
  TDbgpMenuState = ( dmsOff, dmsDisconnected, dmsConnected );
  TDbgpNppPlugin = class(TNppPlugin)
  private
    MainForm: TNppDockingForm1;
    ConfigForm: TConfigForm1;
    AboutForm: TAboutForm1;
    menuEvalIndex: Integer;
    procedure GrayFuncItem(i: integer);
    procedure EnableFuncItem(i: integer);
    procedure InitMarkers;
  public

    //maps: TMaps;
    config: TDbgpNppPluginConfig;
    constructor Create;
    destructor Destroy; override;

    procedure BeNotified(sn: PSCNotification); override;

    procedure FuncDebugger;
    procedure FuncConfig;
    procedure FuncStepInto;
    procedure FuncStepOver;
    procedure FuncStepOut;
    procedure FuncRunTo;
    procedure FuncRun;
    procedure FuncStop;
    procedure FuncEval;
    procedure FuncAbout;
    procedure FuncBreakpoint;
    procedure FuncLocalContext;
    procedure FuncGlobalContext;
    procedure FuncStack;
    procedure FuncBreakpoints;
    procedure FuncWatches;
    procedure ReadMaps(var maps: TMaps);
    procedure WriteMaps(conf: TDbgpNppPluginConfig);

    procedure ChangeMenu(state: TDbgpMenuState);
  end;

var
  Npp: TDbgpNppPlugin;

procedure _FuncDebugger; cdecl;
procedure _FuncConfig; cdecl;
procedure _FuncStepInto; cdecl;
procedure _FuncStepOver; cdecl;
procedure _FuncStepOut; cdecl;
procedure _FuncRunTo; cdecl;
procedure _FuncRun; cdecl;
procedure _FuncStop; cdecl;
procedure _FuncEval; cdecl;
procedure _FuncAbout; cdecl;
procedure _FuncBreakpoint; cdecl;
procedure _FuncLocalContext; cdecl;
procedure _FuncGlobalContext; cdecl;
procedure _FuncStack; cdecl;
procedure _FuncBreakpoints; cdecl;
procedure _FuncWatches; cdecl;

implementation

{ TDbgpNppPlugin }
uses
  Windows,Graphics,SysUtils,Controls;

//var   x:TToolbarIcons;


// Check if the bit at ABitIndex position is 1 (true) or 0 (false)
function IsBitSet(const AValueToCheck, ABitIndex: Integer): Boolean;
begin
  Result := AValueToCheck and (1 shl ABitIndex) <> 0;
end;

procedure TDbgpNppPlugin.BeNotified(sn: PSCNotification);
var
  x:^TToolbarIcons;
  tr: TTextRange;
  s: string;
  i: integer;
  j: integer;
begin

  if (sn^.nmhdr.code = NPPN_READY) then
  begin
	 // ShowMessage('NPPN_READY');
	  self.InitMarkers;
	  FuncDebugger();//Mx+
	  self.MainForm.Hide();	
   
  end;
  

  if (Assigned(self.MainForm) and Assigned(self.MainForm.sock) and Assigned(self.MainForm.ServerSocket1) and self.MainForm.ServerSocket1.Active) then 
  begin
	  if (not self.MainForm.sock.Connected) then exit;//Mx+
	  if (sn^.nmhdr.code = SCN_DWELLSTART) then
	  begin
		//ShowMessage('SCN_DWELLSTART');
		//if (Assigned(self.TestForm)) then self.TestForm.OnDwell();
		//ShowMessage('SCN_DWELLSTART '+IntToStr(sn^.position));
		//self.MainForm.state

		s := '';
		SendMessage(self.NppData.ScintillaMainHandle, SCI_SETWORDCHARS, 0, LPARAM(PChar('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_$->')));
		tr.chrg.cpMin := SendMessage(self.NppData.ScintillaMainHandle, SCI_WORDSTARTPOSITION, sn^.position, 0);
		SendMessage(self.NppData.ScintillaMainHandle, SCI_SETWORDCHARS, 0, LPARAM(PChar('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_')));
		tr.chrg.cpMax := SendMessage(self.NppData.ScintillaMainHandle, SCI_WORDENDPOSITION, sn^.position, 0);

		if (tr.chrg.cpMin<>-1) and (tr.chrg.cpMax-tr.chrg.cpMin>0) then
		begin
		  SetLength(s, tr.chrg.cpMax-tr.chrg.cpMin+10);
		  tr.lpstrText := PChar(s);
		  SendMessage(Npp.NppData.ScintillaMainHandle, SCI_GETTEXTRANGE, 0, LPARAM(@tr));
		  SetString(s, Pchar(tr.lpstrText), StrLen(PChar(tr.lpstrText)));
		  SendMessage(self.NppData.ScintillaMainHandle, SCI_CALLTIPSHOW, sn^.position, LPARAM(PChar(s+' = Getting...')));
		  SendMessage(self.NppData.ScintillaMainHandle, SCI_SETCHARSDEFAULT, 0, 0);
		  if (s<>'') then
		  begin
			s := self.MainForm.sock.GetPropertyAsync(s);
			SendMessage(self.NppData.ScintillaMainHandle, SCI_CALLTIPSHOW, sn^.position, LPARAM(PChar(s)));
		  end;
		end;
		if (s = '') then
			SendMessage(self.NppData.ScintillaMainHandle, SCI_CALLTIPCANCEL, 0, 0);
	  end;

	  if (sn^.nmhdr.code = SCN_DWELLEND) then
	  begin
		//add a delay somehow...
		//SendMessage(self.NppData.ScintillaMainHandle, SCI_CALLTIPCANCEL, 0, 0);
	  end;

	  //Mx+ Add bookmark redirect to CTRL-CLICK
	  if (sn^.nmhdr.code = SCN_MARGINCLICK) and (sn^.margin = 1) and (sn^.modifiers and SCMOD_CTRL = SCMOD_CTRL) then      //Click  only to toggle breakpoint
	  begin
	
		  self.GetFileLine(s,i);
		  i := SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_LINEFROMPOSITION, sn.position, 0);

		  j := SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_MARKERGET, i,24);
		 //  ShowMessage('SCN_MARGINCLICK '+IntToStr(j));
		  if (IsBitSet(j, 24))  then
			 SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_MARKERDELETE, i, 24)  //Remove bookmark if already present
		  else
			 SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_MARKERADD, i, 24);  //Add bookmark and it will be removed with click

	
	  end;

	 // if (sn^.nmhdr.code = SCN_DOUBLECLICK) then ShowMessage('SCN_DOUBLECLICK');
	 // if (sn^.nmhdr.code = SCN_MARGINCLICK) and (sn^.margin = 1) and (sn^.modifiers and SCMOD_CTRL = SCMOD_CTRL) then    //Ctrl+Click
	  if (sn^.nmhdr.code = SCN_MARGINCLICK) and (sn^.margin = 1) and not (sn^.modifiers and SCMOD_CTRL = SCMOD_CTRL) then  //Mx+ 'Click  only' to toggle breakpoint
	  begin
	
		  self.GetFileLine(s,i);
		  i := SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_LINEFROMPOSITION, sn.position, 0);

		  //Mx+ Remove Bookmark with default click button
		  SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_MARKERDELETE, i, 24);  //Remove bookmark if already present
		  SendMessage(self.NppData.ScintillaMainHandle, SciSupport.SCI_MARKERADD, i, 24);  //Add bookmark and it will be removed with click
			
		//  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERDELETE, i, MARKER_BREAK);   //Always remove (IF bugged)
		  
		  self.MainForm.ToggleBreakpoint(s,i+1);
		  //ShowMessage('SCN_MARGINCLICK '+IntToStr(i));

	
	  end;
  end;

  if (sn^.nmhdr.code = SCN_MODIFIED) and (sn^.modificationType and SC_MOD_CHANGEMARKER = SC_MOD_CHANGEMARKER) then
  begin
//    ShowMessage('SCN_MODIFIED SC_MOD_CHANFEMARKER '+IntToStr(sn^.line));
  end;

  if (HWND(sn^.nmhdr.hwndFrom) = self.NppData.NppHandle) then
  begin
    if (sn^.nmhdr.code = NPPN_TB_MODIFICATION) then
    begin
      New(x);
      x^.ToolbarIcon := 0;
      x^.ToolbarBmp := LoadImage(Hinstance, 'IDB_DBGP_TEST', IMAGE_BITMAP, 0, 0, (LR_DEFAULTSIZE or LR_LOADMAP3DCOLORS));
      SendMessage(Npp.NppData.NppHandle, NPPM_ADDTOOLBARICON, self.FuncArray[0].CmdID, LPARAM(x));
    end;
    if (sn^.nmhdr.code = NPPN_SHUTDOWN) then
    begin
      if (Assigned(self.MainForm)) then self.MainForm.Hide;
      if (Assigned(self.MainForm)) then self.MainForm.Free;
      self.MainForm := nil;
    end;
  end;
end;

constructor TDbgpNppPlugin.Create;
var
  sk: PShortcutKey;
  i: Integer;
begin
  inherited;
  // Setup menu items
  SetLength(self.FuncArray,21);

  // #112 = F1... pojma nimam od kje...
  self.PluginName := 'DBGp';

  i := 0;

  StringToWideChar('Debugger', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncDebugger;
  New(self.FuncArray[i].ShortcutKey);
  inc(i);

  StringToWideChar('-', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := nil;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('Step Into', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncStepInto;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #118; // F7
  inc(i);

  StringToWideChar('Step Over', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncStepOver;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #119; // F8
  inc(i);

  StringToWideChar('Step Out', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncStepOut;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := true;
  sk.Key := #119; // Shift+F8
  inc(i);

  StringToWideChar('Run to', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncRunTo;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('Run', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncRun;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := false; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #120; // F9
  inc(i);

  StringToWideChar('Stop', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncStop;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('-', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := nil;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  self.menuEvalIndex := i;
  StringToWideChar('Eval', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncEval;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #118; // Ctrl+F7
  inc(i);

  StringToWideChar('Toggle Breakpoint', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncBreakpoint;
  New(self.FuncArray[i].ShortcutKey);
  sk := self.FuncArray[i].ShortcutKey;
  sk.IsCtrl := true; sk.IsAlt := false; sk.IsShift := false;
  sk.Key := #120; // Ctrl+F9
  inc(i);

  // add stack and context items...

  StringToWideChar('-', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := nil;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('Local Context', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncLocalContext;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('Global Context', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncGlobalContext;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('Stack', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncStack;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('Breakpoints', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncBreakpoints;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('Watches', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncWatches;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('-', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := nil;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('Config...', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncConfig;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('-', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := nil;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);

  StringToWideChar('About...', self.FuncArray[i].ItemName, FuncItemNameLen);
  self.FuncArray[i].Func := _FuncAbout;
  self.FuncArray[i].ShortcutKey := nil;
  inc(i);


 
	 
	 
	 
end;


destructor TDbgpNppPlugin.Destroy;
begin
  if (Assigned(self.MainForm)) then self.MainForm.Close;
  if (Assigned(self.MainForm)) then self.MainForm.Free;
  self.MainForm := nil;
  inherited;
end;

{ hook }
procedure _FuncDebugger; cdecl;
begin
  Npp.FuncDebugger;
end;
procedure _FuncConfig; cdecl;
begin
  Npp.FuncConfig;
end;
procedure _FuncStepInto; cdecl;
begin
  Npp.FuncStepInto;
end;
procedure _FuncStepOver; cdecl;
begin
  Npp.FuncStepOver;
end;
procedure _FuncStepOut; cdecl;
begin
  Npp.FuncStepOut;
end;
procedure _FuncRunTo; cdecl;
begin
  Npp.FuncRunTo;
end;
procedure _FuncRun; cdecl;
begin
  Npp.FuncRun;
end;
procedure _FuncStop; cdecl;
begin
  Npp.FuncStop;
end;
procedure _FuncEval; cdecl;
begin
  Npp.FuncEval;
end;
procedure _FuncAbout; cdecl;
begin
  Npp.FuncAbout;
end;
procedure _FuncBreakpoint; cdecl;
begin
  Npp.FuncBreakpoint;
end;
procedure _FuncLocalContext; cdecl;
begin
  Npp.FuncLocalContext;
end;
procedure _FuncGlobalContext; cdecl;
begin
  Npp.FuncGlobalContext;
end;
procedure _FuncBreakpoints;
begin
  Npp.FuncBreakpoints;
end;
procedure _FuncStack;
begin
  Npp.FuncStack;
end;
procedure _FuncWatches;
begin
  Npp.FuncWatches;
end;

procedure TDbgpNppPlugin.FuncDebugger;
begin
  self.ReadMaps(self.config.maps);
  // do some menu related stuff - njah...
  self.ChangeMenu(dmsDisconnected);
  if (Assigned(self.MainForm)) then
  begin
   // self.MainForm.Show; //Mx-
	self.MainForm.Toggle(); //Mx+
    exit;
  end;
  self.MainForm := TNppDockingForm1.Create(self);
  //self.MainForm.DlgId := self.FuncArray[0].CmdID;
  self.MainForm.DlgId := 0;
  //self.MainForm.Show;
  self.RegisterDockingForm(TNppDockingForm(self.MainForm)); // move code to the docking class
  self.MainForm.Visible := true;
  self.MainForm.ServerSocket1.Port := self.config.listen_port;
  if (not self.config.start_closed) then self.MainForm.BitBtnCloseClick(nil); // activate socket
  
 
   
end;

procedure TDbgpNppPlugin.FuncAbout;
begin
  self.AboutForm := TAboutForm1.Create(self);
  self.AboutForm.DlgId := self.FuncArray[11].CmdID;
  self.AboutForm.Hide;
  self.AboutForm.ShowModal;
end;

procedure TDbgpNppPlugin.FuncConfig;
var
  r: TModalResult;
begin
  self.ReadMaps(self.config.maps);
  self.ConfigForm := TConfigForm1.Create(self);
  //self.ConfigForm.DlgId := self.FuncArray[9].CmdID;
  self.ConfigForm.Hide;
  r := self.ConfigForm.ShowModal;
  self.ConfigForm := nil;
  if (r = mrOK) then
  begin
    if (Assigned(self.MainForm)) then self.MainForm.UpdateConfig;
  end;
end;

procedure TDbgpNppPlugin.FuncEval;
begin
  // show eval dlg...
  if (Assigned(self.MainForm)) then self.MainForm.DoEval;
end;

procedure TDbgpNppPlugin.FuncBreakpoint;
begin
  if (Assigned(self.MainForm)) and (self.MainForm.BitBtnBreakpoint.Enabled) then self.MainForm.BitBtnBreakpointClick(nil);
end;

procedure TDbgpNppPlugin.FuncRunTo;
begin
  if (Assigned(self.MainForm)) then self.MainForm.BitBtnRunToClick(nil);
end;

procedure TDbgpNppPlugin.FuncRun;
begin
  if (Assigned(self.MainForm)) then self.MainForm.DoResume(Run);
end;

procedure TDbgpNppPlugin.FuncStop;
begin
  if (Assigned(self.MainForm)) then self.MainForm.BitBtnStopClick(nil);
end;

procedure TDbgpNppPlugin.FuncStepInto;
begin
  if (Assigned(self.MainForm)) then self.MainForm.DoResume(StepInto);
end;

procedure TDbgpNppPlugin.FuncStepOut;
begin
  if (Assigned(self.MainForm)) then self.MainForm.DoResume(StepOut);
end;

procedure TDbgpNppPlugin.FuncStepOver;
begin
  if (Assigned(self.MainForm)) then self.MainForm.DoResume(StepOver);
end;

procedure TDbgpNppPlugin.FuncLocalContext;
begin
  if (Assigned(self.MainForm)) then self.MainForm.Open(dctLocalContect, true);
end;

procedure TDbgpNppPlugin.FuncGlobalContext;
begin
  if (Assigned(self.MainForm)) then self.MainForm.Open(dctGlobalContext, true);
end;

procedure TDbgpNppPlugin.FuncBreakpoints;
begin
  if (Assigned(self.MainForm)) then self.MainForm.Open(dctBreakpoints, true);
end;

procedure TDbgpNppPlugin.FuncStack;
begin
  if (Assigned(self.MainForm)) then self.MainForm.Open(dctStack, true);
end;

procedure TDbgpNppPlugin.FuncWatches;
begin
  if (Assigned(self.MainForm)) then self.MainForm.Open(dctWatches, true);
end;

procedure TDbgpNppPlugin.InitMarkers;
var
  test: array [0..18] of String;
  r: integer;
begin
  r := SendMessage(self.NppData.ScintillaMainHandle, SCI_GETMARGINMASKN, 1, 0);
  r := r or (1 shl MARKER_ARROW) or (1 shl MARKER_BREAK);
  SendMessage(self.NppData.ScintillaMainHandle, SCI_SETMARGINMASKN, 1{_SC_MARGE_SYBOLE}, r);
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETALPHA, MARKER_ARROW, 90);

  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERDEFINE,  MARKER_ARROW, SC_MARK_SHORTARROW{SC_MARK_ARROW});
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETFORE, MARKER_ARROW, $000000);
  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERSETBACK, MARKER_ARROW, $00ff00);

  test[0]  := '14 14 3 1';
  test[1]  := ' 	c #FFFFFF';
  test[2]  := '.	c #000000';
  test[3]  := 'x	c #FF0000';
  test[4]  := '              ';
  test[5]  := '              ';
  test[6]  := '    ......    ';
  test[7]  := '   .xxxxxx.   ';
  test[8]  := '  .xxxxxxxx.  ';
  test[9]  := '  .xxxxxxxx.  ';
  test[10] := '  .xxxxxxxx.  ';
  test[11] := '  .xxxxxxxx.  ';
  test[12] := '  .xxxxxxxx.  ';
  test[13] := '  .xxxxxxxx.  ';
  test[14] := '   .xxxxxx.   ';
  test[15] := '    ......    ';
  test[16] := '              ';
  test[17] := '              ';

  SendMessage(self.NppData.ScintillaMainHandle, SCI_MARKERDEFINEPIXMAP,  MARKER_BREAK, LPARAM(@test));

  self.ChangeMenu(dmsOff);
end;

procedure TDbgpNppPlugin.ReadMaps(var maps: TMaps);
var
  path: String;
  ini: TIniFile;
  xmaps: TStringList;
  i: integer;
begin
  path := self.GetPluginsConfigDir;
  path := path + '\dbgp.ini';

  ini := TIniFile.Create(path);
  xmaps := TStringList.Create();
  ini.ReadSection('Mapping',xmaps);

  SetLength(maps, xmaps.Count);
  for i:=0 to xmaps.Count-1 do
  begin
    maps[i] := TStringList.Create;
    maps[i].Delimiter := ';';
    maps[i].DelimitedText := ini.ReadString('Mapping',xmaps[i],';;');
  end;

  self.config.refresh_local := ( ini.ReadString('Misc','refresh_local','0') = '1' );
  self.config.refresh_global := ( ini.ReadString('Misc','refresh_global','0') = '1' );
  self.config.use_source := ( ini.ReadString('Misc','use_source','0') = '1' );
  self.config.start_closed := ( ini.ReadString('Misc','start_closed','0') = '1' );
  self.config.break_first_line := ( ini.ReadString('Misc','break_first_line','0') = '1' );
  self.config.listen_port := ini.ReadInteger('Misc','listen_port',9000);
  self.config.max_depth := ini.ReadInteger('Features','max_depth',3);
  self.config.max_children := ini.ReadInteger('Features','max_children',15);
  self.config.local_setup := ( ini.ReadString('Misc','local_setup','1') = '1' );
  self.config.max_data := ini.ReadInteger('Features','max_data',512);

  ini.Free;
  xmaps.Free;
end;

procedure TDbgpNppPlugin.WriteMaps(conf:TDbgpNppPluginConfig);
var
  path: string;
  ini: TIniFile;
  xmaps: TStringList;
  i: integer;
begin
  path := self.GetPluginsConfigDir;
  if (not DirectoryExists(path)) then
  begin
    ForceDirectories(path);
  end;
  path := path + '\dbgp.ini';

  ini := TIniFile.Create(path);

  xmaps := TStringList.Create();
  ini.ReadSection('Mapping',xmaps);

  for i:=0 to xmaps.Count-1 do
  begin
    ini.DeleteKey('Mapping',xmaps[i]);
  end;
  xmaps.Free;

  for i:=0 to Length(conf.maps)-1 do
  begin
    if (conf.maps[i][0] = '') and (conf.maps[i][1] = '') and (conf.maps[i][2] = '') and (conf.maps[i][3] = '') then continue;
    conf.maps[i].Delimiter := ';';
    ini.WriteString('Mapping','Map'+IntToStr(i),conf.maps[i].DelimitedText);
  end;

  SetLength(TrueBoolStrs, 1);
  SetLength(FalseBoolStrs, 1);
  TrueBoolStrs[0] := '1';
  FalseBoolStrs[0] := '0';

  ini.WriteString('Misc','refresh_local',BoolToStr(conf.refresh_local, true));
  ini.WriteString('Misc','refresh_global',BoolToStr(conf.refresh_global, true));
  ini.WriteString('Misc','use_source',BoolToStr(conf.use_source, true));
  ini.WriteString('Misc','start_closed',BoolToStr(conf.start_closed, true));
  ini.WriteString('Misc','break_first_line',BoolToStr(conf.break_first_line, true));
  ini.WriteString('Misc','local_setup',BoolToStr(conf.local_setup, true));

  ini.WriteInteger('Features','max_depth',conf.max_depth);
  ini.WriteInteger('Features','max_children',conf.max_children);
  ini.WriteInteger('Features','max_data',conf.max_data);

  ini.Free;

  // reread config
  self.ReadMaps(self.config.maps);
  
 
end;

// Test, za prikazovanje menujev
procedure TDbgpNppPlugin.GrayFuncItem(i: integer);
var
  hm: HMENU;
begin
  hm := GetMenu(self.NppData.NppHandle);
  EnableMenuItem(hm, self.FuncArray[i].CmdID, MF_BYCOMMAND or MF_DISABLED or MF_GRAYED);
  
    
end;

procedure TDbgpNppPlugin.EnableFuncItem(i: integer);
var
  hm: HMENU;
begin
  hm := GetMenu(self.NppData.NppHandle);
  EnableMenuItem(hm, self.FuncArray[i].CmdID, MF_BYCOMMAND or MF_ENABLED);

   
end;

procedure TDbgpNppPlugin.ChangeMenu(state: TDbgpMenuState);
var
  i: integer;
begin

  if (state = dmsOff) then
  begin
    for i:=2 to 7 do self.GrayFuncItem(i);
    for i:=self.menuEvalIndex to self.menuEvalIndex+1 do self.GrayFuncItem(i);
    for i:=self.menuEvalIndex+3 to self.menuEvalIndex+7 do self.GrayFuncItem(i);
  end;
  if (state = dmsConnected) then
  begin
    for i:=2 to 7 do self.EnableFuncItem(i);
    for i:=self.menuEvalIndex to self.menuEvalIndex+1 do self.EnableFuncItem(i);
    for i:=self.menuEvalIndex+3 to self.menuEvalIndex+7 do self.EnableFuncItem(i);
  end;
  if (state = dmsDisconnected) then
  begin
    for i:=2 to 7 do self.GrayFuncItem(i);
    for i:=self.menuEvalIndex to self.menuEvalIndex+1 do self.EnableFuncItem(i);
    for i:=self.menuEvalIndex+3 to self.menuEvalIndex+7 do self.EnableFuncItem(i);
  end;
  

end;

end.

