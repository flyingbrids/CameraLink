`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 11:14:49 AM
// Design Name: 
// Module Name: cameralink_medium_phy
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
module cameralink_medium_phy(
input		        sys_rst,					
input		        sys_clk,				
input		        clkin1_p,  clkin1_n,	
input      [3:0]	datain1_p, datain1_n,
input		        clkin2_p,  clkin2_n,	
input      [3:0]	datain2_p, datain2_n,
output     [47:0]	pixel_data_o,   // 4 pixel with 12 bit each px		
output reg          pixel_vld,
output              new_frame
) ; 	
		
wire		rx_mmcm_lckdps ;		
wire    	rx_mmcm_lckdpsbs ;	
wire		rx_mmcm_lckd ;	
wire		rxclk_div ;			
wire		delay_ready ;		
wire [55:0]	rxdall ;		
wire [27:0] rx_1;
wire [27:0] rx_2;
wire [7:0]  portA;
wire [7:0]  portB;
wire [7:0]  portC;	
wire [7:0]  portD;
wire [7:0]  portE;
wire [7:0]  portF;	
wire LVAL1, FVAL1, DVAL1;
wire LVAL2, FVAL2, DVAL2;
assign rx_1 = rxdall[27:0];
assign rx_2 = rxdall[55:28];

assign portA = {rx_1[5],rx_1[27],rx_1[6],rx_1[4:0]};
assign portB = {rx_1[11],rx_1[10],rx_1[14:12],rx_1[9:7]};
assign portC = {rx_1[17],rx_1[16],rx_1[22:18],rx_1[15]};
assign LVAL1 = rx_1[24];
assign FVAL1 = rx_1[25];
assign DVAL1 = rx_1[26];

assign portD = {rx_2[5],rx_2[27],rx_2[6],rx_2[4:0]};
assign portE = {rx_2[11],rx_2[10],rx_2[14:12],rx_2[9:7]};
assign portF = {rx_2[17],rx_2[16],rx_2[22:18],rx_2[15]};
assign LVAL2 = rx_2[24];
assign FVAL2 = rx_2[25];
assign DVAL2 = rx_2[26];

IDELAYCTRL icontrol (              			
	.REFCLK			(sys_clk),
	.RST			(sys_rst),
	.RDY			(delay_ready)
);
	
SerdesWrap #(
	.N			        (2),
	.SAMPL_CLOCK		("BUF_G"),
	.PIXEL_CLOCK		("BUF_G"),
	.USE_PLL		    ("FALSE"),
 	.HIGH_PERFORMANCE_MODE 	("FALSE"),
    .D			        (4),	 // Number of data lines
    .CLKIN_PERIOD		(14.286),// 14.286ns = 70MHz
    .MMCM_MODE		    (2),	// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
	.DIFF_TERM		    ("TRUE"),
	.DATA_FORMAT 		("PER_CHANL"))// PER_CLOCK or PER_CHANL data formatting
rx0 (                          
	.clkin_p   		    ({clkin2_p, clkin1_p}),
	.clkin_n   		    ({clkin2_n, clkin1_n}),
	.datain_p     		({datain2_p, datain1_p}),
	.datain_n     		({datain2_n, datain1_n}),
	.enable_phase_detector	(1'b1),
	.rxclk    		    (),
	.idelay_rdy		    (delay_ready),
	.rxclk_div		    (rxclk_div),
	.reset     		    (sys_rst),
	.rx_mmcm_lckd		(rx_mmcm_lckd),
	.rx_mmcm_lckdps		(rx_mmcm_lckdps),
	.rx_mmcm_lckdpsbs	(rx_mmcm_lckdpsbs),
	.clk_data  		    (),
	.rx_data		    (rxdall),
	.bit_rate_value		(16'h0490),	// 70*7 = 490 Mb/s 
	.bit_time_value		(),
	.status			    (),
	.debug			    ()
);

// Async FIFO to cross data from rxclk_div to sys_clk
reg [23:0] pixel_data_in_1;
reg [23:0] pixel_data_in_2;
wire [23:0] pixel_data_o_1;
wire [23:0] pixel_data_o_2;
reg pixel_wr_1, pixel_wr_2;
wire empty_1,empty_2;
wire frame_valid_1, frame_valid_2;
reg [1:0] frame_valid_d;
wire rd_en;

assign rd_en = (~empty_1) & (~empty_2) & frame_valid_d[1];

always @ (posedge rxclk_div) begin
     pixel_wr_1 <= rx_mmcm_lckdpsbs & LVAL1 & FVAL1 & DVAL1; 
     pixel_data_in_1 <= {portB[7:4], portC, portB[3:0], portA};
     pixel_wr_2 <= rx_mmcm_lckdpsbs & LVAL2 & FVAL2 & DVAL2; 
     pixel_data_in_2 <= {portE[7:4], portF, portE[3:0], portD};
end 

always @ (posedge sys_clk) begin
     pixel_vld <= rd_en;
     frame_valid_d <= {frame_valid_d[0], frame_valid_1 & frame_valid_2};
end 

assign pixel_data_o = {pixel_data_o_2,pixel_data_o_1};

cameralink_base_fifo cameralink_base_fifo_inst_1
(
   .din   (pixel_data_in_1)
  ,.wr_en (pixel_wr_1)
  ,.empty (empty_1)
  ,.dout  (pixel_data_o_1)
  ,.rd_en (rd_en)
  ,.rst   (reset)
  ,.wr_clk (rxclk_div)
  ,.rd_clk (sys_clk)  
);

cameralink_base_fifo cameralink_base_fifo_inst_2
(
   .din   (pixel_data_in_2)
  ,.wr_en (pixel_wr_2)
  ,.empty (empty_2)
  ,.dout  (pixel_data_o_2)
  ,.rd_en (rd_en)
  ,.rst   (reset)
  ,.wr_clk (rxclk_div)
  ,.rd_clk (sys_clk)  
);

CDC_sync FVAL1_CDC (
  .sig_in  (FVAL1)
 ,.clk_b   (sys_clk)
 ,.rst_b   (~rx_mmcm_lckdpsbs)
 ,.sig_sync(frame_valid_1)
 ,.pulse_sync(new_frame)
);

CDC_sync FVAL2_CDC (
  .sig_in  (FVAL2)
 ,.clk_b   (sys_clk)
 ,.rst_b   (~rx_mmcm_lckdpsbs)
 ,.sig_sync(frame_valid_2)
 ,.pulse_sync()
);


endmodule