#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"
#include "xdebug.h"
#include "sleep.h"
#include "FPGARegisterConfig.h"
#include "DMA.h"
#include "xuartps_hw.h"
#include "xuartps.h"
#include "main.h"

u32 current_camera_val;

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
         xil_printf("failed to initiate UART to Cameralink \r\n");
     }  
     status = Uart_HEO_init();
     if (status != XST_SUCCESS)
     {
         xil_printf("failed to initiate UART to HEO Camera \r\n");
     }       
     status = spips_int ();
     if (status != XST_SUCCESS)
     {
         xil_printf("failed to initiate SPI to HEO Camera \r\n");
     }       
     return status;
 }

void CmdHelp()
{
    // Print menu information
    xil_printf("\r\n");
    xil_printf("* *****MENU***** *\r\n");
    xil_printf("* ************** *\r\n");
    xil_printf("* %c  capture 1 frame image from owl camera \r\n", OWL_CAMERA_SINGLE_FRAME_CAPTURE);
    xil_printf("* %c  capture 1 frame image from hawk camera \r\n",  HAWK_CAMERA_SINGLE_FRAME_CAPTURE);
    xil_printf("* %c  transfer 1 frame test data form owl camera \r\n", OWL_CAMERA_TEST_CAPTURE );
    xil_printf("* %c  transfer 1 frame test data form hawk camera \r\n", HAWK_CAMERA_TEST_CAPTURE);
    xil_printf("* %c  transfer 1 frame data to Xband \r\n", XBAND_STROBE);
}

unsigned char Kbhit()
{
    return (unsigned char)(XUartPs_IsReceiveData(XPAR_XUARTPS_1_BASEADDR));
}


char CmdRead()
{
    static char cmd[1] = {0};
    setvbuf(stdin, NULL, _IONBF, 0);

    // Get character from stdin
    if (Kbhit()) {
        cmd[0] = getchar();
        xil_printf(" %c", cmd[0]);
    }
    else  {
        cmd[0] = 0;
    }

    return cmd[0];
}
unsigned int tx_data;

int DataRead () {
	setvbuf(stdin, NULL, _IONBF, 0);
	char data;
	tx_data = 0;
	for (int i = 0; i < 10; i++) {
	    while (!Kbhit());
	    data = getchar();
	    if ((data>= 0x30) && (data <= 0x39)){
	       	tx_data = tx_data*10 + (data - 0x30);
	       	xil_printf("%c", data);
	    }
	    else if ((data == '\r') & (tx_data >= 0)) {
	       	return XST_SUCCESS;
	    }
	    else {
	       	xil_printf("\n\rinvalid input 1!\n\r");
	       	return XST_FAILURE;
	    }
	 }
	return XST_SUCCESS;
}

void camera_link_receive (u32 camera_val) {
     u32 imageSize = GetHawkImageSize();
     int totalImageBytes;     
     int imagePixels;
     int status;
     current_camera_val = IsOwlSelected(); 
     u8 sensor_1[20] = "Owl Camera";
     u8 sensor_0[20] = "Hawk Camera";
     u8 sensor[20];
     if (camera_val)
         memcpy (sensor, sensor_1,20);
     else 
         memcpy (sensor, sensor_0,20);

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
        status = ImageReceive(totalImageBytes,sensor);
        if (status == XST_SUCCESS)
            xil_printf("successfully transfered 1 frame of image, total bytes %d\r\n", ReadImageDMABytesXfered()); 
        else 
            xil_printf("transfer failed! \r\n");           
    }  
    else 
        xil_printf("camera is not ready! \r\n");
}

 int main () {
     APP_Init (); 
     FPGARegisterInit();
     make_crc_table();
     xil_printf("\r\n--- Entering main() --- \r\n");
     xil_printf("PL version is %d\r\n", ReadPLVersion());
     CmdHelp();
     while (1){
        char cmd = CmdRead();
        switch (cmd) {
        case HEO_CAMERA_SINGLE_FRAME_CAPTURE:{
            spips_read ();            
        }
        break; 
        case OWL_CAMERA_SINGLE_FRAME_CAPTURE: {
            DisableTestMode(); 
            camera_link_receive (1);
        }
        break;     
        case HAWK_CAMERA_SINGLE_FRAME_CAPTURE:{
            DisableTestMode(); 
            camera_link_receive (0);
        }
        break; 
        case OWL_CAMERA_TEST_CAPTURE: {
            EnableTestMode(); 
            camera_link_receive (1);
        }
        break;     
        case HAWK_CAMERA_TEST_CAPTURE:{
            EnableTestMode(); 
            camera_link_receive (0);
        }
        break; 
        case XBAND_STROBE: {
             xil_printf("\r\n Please specify number of bytes (in decimal) to transfer\r\n");
             if (DataRead() == XST_SUCCESS) {                	 
                if (XbandTransmit(tx_data) == XST_SUCCESS)	 
                    xil_printf ("\n\r successfully transfer %d bytes to xband!\n\r", tx_data);
                else 
                    xil_printf ("transfer failed!\n\r");      
             }
             else 
                xil_printf ("data input invalid!\n\r");
             
        }        
        default:
           usleep(1);
        } 
        usleep(150);
     }
     return 1;
} 
     
  