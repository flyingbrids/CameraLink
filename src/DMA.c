#include "main.h"
#include "xaxidma.h"

XAxiDma ImageDMA;
XAxiDma XbandDMA;

int InitImageDMA () 
{
   XAxiDma_Config *CfgPtr;
   int Status;
   CfgPtr = XAxiDma_LookupConfig(CAMERA_LINK_DMA);
 	if (!CfgPtr) {
		xil_printf("No config found for ImageDMA \r\n");
		return XST_FAILURE;
	} 
	Status = XAxiDma_CfgInitialize(&ImageDMA, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization ImageDMA failed %d\r\n", Status);
		return XST_FAILURE;
	}
 	/* Disable interrupts, we use polling mode
	 */
	XAxiDma_IntrDisable(&ImageDMA, XAXIDMA_IRQ_ALL_MASK,
			    XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&ImageDMA, XAXIDMA_IRQ_ALL_MASK,
			    XAXIDMA_DMA_TO_DEVICE);   
    return Status; 
}

int InitXbandDMA () 
{
   XAxiDma_Config *CfgPtr;
   int Status;
   CfgPtr = XAxiDma_LookupConfig(XBAND_DMA);
 	if (!CfgPtr) {
		xil_printf("No config found for XBAND_DMA \r\n");
		return XST_FAILURE;
	} 
	Status = XAxiDma_CfgInitialize(&XbandDMA, CfgPtr);
	if (Status != XST_SUCCESS) {
		xil_printf("Initialization XbandDMA failed %d\r\n", Status);
		return XST_FAILURE;
	}
 	/* Disable interrupts, we use polling mode
	 */
	XAxiDma_IntrDisable(&XbandDMA, XAXIDMA_IRQ_ALL_MASK,
			    XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(&XbandDMA, XAXIDMA_IRQ_ALL_MASK,
			    XAXIDMA_DMA_TO_DEVICE);   
    return Status; 
}

int ImageReceive (int NumofBytes, u8* Array) 
{
   u8 *RxBufferPtr;
   u8 *RxBufferHeaderPtr;
   RxBufferPtr = (u8 *)PAYLOAD_BUFFER;
   RxBufferHeaderPtr = (u8 *) PAYLOAD_BUFFER_HEADER;
   int TimeOut = POLL_TIMEOUT_COUNTER;
   /* Flush the buffers before the DMA transfer, in case the Data Cache
	 * is enabled
	*/
	Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, NumofBytes);
    //Xil_DCacheInvalidate();
    usleep(100); 
    int Status = XAxiDma_SimpleTransfer(&ImageDMA, (UINTPTR) RxBufferPtr, NumofBytes, XAXIDMA_DEVICE_TO_DMA);
    if (Status != XST_SUCCESS) {
		xil_printf("Can't start ImageDMA transfer : %d\r\n", Status);
        return XST_FAILURE;
	}
    NewFrameCapture();
    while (TimeOut) {
		if (!XAxiDma_Busy(&ImageDMA, XAXIDMA_DEVICE_TO_DMA))			    
			break;
		TimeOut--;
		usleep(1U);
	}
    if ((TimeOut == 0) && XAxiDma_Busy(&ImageDMA, XAXIDMA_DEVICE_TO_DMA)){
       xil_printf("Can't finish ImageDMA transfer!\r\n");
       XAxiDma_Reset(&ImageDMA);
       return XST_FAILURE;
    }       
    // Modify header data to notify the top-level sw that memory is ready to grab
    RxBufferHeaderPtr[0] = 0xFF;
    memcpy(RxBufferHeaderPtr+1,Array,20);
    RxBufferHeaderPtr[21] = NumofBytes & 0xff;
    RxBufferHeaderPtr[22] = (NumofBytes >> 8) & 0xff;
    RxBufferHeaderPtr[23] = (NumofBytes >> 16)  & 0xff;
    RxBufferHeaderPtr[24] = (NumofBytes >> 24)  & 0xff; 

    // wait for the handshake .... 
    #ifndef UART_DEBUG 
        while (RxBufferHeaderPtr[0] == 0xFF);
    #endif 
    return Status;
}

