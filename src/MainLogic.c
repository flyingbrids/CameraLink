#include "main.h" 

XIicPs Iic;
u8 I2CBuffer[1] = {0x00}; // vorgao need to send 0x01 via I2C after camera link bus is ready
                          // and reset to 0x00 via I2C before camera link being switched 
u8 owl_init_status;
u8 hawk_init_status;

u8 *SensorActivate;
u8 *SensorSelect;

void APP_Init () {
     int status;  
     owl_init_status = 0x01;
     hawk_init_status = 0x01;  
     memset((u8*)TX_BUFFER_BASE, 0x00, XBAND_FILE_SIZE);
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
     status = iic_init (I2CBuffer, &Iic);
     if (status != XST_SUCCESS)
     {
         xil_printf("failed to initiate I2C \r\n");
     }  
 }

 int main () {
     APP_Init (); 
     FPGARegisterInit();
     make_crc_table();
     xil_printf("\r\n--- Entering main() --- \r\n");
     xil_printf("PL version is %d\r\n", ReadPLVersion());
     #ifdef UART_DEBUG 
        CmdHelp();
     #else 
        SensorActivate =  (u8 *)SENSOR_COMMAND_MEM;
        SensorSelect = (u8 *) SENSOR_SEL_MEM;
     #endif 
     while (1){
        char cmd;
        #ifdef UART_DEBUG 
            cmd = CmdRead();
        #else 
            if (CheckData(XBAND_FILE_SIZE,0x00,0) == XST_SUCCESS) {
               if (*SensorActivate > 0x00)
                  cmd = *SensorSelect;
               else 
                  cmd = 0x00;
            }
            else
               cmd = XBAND_STROBE;
        #endif   
        switch (cmd) {
        case HEO_CAMERA_SINGLE_FRAME_CAPTURE:{
            spips_read ();            
        }
        break; 
        case OWL_CAMERA_SINGLE_FRAME_CAPTURE: {
            #ifndef UART_DEBUG
              while (I2CBuffer[0] == 0x00);
              if (owl_init_status) {
                 owl_register_write(); // just init register once 
                 owl_init_status = 0x00;
                 usleep(1000);
              }               
            #endif 
            DisableTestMode(); 
            camera_link_receive (1);
        }
        break;     
        case HAWK_CAMERA_SINGLE_FRAME_CAPTURE:{
            #ifndef UART_DEBUG
              while (I2CBuffer[0] == 0x00);
              if (hawk_init_status) {
                 hawk_register_write(); // just init register once 
                 hawk_init_status = 0x00;
                 usleep(1000);
              }              
            #endif             
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
             #ifdef UART_DEBUG 
                    unsigned int tx_data; 
                    xil_printf("\r\n Please specify number of bytes (in decimal) to transfer\r\n");
                    if (DataRead(&tx_data) == XST_SUCCESS) {                	 
                        if (XbandTransmit(tx_data) == XST_SUCCESS)	 
                            xil_printf ("\n\r successfully transfer %d bytes to xband!\n\r", tx_data);
                        else 
                            xil_printf ("transfer failed!\n\r");      
                    }
                    else 
                        xil_printf ("data input invalid!\n\r");
             #else 
                    if (XbandTransmit(XBAND_FILE_SIZE) == XST_SUCCESS)	 
                        xil_printf ("\n\r successfully transfer %d bytes to xband!\n\r", XBAND_FILE_SIZE);
                    else 
                        xil_printf ("transfer failed!\n\r");                          
             #endif             
        }        
        default:
           usleep(1);
        } 
     }
     return 1;
} 
     
void Handler(void *CallBackRef, u32 Event)
{

	if (0 != (Event & XIICPS_EVENT_COMPLETE_RECV)) { // I2C receive interrupt
		XIicPs_SlaveRecv(&Iic, I2CBuffer, 1);  // restart I2C receive
	}
}
