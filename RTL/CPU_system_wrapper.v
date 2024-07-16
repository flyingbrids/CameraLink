//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
//Date        : Tue Jul 16 14:02:50 2024
//Host        : L3520-003 running 64-bit major release  (build 9200)
//Command     : generate_target CPU_system_wrapper.bd
//Design      : CPU_system_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module CPU_system_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    M06_AXI_0_araddr,
    M06_AXI_0_arprot,
    M06_AXI_0_arready,
    M06_AXI_0_arvalid,
    M06_AXI_0_awaddr,
    M06_AXI_0_awprot,
    M06_AXI_0_awready,
    M06_AXI_0_awvalid,
    M06_AXI_0_bready,
    M06_AXI_0_bresp,
    M06_AXI_0_bvalid,
    M06_AXI_0_rdata,
    M06_AXI_0_rready,
    M06_AXI_0_rresp,
    M06_AXI_0_rvalid,
    M06_AXI_0_wdata,
    M06_AXI_0_wready,
    M06_AXI_0_wstrb,
    M06_AXI_0_wvalid,
    M_AXIS_MM2S_0_tdata,
    M_AXIS_MM2S_0_tkeep,
    M_AXIS_MM2S_0_tlast,
    M_AXIS_MM2S_0_tready,
    M_AXIS_MM2S_0_tvalid,
    S_AXIS_S2MM_0_tdata,
    S_AXIS_S2MM_0_tkeep,
    S_AXIS_S2MM_0_tlast,
    S_AXIS_S2MM_0_tready,
    S_AXIS_S2MM_0_tvalid,
    S_AXIS_S2MM_1_tdata,
    S_AXIS_S2MM_1_tkeep,
    S_AXIS_S2MM_1_tlast,
    S_AXIS_S2MM_1_tready,
    S_AXIS_S2MM_1_tvalid,
    clk_100M,
    clk_10M,
    peripheral_aresetn,
    peripheral_reset_0,
    ref_clk,
    sys_clk,
    uart_rtl_0_baudoutn,
    uart_rtl_0_ctsn,
    uart_rtl_0_dcdn,
    uart_rtl_0_ddis,
    uart_rtl_0_dsrn,
    uart_rtl_0_dtrn,
    uart_rtl_0_out1n,
    uart_rtl_0_out2n,
    uart_rtl_0_ri,
    uart_rtl_0_rtsn,
    uart_rtl_0_rxd,
    uart_rtl_0_rxrdyn,
    uart_rtl_0_txd,
    uart_rtl_0_txrdyn,
    xband_rst);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [31:0]M06_AXI_0_araddr;
  output [2:0]M06_AXI_0_arprot;
  input [0:0]M06_AXI_0_arready;
  output [0:0]M06_AXI_0_arvalid;
  output [31:0]M06_AXI_0_awaddr;
  output [2:0]M06_AXI_0_awprot;
  input [0:0]M06_AXI_0_awready;
  output [0:0]M06_AXI_0_awvalid;
  output [0:0]M06_AXI_0_bready;
  input [1:0]M06_AXI_0_bresp;
  input [0:0]M06_AXI_0_bvalid;
  input [31:0]M06_AXI_0_rdata;
  output [0:0]M06_AXI_0_rready;
  input [1:0]M06_AXI_0_rresp;
  input [0:0]M06_AXI_0_rvalid;
  output [31:0]M06_AXI_0_wdata;
  input [0:0]M06_AXI_0_wready;
  output [3:0]M06_AXI_0_wstrb;
  output [0:0]M06_AXI_0_wvalid;
  output [31:0]M_AXIS_MM2S_0_tdata;
  output [3:0]M_AXIS_MM2S_0_tkeep;
  output M_AXIS_MM2S_0_tlast;
  input M_AXIS_MM2S_0_tready;
  output M_AXIS_MM2S_0_tvalid;
  input [63:0]S_AXIS_S2MM_0_tdata;
  input [7:0]S_AXIS_S2MM_0_tkeep;
  input S_AXIS_S2MM_0_tlast;
  output S_AXIS_S2MM_0_tready;
  input S_AXIS_S2MM_0_tvalid;
  input [31:0]S_AXIS_S2MM_1_tdata;
  input [3:0]S_AXIS_S2MM_1_tkeep;
  input S_AXIS_S2MM_1_tlast;
  output S_AXIS_S2MM_1_tready;
  input S_AXIS_S2MM_1_tvalid;
  output clk_100M;
  output clk_10M;
  output [0:0]peripheral_aresetn;
  output [0:0]peripheral_reset_0;
  output ref_clk;
  output sys_clk;
  output uart_rtl_0_baudoutn;
  input uart_rtl_0_ctsn;
  input uart_rtl_0_dcdn;
  output uart_rtl_0_ddis;
  input uart_rtl_0_dsrn;
  output uart_rtl_0_dtrn;
  output uart_rtl_0_out1n;
  output uart_rtl_0_out2n;
  input uart_rtl_0_ri;
  output uart_rtl_0_rtsn;
  input uart_rtl_0_rxd;
  output uart_rtl_0_rxrdyn;
  output uart_rtl_0_txd;
  output uart_rtl_0_txrdyn;
  output [0:0]xband_rst;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [31:0]M06_AXI_0_araddr;
  wire [2:0]M06_AXI_0_arprot;
  wire [0:0]M06_AXI_0_arready;
  wire [0:0]M06_AXI_0_arvalid;
  wire [31:0]M06_AXI_0_awaddr;
  wire [2:0]M06_AXI_0_awprot;
  wire [0:0]M06_AXI_0_awready;
  wire [0:0]M06_AXI_0_awvalid;
  wire [0:0]M06_AXI_0_bready;
  wire [1:0]M06_AXI_0_bresp;
  wire [0:0]M06_AXI_0_bvalid;
  wire [31:0]M06_AXI_0_rdata;
  wire [0:0]M06_AXI_0_rready;
  wire [1:0]M06_AXI_0_rresp;
  wire [0:0]M06_AXI_0_rvalid;
  wire [31:0]M06_AXI_0_wdata;
  wire [0:0]M06_AXI_0_wready;
  wire [3:0]M06_AXI_0_wstrb;
  wire [0:0]M06_AXI_0_wvalid;
  wire [31:0]M_AXIS_MM2S_0_tdata;
  wire [3:0]M_AXIS_MM2S_0_tkeep;
  wire M_AXIS_MM2S_0_tlast;
  wire M_AXIS_MM2S_0_tready;
  wire M_AXIS_MM2S_0_tvalid;
  wire [63:0]S_AXIS_S2MM_0_tdata;
  wire [7:0]S_AXIS_S2MM_0_tkeep;
  wire S_AXIS_S2MM_0_tlast;
  wire S_AXIS_S2MM_0_tready;
  wire S_AXIS_S2MM_0_tvalid;
  wire [31:0]S_AXIS_S2MM_1_tdata;
  wire [3:0]S_AXIS_S2MM_1_tkeep;
  wire S_AXIS_S2MM_1_tlast;
  wire S_AXIS_S2MM_1_tready;
  wire S_AXIS_S2MM_1_tvalid;
  wire clk_100M;
  wire clk_10M;
  wire [0:0]peripheral_aresetn;
  wire [0:0]peripheral_reset_0;
  wire ref_clk;
  wire sys_clk;
  wire uart_rtl_0_baudoutn;
  wire uart_rtl_0_ctsn;
  wire uart_rtl_0_dcdn;
  wire uart_rtl_0_ddis;
  wire uart_rtl_0_dsrn;
  wire uart_rtl_0_dtrn;
  wire uart_rtl_0_out1n;
  wire uart_rtl_0_out2n;
  wire uart_rtl_0_ri;
  wire uart_rtl_0_rtsn;
  wire uart_rtl_0_rxd;
  wire uart_rtl_0_rxrdyn;
  wire uart_rtl_0_txd;
  wire uart_rtl_0_txrdyn;
  wire [0:0]xband_rst;

  CPU_system CPU_system_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .M06_AXI_0_araddr(M06_AXI_0_araddr),
        .M06_AXI_0_arprot(M06_AXI_0_arprot),
        .M06_AXI_0_arready(M06_AXI_0_arready),
        .M06_AXI_0_arvalid(M06_AXI_0_arvalid),
        .M06_AXI_0_awaddr(M06_AXI_0_awaddr),
        .M06_AXI_0_awprot(M06_AXI_0_awprot),
        .M06_AXI_0_awready(M06_AXI_0_awready),
        .M06_AXI_0_awvalid(M06_AXI_0_awvalid),
        .M06_AXI_0_bready(M06_AXI_0_bready),
        .M06_AXI_0_bresp(M06_AXI_0_bresp),
        .M06_AXI_0_bvalid(M06_AXI_0_bvalid),
        .M06_AXI_0_rdata(M06_AXI_0_rdata),
        .M06_AXI_0_rready(M06_AXI_0_rready),
        .M06_AXI_0_rresp(M06_AXI_0_rresp),
        .M06_AXI_0_rvalid(M06_AXI_0_rvalid),
        .M06_AXI_0_wdata(M06_AXI_0_wdata),
        .M06_AXI_0_wready(M06_AXI_0_wready),
        .M06_AXI_0_wstrb(M06_AXI_0_wstrb),
        .M06_AXI_0_wvalid(M06_AXI_0_wvalid),
        .M_AXIS_MM2S_0_tdata(M_AXIS_MM2S_0_tdata),
        .M_AXIS_MM2S_0_tkeep(M_AXIS_MM2S_0_tkeep),
        .M_AXIS_MM2S_0_tlast(M_AXIS_MM2S_0_tlast),
        .M_AXIS_MM2S_0_tready(M_AXIS_MM2S_0_tready),
        .M_AXIS_MM2S_0_tvalid(M_AXIS_MM2S_0_tvalid),
        .S_AXIS_S2MM_0_tdata(S_AXIS_S2MM_0_tdata),
        .S_AXIS_S2MM_0_tkeep(S_AXIS_S2MM_0_tkeep),
        .S_AXIS_S2MM_0_tlast(S_AXIS_S2MM_0_tlast),
        .S_AXIS_S2MM_0_tready(S_AXIS_S2MM_0_tready),
        .S_AXIS_S2MM_0_tvalid(S_AXIS_S2MM_0_tvalid),
        .S_AXIS_S2MM_1_tdata(S_AXIS_S2MM_1_tdata),
        .S_AXIS_S2MM_1_tkeep(S_AXIS_S2MM_1_tkeep),
        .S_AXIS_S2MM_1_tlast(S_AXIS_S2MM_1_tlast),
        .S_AXIS_S2MM_1_tready(S_AXIS_S2MM_1_tready),
        .S_AXIS_S2MM_1_tvalid(S_AXIS_S2MM_1_tvalid),
        .clk_100M(clk_100M),
        .clk_10M(clk_10M),
        .peripheral_aresetn(peripheral_aresetn),
        .peripheral_reset_0(peripheral_reset_0),
        .ref_clk(ref_clk),
        .sys_clk(sys_clk),
        .uart_rtl_0_baudoutn(uart_rtl_0_baudoutn),
        .uart_rtl_0_ctsn(uart_rtl_0_ctsn),
        .uart_rtl_0_dcdn(uart_rtl_0_dcdn),
        .uart_rtl_0_ddis(uart_rtl_0_ddis),
        .uart_rtl_0_dsrn(uart_rtl_0_dsrn),
        .uart_rtl_0_dtrn(uart_rtl_0_dtrn),
        .uart_rtl_0_out1n(uart_rtl_0_out1n),
        .uart_rtl_0_out2n(uart_rtl_0_out2n),
        .uart_rtl_0_ri(uart_rtl_0_ri),
        .uart_rtl_0_rtsn(uart_rtl_0_rtsn),
        .uart_rtl_0_rxd(uart_rtl_0_rxd),
        .uart_rtl_0_rxrdyn(uart_rtl_0_rxrdyn),
        .uart_rtl_0_txd(uart_rtl_0_txd),
        .uart_rtl_0_txrdyn(uart_rtl_0_txrdyn),
        .xband_rst(xband_rst));
endmodule
