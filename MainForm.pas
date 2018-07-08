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

unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, NppDockingForm, StdCtrls, ScktComp, DbgpWinSocket, ComCtrls,
  Buttons, ExtCtrls, Grids, JvDockTree, JvDockControlForm, JvDockVCStyle,
  JvComponentBase, DebugStackForm, DebugVarForms, JvDockVIDStyle, JvDockVSNetStyle,
  DebugEvalForm, DebugRawForm, ImgList, ToolWin, DebugBreakpointsForm,
  DebugContextForms, DebugWatchForms;

type
  TDebugChildType = ( dctWatches, dctGlobalContext, dctLocalContect, dctBreakpoints, dctStack );
  TNppDockingForm1 = class(TNppDockingForm)
    ServerSocket1: TServerSocket;
    JvDockServer1: TJvDockServer;
    JvDockVSNetStyle1: TJvDockVSNetStyle;
    BitBtnStepInto: TBitBtn;
    BitBtnStepOver: TBitBtn;
    BitBtnStepOut: TBitBtn;
    BitBtnRun: TBitBtn;
    BitBtnBreakpoint: TBitBtn;
    BitBtnEval: TBitBtn;
    BitBtnClose: TBitBtn;
    BitBtnRaw: TBitBtn;
    BitBtnRunTo: TBitBtn;
    BitBtnStop: TBitBtn;
    ComboBox1: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure ServerSocket1Accept(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1GetSocket(Sender: TObject; Socket: Integer;
      var ClientSocket: TServerClientWinSocket);
    procedure ServerSocket1ClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientError(Sender: TObject;
      Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure BitBtnStepIntoClick(Sender: TObject);
    procedure BitBtnStepOverClick(Sender: TObject);
    procedure BitBtnStepOutClick(Sender: TObject);
    procedure BitBtnRunClick(Sender: TObject);
    procedure BitBtnBreakpointClick(Sender: TObject);
    procedure BitBtnEvalClick(Sender: TObject);
    procedure BitBtnCloseClick(Sender: TObject);
    procedure BitBtnRawClick(Sender: TObject);
    procedure BitBtnRunToClick(Sender: TObject);
    procedure BitBtnStopClick(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    // run to cursor
  private
    { Private declarations }
    procedure sockDbgpStack(Sender:TDbgpWinSocket; Stack: TStackList);
    procedure sockDbgpInit(Sender:TDbgpWinSocket; init: TInit);
    procedure sockDbgpEval(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems);
    procedure sockDbgpContext(Sender: TDbgpWinSocket; context: Integer; list: TPropertyItems);
    procedure sockDbgpBreak(Sender: TDbgpWinSocket; Stopped: Boolean);
    procedure sockDbgpStream(Sender: TDbgpWinSocket; stream, data:String);
    procedure sockDbgpBreakpoints(Sender: TDbgpWinSocket; breakpoints: TBreakpoints);

    procedure ContextOnRefresh(Sender: TObject);
    procedure StackOnGetContext(Sender: TObject; Depth: Integer);

    procedure BreakpointAdd(Sender: TComponent; bp: TBreakpoint);
    procedure BreakpointEdit(Sender: TComponent; bp: TBreakpoint);
    procedure BreakpointDelete(Sender: TComponent; bp: TBreakpoint);
    procedure StackSelect(Sender: TObject; filename: String; lineno: integer; Depth: integer);

    procedure WatchesOnChange(Sender: TObject; Watches: TPropertyItems);

    procedure SetupSession(Socket: TDbgpWinSocket);
    procedure SessionAdd(Socket: TCustomWinSocket);
    procedure SessionDel(Socket: TCustomWinSocket);
    procedure SessionSelect(Index: Integer);
  public
    { Public declarations }
    state: TDbgpState; // hmmm read only?
    sock: TDbgpWinSocket;
    DebugStackForm1: TDebugStackForm1;
    ContextLocalForm1: TDebugContextForm;
    ContextGlobalForm1: TDebugContextForm;
    DebugEvalForm1: TDebugEvalForm1;
    DebugRawForm1: TDebugRawForm1;
    DebugBreakpointsForm1: TDebugBreakpointsForm1;
    EvalVarForm: TDebugVarForm;
    DebugWatchForm: TDebugWatchFrom;
    destructor Destroy; override;
    procedure GotoLine(filename: string; Lineno:Integer);
    procedure DoResume(runtype: TRun);
    procedure DoEval; overload;
    procedure DoEval(data:string); overload;
    procedure SetState(state: TDbgpState);
    procedure Open(childtype: TDebugChildType; Show: boolean);
    procedure UpdateConfig;
    procedure ToggleBreakpoint(filename: string; lineno: integer);
  end;

var
  NppDockingForm1: TNppDockingForm1;

implementation

{$R *.dfm}
uses dbgpnppplugin, nppplugin, SciSupport;

destructor TNppDockingForm1.Destroy;
var
  i: Integer;
  sock: TDbgpWinSocket;
begin
  for i:=self.ComboBox1.Items.Count-1 downto 1 do
  begin
    sock := self.ComboBox1.Items.Objects[i] as TDbgpWinSocket;
    if sock<>nil then sock.Close;
  end;
  if (self.ServerSocket1.Active) then self.ServerSocket1.Close;
  inherited;
end;

{from JVCL SVN}
function ManualTabDock2(DockSite: TWinControl; Form1, Form2: TForm): TJvDockTabHostForm;
var
  TabHost: TJvDockTabHostForm;
  DockClient1, DockCLient2: TJvDockClient;
  ScreenPos: TRect;
begin
  DockClient1 := FindDockClient(Form1);
  Form1.Hide;

  Assert(Assigned(DockClient1));

  if DockClient1.DockState = JvDockState_Docking then
  begin
	ScreenPos := Application.MainForm.ClientRect; // Just making it float temporarily.
	Form1.ManualFloat(ScreenPos); // This screws up on Delphi 2010.
  end;

  DockClient2 := FindDockClient(Form2);
  Assert(Assigned(DockClient2));
  Form2.Hide;

  if DockClient2.DockState = JvDockState_Docking then
  begin
	ScreenPos := Application.MainForm.ClientRect; // Just making it float temporarily.
	Form2.ManualFloat(ScreenPos);
  end;

  TabHost := DockClient1.CreateTabHostAndDockControl(Form1, Form2);

  TabHost.ManualDock(DockSite,nil,alClient);

  ShowDockForm(Form1);
  ShowDockForm(Form2);
  Result := TabHost;
end;


procedure TNppDockingForm1.FormCreate(Sender: TObject);
var
  d: TJvDockTabHostForm;
begin
  self.Open(dctStack, false);
  self.Open(dctLocalContect, false);
  self.Open(dctGlobalContext, false);

  d := ManualTabDock2(self.JvDockServer1.BottomDockPanel, self.ContextLocalForm1, self.ContextGlobalForm1);

  self.DebugRawForm1 := TDebugRawForm1.Create(self);

  //self.DebugStackForm1.ManualDock(self.JvDockServer1.BottomDockPanel);
  //self.JvDockServer1.BottomDockPanel.ShowDockPanel(true, self.DebugStackForm1);

  self.Open(dctBreakpoints, false);

  //self.DebugBreakpointsForm1.ManualDock(self.JvDockServer1.BottomDockPanel);
  //self.JvDockServer1.BottomDockPanel.ShowDockPanel(true, self.DebugBreakpointsForm1);

  ManualTabDock2(self.JvDockServer1.BottomDockPanel, self.DebugStackForm1, self.DebugBreakpointsForm1);

  self.Open(dctWatches,false);
  ManualTabDockAddPage(d, self.DebugWatchForm);

  self.BitBtnClose.Caption := 'Turn ON';
  self.SetState(DbgpWinSocket.dsStopped);
end;

procedure TNppDockingForm1.ServerSocket1Accept(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  self.SetState(DbgpWinSocket.dsStopped);
  FlashWindow(self.Npp.NppData.NppHandle, true);
  self.Show;

  if (Assigned(self.DebugRawForm1)) then
  begin
    self.DebugRawForm1.Memo1.Lines.Add('Accept: '+Socket.RemoteAddress);
  end;
end;

procedure TNppDockingForm1.ServerSocket1GetSocket(Sender: TObject;
  Socket: Integer; var ClientSocket: TServerClientWinSocket);
begin
  ClientSocket := TDbgpWinSocket.Create(Socket,Sender as TServerWinSocket);
  self.SetupSession(ClientSocket as TDbgpWinSocket);
end;

procedure TNppDockingForm1.ServerSocket1ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  r: String;
  sock: TDbgpWinSocket;
begin
  sock := Socket as TDbgpWinSocket;
  r:=sock.ReadDBGP;
  if (Assigned(self.DebugRawForm1)) then
  begin
    self.DebugRawForm1.Memo1.Lines.AddStrings(sock.debugdata);
    self.DebugRawForm1.Memo1.Lines.Add('----');
  end;
  sock.debugdata.Clear;
end;

procedure TNppDockingForm1.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  if (Assigned(self.DebugRawForm1)) then self.DebugRawForm1.Memo1.Lines.Add('Disconnect: '+Socket.RemoteAddress);
  self.SetupSession(nil);
  self.SessionDel(Socket);
end;

procedure TNppDockingForm1.ServerSocket1ClientError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  // if we have error, jsut kill the socket
  ErrorCode := 0;
  Socket.Close;
  self.ServerSocket1ClientDisconnect(Sender, Socket);
end;

procedure TNppDockingForm1.sockDbgpStack(Sender: TDbgpWinSocket; Stack: TStackList);
begin
  self.DebugStackForm1.SetStack(Stack);
  if (Length(Stack)>0) {and (Stack[0].stacktype = 'file')} then
  begin
    // test hack
    if (FileExists(Stack[0].filename)) then
    begin
      Sender.stack_reentrant := false;
      GotoLine(Stack[0].filename, Stack[0].lineno)
    end
    else
    begin
      if (not Sender.stack_reentrant) then
      begin
        Sender.stack_reentrant := true;
        Sender.GetStack; // let the file get processed and ask for stack again..
      end;
    end;
  end;

  // Do something usefull with this...
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_SETMOUSEDWELLTIME, 1000,0);
end;

procedure TNppDockingForm1.sockDbgpInit(Sender: TDbgpWinSocket; init: TInit);
var
  i,j,oldl,newl: integer;
  tmp: TStringList;
  oldf: string;
  n: TNotifyEvent;
begin
  self.SetState(Sender.state);
  self.UpdateConfig;
  self.SessionAdd(Sender);

  // update breakpoints
  // tstrings
  tmp := TStringList.Create;
  self.Npp.GetOpenFiles(tmp);
  self.Npp.GetFileLine(oldf,oldl);
  for i:=0 to Length(self.DebugBreakpointsForm1.breakpoints)-1 do
  begin
    if (self.DebugBreakpointsForm1.breakpoints[i].sci_handler<>0) then
    begin
      j := tmp.IndexOf(self.DebugBreakpointsForm1.breakpoints[i].filename);
      if (j<>-1) then
      begin
        self.Npp.DoOpen(tmp[j]);
        newl := SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERLINEFROMHANDLE, self.DebugBreakpointsForm1.breakpoints[i].sci_handler, 0);
        if (newl <> -1) then
        begin
          self.DebugBreakpointsForm1.breakpoints[i].lineno := newl+1;
        end;
      end;
    end;
    Sender.SetBreakpoint(self.DebugBreakpointsForm1.breakpoints[i]);
  end;
  tmp.Free;
  // za take stvaro obstaja switch...
  self.Npp.DoOpen(oldf);

  self.sock.GetBreakpoints;
  if (self.Npp as TDbgpNppPlugin).config.break_first_line then
    self.DoResume(StepInto)
  else
    self.DoResume(Run);
end;

procedure TNppDockingForm1.GotoLine(filename: string; Lineno: Integer);
var
  i: integer;
  r: boolean;
begin
  // @todo: create some helper functions in NppPlugin
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, MARKER_ARROW, 0);
  r := self.Npp.DoOpen(filename, lineno-1);
  if (not r) then exit;
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, MARKER_ARROW, 0);
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERADD, lineno-1, MARKER_ARROW);
  // redraw all line breakpoints
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, MARKER_BREAK, 0);
  for i := 0 to Length(self.DebugBreakpointsForm1.breakpoints)-1 do
  begin
    if (self.DebugBreakpointsForm1.breakpoints[i].breakpointtype <> btLine) then continue;
    if (self.DebugBreakpointsForm1.breakpoints[i].filename <> filename) then continue;
    self.DebugBreakpointsForm1.breakpoints[i].sci_handler := SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERADD, self.DebugBreakpointsForm1.breakpoints[i].lineno-1, MARKER_BREAK);
  end;
