////////////////////////////////////////////////////
//功能：vga
//
//子模块：无
//
//版本：V0.00
//
//日期：20131012
////////////////////////////////////////////////////
module vga_module(
	input 	clk40m,
	output 	hsync,
	output reg vsync,
	output reg [15:0] pixel
);

//*------process begin-----*//
//VGA  800*600,60Hz
//red 5  green 6  blue 5
//blue4..blue0  green5..green0  red4..red0
parameter 	RED	=	'h001f;
parameter 	GREEN	=	'h07e0;
parameter 	BLUE	=	'hf100;
parameter 	WHITE	=	'hffff;
parameter 	BLACK	=	'h0000;


//Horizontal timing constants
parameter 		H_PIXELS			=	'd804,//20m-403,d'640,
					H_FRONTPORCH	=	'd40,//20m-19,
					H_SYNCTIME		=	'd128,//20m-64,
					H_BACKPORCH		=	'd88,//20m-42,
					H_SYNCSTART		=	'd900,//20m-421,H_PIXELS+H_FRONTPORCH,
					H_SYNCEND		=	'd1028,//20m-485,H_SYNCSTART+H_SYNCTIME,
					H_PERIOD			=	'd1056,//20m-528,H_SYNCEND+H_BACKPORCH,
			
//VERTICAL TIMING CONSTANTS
			V_LINES			=	'd604,//48,
			V_FRONTPORCH	=	'd1,//d'10,
			V_SYNCTIME		=	'd4,//2,
			V_BACKPORCH		=	'd23,//33,
			V_SYNCSTART		=	'd603,//V_LINES+V_FRONTPORCH,
			V_SYNCEND		=	'd607,//V_SYNCSTART+V_SYNCTIME,
			V_PERIOD			=	'd628;//V_SYNCEND+V_BACKPORCH;
			
			
//parameter 		H_PIXELS			=	'd1366,//'d804,//20m-403,d'640,
//					H_FRONTPORCH	=	'd40,//20m-19,
//					H_SYNCTIME		=	'd128,//20m-64,
//					H_BACKPORCH		=	'd88,//20m-42,
//					H_SYNCSTART		=	'd1406,//'d900,//20m-421,H_PIXELS+H_FRONTPORCH,
//					H_SYNCEND		=	'd1534,//'d1028,//20m-485,H_SYNCSTART+H_SYNCTIME,
//					H_PERIOD			=	'd1622,//'d1056,//20m-528,H_SYNCEND+H_BACKPORCH,
//			
////VERTICAL TIMING CONSTANTS
//			V_LINES			=	'd768,//'d604,//48,
//			V_FRONTPORCH	=	'd1,//d'10,
//			V_SYNCTIME		=	'd4,//2,
//			V_BACKPORCH		=	'd23,//33,
//			V_SYNCSTART		=	'd769,//'d603,//V_LINES+V_FRONTPORCH,
//			V_SYNCEND		=	'd773,//'d607,//V_SYNCSTART+V_SYNCTIME,
//			V_PERIOD			=	'd796;//'d628;//V_SYNCEND+V_BACKPORCH;			

reg 		[11:0] hcnt,vcnt;
reg			enable,hsyncint;

//Horizontal counter of pixels
always @(posedge clk40m)
	if(hcnt<H_PERIOD)
		hcnt	<=	hcnt+1'b1;
	else
		hcnt	<=	0;

//internal horizontal synchronization pule generation (negetive polarity)
always @(posedge clk40m)
	if(hcnt>=H_SYNCSTART && hcnt<H_SYNCEND)
		hsyncint	<=	0;
	else
		hsyncint	<=	1;
		
//horizontal synchronization output
assign hsync	=	hsyncint;

//vertical counter of lines
always @(posedge hsyncint)
	if(vcnt<V_PERIOD)
		vcnt	<=	vcnt+1'b1;
	else
		vcnt	<=	0;

//vertical synchronization pulse generation (negetive polarity)
always @(posedge hsyncint)
	if(vcnt>=V_SYNCSTART && vcnt<V_SYNCEND)
		vsync	<=	0;
	else
		vsync	<=	1;
		
//enabling of color outputs
always @(posedge clk40m)
	if(hcnt>=H_PIXELS || vcnt>=V_LINES)
		enable	<=	0;
	else
		enable	<=	1;

//eight color change ,"hua rong dao"
reg		[15:0]	PIX;
reg		[15:0]	PColor;

always @(negedge enable or negedge clk40m) begin
	if(enable==0) begin
		PIX		=	0;
		PColor	=	0;
		end
	else begin
		if((vcnt>0) && (vcnt<640)) begin
//			if((hcnt>0) && (hcnt<300)) begin
//				PColor[10:5]		<=	PColor[10:5]-1'b1;//green			
//				end
//			else if((hcnt>=301) && (hcnt<600))
//				PColor[4:0]			<=	PColor[4:0]-1'b1;//red
//			else if((hcnt>=601) && (hcnt<800))	
//				PColor[15:11]		<=	PColor[15:11]-1'b1;//blue
//			else
//				PColor	=	BLACK;
//			end
			if((hcnt>0) && (hcnt<100))
				PColor[10:5]		<=	6'h3F;			//green			
			else if((hcnt>101) && (hcnt<200))
				PColor[4:0]			<=	5'h1F;			//red
			else if((hcnt>201) && (hcnt<300))
				PColor[15:11]		<=	5'h1F;			//blue
			else if((hcnt>301) && (hcnt<400))
				PColor[10:5]		<=	6'h0F;			//green
			else if((hcnt>401) && (hcnt<500))
				PColor[4:0]			<=	5'h0F;			//red
			else if((hcnt>501) && (hcnt<600)) 
				PColor[15:11]		<=	5'h0F;			//blue
			else if((hcnt>601) && (hcnt<700)) 
				PColor[10:5]		<=	6'h07;			//green	
			else if((hcnt>701) && (hcnt<800)) 
				PColor[4:0]			<=	5'h07;			//red
			else
				PColor	=	BLACK;
			end
		end
	end

always @(posedge clk40m) begin
	pixel	=	PColor;
	end
	
endmodule
