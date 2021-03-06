# inputfile for demo to select a rl1 device in the "device test" menu.
# Read in with command line option  "demo --cmdfile ..."
td			# device test menu
.wait 3000		# wait for PDP-11 to reset
m i			# install max UNIBUS memory

# mount RSX v4.1 in RL02 #0 and start
sd rl0			# select drive #0
p emulation_speed 10	# 10x speed. Load disk in 5 seconds
p type rl02
p runstopbutton 0	# released: "LOAD"
p powerswitch 1		# power on, now in "load" state
p image rsx11m.rl02     # mount image
p runstopbutton 1	# press RUN/STOP, will start

        # mount disk #1 start
sd rl1			# select drive #1
p emulation_speed 10	# 10x speed. Load disk in 5 seconds
p type rl02
p runstopbutton 0	# released: "LOAD"
p powerswitch 1		# power on, now in "load" state
p image rsx11user.rl02 	# mount image
p runstopbutton 1	# press RUN/STOP, will start

# mount scratch2 in RL02 #2 and start
sd rl2			# select drive #2
p emulation_speed 10	# 10x speed. Load disk in 5 seconds
p type rl02
p runstopbutton 0	# released: "LOAD"
p powerswitch 1		# power on, now in "load" state
p image rsx11hlpdcl.rl02 	# mount image
p runstopbutton 1	# press RUN/STOP, will start

# mount scratch3 in RL02 #3 and start
sd rl3			# select drive #3
p emulation_speed 10	# 10x speed. Load disk in 5 seconds
p type rl02
p runstopbutton 0	# released: "LOAD"
p powerswitch 1		# power on, now in "load" state
p image rsx11excprv.rl02  # mount image
p runstopbutton 1	# press RUN/STOP, will start

.print Disk drive now on track after 5 secs
.wait	6000		# wait until drive spins up

