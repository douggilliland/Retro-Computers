setMode -bs
setMode -bs
setMode -bs
setMode -bs
setCable -port xsvf -file "C:/Users/chamberlin/Documents/68Katy/CPLD/68katy.xsvf"
addDevice -p 1 -file "C:/Users/chamberlin/Documents/68Katy/CPLD/cpld.jed"
Program -p 1 -e -v 
setMode -bs
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
saveProjectFile -file "C:\Users\chamberlin\Documents\floppyemu\CPLD-Xilinx\\auto_project.ipf"
setMode -bs
setMode -bs
deleteDevice -position 1
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
