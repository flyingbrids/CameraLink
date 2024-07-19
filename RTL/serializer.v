`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/18/2024 03:40:46 PM
// Design Name: 
// Module Name: serializer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module serializer(
    input [9:0] data
   ,input  ref_clk
   ,input  bitswap
   ,output dataout_p
   ,output dataout_n 
   ,output clk_p
   ,output clk_n
   ,input txclk
   ,input reset_int
   ,input pixel_clk   
);

wire tx_data_out;

OBUFDS io_data_out (
	.O    			(dataout_p),
	.OB       		(dataout_n),
	.I         		(tx_data_out)
);

OBUFDS io_clk_out (
	.O    			(clk_p),
	.OB       		(clk_n),
	.I         		(ref_clk)
);

wire shift_1, shift_2;

OSERDESE2 #(
	.DATA_WIDTH     	(10), 			// SERDES word width
	.TRISTATE_WIDTH     (1), 
	.DATA_RATE_OQ      	("DDR"), 		// <SDR>, DDR
	.DATA_RATE_TQ      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("MASTER"))  		// <DEFAULT>, MASTER, SLAVE
oserdes_m (
	.OQ       		(tx_data_out),
	.OCE     		(1'b1),
	.CLK    		(txclk),
	.RST     		(reset_int),
	.CLKDIV  		(pixel_clk),
	.D8  			(bitswap? data[2] : data[7]),
	.D7  			(bitswap? data[3] : data[6]),
	.D6  			(bitswap? data[4] : data[5]),
	.D5  			(bitswap? data[5] : data[4]),
	.D4  			(bitswap? data[6] : data[3]),
	.D3  			(bitswap? data[7] : data[2]),
	.D2  			(bitswap? data[8] : data[1]),
	.D1  			(bitswap? data[9] : data[0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TCE	 		(1'b1),
	.TBYTEIN		(1'b0),
	.TBYTEOUT		(),
	.OFB	 		(),
	.TFB	 		(),
	.SHIFTOUT1 		(),			
	.SHIFTOUT2 		(),			
	.SHIFTIN1 		(shift_1),	
	.SHIFTIN2 		(shift_2));	

OSERDESE2 #(
	.DATA_WIDTH     	(10), 			// SERDES word width
	.TRISTATE_WIDTH     (1), 
	.DATA_RATE_OQ      	("DDR"), 		// <SDR>, DDR
	.DATA_RATE_TQ      	("SDR"), 		// <SDR>, DDR
	.SERDES_MODE    	("SLAVE"))  		// <DEFAULT>, MASTER, SLAVE
oserdes_s (
	.OQ       		(),
	.OCE     		(1'b1),
	.CLK    		(txclk),
	.RST     		(reset_int),
	.CLKDIV  		(pixel_clk),
	.D8  			(1'b0),
	.D7  			(),
	.D6  			(),
	.D5  			(),
	.D4  			(bitswap? data[0] : data[9]),
	.D3  			(bitswap? data[1] : data[8]),
	.D2  			(),
	.D1  			(),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TCE	 		(1'b1),
	.TBYTEIN		(1'b0),
	.TBYTEOUT		(),
	.OFB	 		(),
	.TFB	 		(),
	.SHIFTOUT1 		(shift_1),			
	.SHIFTOUT2 		(shift_2),			
	.SHIFTIN1 		(),	
	.SHIFTIN2 		()) ;	

endmodule
