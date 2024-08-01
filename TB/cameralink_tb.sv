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

localparam FRAME_CNT    = 4;   // # of test image 

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
  #10;
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

localparam integer imageWidth_hawk = 1944;
localparam integer imageHeight_hawk = 2;
localparam integer imageWidth_owl = 1280;
localparam integer imageHeight_owl = 2; 

logic [2*4-1:0]  datain1_p; 
logic [2*4-1:0]  datain1_n;
logic [1:0]  clk1_p; 
logic [1:0]  clk1_n;

logic [2*4-1:0]  datain0_p; 
logic [2*4-1:0]  datain0_n;
logic [1:0]  clk0_p; 
logic [1:0]  clk0_n;

logic serde_locked;
logic frame_end = '0;

cam_model 
#(
    .configs (1)
   ,.bit_period(1000ns/70.00/8)
   ,.frame_period(100us) // consult data sheet for frame rate setting. Set this value to save simulation time 
   ,.IMAGE_WIDTH(imageWidth_owl)
   ,.IMAGE_HEIGHT(imageHeight_owl)   
)
owlCamera 
(
    .reset  (~sys_rst)
   ,.xc_p   (clk1_p[0])
   ,.xc_n   (clk1_n[0])
   ,.yc_p   (clk1_p[1])
   ,.yc_n   (clk1_n[1])
   ,.zc_p   ()
   ,.zc_n   ()  
   ,.x0_p   (datain1_p[0])
   ,.x0_n   (datain1_n[0])
   ,.y0_p   (datain1_p[4])
   ,.y0_n   (datain1_n[4])
   ,.z0_p   ()
   ,.z0_n   ()  
   ,.x1_p   (datain1_p[1])
   ,.x1_n   (datain1_n[1])
   ,.y1_p   (datain1_p[5])
   ,.y1_n   (datain1_n[5])
   ,.z1_p   ()
   ,.z1_n   ()       
   ,.x2_p   (datain1_p[2])
   ,.x2_n   (datain1_n[2])
   ,.y2_p   (datain1_p[6])
   ,.y2_n   (datain1_n[6])
   ,.z2_p   ()
   ,.z2_n   ()  
   ,.x3_p   (datain1_p[3])
   ,.x3_n   (datain1_n[3])
   ,.y3_p   (datain1_p[7])
   ,.y3_n   (datain1_n[7])
   ,.z3_p   ()
   ,.z3_n   ()       
);

cam_model 
#(
    .configs (0)
   ,.bit_period(1000ns/74.25/8)
   ,.frame_period(100us) // consult data sheet for frame rate setting. Set this value to save simulation time
   ,.IMAGE_WIDTH(imageWidth_hawk)
   ,.IMAGE_HEIGHT(imageHeight_hawk)
)
hawkCamera
(
    .reset  (~sys_rst)
   ,.xc_p   (clk0_p[0])
   ,.xc_n   (clk0_n[0])
   ,.yc_p   ()
   ,.yc_n   ()
   ,.zc_p   ()
   ,.zc_n   ()  
   ,.x0_p   (datain0_p[0])
   ,.x0_n   (datain0_n[0])
   ,.y0_p   ()
   ,.y0_n   ()
   ,.z0_p   ()
   ,.z0_n   ()  
   ,.x1_p   (datain0_p[1])
   ,.x1_n   (datain0_n[1])
   ,.y1_p   ()
   ,.y1_n   ()
   ,.z1_p   ()
   ,.z1_n   ()       
   ,.x2_p   (datain0_p[2])
   ,.x2_n   (datain0_n[2])
   ,.y2_p   ()
   ,.y2_n   ()
   ,.z2_p   ()
   ,.z2_n   ()  
   ,.x3_p   (datain0_p[3])
   ,.x3_n   (datain0_n[3])
   ,.y3_p   ()
   ,.y3_n   ()
   ,.z3_p   ()
   ,.z3_n   ()       
);

