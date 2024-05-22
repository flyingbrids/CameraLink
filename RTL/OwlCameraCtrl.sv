`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2024 11:34:04 AM
// Design Name: 
// Module Name: OwlCameraCtrl
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
module OwlCameraCtrl(
        input  logic  clkin1_p
       ,input  logic  clkin1_n	
       ,input  logic [3:0] datain1_p 
       ,input  logic [3:0] datain1_n
       ,input  logic  clkin2_p
       ,input  logic  clkin2_n	
       ,input  logic [3:0] datain2_p 
       ,input  logic [3:0] datain2_n       
       ,input  logic [15:0] imageWidth
       ,input  logic [15:0] imageHeight
       ,input  logic sys_clk
       ,input  logic delay_ready
       ,input  logic sys_rst
       ,input  logic capture // pulse
       ,input  logic testMode
       ,output logic serde_locked
       ,output logic new_frame
       ,output logic [47:0] pixel
       ,output logic data_vld
       ,output logic capture_end
       ,input  logic camera_in_progress
       ,input  logic cameraSel
);

logic [47:0] pixel_cl;
logic pixel_vld_cl;
logic [47:0] pixel_test;
logic pixel_vld_test;
logic pixel_vld;

logic new_frame_cl, frame_valid_cl;
logic frame_valid;

logic test_mode_lat;  
logic test_mode_start;
logic test_mode_end;

assign new_frame   = new_frame_cl | test_mode_start;
assign frame_valid = frame_valid_cl | test_mode_lat;
assign pixel       = test_mode_lat? pixel_test :  pixel_cl;
assign pixel_vld   = test_mode_lat? pixel_vld_test : pixel_vld_cl;
    
 cameralink_medium_phy owl_camera_link(
 .sys_rst      (sys_rst),					
 .sys_clk      (sys_clk),	
 .delay_ready  (delay_ready),			
 .clkin1_p     (clkin1_p),  
 .clkin1_n     (clkin1_n),	
 .datain1_p    (datain1_p), 
 .datain1_n    (datain1_n),
 .clkin2_p     (clkin2_p),   
 .clkin2_n     (clkin2_n),	
 .datain2_p    (datain2_p), 
 .datain2_n    (datain2_n),
 .pixel_data_o (pixel_cl),   // 4 pixel with 12 bit each px		
 .pixel_vld    (pixel_vld_cl),
 .new_frame    (new_frame_cl),
 .frame_valid  (frame_valid_cl),
 .locked       (serde_locked),
 .camera_in_progress (camera_in_progress),
 .cameraSel    (cameraSel),
 .lineWidth    (imageWidth)
 );    

logic [15:0] lineCnt;
logic [15:0] colCnt;
logic [1:0] capture_state;
logic capture_vld;
logic imageEnd;
assign imageEnd = (colCnt == imageWidth - 4) & (lineCnt == imageHeight -1)? 1'b1 : 1'b0;
assign data_vld = pixel_vld & capture_vld;

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
         lineCnt <= (colCnt == imageWidth - 4)? lineCnt + 1'b1 : lineCnt;
         colCnt <=  (colCnt == imageWidth - 4)? '0 : colCnt + 4;    
         capture_vld <= ~imageEnd;    
      end 
end 

logic capture_vld_d;
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

assign pixel_test[23:0] = lineCnt_test + colCnt_test;
assign pixel_test[47:24]= lineCnt_test + colCnt_test + 1'b1;

always @ (posedge sys_clk, posedge sys_rst) begin
     if (sys_rst) begin
        pixel_vld_test <= '0;  
        lineCnt_test <= '0;
        colCnt_test <= '0;   
        lineBreakCnt <= '0;    
     end else if (test_mode_lat) begin
        if (pixel_vld_test) begin
           lineCnt_test <= (colCnt_test == imageWidth - 4)? lineCnt_test + 1'b1 : lineCnt_test;
           colCnt_test <=  (colCnt_test == imageWidth - 4)? '0 : colCnt_test + 4;
           lineBreakCnt <= '0;
        end 
        if (((colCnt_test == imageWidth - 4) & pixel_vld_test)| ~pixel_vld_test) begin
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
