#include "xparameters.h"	/* SDK generated parameters */
#include "xspips.h"		/* SPI device driver */
#include "xil_printf.h"
#include "DMA.h"
#include "main.h"

static XSpiPs SpiInstance;
#define MAX_DATA		(4194816+28)

#define SpiPs_RecvByte(BaseAddress) \
	(u8)XSpiPs_In32((BaseAddress) + XSPIPS_RXD_OFFSET)

int spips_int () {
   	int Status;
	XSpiPs_Config *SpiConfig;
    SpiConfig = XSpiPs_LookupConfig(XPAR_XSPIPS_0_BASEADDR);
    if (NULL == SpiConfig) {
		return XST_FAILURE;
	}
    Status = XSpiPs_CfgInitialize((&SpiInstance), SpiConfig,
				      SpiConfig->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	Status = XSpiPs_SetOptions((&SpiInstance), (XSPIPS_CR_CPOL_MASK));
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	XSpiPs_SetRXWatermark((&SpiInstance), MAX_DATA);
	XSpiPs_Enable((&SpiInstance));   
    return XST_SUCCESS;
}

void spips_read () {
    Uart_HEO_trigger();
	int Count;
    u8 *RxBufferPtr;
    u8 *RxBufferHeaderPtr;
    RxBufferPtr = (u8 *)PAYLOAD_BUFFER;
    RxBufferHeaderPtr = (u8 *) PAYLOAD_BUFFER_HEADER;    
	u32 StatusReg;
    int TimeOut = POLL_TIMEOUT_COUNTER;

	StatusReg = XSpiPs_ReadReg(SpiInstance.Config.BaseAddress,
				   XSPIPS_SR_OFFSET);

	/*
	 * Polling the Rx Buffer for Data
	 */
	do {
		StatusReg = XSpiPs_ReadReg(SpiInstance.Config.BaseAddress,
					   XSPIPS_SR_OFFSET);
        TimeOut--;
	} while ((!(StatusReg & XSPIPS_IXR_RXNEMPTY_MASK)) & (TimeOut > 0));

	/*
	 * Reading the Rx Buffer
	 */
	for (Count = 0; Count < MAX_DATA; Count++) {
		RxBufferPtr[Count] = SpiPs_RecvByte(
					    SpiInstance.Config.BaseAddress);
	}
    // Modify the header to notify the top-level software 
    u8 Array[20] = "HEO CAMERA";
    u32 NumofBytes = MAX_DATA;
    RxBufferHeaderPtr[0] = 0xFF;
    memcpy(RxBufferHeaderPtr+1,Array,20);
    RxBufferHeaderPtr[21] = NumofBytes & 0xff;
    RxBufferHeaderPtr[22] = (NumofBytes >> 8) & 0xff;
    RxBufferHeaderPtr[23] = (NumofBytes >> 16)  & 0xff;
    RxBufferHeaderPtr[24] = (NumofBytes >> 24)  & 0xff; 
    if (TimeOut) 
       xil_printf ("HEO image received!\r\n");
    else 
       xil_printf ("HEO image timeout\r\n");
    
    // wait for the handshake 
    
}

