#include "xuartns.h"

XUartNs550 UartCamera;

int PL_uart_int () {  
  int Status = XUartNs550_Initialize(&UartCamera, XPAR_XUARTNS550_0_BASEADDR);
  if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
  Status = XUartNs550_SelfTest(&UartCamera);
  if (Status != XST_SUCCESS) {
		return XST_FAILURE;
  }
  return Status;
}