# Test code

In this folder you will find some assembly code to test various expansion cards.

To assemble, install ca65 and run the following command in this folder:

`cl65 -t none --cpu 65C02 -C planck.cfg -o a.out -l ${file}.lst ${file}.s`

Where `${file}` is the file name you want to assemble.

You can then burn `a.out` to your EEPROM.