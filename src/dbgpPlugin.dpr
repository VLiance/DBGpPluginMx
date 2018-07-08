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

library dbgpPlugin;
{$R 'dbgpPluginRes.res' 'dbgpPluginRes.rc'}

uses
  SysUtils,
  Classes,
  Types,
  Windows,
  Dialogs,
  Messages,
  Forms,
  nppplugin in 'nppplugin.pas',
  dbgpnppplugin in 'dbgpnppplugin.pas',
  scisupport in 'SciSupport.pas',
  NppDockingForm in 'NppDockingForm.pas',
  MainForm in 'MainForm.pas' {Form1},
  DbgpWinSocket in 'DbgpWinSocket.pas',
  ConfigForm in 'ConfigForm.pas' {ConfigForm1},
  DebugStackForm in 'DebugStackForm.pas' {DebugStackForm1},
  DebugEvalForm in 'DebugEvalForm.pas' {DebugEvalForm1},
  Base64 in 'Base64.pas',
  DebugInspectorForm in 'DebugInspectorForm.pas' {DebugInspectorForm1},
  DebugRawForm in 'DebugRawForm.pas' {DebugRawForm1},
  AboutForm in 'AboutForm.pas' {AboutForm1},
  DebugBreakpointsForm in 'DebugBreakpointsForm.pas' {DebugBreakpointsForm1},
  DebugBreakpointEditForm in 'DebugBreakpointEditForm.pas' {DebugBreakpointEditForm1},
  NppForms in 'NppForms.pas' {NppForm},
  DebugVarForms in 'DebugVarForms.pas' {DebugVarForm},
  DebugContextForms in 'DebugContextForms.pas' {DebugContextForm},
  DebugWatchForms in 'DebugWatchForms.pas' {DebugWatchFrom},
  DebugEditWatchForms in 'DebugEditWatchForms.pas' {DebugEditWatchForm};

{$R *.res}

procedure DLLEntryPoint(dwReason: DWord);
begin
  case dwReason of
  DLL_PROCESS_ATTACH:
  begin
    // create the main object
    Npp := TDbgpNppPlugin.Create;
  end;
  DLL_PROCESS_DETACH:
  begin
    Npp.Destroy;
  end;
  //DLL_THREAD_ATTACH: MessageBeep(0);
  //DLL_THREAD_DETACH: MessageBeep(0);
  end;
end;

procedure setInfo(NppData: TNppData); cdecl; export;
begin
  Npp.SetInfo(NppData);
end;

function getName(): PWchar; cdecl; export;
begin
  Result := Npp.GetName;
end;

function getFuncsArray(var nFuncs:integer):Pointer;cdecl; export;
begin
  Result := Npp.GetFuncsArray(nFuncs);
end;

procedure beNotified(sn: PSCNotification); cdecl; export;
begin
  Npp.BeNotified(sn);
end;

function messageProc(msg: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; cdecl; export;
var xmsg:TMessage;
begin
  xmsg.Msg := msg;
  xmsg.WParam := wParam;
  xmsg.LParam := lParam;
  xmsg.Result := 0;
  Npp.MessageProc(xmsg);
  Result := xmsg.Result;
end;

function isUnicode():boolean; cdecl; export;
begin
  Result := true;
end;


exports
  setInfo, getName, getFuncsArray, beNotified, messageProc, isUnicode;

begin
  { First, assign the procedure to the DLLProc variable }
  DllProc := @DLLEntryPoint;
  { Now invoke the procedure to reflect that the DLL is attaching to the process }
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

