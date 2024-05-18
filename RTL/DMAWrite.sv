`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 03:40:15 PM
// Design Name: 
// Module Name: DMAWrite
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
module DMAWrite(
   input logic sys_clk
  ,input logic sys_rst
  ,input logic frame_rst
  ,input logic [23:0] data_in
  ,input logic data_vld
  ,input logic data_end
  ,output logic [63:0]S_AXIS_S2MM_0_tdata
  ,output logic [7:0]S_AXIS_S2MM_0_tkeep = '1
  ,output logic S_AXIS_S2MM_0_tlast
  ,input  logic S_AXIS_S2MM_0_tready
  ,output logic S_AXIS_S2MM_0_tvalid
);

logic reset;
assign reset = sys_rst | frame_rst;

// Package 24 bit to 192 bit buffer
logic [167:0] DMA_fifo_buf;
logic DMA_fifo_wr;
logic shift_full;
logic [2:0] shift_cnt;
logic purge;
logic [31:0] inputBitCnt;   
logic [25:0] totalDataCnt; // cnt per DMA data width
logic [23:0] data;

assign data = purge? '0 : data_in;

always @ (posedge sys_clk, posedge reset) begin
     if (reset) begin
        shift_cnt <= '0;
        inputBitCnt <= '0;        
     end else if (data_vld | purge) begin
        shift_cnt    <=   (&shift_cnt)?  '0 : shift_cnt + 1'b1;
        DMA_fifo_buf <=   {data, DMA_fifo_buf[167:24]};
        inputBitCnt <=   purge? inputBitCnt : inputBitCnt + 24;
     end 
end 

always @ (posedge sys_clk, posedge reset) begin
     if (reset) begin
         shift_full <= '0;
     end else begin
         shift_full  <=   (&shift_cnt);
     end 
end 

assign DMA_fifo_wr = (&shift_cnt) & ~shift_full; 

always @ (posedge sys_clk, posedge reset) begin
     if (reset) begin
         purge <= '0;
         totalDataCnt <= '1;
     end else if (data_end) begin 
         totalDataCnt <= (|inputBitCnt[5:0]) ? inputBitCnt[31:6]+ 1'b1 : inputBitCnt[31:6];
         if (&shift_cnt) 
            purge <= '0;
         else if (|shift_cnt)
            purge <= '1;        
     end 
end     

logic [191:0] DMA_fifo_data;
logic [63:0] DMA_data_next [2:0];
logic [63:0] DMA_data [2:0];
logic empty, rd_en;
logic empty_d;
logic non_vld;
logic [9:0] data_count;

DMA_fifo DMA_fifo_inst (
   .clk (sys_clk)
  ,.srst (reset)
  ,.din ({data, DMA_fifo_buf})
  ,.wr_en(DMA_fifo_wr)
  ,.dout (DMA_fifo_data)
  ,.rd_en(rd_en)
  ,.data_count(data_count)
  ,.empty(empty)
);

// distribute 192 bit to 64 bit DMA data bus 
assign DMA_data_next[0] = DMA_fifo_data[63:0];
assign DMA_data_next[1] = DMA_fifo_data[127:64];
assign DMA_data_next[2] = DMA_fifo_data[191:128];

logic handshake;
logic [1:0]handshakeCnt;
logic init_update, init_update_lat;
logic DMAdataUpdate, fifoUpdate;

assign handshake = S_AXIS_S2MM_0_tvalid & S_AXIS_S2MM_0_tready; 

always @ (posedge sys_clk, posedge reset) begin
      if (reset) begin 
         handshakeCnt <= '0; 
      end else if (handshake) begin
         handshakeCnt <= (handshakeCnt == 2'd2)? '0 : handshakeCnt + 1'b1;
      end 
end

always @ (posedge sys_clk, posedge reset) begin
      if (reset) begin
          init_update <= '0;
          init_update_lat <= '0;
          empty_d <= '1;  
      end else begin
          init_update <= ~empty & empty_d & ~init_update_lat;  
          empty_d <= empty;             
          if (init_update)
             init_update_lat <= '1;     
      end 
end

assign DMAdataUpdate = init_update |(handshake & (handshakeCnt == 2'd2)); 
assign fifoUpdate = (handshake & (handshakeCnt == 2'd1)); 
assign rd_en = fifoUpdate & ~empty;

always @ (posedge sys_clk) begin       
     S_AXIS_S2MM_0_tdata <= DMAdataUpdate? DMA_data_next[0] : DMA_data[handshakeCnt + handshake];      
     for (int i = 0; i<=2; i++)
          DMA_data[i] <= DMAdataUpdate? DMA_data_next[i] : DMA_data[i];   
end 

assign non_vld = handshake & (handshakeCnt == 2'd2) & empty;

logic [25:0] dataXferedCnt;
logic S_AXIS_S2MM_0_tlast_lat;
always @ (posedge sys_clk, posedge reset) begin
      if (reset) begin 
         S_AXIS_S2MM_0_tvalid <= '0;
         S_AXIS_S2MM_0_tlast <= '0;
         S_AXIS_S2MM_0_tlast_lat <= '0;
         dataXferedCnt <= '0;
      end else begin 
         if (~S_AXIS_S2MM_0_tlast_lat) begin
             if (non_vld)
               S_AXIS_S2MM_0_tvalid <= 1'b0; 
            else if (~empty_d)             
               S_AXIS_S2MM_0_tvalid <= 1'b1; 
         end else if (handshake)
               S_AXIS_S2MM_0_tvalid <= 1'b0;
                     
         if (handshake) begin
            dataXferedCnt <= dataXferedCnt + 1'b1;
            S_AXIS_S2MM_0_tlast <= (dataXferedCnt ==  totalDataCnt - 2)? 1'b1: 1'b0;
            if (dataXferedCnt == totalDataCnt-2)
               S_AXIS_S2MM_0_tlast_lat <= 1'b1;
         end
      end 
end 

endmodule
