# Apple1Display

This project is a simple reconstruction of the original Apple 1 display circuit on an FPGA. Rather than simply mimicking the behavior it instead contains VHDL code to synthesize the original TTL chips that Wozniak used to build the circuit and then wires them together exactly as shown in the Apple 1 circuit schematic (apart from a couple of minor analog components that had to be implemented digitally). The end result is a circuit that is functionally very similar to the original hardware and can be easily studied in detail using the usual simulation tools.

   ![](https://raw.githubusercontent.com/Myndale/Apple1Display/master/Docs/pics/20190808_145844_3.jpg)

Given that this is my first "proper" FPGA project you'll have to forgive it for being a bit of a mess, my focus was on learning VHDL and getting the thing to actually work. Finesse and coding standards will have to wait until my next project.

The FPGA used for this project is a [FleaUNO](https://www.fleasystems.com/fleaFPGA_Uno.html) based on the MachXO2 chipset, the project toolchain is Lattice Diamond.

   ![](https://raw.githubusercontent.com/Myndale/Apple1Display/master/Docs/pics/20190808_150011_1.jpg)
