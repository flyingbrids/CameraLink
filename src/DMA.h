#include "xaxidma.h"
#include "xparameters.h"
#include "sleep.h"

#define CAMERA_LINK_DMA           (XPAR_XAXIDMA_0_BASEADDR)
#define XBAND_DMA                 (XPAR_XAXIDMA_1_BASEADDR)
#define HEADER_SIZE               25
#define MEM_BASE_ADDR	          0x0100000 // DDR3 memory base address
#define SENSOR_COMMAND_MEM        (MEM_BASE_ADDR + 0x01000000 - HEADER_SIZE - 1) // Activate/deactivate command
#define SENSOR_SEL_MEM            (SENSOR_COMMAND_MEM - 4) 
#define PAYLOAD_BUFFER_HEADER	  (MEM_BASE_ADDR + 0x01000000 - HEADER_SIZE) 
#define PAYLOAD_BUFFER	          (PAYLOAD_BUFFER_HEADER + HEADER_SIZE) 
#define TX_BUFFER_BASE	          (MEM_BASE_ADDR + 0x01500000) //Transmit buffer via Xband
#define POLL_TIMEOUT_COUNTER     1000000U

int InitImageDMA ();
int InitXbandDMA ();
int ImageReceive (int NumofBytes, u8* Array);
static int CheckData(int NumofBytes, u8 Value, u8 loopback);
int XbandLoopBackTest (int NumofBytes);
int XbandTransmit (int NumofBytes);