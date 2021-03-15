(cd ../simhv36-1; make BIN/pdp8)
make
../simhv36-1/BIN/pdp8 tss8.cmd >simh.log
./pdp8i >8.log
diff -u -d 8.log simh.log >d
head -100000 d >d1
ls -l *.log d d1
