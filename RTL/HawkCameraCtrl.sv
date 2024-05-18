`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 02:34:37 PM
// Design Name: 
// Module Name: HawkCameraCtrl
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
module HawkCameraCtrl(
        input  logic  clkin_p
       ,input  logic  clkin_n	
       ,input  logic [3:0] datain_p 
       ,input  logic [3:0] datain_n
       ,input  logic [15:0] imageWidth
       ,input  logic [15:0] imageHeight
       ,input  logic sys_clk
       ,input  logic ref_clk
       ,input  logic sys_rst
       ,input  logic capture // pulse
       ,input  logic testMode
       ,output logic serde_locked
       ,output logic [63:0]S_AXIS_S2MM_0_tdata
       ,output logic [7:0]S_AXIS_S2MM_0_tkeep
       ,output logic S_AXIS_S2MM_0_tlast
       ,input  logic S_AXIS_S2MM_0_tready
       ,output logic S_AXIS_S2MM_0_tvalid
    );

logic [23:0] pixel_cl;
logic pixel_vld_cl;
logic [23:0] pixel_test;
logic pixel_vld_test;
logic [23:0] pixel;
logic pixel_vld;
logic new_frame_cl, frame_valid_cl;
logic new_frame, frame_valid;

 logic test_mode_lat;  
 logic test_mode_start;
 logic test_mode_end;

assign new_frame   =   new_frame_cl | test_mode_start;
assign frame_valid = frame_valid_cl | test_mode_lat;
assign pixel     = test_mode_lat? pixel_test :  pixel_cl;
assign pixel_vld  = test_mode_lat? pixel_vld_test : pixel_vld_cl;

cameralink_base_phy Hawk_Serdes(
      .sys_rst	(sys_rst)				
     ,.sys_clk  (sys_clk)
     ,.ref_clk  (ref_clk)				
     ,.clkin_p  (clkin_p)     
     ,.clkin_n	(clkin_n)
     ,.datain_p (datain_p)
     ,.datain_n (datain_n)
     ,.pixel_data_o (pixel_cl)  		
     ,.pixel_vld    (pixel_vld_cl)   
     ,.new_frame    (new_frame_cl)  // pulse
     ,.frame_valid  (frame_valid_cl)
     ,.locked       (serde_locked)
);     

logic [15:0] lineCnt;
logic [15:0] colCnt;
logic [1:0] capture_state;
logic capture_vld;
logic imageEnd;
assign imageEnd = (colCnt == imageWidth - 2) & (lineCnt == imageHeight -1)? 1'b1 : 1'b0;

always @ (posedge sys_clk, posedge sys_rst) begin
      if (sys_rst) begin
         lineCnt <= '0;
         colCnt  <= '0;
         capture_vld <= '0;
      end else if (new_frame) begin
         lineCnt <= '0;
         colCnt  <= '0;    
         capture_vld <= capture_state[0];  
      end else if (pixel_vld & capture_vld) begin
         lineCnt <= (colCnt == imageWidth - 2)? lineCnt + 1'b1 : lineCnt;
         colCnt <=  (colCnt == imageWidth - 2)? '0 : colCnt + 2;    
         capture_vld <= ~imageEnd;    
      end 
end 

logic capture_vld_d, capture_end;
always @ (posedge sys_clk, posedge sys_rst) begin
      if (sys_rst) begin
         capture_vld_d <= '0;
         capture_end  <= '0;
      end else if (new_frame) begin
         capture_vld_d <= '0;
         capture_end  <= '0;
      end else begin
         capture_vld_d <= capture_vld;
         if (capture_vld_d & ~capture_vld)
            capture_end  <= 1'b1;      
      end 
end

always @ (posedge sys_clk, posedge sys_rst) begin
     if (sys_rst) begin
         capture_state <= '0;    
     end else if (capture_state == '0) begin
        if (capture & frame_valid)
            capture_state <= 'd2;
        else if  (capture & ~frame_valid)
            capture_state <= 'd1;
     end else if (capture_state[0] & new_frame) begin 
         capture_state <= '0;
     end else if ((capture_state == 'd2) & ~frame_valid) begin
         capture_state <= '1;
     end 
end 

// DMA transfer
DMAWrite DMAWrite_inst(
   .sys_clk            (sys_clk)
  ,.sys_rst            (sys_rst)
  ,.frame_rst          (new_frame)
  ,.data_in            (pixel)
  ,.data_vld           (pixel_vld)
  ,.data_end           (capture_end)
  ,.S_AXIS_S2MM_0_tdata(S_AXIS_S2MM_0_tdata)
  ,.S_AXIS_S2MM_0_tkeep(S_AXIS_S2MM_0_tkeep)
  ,.S_AXIS_S2MM_0_tlast(S_AXIS_S2MM_0_tlast)
  ,.S_AXIS_S2MM_0_tready(S_AXIS_S2MM_0_tready)
  ,.S_AXIS_S2MM_0_tvalid(S_AXIS_S2MM_0_tvalid)   
 );
 
 // test mode 
 assign test_mode_start = capture_state[0] & testMode & ~test_mode_lat & ~capture_vld; // pulse
 assign test_mode_end = test_mode_lat & capture_vld & imageEnd; // pulse
 
 always @ (posedge sys_clk, posedge sys_rst) begin
     if (sys_rst) begin
        test_mode_lat <= '0;
     end else if (test_mode_start) begin
        test_mode_lat <= '1;
     end else if (test_mode_end)
        test_mode_lat <= '0;
 end 

logic [15:0] lineCnt_test;
logic [15:0] colCnt_test;
logic [7:0]  lineBreakCnt;

assign pixel_test[12:0] = lineCnt_test[12:0] + colCnt_test[12:0];
assign pixel_test[23:13]= lineCnt_test[12:0] + colCnt_test[12:0] + 1'b1;

always @ (posedge sys_clk, posedge sys_rst) begin
     if (sys_rst) begin
        pixel_vld_test <= '0;  
        lineCnt_test <= '0;
        colCnt_test <= '0;   
        lineBreakCnt <= '0;    
     end else if (test_mode_lat) begin
        if (pixel_vld_test) begin
           lineCnt_test <= (colCnt_test == imageWidth - 2)? lineCnt_test + 1'b1 : lineCnt_test;
           colCnt_test <=  (colCnt_test == imageWidth - 2)? '0 : colCnt_test + 2;
           lineBreakCnt <= '0;
        end 
        if (((colCnt_test == imageWidth - 2) & pixel_vld_test)| ~pixel_vld_test) begin
           pixel_vld_test <= &lineBreakCnt;
           lineBreakCnt <= lineBreakCnt + 1'b1;
        end 
     end else begin
        pixel_vld_test <= '0;  
        lineCnt_test <= '0;
        colCnt_test <= '0;   
        lineBreakCnt <= '0; 
     end 
end          
    
endmodule