end;

procedure TNppDockingForm1.sockDbgpContext(Sender: TDbgpWinSocket;
  context: Integer; list: TPropertyItems);
begin
  if (context = 0) then self.ContextLocalForm1.SetVars(list);
  if (context = 1) then self.ContextGlobalForm1.SetVars(list);
end;

procedure TNppDockingForm1.sockDbgpEval(Sender: TDbgpWinSocket;
  context: Integer; list: TPropertyItems);
begin
  // TODO: fix this possible leak!
  if (not Assigned(self.DebugEvalForm1)) or (not self.DebugEvalForm1.CheckBoxReuseResult.Checked) then
  begin
    if (Assigned(self.EvalVarForm)) then
    begin
      self.EvalVarForm.DefaultCloseAction := caFree;
      self.EvalVarForm := TDebugVarForm.Create(self);
    end;
  end;

  if (not Assigned(self.EvalVarForm)) then
  begin
    self.EvalVarForm := TDebugVarForm.Create(self);
  end;

  self.EvalVarForm.SetVars(list);
  self.EvalVarForm.Caption := 'Eval';

  self.EvalVarForm.Show;
end;

procedure TNppDockingForm1.sockDbgpBreakpoints(Sender: TDbgpWinSocket;
  breakpoints: TBreakpoints);
