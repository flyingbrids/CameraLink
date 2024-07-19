`timescale 1ns / 1ps
//`define DEBUG
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
       input  logic xclk_p
      ,input  logic xclk_n
      ,input  logic [3:0] x_p
      ,input  logic [3:0] x_n
      ,input  logic yclk_p
      ,input  logic yclk_n
      ,input  logic [3:0] y_p
      ,input  logic [3:0] y_n
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
      ,input  logic [31:0] timeOut
      // DMA
      ,output logic [63:0]S_AXIS_S2MM_0_tdata
      ,output logic [7:0]S_AXIS_S2MM_0_tkeep
      ,output logic S_AXIS_S2MM_0_tlast
      ,input  logic S_AXIS_S2MM_0_tready
      ,output logic S_AXIS_S2MM_0_tvalid  
      ,output logic [31:0] dataXferedCnt             
);

logic [1:0] cameraState;
logic capture_end, cameraSelRegister, frame_rst;

assign camera_in_progress = (cameraState == '0)? 1'b0 : 1'b1;

logic [31:0] timeOutCnt;
always @ (posedge sys_clk) begin
      if (~camera_in_progress) begin
         cameraSelRegister <= cameraSel;    
         timeOutCnt <= '0;  
      end else begin
         timeOutCnt <= timeOutCnt + 1'b1;
      end 
end 

logic [2:0] reset_cnt;
logic camera_rst;
always @ (posedge sys_clk ,posedge sys_rst) begin
    if (sys_rst) begin 
       reset_cnt <= '0;
    end else if ((~camera_in_progress & (cameraSel != cameraSelRegister)) | (|reset_cnt)) begin
       reset_cnt <= reset_cnt + 1'b1;
    end  
end 
assign camera_rst = (reset_cnt > 0)? 1'b1 : 1'b0;     

assign capture_end  = cameraSelRegister? owl_capture_end : hawk_capture_end;
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
          2'b10:  if (S_AXIS_S2MM_0_tlast | (timeOutCnt == timeOut)) cameraState <= 2'b00;
          default: cameraState <= 2'b00;  
          endcase 
       end
end 

logic new_capture_d, capture;
always @ (posedge sys_clk, posedge sys_rst) begin
       if (sys_rst) begin
          new_capture_d <= '0;
          capture <= '0;
       end else begin
          new_capture_d <= new_capture;
          capture <= ~new_capture_d & new_capture;
       end 
end 


logic delay_ready;

IDELAYCTRL icontrol (              			
	.REFCLK			(ref_clk),
	.RST			(sys_rst),
	.RDY			(delay_ready)
);	

logic new_frame_cl,frame_valid_cl,pixel_vld_cl;
logic [47:0] pixel_cl;

 cameralink_medium_phy camera_link(
 .sys_rst      (sys_rst | camera_rst),					
 .sys_clk      (sys_clk),	
 .delay_ready  (delay_ready),			
 .clkin1_p     (xclk_p),  
 .clkin1_n     (xclk_n),	
 .datain1_p    (x_p), 
 .datain1_n    (x_n),
 .clkin2_p     (yclk_p),   
 .clkin2_n     (yclk_n),	
 .datain2_p    (y_p), 
 .datain2_n    (y_n),
 .pixel_data_o (pixel_cl),   // 4 pixel with 12 bit each px		
 .pixel_vld    (pixel_vld_cl),
 .new_frame    (new_frame_cl),
 .frame_valid  (frame_valid_cl),
 .locked       (serde_locked),
 .camera_in_progress (camera_in_progress),
 .cameraSel    (cameraSelRegister),
 .lineWidth    (cameraSelRegister? owl_image_width : hawk_image_width)
 ); 

HawkCameraCtrl HawkCamera
 (
        .frame_valid_cl      (frame_valid_cl & ~cameraSelRegister)
       ,.new_frame_cl        (new_frame_cl   & ~cameraSelRegister)
       ,.pixel_vld_cl        (pixel_vld_cl   & ~cameraSelRegister)
       ,.pixel_cl            (pixel_cl[23:0]) 
       ,.imageWidth          (hawk_image_width)
       ,.imageHeight         (hawk_image_height)
       ,.sys_clk             (sys_clk)
       ,.sys_rst             (sys_rst)
       ,.capture             (capture)
       ,.testMode            (testMode)
       ,.new_frame           (hawk_new_frame)
       ,.pixel               (hawk_pixel)
       ,.data_vld            (hawk_pixel_vld)
       ,.capture_end         (hawk_capture_end)
 );

 OwlCameraCtrl OwlCamera
 (
        .frame_valid_cl       (frame_valid_cl & cameraSelRegister)
       ,.new_frame_cl         (new_frame_cl   & cameraSelRegister)
       ,.pixel_vld_cl         (pixel_vld_cl   & cameraSelRegister)
       ,.pixel_cl             (pixel_cl)       
       ,.imageWidth           (owl_image_width)
       ,.imageHeight          (owl_image_height)
       ,.sys_clk              (sys_clk)
       ,.sys_rst              (sys_rst)
       ,.capture              (capture)
       ,.testMode             (testMode)
       ,.new_frame            (owl_new_frame)
       ,.pixel                (owl_pixel)
       ,.data_vld             (owl_pixel_vld)
       ,.capture_end          (owl_capture_end)

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
