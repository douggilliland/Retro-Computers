
m9312h = m9312h37.vhd m9312h38.vhd m9312h43.vhd m9312h44.vhd m9312h46.vhd m9312h47.vhd
m9312hs = m9312h40.vhd
m9312l = m9312l46.vhd m9312l47.vhd

blockrams = blockramt42.vhd
blockram = blockramt25.vhd blockramt27.vhd blockramt33.vhd blockramt39.vhd blockramt41.vhd

xubr = xubrt45.vhd

allromram = $(m9312h) $(m9312hs) $(m9312l) $(blockrams) $(blockram) $(xubr)

all: $(allromram)

%.obj: %.mac
	macro11 $< -o $*.obj -l $*.lst

$(m9312h): %.vhd: %.obj
	genblkram -t m9312h -s 16 -i $*.obj -o $@

$(m9312hs): %.vhd: %.obj
	genblkram -t m9312h -s 1 -i $*.obj -o $@

$(m9312l): %.vhd: %.obj
	genblkram -t m9312l -s 16 -i $*.obj -o $@

$(blockrams): %.vhd: %.obj
	genblkram -t blockram -s 128 -i $*.obj -o $@

$(blockram): %.vhd: %.obj
	genblkram -t blockram -s 512 -i $*.obj -o $@

$(xubr): %.vhd: %.obj
	genblkram -t xubr -s 256 -i $*.obj -o $@

clean:
	rm -f $(allromram) $(allromram:.vhd=.obj) $(allromram:.vhd=.lst)


