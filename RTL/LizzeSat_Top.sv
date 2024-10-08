`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2024 09:28:38 AM
// Design Name: 
// Module Name: LizzeSat_Top
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
module LizzeSat_Top(
   // DDR3 memory
   inout  logic [14:0]DDR_addr
  ,inout  logic [2:0]DDR_ba
  ,inout  logic DDR_cas_n
  ,inout  logic DDR_ck_n
  ,inout  logic DDR_ck_p
  ,inout  logic DDR_cke
  ,inout  logic DDR_cs_n
  ,inout  logic [3:0]DDR_dm
  ,inout  logic [31:0]DDR_dq
  ,inout  logic [3:0]DDR_dqs_n
  ,inout  logic [3:0]DDR_dqs_p
  ,inout  logic DDR_odt
  ,inout  logic DDR_ras_n
  ,inout  logic DDR_reset_n
  ,inout  logic DDR_we_n 
  // fixed IO
  ,inout  logic  FIXED_IO_ddr_vrn
  ,inout  logic  FIXED_IO_ddr_vrp
  ,inout  logic  [53:0]FIXED_IO_mio
  ,inout  logic  FIXED_IO_ps_clk
  ,inout  logic  FIXED_IO_ps_porb
  ,inout  logic  FIXED_IO_ps_srstb     
  // camera link
  ,input  logic xclk_p
  ,input  logic xclk_n
  ,input  logic [3:0] x_p
  ,input  logic [3:0] x_n
  ,input  logic yclk_p
  ,input  logic yclk_n
  ,input  logic [3:0] y_p
  ,input  logic [3:0] y_n
  ,input  logic SerTFG_p 
  ,input  logic SerTFG_n
  ,output logic SerTC_p
  ,output logic SerTC_n  
  //Xband  
  ,output logic tx1_clk_p
  ,output logic tx1_clk_n
  ,output logic tx1_data_p
  ,output logic tx1_data_n	   
  ,output logic tx2_clk_p
  ,output logic tx2_clk_n
  ,output logic tx2_data_p
  ,output logic tx2_data_n	
);

logic sys_clk, ref_clk;
logic sys_rst;

// AXI4-Lite Bus 
logic [31:0]AXI_0_araddr;
logic [2:0]AXI_0_arprot;
logic [0:0]AXI_0_arready;
logic [0:0]AXI_0_arvalid;
logic [31:0]AXI_0_awaddr;
logic [2:0]AXI_0_awprot;
logic [0:0]AXI_0_awready;
logic [0:0]AXI_0_awvalid;
logic [0:0]AXI_0_bready;
logic [1:0]AXI_0_bresp;
logic [0:0]AXI_0_bvalid;
logic [31:0]AXI_0_rdata;
logic [0:0]AXI_0_rready;
logic [1:0]AXI_0_rresp;
logic [0:0]AXI_0_rvalid;
logic [31:0]AXI_0_wdata;
logic [0:0]AXI_0_wready;
logic [3:0]AXI_0_wstrb;
logic [0:0]AXI_0_wvalid;

// AXI-S Bus
logic [63:0]S_AXIS_S2MM_0_tdata;
logic [7:0]S_AXIS_S2MM_0_tkeep;
logic S_AXIS_S2MM_0_tlast;
logic S_AXIS_S2MM_0_tready;
logic S_AXIS_S2MM_0_tvalid;
logic uart_0_rxd,uart_0_txd;

logic [31:0]M_AXIS_MM2S_0_tdata;
logic [3:0]M_AXIS_MM2S_0_tkeep;
logic M_AXIS_MM2S_0_tlast;
logic M_AXIS_MM2S_0_tready;
logic M_AXIS_MM2S_0_tvalid;

logic [31:0]S_AXIS_S2MM_1_tdata;
logic [3:0]S_AXIS_S2MM_1_tkeep;
logic S_AXIS_S2MM_1_tlast;
logic S_AXIS_S2MM_1_tready;
logic S_AXIS_S2MM_1_tvalid;

logic xband_rst;
logic clk_100M;
logic clk_10M;

CPU_system_wrapper(
     // DDR3 memory 
    .DDR_addr   (DDR_addr),
    .DDR_ba     (DDR_ba),
    .DDR_cas_n  (DDR_cas_n),
    .DDR_ck_n   (DDR_ck_n),
    .DDR_ck_p   (DDR_ck_p),
    .DDR_cke    (DDR_cke),
    .DDR_cs_n   (DDR_cs_n),
    .DDR_dm     (DDR_dm),
    .DDR_dq     (DDR_dq),
    .DDR_dqs_n  (DDR_dqs_n),
    .DDR_dqs_p  (DDR_dqs_p),
    .DDR_odt    (DDR_odt),
    .DDR_ras_n  (DDR_ras_n),
    .DDR_reset_n(DDR_reset_n),
    .DDR_we_n   (DDR_we_n),
    // fixed IO
    .FIXED_IO_ddr_vrn  (FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp  (FIXED_IO_ddr_vrp),
    .FIXED_IO_mio      (FIXED_IO_mio),
    .FIXED_IO_ps_clk   (FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb  (FIXED_IO_ps_porb),
    .FIXED_IO_ps_srstb (FIXED_IO_ps_srstb),
    // clock & reset
    .sys_clk           (sys_clk),
    .ref_clk           (ref_clk),
    .clk_100M          (clk_100M),
    .clk_10M           (clk_10M),
    .xband_rst         (xband_rst),
    .peripheral_reset_0(sys_rst),
    .peripheral_aresetn(sys_rst_n),
    // AXI4-Lite 
    .M06_AXI_0_araddr  (AXI_0_araddr),
    .M06_AXI_0_arprot  (AXI_0_arprot),
    .M06_AXI_0_arready (AXI_0_arready),
    .M06_AXI_0_arvalid (AXI_0_arvalid),
    .M06_AXI_0_awaddr  (AXI_0_awaddr),
    .M06_AXI_0_awprot  (AXI_0_awprot),
    .M06_AXI_0_awready (AXI_0_awready),
    .M06_AXI_0_awvalid (AXI_0_awvalid),
    .M06_AXI_0_bready  (AXI_0_bready),
    .M06_AXI_0_bresp   (AXI_0_bresp),
    .M06_AXI_0_bvalid  (AXI_0_bvalid),
    .M06_AXI_0_rdata   (AXI_0_rdata),
    .M06_AXI_0_rready  (AXI_0_rready),
    .M06_AXI_0_rresp   (AXI_0_rresp),
    .M06_AXI_0_rvalid  (AXI_0_rvalid),
    .M06_AXI_0_wdata   (AXI_0_wdata),
    .M06_AXI_0_wready  (AXI_0_wready),
    .M06_AXI_0_wstrb   (AXI_0_wstrb),
    .M06_AXI_0_wvalid  (AXI_0_wvalid),
    // AXI_S 
    .S_AXIS_S2MM_0_tdata (S_AXIS_S2MM_0_tdata),
    .S_AXIS_S2MM_0_tkeep (S_AXIS_S2MM_0_tkeep),
    .S_AXIS_S2MM_0_tlast (S_AXIS_S2MM_0_tlast),
    .S_AXIS_S2MM_0_tready(S_AXIS_S2MM_0_tready),
    .S_AXIS_S2MM_0_tvalid(S_AXIS_S2MM_0_tvalid),    
    .M_AXIS_MM2S_0_tdata(M_AXIS_MM2S_0_tdata),
    .M_AXIS_MM2S_0_tkeep(M_AXIS_MM2S_0_tkeep),
    .M_AXIS_MM2S_0_tlast(M_AXIS_MM2S_0_tlast),
    .M_AXIS_MM2S_0_tready(M_AXIS_MM2S_0_tready),
    .M_AXIS_MM2S_0_tvalid(M_AXIS_MM2S_0_tvalid),
    .S_AXIS_S2MM_1_tdata(S_AXIS_S2MM_1_tdata),
    .S_AXIS_S2MM_1_tkeep(S_AXIS_S2MM_1_tkeep),
    .S_AXIS_S2MM_1_tlast(S_AXIS_S2MM_1_tlast),
    .S_AXIS_S2MM_1_tready(S_AXIS_S2MM_1_tready),
    .S_AXIS_S2MM_1_tvalid(S_AXIS_S2MM_1_tvalid),   
    // Device UART
    .uart_rtl_0_rxd  (uart_0_rxd),
    .uart_rtl_0_txd  (uart_0_txd)
);    

IBUFDS RX_LVDS 
(
	.I    			(SerTFG_p),
	.IB       		(SerTFG_n),
	.O         		(uart_0_rxd)
);

OBUFDS TX_LVDS 
(
	.I    			(uart_0_txd),
	.OB       		(SerTC_n),
	.O         		(SerTC_p)
);

// AXI4-Lite Register bank
logic capture, testMode, cameraSel, serde_locked, camera_in_progress;
logic [15:0] HawkImageWidth;
logic [15:0] HawkImageHeight;
logic [15:0] OwlImageWidth;
logic [15:0] OwlImageHeight;
logic [31:0] timeOut;
logic [31:0] DMAdataXferedCnt;
logic xband_new_frame, MM2S_overflow, S2MM_overflow;
logic [31:0] xband_rec_bytes;
logic [31:0] xband_rec_dataCnt;
logic [1:0]  loopback;
logic bitswap;

axi_register_interface axi_register_bank(
	    .S_AXI_ACLK    (sys_clk),
		.S_AXI_ARESETN (sys_rst_n),
		// Register data
        .capture      (capture),
        .cameraSel    (cameraSel),
        .testMode     (testMode),
        .HawkImageHeight (HawkImageHeight),
        .HawkImageWidth  (HawkImageWidth),
        .OwlImageHeight  (OwlImageHeight),
        .OwlImageWidth   (OwlImageWidth),
        .serde_locked      (serde_locked),
        .camera_in_progress(camera_in_progress),
        .timeOut           (timeOut),
        .HwVersion         ({24'h2,1'b0,SW6,SW5,SW4,SW3,SW2,SW1,SW0}),
        .ledTest           ({LD5,LD4,LD3,LD2,LD1,LD0}),		
        .DMAdataXferedCnt  (DMAdataXferedCnt),  
        .xband_new_frame   (xband_new_frame),
        .MM2S_overflow     (MM2S_overflow),
        .S2MM_overflow     (S2MM_overflow),
        .xband_rec_bytes   (xband_rec_bytes),
        .xband_rec_dataCnt (xband_rec_dataCnt),
        .loopback          (loopback),
        .bitswap           (bitswap),
		// AXI4Lite 
		.S_AXI_AWADDR  (AXI_0_awaddr),
		.S_AXI_AWPROT  (AXI_0_awprot),
		.S_AXI_AWVALID (AXI_0_awvalid),
		.S_AXI_AWREADY (AXI_0_awready), 
		.S_AXI_WDATA   (AXI_0_wdata),  
		.S_AXI_WSTRB   (AXI_0_wstrb),
		.S_AXI_WVALID  (AXI_0_wvalid),
		.S_AXI_WREADY  (AXI_0_wready),
		.S_AXI_BRESP   (AXI_0_bresp),
		.S_AXI_BVALID  (AXI_0_bvalid),
		.S_AXI_BREADY  (AXI_0_bready),
		.S_AXI_ARADDR  (AXI_0_araddr),
		.S_AXI_ARPROT  (AXI_0_arprot),
		.S_AXI_ARVALID (AXI_0_arvalid),
		.S_AXI_ARREADY (AXI_0_arready),
		.S_AXI_RDATA   (AXI_0_rdata),
		.S_AXI_RRESP   (AXI_0_rresp),
		.S_AXI_RVALID  (AXI_0_rvalid),
		.S_AXI_RREADY  (AXI_0_rready)
	);
	
// camera
camera camera_receiver(
       // camera link
       .xclk_p      (xclk_p)
      ,.xclk_n      (xclk_n)
      ,.x_p         (x_p)
      ,.x_n         (x_n)
      ,.yclk_p      (yclk_p)
      ,.yclk_n      (yclk_n)
      ,.y_p         (y_p)
      ,.y_n         (y_n)
      // system 
      ,.ref_clk      (ref_clk)
      ,.sys_clk      (sys_clk)
      ,.sys_rst      (sys_rst)
      ,.new_capture  (capture)
      ,.cameraSel    (cameraSel)
      ,.testMode     (testMode)
      ,.timeOut      (timeOut)
      ,.hawk_image_height (HawkImageHeight)
      ,.hawk_image_width  (HawkImageWidth)
      ,.owl_image_height  (OwlImageHeight)
      ,.owl_image_width   (OwlImageWidth)
      ,.serde_locked      (serde_locked)
      ,.camera_in_progress(camera_in_progress)
      // DMA
      ,.S_AXIS_S2MM_0_tdata (S_AXIS_S2MM_0_tdata)
      ,.S_AXIS_S2MM_0_tkeep (S_AXIS_S2MM_0_tkeep)
      ,.S_AXIS_S2MM_0_tlast (S_AXIS_S2MM_0_tlast)
      ,.S_AXIS_S2MM_0_tready(S_AXIS_S2MM_0_tready)
      ,.S_AXIS_S2MM_0_tvalid(S_AXIS_S2MM_0_tvalid) 
      ,.dataXferedCnt       (DMAdataXferedCnt)              
);

// xband
Xband Xband_LVDS
(
	   .sys_clk                (sys_clk)
	  ,.sys_rst                (sys_rst)
	  ,.clk_10M                (clk_10M)
	  ,.clk_100M               (clk_100M)
	  ,.ref_clk                (ref_clk)
	  ,.xband_rst              (xband_rst)
	  ,.new_frame              (xband_new_frame)
	  ,.MM2S_overflow          (MM2S_overflow)
	  ,.S2MM_overflow          (S2MM_overflow)
	  ,.expBytes               (xband_rec_bytes)
	  ,.dataCnt                (xband_rec_dataCnt)
	  ,.loopback               (loopback)
	  ,.bitswap                (bitswap)
	  ,.tx1_clk_p              (tx1_clk_p)
	  ,.tx1_clk_n              (tx1_clk_n)
	  ,.tx1_data_p             (tx1_data_p)
	  ,.tx1_data_n	           (tx1_data_n)
	  ,.tx2_clk_p              (tx2_clk_p)
	  ,.tx2_clk_n              (tx2_clk_n)
	  ,.tx2_data_p             (tx2_data_p)
	  ,.tx2_data_n	           (tx2_data_n)
	  // AXIS interface
	  ,.M_AXIS_MM2S_0_tdata    (M_AXIS_MM2S_0_tdata)
      ,.M_AXIS_MM2S_0_tkeep    (M_AXIS_MM2S_0_tkeep)
      ,.M_AXIS_MM2S_0_tready   (M_AXIS_MM2S_0_tready)
      ,.M_AXIS_MM2S_0_tvalid   (M_AXIS_MM2S_0_tvalid)
	  ,.S_AXIS_S2MM_1_tdata    (S_AXIS_S2MM_1_tdata)
      ,.S_AXIS_S2MM_1_tkeep    (S_AXIS_S2MM_1_tkeep)
      ,.S_AXIS_S2MM_1_tlast    (S_AXIS_S2MM_1_tlast)
      ,.S_AXIS_S2MM_1_tready   (S_AXIS_S2MM_1_tready)
      ,.S_AXIS_S2MM_1_tvalid   (S_AXIS_S2MM_1_tvalid)
);
    
endmodule
