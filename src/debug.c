#include "main.h" 

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
    xil_printf("* %c  transfer Ethernet frame\r\n", ETHERNET_FRAME_TX);
    xil_printf("* %c  Update FPGA Fabric Configuration \r\n", UPDATE_FPGA);
    xil_printf("* %c  system reset \r\n", SYSTEM_RST);
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

int DataRead (unsigned int * tx_data) {
	setvbuf(stdin, NULL, _IONBF, 0);
	char data;
	*tx_data = 0;
	for (int i = 0; i < 10; i++) {
	    while (!Kbhit());
	    data = getchar();
	    if ((data>= 0x30) && (data <= 0x39)){
	       	*tx_data = *tx_data*10 + (data - 0x30);
	       	xil_printf("%c", data);
	    }
	    else if ((data == '\r') & (*tx_data >= 0)) {
	       	return XST_SUCCESS;
	    }
	    else {
	       	xil_printf("\n\rinvalid input 1!\n\r");
	       	return XST_FAILURE;
	    }
	 }
	return XST_SUCCESS;
}