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
input               delay_ready,			
input		        clkin1_p,  clkin1_n,	
input      [3:0]	datain1_p, datain1_n,
input		        clkin2_p,  clkin2_n,	
input      [3:0]	datain2_p, datain2_n,
input      [15:0]   lineWidth,
output     [47:0]	pixel_data_o,   // 4 pixel with 12 bit each px		
output reg          pixel_vld,
output reg          new_frame,
output              frame_valid,
output              locked,
input               camera_in_progress,
input               cameraSel
) ; 	
		
wire    	rx_mmcm_lckdpsbs_1 ;	
wire		rxclk_div_1 ;
wire    	rx_mmcm_lckdpsbs_2 ;	
wire		rxclk_div_2 ;
wire [27:0] rx_1;
wire [27:0] rx_2;
wire [6:0]  X0;
wire [6:0]  X1;
wire [6:0]  X2;	
wire [6:0]  X3;	
wire [6:0]  Y0;
wire [6:0]  Y1;
wire [6:0]  Y2;	
wire [6:0]  Y3;	
wire [7:0]  portA;
wire [7:0]  portB;
wire [7:0]  portC;	
wire [7:0]  portD;
wire [7:0]  portE;
wire [7:0]  portF;	
wire LVAL1, FVAL1, DVAL1;
wire LVAL2, FVAL2, DVAL2;

cam_top_rx # (.configs (0), .CLK_PERIOD(14.286))
rx1 (
  .rst_n        (~sys_rst)   // aysnc
  // cameralink IO
 ,.xc_p         (clkin1_p)
 ,.xc_n         (clkin1_n)
 ,.x0_p         (datain1_p[0])
 ,.x0_n         (datain1_n[0]) 
 ,.x1_p         (datain1_p[1])
 ,.x1_n         (datain1_n[1]) 
 ,.x2_p         (datain1_p[2])
 ,.x2_n         (datain1_n[2]) 
 ,.x3_p         (datain1_p[3])
 ,.x3_n         (datain1_n[3]) 
 // parallel out
 ,.sys_rst_f    (rx_mmcm_lckdpsbs_1)
 ,.sys_clk_f    (rxclk_div_1)
 ,.pix_a        (portA)
 ,.pix_b        (portB)
 ,.pix_c        (portC)
 ,.pix_dval     (DVAL1)
 ,.pix_fval     (FVAL1)
 ,.pix_lval     (LVAL1)
);

cam_top_rx # (.configs (0), .CLK_PERIOD(14.286))
rx2 (
  .rst_n        (~sys_rst)   // aysnc
  // cameralink IO
 ,.xc_p         (clkin2_p)
 ,.xc_n         (clkin2_n)
 ,.x0_p         (datain2_p[0])
 ,.x0_n         (datain2_n[0]) 
 ,.x1_p         (datain2_p[1])
 ,.x1_n         (datain2_n[1]) 
 ,.x2_p         (datain2_p[2])
 ,.x2_n         (datain2_n[2]) 
 ,.x3_p         (datain2_p[3])
 ,.x3_n         (datain2_n[3]) 
 // parallel out
 ,.sys_rst_f    (rx_mmcm_lckdpsbs_2)
 ,.sys_clk_f    (rxclk_div_2)
 ,.pix_a        (portD)
 ,.pix_b        (portE)
 ,.pix_c        (portF)
 ,.pix_dval     (DVAL2)
 ,.pix_fval     (FVAL2)
 ,.pix_lval     (LVAL2)
);

// Async FIFO to cross data from rxclk_div to sys_clk
reg [23:0] pixel_data_in_1;
reg [23:0] pixel_data_in_2;
wire [23:0] pixel_data_o_1;
wire [23:0] pixel_data_o_2;
reg pixel_wr_1, pixel_wr_2;
wire empty_1,empty_2;
wire empty_1_sync,empty_2_sync;
reg [1:0] frame_valid_d;
wire rd_en;
reg line_rd;
wire dmaIdle;
wire dmaBusy2Idle;
wire cameraSel_sync;

reg [1:0] frame_valid_state;
wire fifo_rst;
reg Fvalid_1, Fvalid_2;
wire ready_sync_1, ready_sync_2;
wire FVAL_sync_1, FVAL_sync_2;