var
  i,j,oldl: integer;
  filename: string;
  tmp: TStringList;
begin
  self.DebugBreakpointsForm1.SetBreakpoints(breakpoints);

  // this will be a significan performance impact...
  // possible optimizaton would be to draw only what chanegd?

  self.Npp.GetFileLine(filename,oldl);
  // redraw all breakpoints

  tmp := TStringList.Create;
  self.Npp.GetOpenFiles(tmp);
  for i := 0 to Length(self.DebugBreakpointsForm1.breakpoints)-1 do
  begin
    if (self.DebugBreakpointsForm1.breakpoints[i].sci_handler <> 0) then continue; // already set
    if (self.DebugBreakpointsForm1.breakpoints[i].breakpointtype <> btLine) then continue;
    j := tmp.IndexOf(self.DebugBreakpointsForm1.breakpoints[i].filename);
    if (j<>-1) then
    begin
      self.Npp.DoOpen(tmp[j]);
      self.DebugBreakpointsForm1.breakpoints[i].sci_handler := SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERADD, self.DebugBreakpointsForm1.breakpoints[i].lineno-1, MARKER_BREAK);
    end;
  end;
  tmp.Free;
  self.Npp.DoOpen(filename);
end;


procedure TNppDockingForm1.DoResume(runtype: TRun);
begin
  if (Assigned(self.sock)) then
  begin
    self.SetState(DbgpWinSocket.dsRunning);
    self.sock.Resume(runtype);
  end;
