`timescale 1ns / 1ps
//`define DEBUG
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2024 02:38:38 PM
// Design Name: 
// Module Name: Xband
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
module Xband(
	   input  logic sys_clk
	  ,input  logic sys_rst
	  ,input  logic ref_clk
	  ,input  logic clk_10M
	  ,input  logic clk_100M
	  ,input  logic xband_rst
	  ,input  logic new_frame
	  ,output logic MM2S_overflow
	  ,output logic S2MM_overflow
	  ,input  logic bitswap
	  ,input  logic [1:0] loopback
	  ,input  logic [31:0] expBytes
	  ,output logic [31:0] dataCnt 
	  // Xband LVDS
	  ,output logic tx1_clk_p
	  ,output logic tx1_clk_n
	  ,output logic tx1_data_p
	  ,output logic tx1_data_n	   
	  ,output logic tx2_clk_p
	  ,output logic tx2_clk_n
	  ,output logic tx2_data_p
	  ,output logic tx2_data_n		  
	  // AXIS interface
	  ,input  logic [31:0]  M_AXIS_MM2S_0_tdata
      ,input  logic [3:0]   M_AXIS_MM2S_0_tkeep
      ,output logic M_AXIS_MM2S_0_tready
      ,input  logic M_AXIS_MM2S_0_tvalid
	  ,output logic [31:0] S_AXIS_S2MM_1_tdata
      ,output logic [3:0]  S_AXIS_S2MM_1_tkeep
      ,output logic S_AXIS_S2MM_1_tlast
      ,input  logic S_AXIS_S2MM_1_tready
      ,output logic S_AXIS_S2MM_1_tvalid
    );

// new frame CDC
logic new_frame_lat;
logic new_frame_tx, new_frame_tx_fbin, new_frame_tx_fb;
//logic new_frame_rx, new_frame_rx_fbin, new_frame_rx_fb;
logic new_frame_d;
always @ (posedge sys_clk, posedge sys_rst) begin
      if (sys_rst)
         new_frame_d <= '0;
      else 
         new_frame_d <= new_frame;
end 

always @ (posedge sys_clk, posedge sys_rst) begin
      if (sys_rst) 
	     new_frame_lat <= '0; 
	  else if (new_frame_tx_fb)
	     new_frame_lat <= '0; 
      else if (new_frame & ~new_frame_d)
	     new_frame_lat <= '1;
end

CDC_sync new_frame_tx_sync (
       .sig_in(new_frame_lat),                    
       .clk_b (clk_10M),      
       .rst_b (xband_rst),       
       .sig_sync(new_frame_tx_fbin), 
	   .pulse_sync (new_frame_tx)
);

CDC_sync new_frame_tx_fd (
       .sig_in(new_frame_tx_fbin),                    
       .clk_b (sys_clk),      
       .rst_b (sys_rst),       
       .sig_sync(new_frame_tx_fb), 
	   .pulse_sync ()
);
 
logic [7:0] txdata;
logic txctrl;
logic [7:0] rxdata;
logic rxctrl;

logic [9:0] data_out_10bit;
logic [9:0] data_in_10bit;
logic data_out_val, data_out_kerr, data_out_rd;
logic data_in_val,  dataout_k, dataout_kerr, dataout_val, rxdataVld;
assign rxdataVld = dataout_val & ~dataout_k & ~dataout_kerr;

`ifdef DEBUG
ila_1 data_IF (
   .clk (clk_10M),
   .probe0 (txdata),
   .probe1 (txctrl),  
   .probe2 (data_out_10bit),
   .probe3 (data_out_kerr),  
   .probe4 (data_out_rd),
   .probe5 (data_out_val),  
   .probe6 (rxdata),
   .probe7 (rxdataVld),
   .probe8 (dataout_k),      
   .probe9 (dataout_kerr),  
   .probe10(dataout_val),
   .probe11(loopback)   
);
`endif 