assign rd_en = (~empty_1) & (~empty_2 |~cameraSel) & line_rd;
assign fifo_rst = (frame_valid_state >= 2'd2)? 1'b0: 1'b1;

always @ (posedge rxclk_div_1) begin
     pixel_wr_1 <= rx_mmcm_lckdpsbs_1 & LVAL1 & FVAL1 & DVAL1 & ready_sync_1;      
     pixel_data_in_1 <= {portB[7:4], portC, portB[3:0], portA};
     if (rx_mmcm_lckdpsbs_1 & ready_sync_1) begin
         if (FVAL1)
            Fvalid_1 <= 1'b1;
         else if (empty_1_sync)
            Fvalid_1 <= 1'b0; 
     end else begin
        Fvalid_1 <= 1'b0;
     end   
end 

always @ (posedge rxclk_div_2) begin
     pixel_wr_2 <= rx_mmcm_lckdpsbs_2 & LVAL2 & FVAL2 & DVAL2 & ready_sync_2;      
     pixel_data_in_2 <= {portE[7:4], portF, portE[3:0], portD};  
     if (rx_mmcm_lckdpsbs_2 & ready_sync_2) begin
         if (FVAL2)
            Fvalid_2 <= 1'b1;
         else if (empty_1_sync)
            Fvalid_2 <= 1'b0; 
     end else begin
        Fvalid_2 <= 1'b0;
     end      
end 

reg camera_in_progress_d;
wire frame_valid_1, frame_valid_2;
assign frame_valid = frame_valid_1 & (frame_valid_2 |~cameraSel);

always @ (posedge sys_clk) begin
     pixel_vld <= rd_en;
     frame_valid_d <= {frame_valid_d[0], frame_valid}; 
     new_frame <= ~frame_valid_d[0] & frame_valid & (frame_valid_state == 2'd2);   
     camera_in_progress_d <= camera_in_progress;       
     if (locked) begin
        if ((frame_valid_state == 0) & FVAL_sync_1 & (FVAL_sync_2 | ~cameraSel) ) 
            frame_valid_state <= 2'd1;  
        else if ((frame_valid_state == 1) & ~FVAL_sync_1 & (~FVAL_sync_2 | ~cameraSel) & ~camera_in_progress )
            frame_valid_state <= 2'd2;  
        else if ((frame_valid_state == 2) & ~FVAL_sync_1 & (~FVAL_sync_2 | ~cameraSel) & camera_in_progress )
            frame_valid_state <= 2'd3;              
        else if ((frame_valid_state == 3) & camera_in_progress_d & ~camera_in_progress)  
            frame_valid_state <= 2'd1;            
     end else 
        frame_valid_state <= 0;     
end 

assign pixel_data_o = {pixel_data_o_2,pixel_data_o_1};

wire full, full_sync;

async_fifo cameralink_fifo_inst_1
(
   .din   (pixel_data_in_1)
  ,.wr_en (pixel_wr_1 & ~fifo_rst)
  ,.prog_full (full)
  ,.empty (empty_1)
  ,.dout  (pixel_data_o_1)
  ,.rd_en (rd_en)
  ,.rst   (sys_rst | fifo_rst)
  ,.wr_clk (rxclk_div_1)
  ,.rd_clk (sys_clk)
  ,.prog_full_thresh(cameraSel? lineWidth[11:2] : lineWidth[10:1] )  
);

async_fifo cameralink_fifo_inst_2
(
   .din   (pixel_data_in_2)
  ,.wr_en (pixel_wr_2 & ~fifo_rst)
  ,.empty (empty_2)
  ,.dout  (pixel_data_o_2)
  ,.rd_en (rd_en)
  ,.rst   (sys_rst | fifo_rst)
  ,.wr_clk (rxclk_div_2)
  ,.rd_clk (sys_clk) 
  ,.prog_full_thresh(cameraSel? lineWidth[11:2] : lineWidth[10:1])  
);

reg [15:0] rd_cnt;
always @ (posedge sys_clk, posedge sys_rst) begin
      if (sys_rst) begin
          line_rd <= 1'b0;
          rd_cnt  <= 16'd0;
      end else if (new_frame) begin
          line_rd <= 1'b0;
          rd_cnt  <= 16'd0;
      end else if (frame_valid_d[1]) begin
          if (full_sync & ~line_rd) begin
             line_rd <= 1'b1;
             rd_cnt  <= 16'd0;         
          end else if (line_rd) begin
             rd_cnt  <= cameraSel? rd_cnt + 16'd4 : rd_cnt + 16'd2;
             line_rd <= cameraSel? (rd_cnt < lineWidth-4): (rd_cnt < lineWidth-2); 
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

CDC_sync Fvalid1_CDC (
  .sig_in  (Fvalid_2)
 ,.clk_b   (sys_clk)
 ,.rst_b   (sys_rst)
 ,.sig_sync(frame_valid_1)
 ,.pulse_sync()
);

CDC_sync Fvalid2_CDC (
  .sig_in  (Fvalid_2)
 ,.clk_b   (sys_clk)
 ,.rst_b   (sys_rst)
 ,.sig_sync(frame_valid_2)
 ,.pulse_sync()
);

CDC_sync LOCKED_CDC (
  .sig_in  (rx_mmcm_lckdpsbs_1 & rx_mmcm_lckdpsbs_2)
 ,.clk_b   (sys_clk)
 ,.rst_b   (sys_rst)
 ,.sig_sync(locked)
 ,.pulse_sync()
);

CDC_sync FVAL1_CDC (
  .sig_in  (FVAL1)
 ,.clk_b   (sys_clk)
 ,.rst_b   (sys_rst)
 ,.sig_sync(FVAL_sync_1)
 ,.pulse_sync()
);

CDC_sync FVAL2_CDC (
  .sig_in  (FVAL2)
 ,.clk_b   (sys_clk)
 ,.rst_b   (sys_rst)
 ,.sig_sync(FVAL_sync_2)
 ,.pulse_sync()
);

CDC_sync empty1_CDC (
  .sig_in  (empty_1)
 ,.clk_b   (rxclk_div_1)
 ,.rst_b   (~rx_mmcm_lckdpsbs)
 ,.sig_sync(empty_1_sync)
 ,.pulse_sync()
);

CDC_sync empty2_CDC (
  .sig_in  (empty_2)
 ,.clk_b   (rxclk_div_2)
 ,.rst_b   (~rx_mmcm_lckdpsbs)
 ,.sig_sync(empty_2_sync)
 ,.pulse_sync()
);

CDC_sync ready1_CDC (
  .sig_in  ((frame_valid_state >= 2'd2))
 ,.clk_b   (rxclk_div_1)
 ,.rst_b   (~rx_mmcm_lckdpsbs_1)
 ,.sig_sync(ready_sync_1)
 ,.pulse_sync()
);

CDC_sync ready2_CDC (
  .sig_in  ((frame_valid_state >= 2'd2))
 ,.clk_b   (rxclk_div_2)
 ,.rst_b   (~rx_mmcm_lckdpsbs_2)
 ,.sig_sync(ready_sync_2)
 ,.pulse_sync()
);

endmodule