end;

// show eval dlg and send eval cmd
procedure TNppDockingForm1.DoEval;
var
  r: Integer;
begin
  if (not Assigned(self.DebugEvalForm1)) then
  begin
    self.DebugEvalForm1 := TDebugEvalForm1.Create(self);
  end;
  self.DebugEvalForm1.ComboBox1.Text := self.Npp.GetWord;
  r := self.DebugEvalForm1.ShowModal;
  if (r = mrOk) then
  begin
    self.DoEval(self.DebugEvalForm1.ComboBox1.Text);
  end;
end;

procedure TNppDockingForm1.DoEval(data: string);
begin
  if (Assigned(self.sock)) then
    self.sock.SendEval(data);
end;


procedure TNppDockingForm1.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  // Only executed when exiting the app... Otherwise the form is only hidden...
  Action := caFree;
end;

procedure TNppDockingForm1.sockDbgpBreak(Sender: TDbgpWinSocket;
  Stopped: Boolean);
begin
  if (not Stopped) then
  begin
    Sender.GetStack;
    self.SetState(Sender.state);
    // update stuff
    Sender.GetBreakpoints;
    if (self.Npp as TDbgpNppPlugin).config.refresh_local then Sender.GetContext(0);
    if (self.Npp as TDbgpNppPlugin).config.refresh_global then Sender.GetContext(1);
    if (Assigned(self.DebugWatchForm)) then self.DebugWatchForm.DoChange;
  end
  else
  begin
    SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, MARKER_ARROW, 0);
    Sender.Resume(Run);
  end;