int XbandTransmit (int NumofBytes)  {
    NewXbandFrame ();
    u8 *TxBufferPtr;
    TxBufferPtr = (u8 *)TX_BUFFER_BASE;
    //usleep(100);
	int Status = XAxiDma_SimpleTransfer(&XbandDMA, (UINTPTR) TxBufferPtr,
						NumofBytes, XAXIDMA_DMA_TO_DEVICE);
    int TimeOut = POLL_TIMEOUT_COUNTER;
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
 	while (TimeOut) {
		if (!(XAxiDma_Busy(&XbandDMA, XAXIDMA_DEVICE_TO_DMA)) &&
			!(XAxiDma_Busy(&XbandDMA, XAXIDMA_DMA_TO_DEVICE))) {
			break;
		}
		TimeOut--;
		usleep(1U);
	}   
    memset(TxBufferPtr, 0x00, NumofBytes); // zero out the buffer for handshake
    return Status;
}

int XbandLoopBackTest (int NumofBytes) {
    u8 *RxBufferPtr;
    u8 *TxBufferPtr;
    RxBufferPtr = (u8 *)PAYLOAD_BUFFER;
    TxBufferPtr = (u8 *)TX_BUFFER_BASE;
    int TimeOut = POLL_TIMEOUT_COUNTER;
    u8 Value = 0x0A;
    int Index;
    for (Index = 0; Index < NumofBytes; Index ++) {
		TxBufferPtr[Index] = Value;
		Value = (Value + 1) & 0xFF;
	}
 /* Flush the buffers before the DMA transfer, in case the Data Cache
	 * is enabled
	 */
	Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, NumofBytes);
	Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, NumofBytes);

    int Status;
    SetXbandRemoteLoopback();
    
    for (Index = 0; Index < 10; Index ++) {

        SetXbandRecBytes (NumofBytes);
        NewXbandFrame ();

		Status = XAxiDma_SimpleTransfer(&XbandDMA, (UINTPTR) RxBufferPtr,
						NumofBytes, XAXIDMA_DEVICE_TO_DMA);

		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}
        
		Status = XAxiDma_SimpleTransfer(&XbandDMA, (UINTPTR) TxBufferPtr,
						NumofBytes, XAXIDMA_DMA_TO_DEVICE);

		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}
        
        

		/*Wait till tranfer is done or 1usec * 10^6 iterations of timeout occurs*/
		while (TimeOut) {
			if (!(XAxiDma_Busy(&XbandDMA, XAXIDMA_DEVICE_TO_DMA)) &&
			    !(XAxiDma_Busy(&XbandDMA, XAXIDMA_DMA_TO_DEVICE))) {
				break;
			}
			TimeOut--;
			usleep(1U);
		}

		Status = CheckData(NumofBytes, Value, 1);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}
	}
    FPGA_WriteReg(0,0x00000000); // set normal mode
    return Status;
}

int CheckData(int NumofBytes, u8 Value, u8 loopback)
{
	u8 *RxPacket;
	int Index = 0;
    if (loopback)
	    RxPacket = (u8 *) PAYLOAD_BUFFER;
    else  
	    RxPacket = (u8 *) TX_BUFFER_BASE;

	/* Invalidate the DestBuffer before receiving the data, in case the
	 * Data Cache is enabled
	 */
	Xil_DCacheInvalidateRange((UINTPTR)RxPacket, NumofBytes);

	for (Index = 0; Index < NumofBytes; Index++) {
		if (RxPacket[Index] != Value) {
			xil_printf("Data error %d: %x/%x\r\n",
				   Index, (unsigned int)RxPacket[Index],
				   (unsigned int)Value);

			return XST_FAILURE;
		}
        if (loopback)
		    Value = (Value + 1) & 0xFF;
	}

	return XST_SUCCESS;
}