`timescale 1ns / 1ps
`define DEBUG
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2022 02:57:09 PM
// Design Name: 
// Module Name: S2MM_buffer
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
module S2MM_buffer(
	   input  logic sys_clk
	  ,input  logic sys_rst
	  ,input  logic new_frame
	  ,input  logic rx_clk
	  ,input  logic rx_rst
	  ,input  logic [7:0] rxdata
	  ,input  logic rxdataVld      
	  ,output logic FIFO_overflow
	  ,input  logic [31:0] expBytes
	  ,output logic [31:0] dataCnt
	  // AXIS interface
	  ,output logic [31:0] AxisData
      ,output logic [3:0]  AxisDataReady
      ,output logic AxisDataEnd
      ,input  logic AxisDataRead
      ,output logic AxisDataVld
    );
	

`ifdef DEBUG
ila_11 S2MMFIFO_IF (
   .clk (rx_clk),
   .probe0 (rxdata),
   .probe1 (rxdataVld)   
);   

ila_10 S2MM_IF (
   .clk (sys_clk),
   .probe0 (expBytes),
   .probe1 (FIFO_rd),
   .probe2 (new_frame),
   .probe3 (FIFO_vld),
   .probe4 (FIFO_out),
   .probe5 (dataCnt)  
);   
`endif 

logic  FIFO_full;  
always @ (posedge rx_clk, posedge new_frame) begin
     if (new_frame)
	    FIFO_overflow <= 1'b0;
	 else if (rxdataVld & FIFO_full)
        FIFO_overflow <= 1'b1;
end		

// initiate data read
logic [31:0] FIFO_out;
logic prog_full, FIFO_empty;
logic initRead, initRead_d, initRead_2d;
logic FIFO_reset, FIFO_rd;
assign FIFO_reset = sys_rst | new_frame;
assign FIFO_rd = ~FIFO_empty & ( AxisDataRead | (initRead & (~initRead_d))  | (initRead_d & (~initRead_2d)));
always @ (posedge sys_clk, posedge FIFO_reset) begin
      if (FIFO_reset) begin
         initRead <= 1'b0;
		 initRead_d <= 1'b0;
		 initRead_2d <= 1'b0;
      end else begin
         initRead <= prog_full & (~AxisDataVld) & (~AxisDataRead);	
         initRead_d <= initRead;
         initRead_2d <= initRead_d;
	  end
end

logic FIFO_vld, FIFO_rd_d;

always @ (posedge sys_clk) begin
   // FIFO_rd_d <= FIFO_rd;
    FIFO_vld  <= FIFO_rd;
end
	
    s2mm_fifo S2MM_fifo
    (
        .rst        (new_frame)
       ,.din        (rxdata)
       ,.wr_en      (rxdataVld)
       ,.dout       (FIFO_out)
	   ,.prog_full  (prog_full)
	   ,.full       (FIFO_full)
	   ,.empty      (FIFO_empty)
       ,.rd_en      (FIFO_rd)
       ,.rd_clk     (sys_clk)
       ,.wr_clk     (rx_clk)
    );		

logic AxisDataVld_next;
logic [31:0] AxisData_next;
logic [3:0]  AxisDataReady_next;
always @ (posedge sys_clk, posedge FIFO_reset) begin
      if (FIFO_reset) begin
         AxisData_next <= '0;
         AxisDataVld_next <= '0;
		 AxisDataReady_next <= '0;
		 dataCnt <= '0;
      end else if (FIFO_vld & ~countfinished) begin
         AxisData_next <= FIFO_out;
         AxisDataVld_next  <= 1'b1;	 
		 dataCnt <= dataCnt + 4;
		 AxisDataReady_next <= '1; // keep signal of AXIS 
	  end else begin        
         AxisDataVld_next  <= '0;	 
	  end
end

logic countfinished;
assign countfinished = (dataCnt >= expBytes)? 1'b1 : 1'b0;	

logic AxisDataEndSent;
logic AxisDataEnd_next;
always @ (posedge sys_clk, posedge FIFO_reset) begin
      if (FIFO_reset) begin
	     AxisDataEnd_next<= 1'b0;
		 AxisDataEndSent <= 1'b0;
	  end else if ((~AxisDataVld | AxisDataRead) & AxisDataEnd_next) begin
         AxisDataEnd_next <= 1'b0;	
         AxisDataEndSent <= 1'b1;		 
	  end else if (~AxisDataEndSent & (dataCnt == expBytes-4) & FIFO_vld )begin 	     
		 AxisDataEnd_next <= 1'b1;	
      	 AxisDataEndSent <= 1'b1;	 
	  end
end		 

always @ (posedge sys_clk) begin
      if (FIFO_reset) begin
	     AxisDataVld <= 1'b0;
	     AxisData <= '0;
	     AxisDataEnd <= 1'b0;
	     AxisDataReady <= '0;
	  end else if (~AxisDataVld | AxisDataRead) begin
	     AxisDataVld <= AxisDataVld_next;
	     AxisData <= AxisData_next;
	     AxisDataEnd <= AxisDataEnd_next;
	     AxisDataReady <= AxisDataReady_next;
	  end
end   	
	
endmodule
