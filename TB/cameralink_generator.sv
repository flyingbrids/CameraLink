`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2024 01:54:42 PM
// Design Name: 
// Module Name: cameralink_generator
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
module cameralink_generator
#(
       parameter PIXEL_CLOCK_PERIOD = 1000ns/74.25
      ,parameter PIX_PER_TAP = 2
)
(
        output logic [2*4-1:0]  datain_p 
       ,output logic [2*4-1:0]  datain_n
       ,output logic [1:0] clk_p
       ,output logic [1:0] clk_n
       ,input  logic [15:0] imageWidth
       ,input  logic [15:0] imageHeight
       ,input  logic frame_end
       ,input  logic sys_rst       
);

bit bit_clk;
bit pixel_clk;
initial bit_clk = 1'b0;
always #(PIXEL_CLOCK_PERIOD/7/2) bit_clk = ~bit_clk;
initial pixel_clk = 1'b0;
always #(PIXEL_CLOCK_PERIOD/2) pixel_clk = ~pixel_clk;

 
logic Lval =0, Fval=0, Dval=0;

function int convert2Pixel (string pixel); // covert image.hex file into 12 bits pixel data
  int pixeldata;
  int pixelNibble;
  pixeldata = 0;
  for (int index =0; index < 4; index++) begin
    if (index == 2)
      continue;
    if ((pixel[index] >8'h29) & (pixel[index] < 8'h40)) begin // ASCII value to data
      pixelNibble = pixel[index] - 8'h30;
    end else
      pixelNibble = pixel[index] - 8'h37;
    case (index)
      0: pixeldata = pixeldata + (pixelNibble << 4);
      1: pixeldata = pixeldata +  pixelNibble;
      3: pixeldata = pixeldata + (pixelNibble << 8);	  
    endcase
  end
  return pixeldata;
endfunction

logic [11:0] imageData [PIX_PER_TAP-1:0];
logic [2:0]shiftCnt;  
int i,j,k,d,t;
    
task automatic load_image;  
  int img, file;
  string pixel;
  begin
    // file process
    while (~frame_end) begin
    file = $fopen("imgr.hex","r");
    img = $fopen($sformatf("Loadimgr_%0dppc.txt", PIX_PER_TAP),"w"); 
    for (i = 0; i < imageHeight; i++) begin
      Fval = 1;
      // 1 clk delay between each row
      Lval = 1'b0;
      Dval = 1'b0;
      wait (shiftCnt == 6);
      wait (shiftCnt == 0);
      for (j = 0; j < imageWidth/PIX_PER_TAP; j++) begin  
        Lval = 1;
        Dval = 1;
        for (k = 0; k < PIX_PER_TAP; k++) begin
          $fgets(pixel,file);
          imageData[k] = convert2Pixel(pixel);         
          $fwrite(img,"%d\n",imageData[k]);
        end
        wait (shiftCnt == 6);
        wait (shiftCnt == 0); 
      end
      //$display("<<TESTBENCH NOTE>> image row %d is captured!",i);
    end
    Lval = 1'b0;
    Dval = 1'b0;
    Fval = 1'b0;
    //$display("<<TESTBENCH NOTE>> raw image captured!");
    $fclose(img);
    $fclose(file);
    #500;    
  end
  end 
endtask
    
// Scramble cameralink data
logic [7:0] A;
logic [7:0] B;
logic [7:0] C;
logic [7:0] D;
logic [7:0] E;
logic [7:0] F;
logic [7:0] G;
logic [7:0] H;
logic [27:0] TX [2:0]; 
logic Lvalid, Fvalid, Dvalid; 
logic start;

assign A = imageData[0][7:0];
assign B = {imageData[1][11:8],imageData[0][11:8]}; 
assign C = imageData[1][7:0]; 
assign Lvalid =  Lval;
assign Dvalid =  Lval;
assign Fvalid =  Fval;
//assign TX[0] = {A[6],Dvalid,Fvalid,Lvalid,0,C[5:1],C[7:6],C[0],B[5:3],B[7:6],B[2:0],A[5],A[7],A[4:0]};    
assign D = imageData[2][7:0];
assign E = {imageData[3][11:8],imageData[2][11:8]}; 
assign F = imageData[3][7:0]; 
//assign TX[1] = {D[6],Dvalid,Fvalid,Lvalid,0,F[5:1],F[7:6],F[0],E[5:3],E[7:6],E[2:0],D[5],D[7],D[4:0]};    

logic [6:0] X [3:0]; 
logic [6:0] Y [3:0];
logic [6:0] Z [3:0];
logic [6:0] clk_out;
//assign   X[0] = TX[0][6:0];
//assign   X[1] = TX[0][13:7];
//assign   X[2] = TX[0][20:14];
//assign   X[3] = TX[0][27:21];
//assign   Y[0] = TX[1][6:0];
//assign   Y[1] = TX[1][13:7];
//assign   Y[2] = TX[1][20:14];
//assign   Y[3] = TX[1][27:21];

assign   X[0] = {A[0],A[1],A[2],A[3],A[4],A[5],B[0]};
assign   X[1] = {B[1],B[2],B[3],B[4],B[5],C[0],C[1]};
assign   X[2] = {C[2],C[3],C[4],C[5],Lvalid,Fvalid,Dvalid};
assign   X[3] = {A[6],A[7],B[6],B[7],C[6],C[7],0};
assign   Y[0] = {D[0],D[1],D[2],D[3],D[4],D[5],E[0]};
assign   Y[1] = {E[1],E[2],E[3],E[4],E[5],F[0],F[1]};
assign   Y[2] = {F[2],F[3],F[4],F[5],Lvalid,Fvalid,Dvalid};
assign   Y[3] = {D[6],D[7],E[6],E[7],F[6],F[7],0};


always @ (posedge bit_clk, posedge sys_rst) begin
    if (sys_rst) begin
       shiftCnt <= '0;
       clk_out <= {1'b1,1'b1,1'b0,1'b0,1'b0,1'b1,1'b1};
    end 
    else begin 
      clk_out <= {clk_out[0],clk_out[6:1]}; 
      shiftCnt <= shiftCnt == 6? '0 : shiftCnt + 1'b1;
    end  
end 

assign datain_p[0] = X[0][shiftCnt];
assign datain_p[1] = X[1][shiftCnt];
assign datain_p[2] = X[2][shiftCnt];
assign datain_p[3] = X[3][shiftCnt];
 
assign datain_n[0] = ~datain_p[0];
assign datain_n[1] = ~datain_p[1];
assign datain_n[2] = ~datain_p[2];
assign datain_n[3] = ~datain_p[3];

assign datain_p[4] = Y[0][shiftCnt];
assign datain_p[5] = Y[1][shiftCnt];
assign datain_p[6] = Y[2][shiftCnt];
assign datain_p[7] = Y[3][shiftCnt];
 
assign datain_n[4] = ~datain_p[4];
assign datain_n[5] = ~datain_p[5];
assign datain_n[6] = ~datain_p[6];
assign datain_n[7] = ~datain_p[7];

assign clk_p[0] = clk_out[0];
assign clk_p[1] = clk_out[0];
assign clk_n[0] = ~clk_p[0];
assign clk_n[1] = ~clk_p[1];
    
endmodule