logic [63:0]S_AXIS_S2MM_0_tdata;
logic [7:0]S_AXIS_S2MM_0_tkeep;
logic S_AXIS_S2MM_0_tlast;
logic S_AXIS_S2MM_0_tvalid;
logic S_AXIS_S2MM_0_tready;
always @ (posedge sys_clk, posedge sys_rst) begin
     if (sys_rst)
        S_AXIS_S2MM_0_tready <= '0;
     else if (camera_receiver.DMAWrite_inst.data_count[0])
        S_AXIS_S2MM_0_tready <= '1;
     else if (camera_receiver.DMAWrite_inst.empty & ~camera_receiver.DMAWrite_inst.data_end)
        S_AXIS_S2MM_0_tready <= '0;
end 

logic cameraSel,camera_in_progress;
assign cameraSel = frame_cnt[0]; 

camera camera_receiver(
       // camera link
       .xclk_n       (cameraSel? clk1_n[0] : clk0_n[0])
      ,.xclk_p       (cameraSel? clk1_p[0] : clk0_p[0])
      ,.yclk_n       (clk1_n[1])
      ,.yclk_p       (clk1_p[1])
      ,.x_p          (cameraSel? datain1_p[3:0] : datain0_p[3:0])
      ,.x_n          (cameraSel? datain1_n[3:0] : datain0_n[3:0])
      ,.y_p          (datain1_p[7:4])
      ,.y_n          (datain1_n[7:4])
      // system 
      ,.ref_clk      (ref_clk)
      ,.sys_clk      (sys_clk)
      ,.sys_rst      (sys_rst)
      ,.new_capture  (new_frame)
      ,.cameraSel    (cameraSel)
      ,.testMode     (0)
      ,.hawk_image_height (imageHeight_hawk)
      ,.hawk_image_width  (imageWidth_hawk)
      ,.owl_image_height  (imageHeight_owl)
      ,.owl_image_width   (imageWidth_owl)
      ,.serde_locked      (serde_locked)
      ,.camera_in_progress(camera_in_progress)
      ,.timeOut           ('1)
      // DMA
      ,.S_AXIS_S2MM_0_tdata (S_AXIS_S2MM_0_tdata)
      ,.S_AXIS_S2MM_0_tkeep (S_AXIS_S2MM_0_tkeep)
      ,.S_AXIS_S2MM_0_tlast (S_AXIS_S2MM_0_tlast)
      ,.S_AXIS_S2MM_0_tready(1)
      ,.S_AXIS_S2MM_0_tvalid(S_AXIS_S2MM_0_tvalid)               
);

task image_receive;
   while (frame_cnt < FRAME_CNT) begin   
         wait (serde_locked == 1'b1);     
         wait_for_new_frame ();
         wait (camera_in_progress == 1);
         wait (camera_in_progress == 0);
         frame_cnt = frame_cnt + 1;
   end 
   frame_end = 1'b1;
endtask

logic [191:0] DMAdata;
logic [1:0] buffer_full_cnt;

task DMA_data_write;
int file; 
   while (frame_cnt < FRAME_CNT) begin  
        file = $fopen($sformatf("DMAimgr%0d.txt",frame_cnt+1),"w"); 
        buffer_full_cnt = 0;
        wait (camera_in_progress == 1'b1);
        while (camera_in_progress) begin              
              wait (S_AXIS_S2MM_0_tready & S_AXIS_S2MM_0_tvalid == 1'b1);              
              DMAdata = {S_AXIS_S2MM_0_tdata,DMAdata[191:64]};
              buffer_full_cnt = buffer_full_cnt + 1;
              if (buffer_full_cnt == 3) begin
                 buffer_full_cnt = 0;
                 for (int i = 0 ; i < 16; i++ )
                  $fwrite(file,"%d\n",DMAdata[i*12 +: 12]);              
              end
              @(posedge sys_clk); 
              #1;               
        end
        $fclose(file); 
   end 
endtask

// main function
initial begin
  wait_for_reset(); 
  fork  
     image_receive();
     DMA_data_write();
  join
  $stop();
end   
 
endmodule
