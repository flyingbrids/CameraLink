`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2024 11:58:15 AM
// Design Name: 
// Module Name: SerdesWrap
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
module SerdesWrap # (
parameter integer 	N = 8 ,				// Set the number of channels
parameter integer 	D = 6 ,   			// Parameter to set the number of data lines per channel
parameter integer   MMCM_MODE = 1 ,   	// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
parameter real 	  	CLKIN_PERIOD = 6.000 ,	// clock period (ns) of input clock on clkin_p
parameter 		    HIGH_PERFORMANCE_MODE = "FALSE",// Parameter to set HIGH_PERFORMANCE_MODE of input delays to reduce jitter
parameter         	DIFF_TERM = "FALSE" , 		// Parameter to enable internal differential termination
parameter         	SAMPL_CLOCK = "BUFIO" ,   	// Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
parameter         	PIXEL_CLOCK = "BUF_R" ,     // Parameter to set pixel clock buffer type, BUF_R, BUF_H, BUF_G
parameter         	USE_PLL = "FALSE" ,         // Parameter to enable PLL use rather than MMCM use, overides SAMPL_CLOCK and INTER_CLOCK to be both BUFH
parameter         	DATA_FORMAT = "PER_CLOCK"  // Parameter Used to determine method for mapping input parallel word to output serial words
)
(                                     	
 input 	[N-1:0]		clkin_p  			// Input from LVDS clock receiver pin
,input 	[N-1:0]		clkin_n  			// Input from LVDS clock receiver pin
,input 	[N*D-1:0]	datain_p 			// Input from LVDS clock data pins
,input 	[N*D-1:0]	datain_n 			// Input from LVDS clock data pins
,input 			    enable_phase_detector	// Enables the phase detector logic when high
,input			    enable_monitor 		// Enables the monitor logic when high, note time-shared with phase detector function
,input 			    reset 				// Reset line
,input			    idelay_rdy			// input delays are ready
,output 			rxclk 				// Global/BUFIO rx clock network
,output 			rxclk_div 			// Global/Regional clock output
,output 			rx_mmcm_lckd 		// MMCM locked, synchronous
,output 			rx_mmcm_lckdps 		// MMCM locked and phase shifting finished
,output  [N-1:0]	rx_mmcm_lckdpsbs	// MMCM locked and phase shifting finished and bitslipping finished
,output  [N*7-1:0]	clk_data  		// Clock Data
,output  [N*D*7-1:0]rx_data	 		// Received Data
,output  [(10*D+6)*N-1:0]debug		// debug info
,output  [6:0]		status   		// clock status
,input 	 [15:0]		bit_rate_value 	// Bit rate in Mbps, for example 16'h0585
,output	 [4:0]		bit_time_value  // Calculated bit time value for slave devices
,output	 [32*D*N-1:0]	eye_info	// Eye info
,output	 [32*D*N-1:0]	m_delay_1hot // Master delay control value as a one-hot vector
);

serdes_1_to_7_mmcm_idelay_sdr #(
	.SAMPL_CLOCK		(SAMPL_CLOCK),
	.PIXEL_CLOCK		(PIXEL_CLOCK),
	.USE_PLL		    (USE_PLL),
	.HIGH_PERFORMANCE_MODE	(HIGH_PERFORMANCE_MODE),
    .D			        (D),	
    .CLKIN_PERIOD		(CLKIN_PERIOD),			
    .MMCM_MODE		    (MMCM_MODE),			
	.DIFF_TERM		    (DIFF_TERM),
	.DATA_FORMAT		(DATA_FORMAT))
rx0 (
	.clkin_p   		    (clkin_p[0]),
	.clkin_n   		    (clkin_n[0]),
	.datain_p     		(datain_p[D-1:0]),
	.datain_n     		(datain_n[D-1:0]),
	.enable_phase_detector	(enable_phase_detector),
	.enable_monitor		    (enable_monitor),
	.rxclk    		        (rxclk),
	.idelay_rdy		        (idelay_rdy),
	.rxclk_div		        (rxclk_div),
	.reset     		        (reset),
	.rx_mmcm_lckd		    (rx_mmcm_lckd),
	.rx_mmcm_lckdps		    (rx_mmcm_lckdps),
	.rx_mmcm_lckdpsbs	    (rx_mmcm_lckdpsbs[0]),
	.clk_data  		        (clk_data[6:0]),
	.rx_data		        (rx_data[7*D-1:0]),
	.bit_rate_value		    (bit_rate_value),
	.bit_time_value		    (bit_time_value),
	.status			        (status),
	.eye_info		        (eye_info[32*D-1:0]),
	.rst_iserdes		    (rst_iserdes),
	.m_delay_1hot		    (m_delay_1hot[32*D-1:0]),
	.debug			        (debug[10*D+5:0]));

genvar i ;
genvar j ;

generate
if (N > 1) begin
for (i = 1 ; i <= (N-1) ; i = i+1)
begin : loop0

serdes_1_to_7_slave_idelay_sdr #(
    .D			            (D),				// Number of data lines
	.HIGH_PERFORMANCE_MODE	(HIGH_PERFORMANCE_MODE),
	.DIFF_TERM		        (DIFF_TERM),
	.DATA_FORMAT		    (DATA_FORMAT))
rxn (
	.clkin_p   		(clkin_p[i]),
	.clkin_n   		(clkin_n[i]),
	.datain_p     	(datain_p[D*(i+1)-1:D*i]),
	.datain_n     	(datain_n[D*(i+1)-1:D*i]),
	.enable_phase_detector	(enable_phase_detector),
	.enable_monitor		    (enable_monitor),
	.rxclk    		        (rxclk),
	.idelay_rdy		        (idelay_rdy),
	.rxclk_div		        (rxclk_div),
	.reset     		        (~rx_mmcm_lckdps),
	.bitslip_finished	    (rx_mmcm_lckdpsbs[i]),
	.clk_data  		        (clk_data[7*i+6:7*i]),
	.rx_data		        (rx_data[(D*(i+1)*7)-1:D*i*7]),
	.bit_time_value		    (bit_time_value),
	.eye_info		        (eye_info[32*D*(i+1)-1:32*D*i]),
	.m_delay_1hot		    (m_delay_1hot[(32*D)*(i+1)-1:(32*D)*i]),
	.rst_iserdes		    (rst_iserdes),
	.debug			        (debug[(10*D+6)*(i+1)-1:(10*D+6)*i]));

end
end
endgenerate
endmodule
