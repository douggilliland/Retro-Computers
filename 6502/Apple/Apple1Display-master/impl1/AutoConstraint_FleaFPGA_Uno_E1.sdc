
#Begin clock constraint
define_clock -name {FleaFPGA_Uno_E1|sys_clock} {p:FleaFPGA_Uno_E1|sys_clock} -period 6.265 -clockgroup Autoconstr_clkgroup_0 -rise 0.000 -fall 3.133 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {dm7400_1|y3_inferred_clock} {n:dm7400_1|y3_inferred_clock} -period 3.180 -clockgroup Autoconstr_clkgroup_2 -rise 0.000 -fall 1.590 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {dm7427|y1_inferred_clock} {n:dm7427|y1_inferred_clock} -period 3.418 -clockgroup Autoconstr_clkgroup_3 -rise 0.000 -fall 1.709 -route 0.000 
#End clock constraint

#Begin clock constraint
define_clock -name {dm7400_1|y1_inferred_clock} {n:dm7400_1|y1_inferred_clock} -period 6.074 -clockgroup Autoconstr_clkgroup_4 -rise 0.000 -fall 3.037 -route 0.000 
#End clock constraint
