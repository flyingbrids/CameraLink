#include "xparameters.h"
#include "xil_printf.h"
#include "xdebug.h"
#include "sleep.h"
#include "FPGARegisterConfig.h"
#include "DMA.h"
#include "xuartns.h"

#define OWLCAMERA 1U
#define HAWKCAMERA 0U

u32 trigger_val;
u32 trigger_val_prev;
u32 camera_val;
u32 selected_camera;

 int APP_Init () {
     int status;     
     status = InitImageDMA();
     if (status != XST_SUCCESS)
     {
         xil_printf("failed to initiate ImageDMA \r\n");
     }
     status = InitXbandDMA();
     if (status != XST_SUCCESS)
     {
         xil_printf("failed to initiate XbandDMA \r\n");
     }        
     status = PL_uart_int();
     if (status != XST_SUCCESS)
     {
         xil_printf("failed to initiate UART to Camera \r\n");
     }  
     return status;
 }

 int main () {
     APP_Init (); 
     FPGARegisterInit();
     selected_camera = OWLCAMERA;
     int totalImageBytes;
     u32 imageSize;
     int imagePixels;
     int status;
     u32 switch_val;
     xil_printf("\r\n--- Entering main() --- \r\n");
     xil_printf("PL version is %d\r\n", ReadPLVersion());
     trigger_val_prev = 0;
     while (1){
     switch_val = ReadSwitchValue();        
     camera_val = switch_val & 0x02;
     // trigger by switch for now. eventually will need to use i2c input
     trigger_val = switch_val & 0x1;
     if (trigger_val_prev != trigger_val ){
        if ((trigger_val_prev == 0) && (trigger_val != 0))
        {
            // trigger routine 
            if (selected_camera != OWLCAMERA) {
                SelectOwl();                
                selected_camera = OWLCAMERA;
            }   
            imageSize = GetOwlImageSize();            
            imagePixels = (imageSize >> 16) *(imageSize & 0xffff);
            totalImageBytes = (imagePixels * 3) >> 1; // each pixel is (12bits) 1.5 bytes  
            if(IsTestMode() | ReadCameraLinkStatus()){ 
              status = ImageReceive(totalImageBytes);
              if (status == XST_SUCCESS)
                 xil_printf("successfully transfered 1 frame of image, total bytes %d\r\n", ReadImageDMABytesXfered());            
            }             
        }
       trigger_val_prev = trigger_val;
       usleep(150);
     }
     // switch & LED test
      u32 led_val = switch_val;  
      FPGA_WriteReg (4,led_val);
     } 
     return 1;
 }   