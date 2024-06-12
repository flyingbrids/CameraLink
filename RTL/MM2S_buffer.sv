`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2022 12:15:08 PM
// Design Name: 
// Module Name: MM2S_buffer
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
//`define DEBUG

module MM2S_buffer(
       input  logic [31:0]  M_AXIS_MM2S_0_tdata
      ,input  logic [3:0]   M_AXIS_MM2S_0_tkeep
      ,output logic M_AXIS_MM2S_0_tready
      ,input  logic M_AXIS_MM2S_0_tvalid
	  ,input  logic sys_clk
	  ,input  logic sys_rst
	  ,input  logic new_frame
	  ,input  logic tx_clk
	  ,input  logic tx_rst
	  ,output logic tx_empty
	  ,output logic FIFO_overflow
	  ,output logic [7:0] txdata
	  ,output logic txctrl
    );
	
logic prog_full;
logic rd_en, read, fifoVld;
assign rd_en = ~tx_empty;
assign M_AXIS_MM2S_0_tready = ~prog_full;
	
logic [7:0] dout;
logic   kout;
logic FIFO_reset;
assign FIFO_reset = sys_rst | new_frame;
	
logic FIFO_full;
always @ (posedge sys_clk, posedge FIFO_reset) begin
    if (FIFO_reset)
       FIFO_overflow <= 1'b0;
	else if (M_AXIS_MM2S_0_tvalid & M_AXIS_MM2S_0_tready & FIFO_full)
       FIFO_overflow <= 1'b1;
end		
	
    tdata_fifo xband_tx_fifo_1
    (
        .rst        (new_frame)
       ,.prog_full  (prog_full)
	   ,.full       (FIFO_full)
       ,.din        (M_AXIS_MM2S_0_tdata)
       ,.wr_en      (M_AXIS_MM2S_0_tvalid & M_AXIS_MM2S_0_tready)
       ,.empty      (tx_empty)
       ,.dout       (dout)
       ,.rd_en      (rd_en)
       ,.wr_clk     (sys_clk)
       ,.rd_clk     (tx_clk)
    );	

    tkeep_fifo xband_tx_fifo_2
    (
        .rst        (new_frame)
       ,.din        (M_AXIS_MM2S_0_tkeep)
       ,.wr_en      (M_AXIS_MM2S_0_tvalid & M_AXIS_MM2S_0_tready)
       ,.dout       (kout)
       ,.rd_en      (rd_en)
       ,.wr_clk     (sys_clk)
       ,.rd_clk     (tx_clk)
    );	
	
always @ (posedge tx_clk) begin
      fifoVld    <= rd_en;
      //fifoVld <= read;
end 	

always @ (posedge tx_clk, posedge tx_rst) begin
     if (tx_rst) begin
        txdata   <= 8'hBC; 
        txctrl   <= '1;
     end else if (fifoVld) begin
        txdata   <= dout; 
        txctrl   <= ~kout;
     end else begin
        txdata   <= 8'hBC;  
        txctrl   <= '1;     
     end 
end 
	
`ifdef DEBUG
ila_12 MM2S_IF (
   .clk (tx_clk),
   .probe0 (txdata),
   .probe1 (txctrl),
   .probe2 (new_frame),
   .probe3 (fifoVld),
   .probe4 (FIFO_full),
   .probe5 (M_AXIS_MM2S_0_tvalid)
);   	
`endif	
	
endmodule
