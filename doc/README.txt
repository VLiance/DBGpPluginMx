DBGP Notepad++ plugin

ABSTRACT

This is a plugin for Notepad++ 4.4. It is a debugger client that talks DBGP 
protocol. It was built mostly for PHP (XDebug) but may/should/will work with 
other languages as well.

HISTORY

I was looking for a good PHP debugger for a long time. I tried most of what’s 
out there and finally found XDebug. Server side part was good and the only 
thing left was to find a decent client. Tuff luck! Most editors listed on the 
site were either too big or did not work as I expected (mostly editor wise) or 
I could not test them at all.
We are heavy users of Notepad++ (yes... like a drug). The editor behaves just as 
we want it and it is blazing fast. I started experimenting with the plugin 
interface and ended up writing this plugin in Delphi.

VERSION

Version 0.13. I'm declaring this version a beta, though I still might add a
feature or two.

NOTE

I want to emphasize again how this works. This .dll is a Notepad++ plugin. It
gives Notepad++ the ability to act as a DBGP DEBUGGING CLIENT. To actually debug
some PHP code, you also need a SERVER SIDE DEBUGGING ENGINE. That would be XDebug
(http://www.xdebug.com). After all is set up, you start the debugging session
from your browser (see FireFox XDebug helper extension). The engine (web server)
connects to the client (Notepad++) and you can do your magic.

FEATURES / TODOS
 
+ a dockable main form with child dialogs that dock
+ configuration dialog
+ stack child
+ properties child
+ context child
+ eval child
+ raw child (for debugging) 
+ breakpoint child
+ breakpoint indicator (SCI)
+ tracing command (step into, over, out, run)
+ tracing indicator (SCI)
/ fast eval on mouse dwell
? STDOUT redirect (log child?)
- STDERR redirect (log child?)
+ watch child
/ NL convert (needs tweaking)
/ toolbar icons (step into, over, out, run to, run, add and remove breakpoint, child icons?)
+ run to cursor
/ DBGp proxy support
+ file mapping (server ip based)
+ dbgp error processing...
+ interface for getting local context on depth (on stack child)
- a Manual!!
+ SOURCE support
+ Easy line breakpoint toggle
- child window position save
+ multi sessions

( - todo, / started, + done, ? don't know if I'll do it )

INSTALL

Just drop the dbgpPlugin.dll into you Notepad++ plugins directory.
Note: This plugin uses a set of shortcuts for debugging actions (run, eval,
step...) that were taken from Delphi. F9 that is used for "Run", conflicts
with a command from ConvertExt plugin. Also F7 could conflict if it is
enabled.

Try to look at this too:
http://www.judiwa.com/wiki/How_to_Setup_BDGp_debugger_in_Notepad%2B%2B_to_Debug_PHP

Also check out the forums on Notepad++ and Notepad++ plugins SourceForge pages.

SERVER SIDE INSTALL

Download xdebug binary that suites your needs. You should read the instructions
over at http://www.xdebug.com/docs/remote how to set it up, here is just a
quick start:
xdebug.remote_enable=On 
xdebug.remote_host=127.0.0.1
xdebug.remote_enable=1
xdebug.remote_handler=dbgp

TESTING

One of the simplest ways to test remote debugging is a local command line setup.
- Download and install PHP - assuming install path is c:\php5
- Download Xdebug and place it in c:\php5\ext\
- Add this to c:\php5\php.ini
    zend_extension_ts=ext/php_xdebug-2.1-5.2.5.dll
    [xdebug]
    xdebug.remote_enable=1
- Open a command prompt and see if xdebug is loaded:
    C:\test>php -v
    PHP 5.2.5 (cli) (built: Nov  8 2007 23:18:51)
    Copyright (c) 1997-2007 The PHP Group
    Zend Engine v2.2.0, Copyright (c) 1998-2007 Zend Technologies
        with Xdebug v2.1.0-dev, Copyright (c) 2002-2007, by Derick Rethans
- Create a simple php file using your favorite editor (Notepad++), for example c:\test\test.php
    <?php
    echo "test1\n";
    xdebug_break();
    echo "test2\n";
- In Notepad++ open DBGp options (menu Plugins / DBGp / Config...)
    - Check "Bypass all mapping..." and click OK
    - Open the debugger (menu Plugins / DBGp / Debugger)
- Go back to command line where you stored test.php and type
    C:\test>set XDEBUG_CONFIG="idekey=xxx"
	C:\test>php test.php
- Notepad++ should flash indicating a debugging session is in progress.
	
USAGE

When installed the plugin exposes a new submenu in the Plugins menu. The first
item, "Debugger" starts the debugger. Note that when Notepad++ is loaded the
debugger is not started. The main forms are not loaded hopefully so that less
memory is used and to ensure faster startup. The second section is there mainly
for the keyboard shortcuts. And then there are all child windows and the
Configuration.

Configuration
Currently configuration is used to set up file maps. There are 4 cols. Remote IP
(this MUST be an IP not a hostname), IDE KEY, Remote Path and Local Path.
Remote IP and IDE KEY may be left blank in witch case they are ignored.

Some examples for file mappings:
Remote IP   IDE KEY     Remote Path   Local Path
10.0.0.1    zobo        /var/www/     W:\
10.0.0.50               c:\dev\       x:\dev\
127.0.0.1               d:\dev\       d:\dev\
10.1.1.3                /home/p1/     DBGP:

The first one is a classic mapping for a remote *nix box, while the second is a
windows server. Local development should work right away, but if there are problems
a dialog will pop up with some information. 
In 0.2 a "Local path" constant was added. If it's "DBGP:" then the file will be
fetched via the SOURCE command.

New options have been added in 0.2. The fetch local or remote context on every step
fetch local or remote contexts on every break respectively.
The use "SOURCE" command bypasses the mapping altogether and gets all files over
the dbgp protocol. Additionally as of 0.2 if the file cannot be mapped the system
falls back to SOURCE retrieval, no more error box.
Also new as of 0.6 are "Start with closed socket" and two DBGP features
(max_depth and max_children). If the plugin seems to hang when you try to open
the debugging window, try to enable the first option.
New in 0.7 is the "Break at fist line when debugging starts". If you uncheck this,
execution will only stop at the first breakpoint.
In 0.13 added on-demand property loading. So if you ser max_depth to 1, each expand
in any property tree will fetch the next level from the engine. You may also set
max_depth to more than 1.

Debugger
When the debugger is started a dialog is docked at the bottom part of N++. It can
be floated and attached elsewhere, but I think this is the best place for it. This
dialog is used to dock other child dialogs. It also has a set of buttons that
expose debugger commands. You can open the RAW windows with the DBG button.
This can be used to send raw commands to the debugging engine and inspect the data
send to the engine and back. Mostly for debugging, can be closed (but won’t currently unload).
Right click to get a popup menu with "Clear" and "Copy" command.

Debugging is started from the browser. I won’t go into this, but I do recommend
the Firefox extension for starting XDebug sessions. When the debugging engine
connects to the debugger N++ will flash and most of the buttons will get enabled.
The debugger will do some basic initialization and will step to the first line
of code. As of 0.7 this is optional and the cebugger can continue until the
first breakpoint.

Stepping
Once connected and in a starting or break state you can step around using
Step out, Step into, Step over, Run to and Run (Continue). New in 0.8 is the
stop button. This will cause the debugging engine to abort executing the script.

Breakpoints
As of 0.2 there is a breakpoint child window and a breakpoint button. Use the
button to easily set a line breakpoint, right click the breakpoint child
to set more advanced breakpoints. Breakpoints are persistent now (this means
that they reside locally and get sent to the engine when it connects).
Ctrl+F9 will toggle a line breakpoint on the current line. Ctrl+click on the
margin will toggle a line breakpoint on that line.

Evaling
When in a break state you can eval things. Ctrl+F7 will bring up the eval window.
You can type in something like  $paramter1  or  mysql_error() . Just give it a spin.
As of 0.2 the currently selected text or the word under the cursor will be in
the eval window.

Context windows
Contexts can be refreshed on demand and as of 0.2 a configuration option is
available so that they can be refreshed on every step. Right click to get a
popup menu and select refresh.
Note: There is a small bug in pre 2 XDebug so when refreshing global context you
will get the response into the Local context window. The bug has been fixed in
XDebug 2 release.

Stack
A stack is printed when stepping thru code. Double click on a row to go to that
stack point. Right click on a stack row to get the local context from that stack
level.

Watch
A Watch child gives values of watched variables on each step. A context menu is
available for adding and removing variables.
The variable display form now (since v0.5) show difference from last update in
red color.

Misc
There is a "Turn OFF"/"Turn ON" button. It closes the listening socket. This
is usefull if you work on a page that loads a bunch of banners that are
processed on the same domain and each one would fire up the debugger. Turn
the debugger off and then back on when you need it.

Multiple sessions
As of 0.10 a pull down box is available on the main window, that enables
switching between active sessions.

MISC

To change the port the debugger listens on, find the config file (dbgp.ini) and
add key "listen_port" under "misc" section. Default port is 9000.

BUILDING

I use Delphi 6 (Update Pack 2), JVCL and VirtualTree.

AUTHOR

Damjan Cvetko <zobo@users.sf.net>

THANKS

- I guess Derick for creating this kickass debugging engine (http://www.xdebug.org).
- Don for Notepad++.
- Chris for being the first to test-drive this thing and giving usefull sugestions.
- JC / Traveller from www.OurWikiCommunity.com for the nice wiki help page.