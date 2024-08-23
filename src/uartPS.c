#include "main.h" 

#define	XUARTPS_BASEADDRESS		XPAR_XUARTPS_0_BASEADDR

XUartPs Uart_Ps;		/* The instance of the UART Driver */

int Uart_HEO_init () {
    XUartPs_Config *Config;
    Config = XUartPs_LookupConfig(XUARTPS_BASEADDRESS);
	if (NULL == Config) {
		return XST_FAILURE;
	}
 	int Status = XUartPs_CfgInitialize(&Uart_Ps, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}   
    XUartPs_SetBaudRate(&Uart_Ps, 1500000);
    return XST_SUCCESS; 
}

void Uart_HEO_trigger () {
    u8 HEO_image_request[14];
    HEO_image_request[0] = 0xCA;
    HEO_image_request[1] = 0xFE;
    HEO_image_request[2] = 0xBE;
    HEO_image_request[3] = 0xEF;
    HEO_image_request[4] = 0x58; // SPI image mode
    HEO_image_request[5] = 0x00;
    HEO_image_request[6] = 0x01;
    // dummy bytes 
    HEO_image_request[7] = 0xAA;
    HEO_image_request[8] = 0xAA;
    HEO_image_request[9] = 0xAA;
    HEO_image_request[10] = 0xAA;
    HEO_image_request[11] = 0xAA;
    HEO_image_request[12] = 0xAA;
    // end bytes 
    HEO_image_request[13] = 0x0A;
    int SentCount = 0;
	while (SentCount < 14) {
		/* Transmit the data */
		SentCount += XUartPs_Send(&Uart_Ps,
					   &HEO_image_request[SentCount], 1);
	}
    usleep(1000);
}