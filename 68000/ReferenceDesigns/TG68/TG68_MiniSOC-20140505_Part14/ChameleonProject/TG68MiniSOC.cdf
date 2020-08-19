/* Quartus II 32-bit Version 12.0 Build 232 07/05/2012 Service Pack 1 SJ Web Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(CHAMELEON_CPLD) MfrSpec(OpMask(0));
	P ActionCode(Cfg)
		Device PartName(EP3C25E144) Path("/home/amr/FPGA/TG68MiniSOC/ChameleonProject/") File("TG68MiniSOC.sof") MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
