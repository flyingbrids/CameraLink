#include "xaxidma.h"
#include "xparameters.h"
#include "sleep.h"

#define CAMERA_LINK_DMA   (XPAR_XAXIDMA_0_BASEADDR)
#define XBAND_DMA         (XPAR_XAXIDMA_1_BASEADDR)
#define MEM_BASE_ADDR	  0x01000000
#define RX_BUFFER_BASE	  (MEM_BASE_ADDR + 0x01000000)
#define POLL_TIMEOUT_COUNTER    1000000U

int InitImageDMA ();
int InitXbandDMA ();
int ImageReceive (int NumofBytes);