//************************************************TX SIDE**********************************************
 //MM2S interface
MM2S_buffer MM2S_buffer_inst (
     .tx_clk    (clk_10M)  
   , .tx_rst    (xband_rst) 
   , .sys_clk   (sys_clk)
   , .sys_rst   (sys_rst)
   , .new_frame (new_frame_lat)
   , .tx_empty  (tx_empty)
   , .txdata    (txdata)
   , .txctrl    (txctrl)
   , .FIFO_overflow (MM2S_overflow)
   , .M_AXIS_MM2S_0_tdata (M_AXIS_MM2S_0_tdata)
   , .M_AXIS_MM2S_0_tkeep (M_AXIS_MM2S_0_tkeep)
   , .M_AXIS_MM2S_0_tready(M_AXIS_MM2S_0_tready)
   , .M_AXIS_MM2S_0_tvalid(M_AXIS_MM2S_0_tvalid)
);

enc_8b10b_n #( 
   .nb (1)
)
Xband_TX 
(
      .clk          (clk_10M)
    , .reset        (~xband_rst)
    , .datain       (txdata)
    , .datain_k     (txctrl)
    , .datain_val   (1'b1)
    , .dataout      (data_out_10bit)
    , .dataout_kerr (data_out_kerr)
    , .dataout_rd   (data_out_rd)
    , .dataout_val  (data_out_val)
);

serializer xband_Tx1 (
       .data       (data_out_10bit)
      ,.ref_clk    (ref_clk)
      ,.bitswap    (bitswap)
      ,.dataout_p (tx1_data_p)
      ,.dataout_n (tx1_data_n)
      ,.clk_p      (tx1_clk_p)
      ,.clk_n      (tx1_clk_n)
      ,.txclk      (clk_100M)
      ,.reset_int  (xband_rst)
      ,.pixel_clk  (clk_10M)
);

serializer xband_Tx2 (
       .data       (data_out_10bit)
      ,.ref_clk    (ref_clk) 
      ,.bitswap    (bitswap) 
      ,.dataout_p (tx2_data_p)
      ,.dataout_n (tx2_data_n)
      ,.clk_p      (tx2_clk_p)
      ,.clk_n      (tx2_clk_n)
      ,.txclk      (clk_100M)
      ,.reset_int  (xband_rst)
      ,.pixel_clk  (clk_10M)
);
//************************************************RX SIDE**********************************************
dec_8b10b_n #(
    .nw (1)
)
Xband_RX 
(
    .clk           (clk_10M)
  , .reset         (~xband_rst)
  , .datain        (loopback[1]? data_out_10bit :data_in_10bit)
  , .datain_val    (loopback[1]? data_out_val :data_in_val)
  , .dataout       (rxdata)
  , .dataout_k     (dataout_k)
  , .dataout_kerr  (dataout_kerr)
  , .dataout_val   (dataout_val)
);

//S2MM interface 
S2MM_buffer S2MM_buffer_inst (
     .rx_clk        (clk_10M)  
   , .rx_rst        (xband_rst) 
   , .sys_clk       (sys_clk)
   , .sys_rst       (sys_rst)
   , .new_frame     (new_frame_lat)
   , .expBytes      (expBytes)
   , .dataCnt       (dataCnt)
   , .FIFO_overflow (S2MM_overflow)
   , .rxdata        (loopback[0]? txdata : rxdata)
   , .rxdataVld     (loopback[0]? ~txctrl : rxdataVld)
   , .AxisData      (S_AXIS_S2MM_1_tdata)
   , .AxisDataReady (S_AXIS_S2MM_1_tkeep)
   , .AxisDataEnd   (S_AXIS_S2MM_1_tlast)
   , .AxisDataRead  (S_AXIS_S2MM_1_tready)
   , .AxisDataVld   (S_AXIS_S2MM_1_tvalid)
);   
    
endmodule