end;

procedure TNppDockingForm1.FormResize(Sender: TObject);
begin
  if (self.Height > 60) then
  self.JvDockServer1.BottomDockPanel.Height := self.Height - 30;
end;

procedure TNppDockingForm1.ContextOnRefresh(Sender: TObject);
begin
 // send context refresh
 if (Assigned(self.sock)) then
   self.sock.GetContext(TForm(Sender).Tag);
end;

procedure TNppDockingForm1.StackOnGetContext(Sender: TObject;
  Depth: Integer);
begin
  // get context for depth
 if (Assigned(self.sock)) then
   self.sock.GetContext(0,Depth);
end;

{ "Toolbar" icons }
procedure TNppDockingForm1.BitBtnStepIntoClick(Sender: TObject);
begin
  self.DoResume(StepInto);
end;

procedure TNppDockingForm1.BitBtnStepOverClick(Sender: TObject);
begin
  self.DoResume(StepOver);
end;

procedure TNppDockingForm1.BitBtnStepOutClick(Sender: TObject);
begin
  self.DoResume(StepOut);
end;

procedure TNppDockingForm1.BitBtnRunClick(Sender: TObject);
begin
  self.DoResume(Run);
end;

procedure TNppDockingForm1.BitBtnStopClick(Sender: TObject);
begin
  self.DoResume(Stop);
end;

procedure TNppDockingForm1.BitBtnRunToClick(Sender: TObject);
var
  s: string;
  i: integer;
  bp: TBreakpoint;
begin
  self.Npp.GetFileLine(s,i);
  bp.breakpointtype := btLine;
  bp.filename := s;
  bp.lineno := i+1;
  bp.state := true;
  bp.temporary := true;
  // todo: check it is assigned
  self.sock.SetBreakpoint(bp);
  self.DoResume(Run);
  // do run to
end;

procedure TNppDockingForm1.BitBtnBreakpointClick(Sender: TObject);
var
  s: string;
  i: integer;
begin
  self.Npp.GetFileLine(s,i);
  self.ToggleBreakpoint(s,i+1);
end;

// Pass line no with 1 for first line etc
procedure TNppDockingForm1.ToggleBreakpoint(filename: string; lineno: integer);
var
  j: integer;
  bp: TBreakpoint;
  remove: boolean;
begin
  remove := false;
  for j := 0 to Length(self.DebugBreakpointsForm1.breakpoints)-1 do
  begin
    if (self.DebugBreakpointsForm1.breakpoints[j].breakpointtype <> btLine) then continue;
    if (self.DebugBreakpointsForm1.breakpoints[j].filename <> filename) then continue;
    if (self.DebugBreakpointsForm1.breakpoints[j].lineno <> lineno) then continue;
    remove := true;
    bp := self.DebugBreakpointsForm1.breakpoints[j];
    // assuming we are in the right file...
    break;
  end;

  // @todo: create some helper functions in NppPlugin
  if (remove) then
    SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETE, lineno-1, MARKER_BREAK)
  else
    bp.sci_handler := SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERADD, lineno-1, MARKER_BREAK);

  if (self.state in [dsStarting, dsBreak]) then
  begin
    if (remove) then
      self.sock.RemoveBreakpoint(bp)
    else
      self.sock.SetBreakpoint(filename,lineno);
    self.sock.GetBreakpoints;
  end
  else
  if (remove) then
  begin
    self.DebugBreakpointsForm1.RemoveBreakpoint(bp);
  end
  else
  begin
    bp.id := '';
    bp.breakpointtype := btLine;
    bp.filename := filename;
    bp.lineno := lineno;
    bp.state := true;
    bp.functionname := '';
    bp.classname := '';
    bp.temporary := false;
    bp.hit_count := 0;
    bp.hit_value := 0;
    bp.hit_condition := '>=';
    bp.exception := '';
    bp.expression := '';
    self.DebugBreakpointsForm1.AddBreakpoint(bp);
  end;
