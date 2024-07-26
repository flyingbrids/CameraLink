#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"
#include "xdebug.h"
#include "sleep.h"
#include "FPGARegisterConfig.h"
#include "xiicps.h"
#include "xscugic.h"
#include "xil_exception.h"
#include "xuartps_hw.h"
#include "xuartps.h"
#include "xuartns550.h"

#define UART_DEBUG

#define HEO_CAMERA_SINGLE_FRAME_CAPTURE ('0')
#define OWL_CAMERA_SINGLE_FRAME_CAPTURE ('1')
#define HAWK_CAMERA_SINGLE_FRAME_CAPTURE ('2')
#define OWL_CAMERA_TEST_CAPTURE ('3')
#define HAWK_CAMERA_TEST_CAPTURE ('4')
#define XBAND_STROBE ('5')

#define XBAND_FILE_SIZE           0x400000
#define CAMERA_LINK_DMA           (XPAR_XAXIDMA_0_BASEADDR)
#define XBAND_DMA                 (XPAR_XAXIDMA_1_BASEADDR)

#define HEADER_SIZE               25
#define MEM_BASE_ADDR	          0x0100000 // DDR3 memory base address
#define SENSOR_COMMAND_MEM        (MEM_BASE_ADDR + 0x01000000 - HEADER_SIZE - 1) // Activate/deactivate command
#define SENSOR_SEL_MEM            (SENSOR_COMMAND_MEM - 4) 
#define PAYLOAD_BUFFER_HEADER	  (MEM_BASE_ADDR + 0x01000000 - HEADER_SIZE) 
#define PAYLOAD_BUFFER	          (PAYLOAD_BUFFER_HEADER + HEADER_SIZE) 
#define TX_BUFFER_BASE	          (MEM_BASE_ADDR + 0x01500000) //Transmit buffer via Xband
#define POLL_TIMEOUT_COUNTER      1000000U

int InitImageDMA ();
int InitXbandDMA ();
int ImageReceive (int NumofBytes, u8* Array);
int CheckData(int NumofBytes, u8 Value, u8 loopback);
int XbandLoopBackTest (int NumofBytes);
int XbandTransmit (int NumofBytes);
void make_crc_table();
int Uart_HEO_init ();
void Uart_HEO_trigger ();
int spips_int ();
void spips_read ();
void Handler(void *CallBackRef, u32 Event);
int iic_init (u8 * RecvBuffer, XIicPs * Iic);
void CmdHelp();
char CmdRead();
int DataRead (unsigned int * tx_data);
void camera_link_receive (u32 camera_val);
void owl_register_write();
void hawk_register_write();
int PL_uart_int ();