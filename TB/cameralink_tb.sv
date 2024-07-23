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
  @(posedge sys_clk);
  @(posedge sys_clk);
  @(posedge sys_clk);
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

logic [2*4-1:0]  datain1_p; 
logic [2*4-1:0]  datain1_n;
logic [1:0]  clk1_p; 
logic [1:0]  clk1_n;

logic [2*4-1:0]  datain0_p; 
logic [2*4-1:0]  datain0_n;
logic [1:0]  clk0_p; 
logic [1:0]  clk0_n;

logic [15:0] imageWidth_hawk;
logic [15:0] imageHeight_hawk;
logic [15:0] imageWidth_owl;
logic [15:0] imageHeight_owl;

logic serde_locked;
logic frame_end = '0;

assign imageWidth_hawk = 1944;
assign imageHeight_hawk = 2;
assign imageWidth_owl = 1280;
assign imageHeight_owl = 2;

cameralink_generator
#(
       .PIXEL_CLOCK_PERIOD (1000ns/70.00)
      ,.PIX_PER_TAP (4)
)
owlCamera
(
        .datain_p   (datain1_p)
       ,.datain_n   (datain1_n)
       ,.clk_p      (clk1_p)
       ,.clk_n      (clk1_n)
       ,.imageWidth (imageWidth_owl)
       ,.imageHeight(imageHeight_owl)
       ,.frame_end  (frame_end)
       ,.sys_rst    (sys_rst)
);

cameralink_generator
#(
       .PIXEL_CLOCK_PERIOD (1000ns/74.25)
      ,.PIX_PER_TAP (2)
)
hawkCamera
(
        .datain_p   (datain0_p)
       ,.datain_n   (datain0_n)
       ,.clk_p      (clk0_p)
       ,.clk_n      (clk0_n)
       ,.imageWidth (imageWidth_hawk)
       ,.imageHeight(imageHeight_hawk)
       ,.frame_end  (frame_end)
       ,.sys_rst    (sys_rst)
);

logic [63:0]S_AXIS_S2MM_0_tdata;
logic [7:0]S_AXIS_S2MM_0_tkeep;
logic S_AXIS_S2MM_0_tlast;
logic S_AXIS_S2MM_0_tvalid;
logic S_AXIS_S2MM_0_tready;
always @ (posedge sys_clk, posedge sys_rst) begin
     if (sys_rst)
        S_AXIS_S2MM_0_tready <= '0;
     else if (camera_receiver.DMAWrite_inst.data_count[3])
        S_AXIS_S2MM_0_tready <= '1;
     else if (camera_receiver.DMAWrite_inst.empty & ~camera_receiver.DMAWrite_inst.data_end)
        S_AXIS_S2MM_0_tready <= '0;
end 

logic cameraSel,camera_in_progress;
assign cameraSel = frame_cnt[0]; 

camera camera_receiver(
       // camera link
       .xclk_n       (cameraSel? clk1_n[1] : clk0_n[0])
      ,.xclk_p       (cameraSel? clk1_p[1] : clk0_p[0])
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
      ,.testMode     (1)
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
      ,.S_AXIS_S2MM_0_tready(S_AXIS_S2MM_0_tready)
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
     owlCamera.load_image();
     hawkCamera.load_image();
     image_receive();
     DMA_data_write();
  join
  $stop();
end   
 
endmodule