end;

procedure TNppDockingForm1.BitBtnEvalClick(Sender: TObject);
begin
  TDbgpNppPlugin(self.Npp).FuncEval;
end;

{ ugasne debugger }
procedure TNppDockingForm1.BitBtnCloseClick(Sender: TObject);
begin
  if (Assigned(self.sock)) then self.sock.Close;
  if (self.ServerSocket1.Active) then self.BitBtnClose.Caption := 'Turn ON' else self.BitBtnClose.Caption := 'Turn OFF';
  if (self.ServerSocket1.Active) then self.ServerSocket1.Close else self.ServerSocket1.Open;
end;

procedure TNppDockingForm1.BitBtnRawClick(Sender: TObject);
begin
  self.DebugRawForm1.Show;
end;

{ test stream }
procedure TNppDockingForm1.sockDbgpStream(Sender: TDbgpWinSocket; stream,
  data: String);
begin
  self.DebugRawForm1.Memo1.Lines.Add(stream+': '+data);
end;

{ set enable buttons and stuff }
procedure TNppDockingForm1.SetState(state: TDbgpState);
var
  stepping, evaling, breaking: boolean;
begin
  self.state := state;

  stepping := false; evaling := false; breaking := false;

  case state of
  dsStarting: begin stepping := true;{ breaking := true;} end;
  dsStopping: stepping := true;
  //dsStopped:
  //dsRunning:
  dsBreak: begin stepping := true; evaling := true;{ breaking := true;} end;
  end;

  breaking := true; { always true, bp child }

  self.BitBtnStepInto.Enabled := stepping;
  self.BitBtnStepOver.Enabled := stepping;
  self.BitBtnStepOut.Enabled := stepping;
  self.BitBtnRun.Enabled := stepping;
  self.BitBtnRunTo.Enabled := stepping;
  self.BitBtnStop.Enabled := stepping;

  self.BitBtnEval.Enabled := evaling;
  self.BitBtnBreakpoint.Enabled := breaking;

  // TODO
  if (stepping) then
    (self.Npp as TDbgpNppPlugin).ChangeMenu(dmsConnected)
  else
    (self.Npp as TDbgpNppPlugin).ChangeMenu(dmsDisconnected);
end;

{
procedure TNppDockingForm1.Button3Click(Sender: TObject);
var
  s: String;
  //f: TextFile;
  i: Integer;
begin

  // test
  Output redirect...

  s := '';
  SetLength(s, 200);
  GetTempPath(200, PChar(s)); // stupid.. doda na koncu #0 in se ne da pripet vec stringa@#!@
  SetLength(s, StrLen(PChar(s)));
  s := s + 'STDOUT';
  //self.Memo1.Lines.Add('tmp: '+s);
  AssignFile(f, s);
  Rewrite(f);
  CloseFile(f);
  SendMessage(self.Npp.NppData.NppHandle, WM_DOOPEN, 0, LPARAM(PChar(s)));

  SendMessage(self.Npp.NppData.ScintillaMainHandle, SciSupport.SCI_CLEARALL,0,0);
  SendMessage(self.Npp.NppData.ScintillaMainHandle, SciSupport.SCI_APPENDTEXT,10,LPARAM(PChar('123456789012')));

end;
}

{ breakpoint editing hooks }
procedure TNppDockingForm1.BreakpointAdd(Sender: TComponent;
  bp: TBreakpoint);
begin
  if Assigned(self.sock) and (self.state <> dsStopped) then
  begin
    self.sock.SetBreakpoint(bp);
    self.sock.GetBreakpoints;
  end;
