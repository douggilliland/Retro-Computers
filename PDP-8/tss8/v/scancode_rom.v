// scancode_rom.v

module scancode_rom(addr, data);

   input [7:0] addr;
   output reg [7:0] data;

   always @addr   
     case (addr)
       8'h0d: data <= 8'h07;	/* TAB */
       8'h0e: data <= "`";
       8'h11: data <= 0;	/* Left alt */
       8'h12: data <= 0;	/* Left shift */
       8'h14: data <= 0;	/* Left ctrl */
       8'h15: data <= "q";
       8'h16: data <= "1";
       8'h1a: data <= "z";
       8'h1b: data <= "s";
       8'h1c: data <= 8'h61 /* "a" */;
       8'h1d: data <= "w";
       8'h1e: data <= "2";

       8'h21: data <= "c";
       8'h22: data <= "x";
       8'h23: data <= "d";
       8'h24: data <= "e";
       8'h25: data <= "4";
       8'h26: data <= "3";
       8'h29: data <= " ";	/* SPACE */
       8'h2a: data <= "v";
       8'h2b: data <= "f";
       8'h2c: data <= "t";
       8'h2d: data <= "r";
       8'h2e: data <= "5";

       8'h31: data <= "n";
       8'h32: data <= "b";
       8'h33: data <= "h";
       8'h34: data <= "g";
       8'h35: data <= "y";
       8'h36: data <= "6";
       8'h3a: data <= "m";
       8'h3b: data <= "j";
       8'h3c: data <= "u";
       8'h3d: data <= "7";
       8'h3e: data <= "8";

       8'h41: data <= ",";
       8'h42: data <= "k";
       8'h43: data <= "i";
       8'h44: data <= "o";
       8'h45: data <= "0";
       8'h46: data <= "9";
       8'h49: data <= ".";
       8'h4a: data <= "/";
       8'h4b: data <= "l";
       8'h4c: data <= ";";
       8'h4d: data <= "p";
       8'h4e: data <= "-";

       8'h52: data <= "'";
       8'h54: data <= "[";
       8'h55: data <= "=";
       8'h58: data <=  0;	/* Caps lock */
       8'h59: data <=  0;	/* Right shift */
       8'h5a: data <= 8'h0d;	/* Enter */
       8'h5b: data <= "]";
       8'h5d: data <= 8'h5c;	/* "\\" */
       8'h66: data <= 8'h08;	/* BKSP */
       8'h76: data <= 8'h1b;	/* ESC */

       8'h8e: data <= "~";
       8'h95: data <= "Q";
       8'h96: data <= "!";
       8'h9a: data <= "Z";
       8'h9b: data <= "S";
       8'h9c: data <= 8'h41 /* "A" */;
       8'h9d: data <= "W";
       8'h9e: data <= "2";
       
       8'ha1: data <= "C";
       8'ha2: data <= "X";
       8'ha3: data <= "D";
       8'ha4: data <= "E";
       8'ha5: data <= "$";
       8'ha6: data <= "#";
       8'ha9: data <= " ";	/* SPACE */
       8'haa: data <= "V";
       8'hab: data <= "F";
       8'hac: data <= "T";
       8'had: data <= "R";
       8'hae: data <= "%";

       8'hb1: data <= "N";
       8'hb2: data <= "B";
       8'hb3: data <= "H";
       8'hb4: data <= "G";
       8'hb5: data <= "Y";
       8'hb6: data <= "^";
       8'hba: data <= "M";
       8'hbb: data <= "J";
       8'hbc: data <= "U";
       8'hbd: data <= "&";
       8'hbe: data <= "*";

       8'hc1: data <= "<";
       8'hc2: data <= "K";
       8'hc3: data <= "I";
       8'hc4: data <= "O";
       8'hc5: data <= ")";
       8'hc6: data <=  "(";
       8'hc9: data <= ">";
       8'hca: data <= "?";
       8'hcb: data <= "L";
       8'hcc: data <= ":";
       8'hcd: data <= "P";
       8'hce: data <= "-";
       
       8'hd2: data <= "\"";
       8'hd4: data <= "{";
       8'hd5: data <= "+";
       8'hda: data <= 8'h0d;	/* Enter */
       8'hdb: data <= "}";
       8'hdd: data <= "|";

       8'he6: data <= 8'h08;	/* BKSP */

       8'hf6: data <= 8'h1b;	/* ESC */
       default: data <=  0;	/* All other keys are undefined */
     endcase
endmodule

