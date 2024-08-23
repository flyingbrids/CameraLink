#include "main.h"

XUartNs550 UartCamera;

int PL_uart_int () {  
  int Status = XUartNs550_Initialize(&UartCamera, XPAR_XUARTNS550_0_BASEADDR);
  if (Status != XST_SUCCESS) {
		return XST_FAILURE;
  }
  XUartNs550_SetBaud(XPAR_XUARTNS550_0_BASEADDR, XPAR_XUARTNS550_0_CLOCK_FREQ, 115200);
  Status = XUartNs550_SelfTest(&UartCamera);
  if (Status != XST_SUCCESS) {
		return XST_FAILURE;
  }
  return Status;
}
u8 SendBuffer [7];
void owl_register_write() {
    // set frame rate to 10Hz = 0.1s = 10^8ns. FR=10^8/14.2857 = 7*10^6
    unsigned int FR = 7000000; 
    int Index;
    for (Index = 0x00; index < 4; Index ++ ){
        SendBuffer[0] = 0x53;
        SendBuffer[1] = 0x00;
        SendBuffer[2] = 0x03;
        SendBuffer[3] = 0x01;
        SendBuffer[4] = 0xDD + Index;
        SendBuffer[5] = (FR >> (8 * (3-Index))) & 0xff;  
        SendBuffer[6] = 0x50;
        XUartNs550_Send(&UartCamera, SendBuffer, 7);
    }  
    // add other setup when necessary. Consult datasheet 
}

void hawk_register_write() {
    // set frame rate to 15Hz = 0.066s = 66*10^6ns. FR=66*10^6/13.468
    unsigned int FR = 4900504; 
    int Index;
    for (Index = 0x00; index < 4; Index ++ ){
        SendBuffer[0] = 0x53;
        SendBuffer[1] = 0x00;
        SendBuffer[2] = 0x03;
        SendBuffer[3] = 0x01;
        SendBuffer[4] = 0xDD + Index;
        SendBuffer[5] = (FR >> (8 * (3-Index))) & 0xff;  
        SendBuffer[6] = 0x50;
        XUartNs550_Send(&UartCamera, SendBuffer, 7);
    }  
    // add other setup when necessary. Consult datasheet 
}