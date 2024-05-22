`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 11:14:49 AM
// Design Name: 
// Module Name: cameralink_base_phy
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
module cameralink_base_phy(
input		        sys_rst,					
input		        sys_clk,	
input               delay_ready,			
input		        clkin_p,  clkin_n,	
input      [3:0]	datain_p, datain_n,
input      [15:0]   lineWidth,
output     [23:0]	pixel_data_o,   // 2 pixel with 12 bit each px		
output reg          pixel_vld,
output              new_frame,
output              frame_valid,
output              locked,
input               camera_in_progress,
input               cameraSel
) ; 	
		
wire		rx_mmcm_lckdps ;		
wire    	rx_mmcm_lckdpsbs ;	
wire		rx_mmcm_lckd ;	
wire		rxclk_div ;		
		
wire [27:0]	rxdall ;	
wire [6:0]  X0;
wire [6:0]  X1;
wire [6:0]  X2;	
wire [6:0]  X3;	
wire [7:0]  portA;
wire [7:0]  portB;
wire [7:0]  portC;	
wire LVAL, FVAL, DVAL;

assign X0 = rxdall[6:0];
assign X1 = rxdall[13:7];
assign X2 = rxdall[20:14];
assign X3 = rxdall[27:21];

assign portA = {X3[5],X3[6],X0[1],X0[2],X0[3],X0[4],X0[5],X0[6]};
assign portB = {X3[3],X3[4],X1[2],X1[3],X1[4],X1[5],X1[6],X0[0]};
assign portC = {X3[1],X3[2],X2[3],X2[4],X2[5],X2[6],X1[0],X1[1]};
assign LVAL = X2[2];
assign FVAL = X2[1];
assign DVAL = X2[0];
	
SerdesWrap #(
	.N			        (1),
	.SAMPL_CLOCK		("BUF_G"),
	.PIXEL_CLOCK		("BUF_G"),
	.USE_PLL		    ("TRUE"),
 	.HIGH_PERFORMANCE_MODE 	("FALSE"),
    .D			        (4),	 // Number of data lines
    .CLKIN_PERIOD		(13.468),// 13.468ns = 74.25MHz
    .MMCM_MODE		    (2),	// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
	.DIFF_TERM		    ("TRUE"),
	.DATA_FORMAT 		("PER_CHANL"))// PER_CLOCK or PER_CHANL data formatting
rx0 (                          
	.clkin_p   		    (clkin_p),
	.clkin_n   		    (clkin_n),
	.datain_p     		(datain_p),
	.datain_n     		(datain_n),
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
	.bit_rate_value		(16'h0520),	// 74.25*7 = 520 Mb/s 
	.bit_time_value		(),
	.status			    (),
	.debug			    ()
);

// Async FIFO to cross data from rxclk_div to sys_clk
reg [23:0] pixel_data_in;
reg [1:0] frame_valid_d;
reg pixel_wr;
wire empty;
wire rd_en;
reg line_rd;
wire dmaIdle;
wire dmaBusy2Idle;
wire cameraSel_sync;

assign rd_en = ~empty & line_rd;

reg [1:0] frame_valid_state;
reg Fvalid;
wire fifo_rst; 
assign fifo_rst = (frame_valid_state == 2'd2)? 1'b0: 1'b1;

always @ (posedge rxclk_div) begin
     pixel_wr <= rx_mmcm_lckdpsbs & LVAL & FVAL & DVAL & frame_valid_state[1];      
     pixel_data_in <= {portB[7:4], portC, portB[3:0], portA};
     
     if (rx_mmcm_lckdpsbs & (frame_valid_state == 2'd2)) begin
         if (FVAL)
            Fvalid <= 1'b1;
         else if (empty)
            Fvalid <= 1'b0; 
     end else begin
        Fvalid <= 1'b0;
     end 
         
     if (rx_mmcm_lckdpsbs) begin
        if ((frame_valid_state == 0) & FVAL) 
            frame_valid_state <= 2'd1;  
        else if ((frame_valid_state == 1) & ~FVAL & dmaIdle & cameraSel_sync)
            frame_valid_state <= 2'd2; 
        else if ((frame_valid_state == 2) & dmaBusy2Idle)   
            frame_valid_state <= 2'd3; 
        else if ((frame_valid_state == 3) & ~FVAL & dmaIdle & cameraSel_sync)
            frame_valid_state <= 2'd2; 
     end else 
        frame_valid_state <= 0;        
  
end 

always @ (posedge sys_clk) begin
     pixel_vld <= rd_en;
     frame_valid_d <= {frame_valid_d[0],frame_valid};
end 

wire full, full_sync;

cameralink_base_fifo cameralink_base_fifo_inst
(
   .din   (pixel_data_in)
  ,.wr_en (pixel_wr & ~fifo_rst)
  ,.prog_full (full) 
  ,.empty (empty)
  ,.dout  (pixel_data_o)
  ,.rd_en (rd_en)
  ,.rst   (sys_rst | fifo_rst)
  ,.wr_clk (rxclk_div)
  ,.rd_clk (sys_clk)  
);

reg [15:0] rd_cnt;
always @ (posedge sys_clk, posedge sys_rst) begin
      if (sys_rst) begin
          line_rd <= 1'b0;
          rd_cnt  <= 16'd0;
      end else if (fifo_rst) begin
          line_rd <= 1'b0;
          rd_cnt  <= 16'd0;
      end else if (frame_valid_d[1]) begin
          if (full_sync & ~line_rd) begin
             line_rd <= 1'b1;
             rd_cnt  <= 16'd0;         
          end else if (line_rd) begin
             rd_cnt  <= rd_cnt + 16'd2;
             line_rd <=  (rd_cnt < lineWidth-2)? 1'b1 : 1'b0; 
          end 
      end 
end 

CDC_sync FULL_CDC (
  .sig_in  (full)
 ,.clk_b   (sys_clk)
 ,.rst_b   (sys_rst)
 ,.sig_sync(full_sync)
 ,.pulse_sync()
);

CDC_sync FVAL_CDC (
  .sig_in  (Fvalid)
 ,.clk_b   (sys_clk)
 ,.rst_b   (sys_rst)
 ,.sig_sync(frame_valid)
 ,.pulse_sync(new_frame)
);

CDC_sync LOCKED_CDC (
  .sig_in  (rx_mmcm_lckdpsbs)
 ,.clk_b   (sys_clk)
 ,.rst_b   (sys_rst)
 ,.sig_sync(locked)
 ,.pulse_sync()
);

CDC_sync BUSY_CDC (
  .sig_in  (~camera_in_progress)
 ,.clk_b   (rxclk_div)
 ,.rst_b   (~rx_mmcm_lckdpsbs)
 ,.sig_sync(dmaIdle)
 ,.pulse_sync(dmaBusy2Idle)
);

CDC_sync SEL_CDC (
  .sig_in  (cameraSel)
 ,.clk_b   (rxclk_div)
 ,.rst_b   (~rx_mmcm_lckdpsbs)
 ,.sig_sync(cameraSel_sync)
 ,.pulse_sync()
);

endmodule
