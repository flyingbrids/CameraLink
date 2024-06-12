#include "xparameters.h"
#include "xil_printf.h"
#include "xdebug.h"
#include "sleep.h"
#include "FPGARegisterConfig.h"
#include "DMA.h"
#include "xuartns.h"

u32 camera_val;
u32 trigger_val;

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
     status = XbandLoopBackTest(1024);   
      if (status != XST_SUCCESS)
     {
         xil_printf("failed loopback test for XbandDMA \r\n");
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
     u32 trigger_val_prev;
     u32 current_camera_val;
     int totalImageBytes;
     u32 imageSize;
     int imagePixels;
     int status;
     u32 switch_val;
     xil_printf("\r\n--- Entering main() --- \r\n");
     xil_printf("PL version is %d\r\n", ReadPLVersion());
     trigger_val_prev = (ReadSwitchValue()) & 0x1;
     while (1){
     current_camera_val = IsOwlSelected();  
     switch_val = ReadSwitchValue();   // load camera_val and trigger_val by reading switch on ZED for now. Will use I2C eventually. 
     camera_val = switch_val & 0x02;    
     trigger_val = switch_val & 0x1;
     if (trigger_val_prev != trigger_val ){
        if ((trigger_val_prev == 0) && (trigger_val != 0))
        {
            // trigger routine 
            if ((current_camera_val == 0) & (camera_val != 0)) {
                SelectOwl();     
                imageSize = GetOwlImageSize(); 
                usleep(15000); // delay to allow cameralink switching and re-calibration
            }  
            else if ((current_camera_val == 0) & (camera_val == 0)) {
                imageSize = GetHawkImageSize();  
            }  
            else if ((current_camera_val != 0) & (camera_val != 0)) {
                imageSize = GetOwlImageSize();  
            } 
            else if ((current_camera_val != 0) & (camera_val == 0)) {
                SelectHawk ();
                imageSize = GetHawkImageSize();
                usleep(15000); 
            }                  
            imagePixels = (imageSize >> 16) *(imageSize & 0xffff);
            totalImageBytes = (imagePixels * 3) >> 1; // each pixel is (12bits) 1.5 bytes  
            if((IsTestMode() !=0) || (ReadCameraLinkStatus() !=0)){ 
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