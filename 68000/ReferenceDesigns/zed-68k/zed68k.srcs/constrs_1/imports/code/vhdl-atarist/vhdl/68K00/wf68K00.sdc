#                                                             
# Copyright © 2014 Wolfgang Foerster Inventronik GmbH.        
#                                                             
# This documentation describes Open Hardware and is licensed  
# under the CERN OHL v. 1.2. You may redistribute and modify  
# this documentation under the terms of the CERN OHL v.1.2.   
# (http://ohwr.org/cernohl). This documentation is distributed
# WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF       
# MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR A     
# PARTICULAR PURPOSE. Please see the CERN OHL v.1.2 for       
# applicable conditions                                       
 
# Revision History
 
# Revision 2K14B 20140922 WF
#   Initial Release.
 

#**************************************************************
# Time Information
#**************************************************************

# set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

# create_clock -name CLK -period 100.000 -waveform {0.000 50.000} [get_ports {CLK}]
create_clock -period 80.000 -name CLK [get_ports {CLK}]

#derive_pll_clocks
#derive_pll_clocks -use_net_name
derive_clock_uncertainty

#set_clock_groups -exclusive -group {CLK_PLL1}
#set_clock_groups -exclusive -group {CLK_PLL2}
#set_clock_groups -exclusive -group {CODEC_SCLK}
