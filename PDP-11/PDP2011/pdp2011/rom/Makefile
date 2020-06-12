
m9312h = m9312h37.vhd m9312h38.vhd m9312h43.vhd m9312h44.vhd m9312h46.vhd m9312h47.vhd m9312hdjrm.vhd 23-760A9.vhd 23-753A9.vhd
m9312hs = m9312h40.vhd
m9312l = m9312l46.vhd m9312l47.vhd m9312ldjrm.vhd

odt11 = odt11.vhd
monitor = monitor.vhd

blockrams = blockramt42.vhd
blockram = blockramt25.vhd blockramt27.vhd blockramt33.vhd blockramt39.vhd blockramt41.vhd

xubr = xubrt45.vhd

allromram = $(m9312h) $(m9312hs) $(m9312l) $(blockrams) $(blockram) $(xubr) $(odt11) $(monitor)

all: $(allromram)

%.obj: %.mac
	macro11 $< -o $*.obj -l $*.lst

$(m9312h): %.vhd: %.obj
	genblkram -t m9312h -s 16 -i $*.obj -o $@ -b $*.bin

$(m9312hs): %.vhd: %.obj
	genblkram -t m9312h -s 1 -i $*.obj -o $@ -b $*.bin

$(m9312l): %.vhd: %.obj
	genblkram -t m9312l -s 16 -i $*.obj -o $@ -b $*.bin

$(odt11): %.vhd: %.obj
	genblkram -t odt11_ -s 64 -i $*.obj -o $@ -b $*.bin

$(monitor): %.vhd: %.obj
	genblkram -t monitor -s 128 -i $*.obj -o $@ -b $*.bin

$(blockrams): %.vhd: %.obj
	genblkram -t blockram -s 128 -i $*.obj -o $@ -b $*.bin

$(blockram): %.vhd: %.obj
	genblkram -t blockram -s 512 -i $*.obj -o $@ -b $*.bin

$(xubr): %.vhd: %.obj
	genblkram -t xubr -s 256 -i $*.obj -o $@ -b $*.bin

clean:
	rm -f $(allromram) $(allromram:.vhd=.obj) $(allromram:.vhd=.lst)


