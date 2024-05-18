`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/13/2024 11:36:32 AM
// Design Name: 
// Module Name: cameralink_tb
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
module cameralink_tb();

localparam FRAME_CNT    = 2;   // # of test image 

localparam CLOCK_FREQ_1   = 125; // MHz
localparam CLOCK_PERIOD_1 = (1000ns/CLOCK_FREQ_1);

localparam CLOCK_FREQ_2   = 200; // MHz
localparam CLOCK_PERIOD_2 = (1000ns/CLOCK_FREQ_2);

bit sys_clk;
bit ref_clk;
bit sys_rst;
bit new_frame;
int frame_cnt = 0;

initial sys_clk = 1'b0;
always #(CLOCK_PERIOD_1/2) sys_clk = ~sys_clk;

initial ref_clk = 1'b0;
always #(CLOCK_PERIOD_2/2) ref_clk = ~ref_clk;

task wait_for_reset;
  @(posedge sys_clk);
  @(posedge sys_clk);
  @(posedge sys_clk);
  sys_rst = 1'b1;
  @(posedge sys_clk);
  @(posedge sys_clk);
  @(posedge sys_clk);
  sys_rst = 1'b0;
  @(posedge sys_clk);
  @(posedge sys_clk);
  @(posedge sys_clk);
  $display("<<TESTBENCH NOTE>> system clk came out of reset");
endtask

task wait_for_new_frame;
  @(posedge sys_clk);
  new_frame = 1'b1;
  @(posedge sys_clk);
  new_frame = 1'b0;
  @(posedge sys_clk);
  @(posedge sys_clk);
  @(posedge sys_clk);
  @(posedge sys_clk);
  $display("<<TESTBENCH NOTE>> frame %0d requested", frame_cnt+1);
endtask

bit clk_p_hawk, x_3_p_hawk, x_2_p_hawk, x_1_p_hawk, x_0_p_hawk;
bit clk_n_hawk, x_3_n_hawk, x_2_n_hawk, x_1_n_hawk, x_0_n_hawk;

logic [2*4-1:0]  datain_p; 
logic [2*4-1:0]  datain_n;
logic [1:0]  clk_p; 
logic [1:0]  clk_n;
logic [15:0] imageWidth_hawk;
logic [15:0] imageHeight_hawk;
logic serde_locked ;

assign imageWidth_hawk = 1944;
assign imageHeight_hawk = 2;

cameralink_generator
#(
       .PIXEL_CLOCK_PERIOD (1000ns/74.25)
      ,.PIX_PER_TAP (2)
)
 hawk_camera
(
        .datain_p   (datain_p)
       ,.datain_n   (datain_n)
       ,.clk_p      (clk_p)
       ,.clk_n      (clk_n)
       ,.imageWidth (imageWidth_hawk)
       ,.imageHeight(imageHeight_hawk)
       ,.frame_cnt  (frame_cnt)
       ,.sys_rst    (sys_rst)
);

assign x_3_p_hawk = datain_p[3];
assign x_2_p_hawk = datain_p[2];
assign x_1_p_hawk = datain_p[1];
assign x_0_p_hawk = datain_p[0];
assign x_3_n_hawk = datain_n[3];
assign x_2_n_hawk = datain_n[2];
assign x_1_n_hawk = datain_n[1];
assign x_0_n_hawk = datain_n[0];
assign clk_p_hawk = clk_p[0];
assign clk_n_hawk = clk_n[0];

logic [63:0]S_AXIS_S2MM_0_tdata;
logic [7:0]S_AXIS_S2MM_0_tkeep;
logic S_AXIS_S2MM_0_tlast;
logic S_AXIS_S2MM_0_tvalid;
logic S_AXIS_S2MM_0_tready;
always @ (posedge sys_clk, posedge sys_rst) begin
     if (sys_rst)
        S_AXIS_S2MM_0_tready <= '0;
     else if (DUT.DMAWrite_inst.data_count[3])
        S_AXIS_S2MM_0_tready <= '1;
     else if (DUT.DMAWrite_inst.empty & ~DUT.DMAWrite_inst.data_end)
        S_AXIS_S2MM_0_tready <= '0;
end 

 HawkCameraCtrl DUT
 (
        .clkin_p             (clk_p_hawk)
       ,.clkin_n	         (clk_n_hawk)
       ,.datain_p            ({x_3_p_hawk,x_2_p_hawk,x_1_p_hawk,x_0_p_hawk})
       ,.datain_n            ({x_3_n_hawk,x_2_n_hawk,x_1_n_hawk,x_0_n_hawk})
       ,.imageWidth          (imageWidth_hawk)
       ,.imageHeight         (imageHeight_hawk)
       ,.sys_clk             (sys_clk)
       ,.ref_clk             (ref_clk)
       ,.sys_rst             (sys_rst)
       ,.capture             (new_frame)
       ,.serde_locked        (serde_locked)
       ,.testMode            (0)
       ,.S_AXIS_S2MM_0_tdata (S_AXIS_S2MM_0_tdata)
       ,.S_AXIS_S2MM_0_tkeep (S_AXIS_S2MM_0_tkeep)
       ,.S_AXIS_S2MM_0_tlast (S_AXIS_S2MM_0_tlast)
       ,.S_AXIS_S2MM_0_tready((|frame_cnt) | S_AXIS_S2MM_0_tready)
       ,.S_AXIS_S2MM_0_tvalid(S_AXIS_S2MM_0_tvalid)  
 );

// main function
initial begin
  wait_for_reset();
  while (~serde_locked) begin  
  hawk_camera.load_image();  
  end 
  for (frame_cnt = 0; frame_cnt < FRAME_CNT; frame_cnt++) begin
       wait_for_new_frame();
       hawk_camera.load_image();
       wait (DUT.DMAWrite_inst.S_AXIS_S2MM_0_tlast_lat == 1'b1);
       #500;
  end 
  $stop();
end   
       




endmodule
