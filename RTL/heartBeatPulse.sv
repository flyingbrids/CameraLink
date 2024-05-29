`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Leon Shen
// 
// Create Date: 04/15/2022 04:03:41 PM
// Design Name: 
// Module Name: heartBeatPulse
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: clock divider to generate 1 sec pulse 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module heartBeatPulse 
#(
   parameter FREQ = 100000000
)
( 
   input logic clk,
   input logic rst,
   output logic tick   
);
    
logic  [31:0] clockCnt;
   
always @(posedge clk, posedge rst) begin
    if (rst) begin
       tick <= 1'b0;
       clockCnt <= 32'd0;
    end else if (clockCnt == FREQ/2) begin
        tick <= ~tick;
        clockCnt <= 0;
    end else begin
        tick <= tick;
        clockCnt <= clockCnt + 1;     
    end 
end        
    
    
endmodule