mo rtest.mo
defn 0:BAUD$ $01
rem str 1 0x0000
str 3 0x1000
str 4 0xE000
str 5 0xf000
load rtest1
lib rtest.l
objx rtest
map
mo
quit
