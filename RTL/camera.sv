`timescale 1ns / 1ps
`define DEBUG
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2024 09:18:06 AM
// Design Name: 
// Module Name: camera
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
module camera(
       // camera link
       input  logic hawk_clk_n
      ,input  logic hawk_clk_p
      ,input  logic owl_clk_1_n
      ,input  logic owl_clk_1_p  
      ,input  logic owl_clk_2_n
      ,input  logic owl_clk_2_p
      ,input  logic [3:0] data_hawk_p
      ,input  logic [3:0] data_hawk_n
      ,input  logic [7:0] data_owl_p
      ,input  logic [7:0] data_owl_n
      // system 
      ,input  logic ref_clk
      ,input  logic sys_clk
      ,input  logic sys_rst
      ,input  logic new_capture
      ,input  logic cameraSel
      ,input  logic testMode
      ,input  logic [15:0] hawk_image_height
      ,input  logic [15:0] hawk_image_width
      ,input  logic [15:0] owl_image_height
      ,input  logic [15:0] owl_image_width
      ,output logic serde_locked
      ,output logic camera_in_progress
      // DMA
      ,output logic [63:0]S_AXIS_S2MM_0_tdata
      ,output logic [7:0]S_AXIS_S2MM_0_tkeep
      ,output logic S_AXIS_S2MM_0_tlast
      ,input  logic S_AXIS_S2MM_0_tready
      ,output logic S_AXIS_S2MM_0_tvalid  
      ,output logic [31:0] dataXferedCnt             
);

logic [1:0] cameraState;
logic capture_end, cameraSelRegister, hawk_serde_locked, owl_serde_locked, frame_rst;

assign camera_in_progress = (cameraState == '0)? 1'b0 : 1'b1;

always @ (posedge sys_clk) begin
      if (~camera_in_progress) begin
         cameraSelRegister <= cameraSel;      
      end 
end 

assign capture_end  = cameraSelRegister? owl_capture_end : hawk_capture_end;
assign serde_locked = cameraSelRegister? owl_serde_locked : hawk_serde_locked;
assign frame_rst    = cameraSelRegister? owl_new_frame   : hawk_new_frame; 

logic hawk_new_frame;
logic [23:0] hawk_pixel;
logic hawk_pixel_vld, hawk_capture_end;

logic owl_new_frame;
logic [47:0] owl_pixel;
logic owl_pixel_vld, owl_capture_end;

always @ (posedge sys_clk, posedge sys_rst) begin
       if (sys_rst) begin
          cameraState <= '0;
       end else begin 
          case (cameraState) 
          2'b00:  if (frame_rst) cameraState <= 2'b01;
          2'b01:  if (capture_end) cameraState <= 2'b10;
          2'b10:  if (S_AXIS_S2MM_0_tlast) cameraState <= 2'b00;
          default: cameraState <= 2'b00;  
          endcase 
       end
end 

logic new_capture_d, capture;
always @ (posedge sys_clk, posedge sys_rst) begin
       if (sys_rst) begin
          new_capture_d <= '0;
       end else begin
          new_capture_d <= new_capture;
       end 
end 

assign capture = ~new_capture_d & new_capture;

IDELAYCTRL icontrol (              			
	.REFCLK			(ref_clk),
	.RST			(sys_rst),
	.RDY			(delay_ready)
);	

HawkCameraCtrl HawkCamera
 (
        .clkin_p             (hawk_clk_p)
       ,.clkin_n	         (hawk_clk_n)
       ,.datain_p            (data_hawk_p)
       ,.datain_n            (data_hawk_n)
       ,.imageWidth          (hawk_image_width)
       ,.imageHeight         (hawk_image_height)
       ,.sys_clk             (sys_clk)
       ,.delay_ready         (delay_ready)
       ,.sys_rst             (sys_rst)
       ,.capture             (capture)
       ,.serde_locked        (hawk_serde_locked)
       ,.testMode            (testMode)
       ,.new_frame           (hawk_new_frame)
       ,.pixel               (hawk_pixel)
       ,.data_vld            (hawk_pixel_vld)
       ,.capture_end         (hawk_capture_end)
       ,.camera_in_progress  (camera_in_progress)
       ,.cameraSel           (~cameraSelRegister)
 );
 
logic [3:0] datain1_p;
logic [3:0] datain1_n;
logic [3:0] datain2_p;
logic [3:0] datain2_n;
assign datain1_p = data_owl_p[3:0]; 
assign datain1_n = data_owl_n[3:0];  
assign datain2_p = data_owl_p[7:4]; 
assign datain2_n = data_owl_n[7:4];

OwlCameraCtrl OwlCamera
 (
        .clkin1_p             (owl_clk_1_p)
       ,.clkin1_n	          (owl_clk_1_n)
       ,.datain1_p            (datain1_p)
       ,.datain1_n            (datain1_n)
       ,.clkin2_p             (owl_clk_2_p)
       ,.clkin2_n	          (owl_clk_2_n)
       ,.datain2_p            (datain2_p )
       ,.datain2_n            (datain2_n )       
       ,.imageWidth           (owl_image_width)
       ,.imageHeight          (owl_image_height)
       ,.sys_clk              (sys_clk)
       ,.delay_ready          (delay_ready)
       ,.sys_rst              (sys_rst)
       ,.capture              (capture)
       ,.serde_locked         (owl_serde_locked)
       ,.testMode             (testMode)
       ,.new_frame            (owl_new_frame)
       ,.pixel                (owl_pixel)
       ,.data_vld             (owl_pixel_vld)
       ,.capture_end          (owl_capture_end)
       ,.camera_in_progress  (camera_in_progress)
       ,.cameraSel           (cameraSelRegister)
 );
 
 DMAWrite DMAWrite_inst(
   .sys_clk              (sys_clk)
  ,.sys_rst              (sys_rst)
  ,.frame_rst            (frame_rst)
  ,.data_in              (cameraSelRegister? owl_pixel       : {'0,hawk_pixel} )
  ,.data_vld             (cameraSelRegister? owl_pixel_vld   : hawk_pixel_vld  )
  ,.data_end             (cameraSelRegister? owl_capture_end : hawk_capture_end)
  ,.data_sel             (cameraSelRegister)
  ,.S_AXIS_S2MM_0_tdata  (S_AXIS_S2MM_0_tdata)
  ,.S_AXIS_S2MM_0_tkeep  (S_AXIS_S2MM_0_tkeep)
  ,.S_AXIS_S2MM_0_tlast  (S_AXIS_S2MM_0_tlast)
  ,.S_AXIS_S2MM_0_tready (S_AXIS_S2MM_0_tready)
  ,.S_AXIS_S2MM_0_tvalid (S_AXIS_S2MM_0_tvalid)   
  ,.dataXferedCnt        (dataXferedCnt)
 );
   

`ifdef DEBUG
ila_0 ila_camera (
 .clk    (sys_clk)
,.probe0 (cameraSelRegister)
,.probe1 (testMode)
,.probe2 (dataXferedCnt)
,.probe3 (S_AXIS_S2MM_0_tready)
,.probe4 (S_AXIS_S2MM_0_tvalid)
,.probe5 (frame_rst)
,.probe6 (capture_end)
);

`endif 

endmodule