end;

procedure TNppDockingForm1.BreakpointDelete(Sender: TComponent;
  bp: TBreakpoint);
var
  s: string;
  i: integer;
begin
  // @todo: change view to file and back
  self.Npp.GetFileLine(s,i);
  if (bp.sci_handler>0) and (bp.filename=s) then
    SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEHANDLE, bp.sci_handler, 0);

  if Assigned(self.sock) and (self.state <> dsStopped) then
  begin
    self.sock.RemoveBreakpoint(bp);
    self.sock.GetBreakpoints;
  end;
end;

procedure TNppDockingForm1.BreakpointEdit(Sender: TComponent;
  bp: TBreakpoint);
begin
  if Assigned(self.sock) and (self.state <> dsStopped) then
  begin
    self.sock.UpdateBreakpoint(bp);
    self.sock.GetBreakpoints;
  end;
end;

procedure TNppDockingForm1.StackSelect(Sender: TObject; filename: String;
  lineno: integer; Depth: Integer);
begin
  self.GotoLine(filename, lineno);
end;

procedure TNppDockingForm1.Open(childtype: TDebugChildType; Show: boolean);
begin
  case (childtype) of
  dctWatches:
    begin
      if (not Assigned(self.DebugWatchForm)) then self.DebugWatchForm := TDebugWatchFrom.Create(self);
      self.DebugWatchForm.OnChange := self.WatchesOnChange;
      if (Show) then self.DebugWatchForm.Show;
    end;
  dctStack:
    begin
      if (not Assigned(self.DebugStackForm1)) then self.DebugStackForm1 := TDebugStackForm1.Create(self);
      self.DebugStackForm1.OnGetContext := self.StackOnGetContext;
      self.DebugStackForm1.OnStackSelect := self.StackSelect;
      if (Show) then self.DebugStackForm1.Show;
    end;
  dctLocalContect:
    begin
      if (not Assigned(self.ContextLocalForm1)) then self.ContextLocalForm1 := TDebugContextForm.Create(self);
      self.ContextLocalForm1.OnRefresh := self.ContextOnRefresh;
      self.ContextLocalForm1.Tag := 0;
      self.ContextLocalForm1.Caption := 'Local context';
      if (Show) then self.ContextLocalForm1.Show;
    end;
  dctGlobalContext:
    begin
      if (not Assigned(self.ContextGlobalForm1)) then self.ContextGlobalForm1 := TDebugContextForm.Create(self);
      self.ContextGlobalForm1.OnRefresh := self.ContextOnRefresh;
      self.ContextGlobalForm1.Tag := 1;
      self.ContextGlobalForm1.Caption := 'Global context';
      if (Show) then self.ContextGlobalForm1.Show;
    end;
  dctBreakpoints:
    begin
      if (not Assigned(self.DebugBreakpointsForm1)) then self.DebugBreakpointsForm1 := TDebugBreakpointsForm1.Create(self);
      self.DebugBreakpointsForm1.OnBreakpointAdd := self.BreakpointAdd;
      self.DebugBreakpointsForm1.OnBreakpointEdit := self.BreakpointEdit;
      self.DebugBreakpointsForm1.OnBreakpointDelete := self.BreakpointDelete;
      if (Show) then self.DebugBreakpointsForm1.Show;
    end;
  end;
end;

// watches handler
procedure TNppDockingForm1.WatchesOnChange(Sender: TObject;
  Watches: TPropertyItems);
var
  tmp, res: TPropertyItems;
  r: string;
  i: integer;
begin
  if (not Assigned(self.DebugWatchForm)) then exit;

  if (self.state in [dsStarting, dsBreak]) and (Assigned(self.sock))then
  begin
    SetLength(tmp, Length(Watches));
    for i:=0 to Length(Watches)-1 do
    begin
      r := self.sock.GetPropertyAsync(Watches[i].fullname, res);
      tmp[i] := res[0];
      // Note: We do not FreePropertyItems here, as the deeper elemts are pointes and get freed later
    end;
    self.DebugWatchForm.SetVars(tmp);
    FreePropertyItems(tmp);
  end
  else
  begin
    self.DebugWatchForm.SetVars(Watches);
  end;
