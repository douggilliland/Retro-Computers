#!/usr/bin/env python3

# Demo program for using class-os8script.
#
# Starts SIMH, boots the default v3d.rk05 system image.
# Starts OS/8 BASIC
# Engages in dialog to tell BASIC this will be a new program
# called MYPROG.BA
# A two line program is fed in:
#    10 PRINT 1 + 2
#    20 END
# and run.
# The result, 3 is detected.
# ^C is sent to quit out of BASIC.
# Program exits cleanly.

# Imports 
import os
import sys
sys.path.insert (0, os.path.dirname (__file__) + '/../lib')
sys.path.insert (0, os.getcwd () + '/lib')

from pidp8i import *
from simh   import *
from os8script import *

# Our replies array with the regular expressions we
# expect to see.
# Subtle point: We contrive the test result of "3"
# with an awareness that line numbers 10, and 20 would
# trigger on a test for 0, 1, or 2.

_basic_replies = [
  ["READY", "\r\nREADY\r\n", False],
  ["NEW OR OLD", "NEW OR OLD--$", False],
  ["FILENAME", "FILE NAME--$", False],
  ["BAD FILE", "BAD FILE$", False],
  ["ME", "ME", False],
  ["3 READY", "\s+3\s+READY\r\n", False],
  ]

import argparse

def main ():    
  # Use argparse to create the args array and parse the command line.
  parser = argparse.ArgumentParser(
    description = """
    Demo: BASIC program dialog under PDP-8 OS/8.""",
    usage = "%(prog)s [options]")
  parser.add_argument ("--target", help="target image file", default="v3d.rk05")
  parser.add_argument("-v", "--verbose", help="increase output verbosity",
             action="store_true")
  args = parser.parse_args()

  # Path to our system image using library utilities.
  image_path = os.path.join(dirs.os8mo, args.target)

  # This should always succeed, but it's good form to catch
  # any failure to start SIMH.
  try:
    s = simh (dirs.build, True)
  except (RuntimeError) as e:
    print("Could not start simulator: " + e.message + '!')
    sys.exit (1)

  # If the verbose argument was set, send log output from SIMH
  # to the standard output.
  if args.verbose: s.set_logfile (os.fdopen (sys.stdout.fileno (), 'wb', 0))

  # Create our os8script object, that contains our SIMH object.
  # Passing in the verbose flag from args, empty enable and disable arrays,
  # and set debug false.
  os8 = os8script (s, [], [], verbose=args.verbose, debug=False)

  # Intern our replies array called "basic" in the replies nand replies_rex
  # arrays within the os8 object.
  os8.intern_replies ("basic", _basic_replies, True)

  # Mount our system image
  # required means we quit if the image isn't found.
  # scratch is the concurrency protection, we make a copy of v3d.rk05
  # and run inside the copy.
  os8.mount_command ("rk0 " + image_path + " required scratch", None)
  
  # Boot it.
  os8.boot_command ("rk0", None)

  # Perform once-only boot success check and run BASIC.
  # Use our replies_rex array, "basic"
  # Quit cleanly with status 1 if running BASIC fails.
  reply = os8.check_and_run ("demo", "R BASIC", "", os8.replies_rex["basic"])
  if reply == -1:
    print ("OS/8 isn't running! Fatal error!")
    os8.exit_command("1", "")

  # To make code cleaner, we have a quit_now flag.
  quit_now = False

  # State machine to submit, run and revise a BASIC program.
  # We keep looping until we see the OS/8 monitor prompt.
  # We expect the initial run of basic is successful and we don't
  # get the monitor prompt, but we set our test value initially here.
  mon = os8.simh.test_result(reply, "Monitor Prompt", os8.replies["basic"], "")
  while not mon:
    # A verbose debugging aid: Show what we got.
    if args.verbose: print ("Got reply: " + os8.replies["basic"][reply][0])

    if os8.simh.test_result(reply, "NEW OR OLD", os8.replies["basic"], ""):
      send_str = "NEW"
    elif os8.simh.test_result(reply, "FILENAME", os8.replies["basic"], ""):
      send_str = "MYPROG.BA"
    elif os8.simh.test_result(reply, "READY", os8.replies["basic"], ""):
      send_str = "10 PRINT 1 + 2\r20 END\rRUN\r"
    elif os8.simh.test_result(reply, "3 READY", os8.replies["basic"], ""):
      print ("Got Expected Result!")
      quit_now = True
    # Having a default that says oops and gets out is important
    # to keep evolving replies arrays from turning into infinite loops.
    else:
      print ("Unexpected result:" + os8.replies["basic"][reply][0])
      quit_now = True
    # We carefully send ^C and look for a monitor prompt
    # To put the state machine in a known good state.
    # By taking that care, you can compose multiple state machines reliably.
    if quit_now:
      if args.verbose: print ("Sending ^C")
      os8.simh.os8_send_ctrl ('c')
      reply = os8.simh._child.expect(os8.replies_rex["basic"])
    else:
      reply = os8.simh.os8_cmd (send_str, os8.replies_rex["basic"])
    # Eventually we get our monitor prompt and exit the loop.
    mon = os8.simh.test_result(reply, "Monitor Prompt", os8.replies["basic"], "")

  # Clean up temporaries and exit with success status 0.
  os8.exit_command("0", "")

if __name__ == "__main__": main()
