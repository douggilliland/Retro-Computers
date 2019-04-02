WinOSI V 1.5  *** PRE-RELEASE ***

Well what's changed?
This version is still very incomplete but usable (mess) program.

New Features
- Supports OS65U Business OS!

- Supports Windows command-shell style copy and paste
  You can use the mouse to select rectangular areas of the WinOSI screen
  to copy to the windows clipboard as text. Use left mouse button to select 
  an area, and while selected use the right mouse button to initiate the copy.

- Support for windows paste via right-mouse button when there is no selection.
  The paste operation simulates keyboard key presses.  This is somewhat buggy
  depending on the emulated machine configuration

- Windows PrintScreen command (PrtScn/ Alt-PrtScn) only copies emulated display

- Input/Output OSI serial port to real Windows COM ports.
- OSI ACIA emulation supports IRQ

- Built in screen grabber *in progress*
  Saves a continuous series of screenshot bitmaps to C:\screenxxx.bmp starting 
  at screen001.bmp up to screen999.bmp. Configure via screenshot setting dialog.
  Initiated via F11

- Built in OSI BASIC export.  Detokenize & save loaded OSI BASIC programs, even OS65U & OS65D listing disabled programs

- Rework configuration dialogs
  - Machine Emulation includes additonal OSI machines 
  - Video tab options expanded, uses internal or external chargen ROM files
    Support for C1 customized display sizes
  - Ports tab includes Serial and Parallel port options (Parallel port incomplete)
  - Added System ROMs page with support for internal and external ROM files including
    custom mapped ROMS. Now supports CEGMON ROM & C2 Cegmon page remapping
  - Added Keyboard configuration tab with editor and PC joystick support
  - Added RAM config page

- Rework CPU speed dialog  (Although you can set 400%, emulator main loop still gives
  too much time to windows, slowing actual emulation speed to about 200%).

- Rework Debugger (work in progress)
  New hex memory viewer - editing mode supported
  Code window shows address, opcode values and disassembled view (scrollable) 
  Step Into/Step Over (Step out button inactive)
  Set breakpoint by double-clicking line in code window or using stop location buttons. Multiple breakpoints supported. Edit using breakpoint editor dialog
  Code history button disabled again

- Allow for $F00 or $E00 sized tracks for 8" disk images. Emulator generated $F00 sized
  tracks but OSIDUMP used $E00 sized.  

- Fixed ADC, SBC decimal mode bugs
- Removed border from sides and top of emulator window so it fits on smaller screens
- Fixed graphic overlay mode
- Made system roms internal (you can still use external if you wish)
- Added cassette icon to status area
- Add hyperlink support to "Help" window

-Incomplete/Todo
  Sound support
  Capture AVI
  Hard disk emulation
  Faster emulation speed
  Save/load state on exit/launch



WinOSI changes
-------------------
Version 1.4

 ** MOST OF THESE NEW CHANGES ARE INCOMPLETE, but the emulator still works OK **

New Features
- Supports Windows command-shell style quick-edit mode copy and paste
  You can use the mouse to select rectangular areas of the WinOSI screen
  to copy to the windows clipboard as text. Use left mouse button to select 
  an area, and while selected use the right mouse button to initiate the copy.

- Support for windows paste via right-mouse button when there is no selection.
  The paste operation simulates keyboard key presses.  This is somewhat buggy
  depending on the emulated machine configuration!

- Windows PrintScreen command (PrtScn/ Alt-PrtScn) only copies emulated display

- Built in screen grabber *incomplete*
  Saves a continuous series of screenshot bitmaps to C:\screenxxx.bmp starting 
  at screen001.bmp up to screen999.bmp
  Initiated via Scroll-Lock

- Rework configuration dialogs
  - Machine Emulation includes additonal OSI machines (incomplete)
  - Video tab options expanded, uses internal or external chargen ROM files
    Support for C1 customized display sizes
  - Ports tab includes Serial and Parallel port options (Parallel port incomplete)
  - Added System ROMs page with support for internal and external ROM files including
    custom mapped ROMS. Now supports CEGMON ROM with F4, F6, F7 remapped page
  - Added Keyboard configuration tab with editor and PC joystick support (incomplete)

- Rework CPU speed dialog  (Although you can set 400%, emulator main loop still gives
  too much time to windows, slowing actual emulation speed to about 200%).

- Rework Debugger (work in progress)
  Added command history toggle which shows you the last instructions executed in reverse order
  New hex memory viewer - editing mode still incomplete (selection is a fixed area for testing)
  Code window shows address, opcode values and disassembled view (scrollable disassembly not complete)
  Step Into/Step Over/Step out buttons inactive, Step Into still works like "Step"

- Fixed ADC, SBC decimal mode bugs (Makes PlotBasic work)
- Removed border from sides and top of emulator window so it fits on smaller screens
- Fixed graphic overlay mode
- Made system roms internal (you can still use external if you wish)
- Added cassette icon to status area
- Add hyperlink support to "Help" window

-Incomplete/Todo
  Sound support
  440 ASCII KB & system support
  C3 Serial support
  using real COM ports with emulator
  OS65U support
  Capture AVI
  Interrupt support
  Hard disk emulation
  Faster emulation speed
  Save/load state on exit/launch
  drag & drop file support

---------------------------------------------------------------------------------------------------
Version 1.3

Consolidate configuration dialogs into one tabbed dialog.

Completed disk image preview & creation in attach disk image menu.
Supports creation of 5.25 or 8 inch images, as well as giving a directory
of disk images when they are selected.

Enabled disk writing in emulator. 

Changed serial port speed to be based on emulated clock cycles instead
of system time. Changed options dialog to support 110 & 19.2K

Added disk drive indicators to bottom of screen showing track, selection
and write status.

C1/UK101 screen 64x16 doubles vertical pixels to match display aspect of
original systems.


---------------------------------------------------------------------------------------------------

Version 1.2
Rearranged menus to more closely match VICE emulator.

Fixed repaint issues in internal "debugger" dialog. Made dialog resizeable so
full stack & more disassebled instructions are visible

Implemented video preferences dialog
	-added RGB palette (default is OSI composite color palette)
	-added Black & White option
	-added Maintain aspect ratio option

Screen size & attribute changes can take effect under emulator control
Rewrote disk controller. It is now a class based on a PIA class which contains
a additional serial port code.

Enhanced keyboard emulation. Work around Windows detections problems of left & right
shift keys.

Initial work on directory of disk image upon load. Still not complete.

Implemented Simulated clock tick for 505 board 400ms clock. 
(This allows OSI dealer demo to work.)

  