end;

procedure TNppDockingForm1.UpdateConfig;
begin
  if (Assigned(self.sock)) then
  begin
    self.sock.maps := (self.Npp as TDbgpNppPlugin).config.maps;
    self.sock.use_source := (self.Npp as TDbgpNppPlugin).config.use_source;
    self.sock.local_setup := (self.Npp as TDbgpNppPlugin).config.local_setup;
    self.sock.SetFeature('max_depth',IntToStr((self.Npp as TDbgpNppPlugin).config.max_depth));
    self.sock.SetFeature('max_children',IntToStr((self.Npp as TDbgpNppPlugin).config.max_children));
    self.sock.SetFeature('max_data',IntToStr((self.Npp as TDbgpNppPlugin).config.max_data));
  end;
end;

procedure TNppDockingForm1.SetupSession(Socket: TDbgpWinSocket);
begin
  if (Socket = nil) then
  begin
    //self.Label1.Caption := 'Disconnected...';
    self.sock := nil;
    self.DebugStackForm1.ClearStack;
    self.ContextLocalForm1.ClearVars;
    self.ContextGlobalForm1.ClearVars;
    SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_MARKERDELETEALL, MARKER_ARROW, 0);
    SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_SETMOUSEDWELLTIME, SC_TIME_FOREVER,0);
    SendMessage(self.Npp.NppData.ScintillaMainHandle, SCI_CALLTIPCANCEL, 0, 0);
    self.SetState(dsStopped);
    exit;
  end;
  self.sock := Socket;
  //self.Label1.Caption := 'Connected to '+self.sock.Init.server+' idekey: '+self.sock.Init.idekey+' file: '+self.sock.Init.filename;
  self.sock.maps := (self.Npp as TDbgpNppPlugin).config.maps;
  self.sock.use_source := (self.Npp as TDbgpNppPlugin).config.use_source;
  self.sock.local_setup := (self.Npp as TDbgpNppPlugin).config.local_setup;
  self.sock.OnDbgpStack := self.sockDbgpStack;
  self.sock.OnDbgpInit := self.sockDbgpInit;
  self.sock.OnDbgpEval := self.sockDbgpEval;
  self.sock.OnDbgpContext := self.sockDbgpContext;
  self.sock.OnDbgpBreak := self.sockDbgpBreak;
  self.sock.OnDbgpBreakpoints := self.sockDbgpBreakpoints;
  self.SetState(self.sock.state);
end;

procedure TNppDockingForm1.SessionAdd(Socket: TCustomWinSocket);
var
  init: TInit;
begin
  init := TDbgpWinSocket(Socket).Init;
  self.ComboBox1.ItemIndex := self.ComboBox1.Items.AddObject(init.filename+' ('+init.server+' '+init.idekey+')', Socket);
  self.ComboBox1.Hint := self.ComboBox1.Text;
end;

procedure TNppDockingForm1.SessionDel(Socket: TCustomWinSocket);
var
  i: Integer;
begin
  for i:=0 to self.ComboBox1.Items.Count-1 do
  begin
    if (Socket = self.ComboBox1.Items.Objects[i]) then
    begin
      self.ComboBox1.Items.Delete(i);
      break;
    end;
  end;
  self.SessionSelect(self.ComboBox1.Items.Count-1); // count will always be at least 1
end;

procedure TNppDockingForm1.ComboBox1Select(Sender: TObject);
begin
  self.SessionSelect(self.ComboBox1.ItemIndex);
end;

procedure TNppDockingForm1.SessionSelect(Index: Integer);
begin
  self.ComboBox1.ItemIndex := Index;
  self.ComboBox1.Hint := self.ComboBox1.Text;
  self.SetupSession(TDbgpWinSocket(self.ComboBox1.Items.Objects[Index]));
  if (self.sock <> nil) then
  begin
    // get "State" back from server
    self.sockDbgpBreak(self.sock, (self.sock.state = DbgpWinSocket.dsStopping) or (self.sock.state = DbgpWinSocket.dsStopped));
  end;
end;

end.
