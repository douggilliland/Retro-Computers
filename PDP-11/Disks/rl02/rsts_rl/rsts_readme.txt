  Here are two pre-build and patched RSTS systems built on RL01
  drives using the simulator.  

  I've also included instructions for building and installing your
  own copy of RSTS from the distributions based on the info from the
  V7.0-07 SYSGEN manual.

  To boot the system:
	sim> set cpu 1m

    for the minimal system use:
	sim> att rl0 rsts_min_rl.dsk	
	sim> b rl0

    for the full system use:
	sim> att rl0 rsts_full_rl.dsk	
	sim> att rl1 rsts_swap_rl.dsk
	sim> b rl0

    To boot from the "Option: " prompt, hit <line-feed> (^J), enter
    the date and time, and hit <return> at INIT's command file name
    prompt.   When the output stops you can login to [1,2] using
    "HELLO 1,2" with the password of "SYSTEM" .  The full system has
    the HELP command installed.   To shutdown, "RUN $SHUTUP" as [1,2].

    You can add packages to the minimal system using $BUILD.BAC
    (see build.txt).

  Chuck Cranor <chuck@ccrc.wustl.edu>
  09-Jun-98


file/directory  description
--------------- -----------------------------------------------
rsts_build.txt	how to build a RSTS system from the distribution

rsts_min_rl.dsk	a minimal RSTS system on a single 5MB disk

rsts_full_rl.dsk	a full install of RSTS, RL1 contains the SWAP0
rsts_swap_rl.dsk	swap file and the patched version of
		all the source files.   i used the following
		accounts:
		DL1:[1,3] -- general patched source code
		SY:[1,5] -- spooler package 
			(patched src DL1:[1,5])
		SY:[1,6] -- backup package
			(patched src DL1:[1,6])
		SY:[1,7] -- device test (devtst) package
			(patched src DL1:[1,7])
		SY:[1,8] -- help package
			(patched src DL1:[1,8])
