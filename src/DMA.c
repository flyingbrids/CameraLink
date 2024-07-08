#include "DMA.h"
#include "FPGARegisterConfig.h"

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

int ImageReceive (int NumofBytes) 
{
   u8 *RxBufferPtr;
   RxBufferPtr = (u8 *)IMG_BUFFER_BASE;
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

    return Status;
}

int XbandLoopBackTest (int NumofBytes) {
    u8 *RxBufferPtr;
    u8 *TxBufferPtr;
    RxBufferPtr = (u8 *)XBAND_BUFFER_BASE;
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

		Status = CheckData(NumofBytes);
		if (Status != XST_SUCCESS) {
			return XST_FAILURE;
		}
	}
    return Status;
}

static int CheckData(int NumofBytes)
{
	u8 *RxPacket;
	int Index = 0;
	u8 Value;

	RxPacket = (u8 *) XBAND_BUFFER_BASE;
	Value = 0x0A;

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
		Value = (Value + 1) & 0xFF;
	}

	return XST_SUCCESS;
}