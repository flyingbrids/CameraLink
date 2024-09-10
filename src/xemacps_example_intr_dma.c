/***************************** Include Files ********************************/
#include "xemacps_example.h"
#include "xil_exception.h"
#include <xil_io.h>
#include <xil_printf.h>

#ifndef __MICROBLAZE__
#include "xil_mmu.h"
#endif

#if defined (__aarch64__) && (EL1_NONSECURE == 1)
#include "xil_smc.h"
#endif
/*************************** Constant Definitions ***************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifdef __MICROBLAZE__
#define XPS_SYS_CTRL_BASEADDR	XPAR_PS7_SLCR_0_S_AXI_BASEADDR
#endif

#ifdef SDT
#define EMACPS_BASEADDR         XPAR_XEMACPS_0_BASEADDR
#elif XPAR_INTC_0_DEVICE_ID
#define INTC		XIntc
#define EMACPS_DEVICE_ID	XPAR_XEMACPS_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_INTC_0_DEVICE_ID
#else
#define INTC		XScuGic
#define EMACPS_DEVICE_ID	XPAR_XEMACPS_0_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID
#endif

#define ZYNQ_EMACPS_0_BASEADDR 0xE000B000
#define ZYNQ_EMACPS_1_BASEADDR 0xE000C000

#define ZYNQMP_EMACPS_0_BASEADDR 0xFF0B0000
#define ZYNQMP_EMACPS_1_BASEADDR 0xFF0C0000
#define ZYNQMP_EMACPS_2_BASEADDR 0xFF0D0000
#define ZYNQMP_EMACPS_3_BASEADDR 0xFF0E0000

#define VERSAL_EMACPS_0_BASEADDR 0xFF0C0000
#define VERSAL_EMACPS_1_BASEADDR 0xFF0D0000

#define VERSAL_NET_EMACPS_0_BASEADDR	0xF19E0000
#define VERSAL_NET_EMACPS_1_BASEADDR	0xF19F0000

#define RXBD_CNT       32	/* Number of RxBDs to use */
#define TXBD_CNT       32	/* Number of TxBDs to use */

/*
 * SLCR setting
 */
#define SLCR_LOCK_ADDR			    (XPS_SYS_CTRL_BASEADDR + 0x4)
#define SLCR_UNLOCK_ADDR		    (XPS_SYS_CTRL_BASEADDR + 0x8)
#define SLCR_GEM0_CLK_CTRL_ADDR		(XPS_SYS_CTRL_BASEADDR + 0x140)
#define SLCR_GEM1_CLK_CTRL_ADDR		(XPS_SYS_CTRL_BASEADDR + 0x144)


#define SLCR_LOCK_KEY_VALUE		    0x767B
#define SLCR_UNLOCK_KEY_VALUE		0xDF0D
#define SLCR_ADDR_GEM_RST_CTRL		(XPS_SYS_CTRL_BASEADDR + 0x214)

/* CRL APB registers for GEM clock control */
#ifdef XPAR_PSU_CRL_APB_S_AXI_BASEADDR
#define CRL_GEM0_REF_CTRL	(XPAR_PSU_CRL_APB_S_AXI_BASEADDR + 0x50)
#define CRL_GEM1_REF_CTRL	(XPAR_PSU_CRL_APB_S_AXI_BASEADDR + 0x54)
#define CRL_GEM2_REF_CTRL	(XPAR_PSU_CRL_APB_S_AXI_BASEADDR + 0x58)
#define CRL_GEM3_REF_CTRL	(XPAR_PSU_CRL_APB_S_AXI_BASEADDR + 0x5C)
#endif

#define CRL_GEM_DIV_MASK	0x003F3F00
#define CRL_GEM_DIV0_SHIFT	8
#define CRL_GEM_DIV1_SHIFT	16

#ifdef XPAR_PSV_CRL_0_S_AXI_BASEADDR
#define CRL_GEM0_REF_CTRL	(XPAR_PSV_CRL_0_S_AXI_BASEADDR + 0x118)
#define CRL_GEM1_REF_CTRL	(XPAR_PSV_CRL_0_S_AXI_BASEADDR + 0x11C)
#endif

#ifdef XPAR_PSX_CRL_0_S_AXI_BASEADDR
#define CRL_GEM0_REF_CTRL  ( XPAR_PSX_CRL_0_S_AXI_BASEADDR + 0x118)
#define CRL_GEM1_REF_CTRL  ( XPAR_PSX_CRL_0_S_AXI_BASEADDR + 0x11C)
#endif

#define CRL_GEM_DIV_VERSAL_MASK		0x0003FF00
#define CRL_GEM_DIV_VERSAL_SHIFT	8

#define JUMBO_FRAME_SIZE	10240
#define FRAME_HDR_SIZE		18

#define GEMVERSION_ZYNQMP	0x7
#define GEMVERSION_VERSAL	0x107

#define CHECKSUM_OFFLOAD_MASK 0x00000800

/*************************** Variable Definitions ***************************/

#ifdef __ICCARM__
#pragma data_alignment = 64
EthernetFrame TxFrame;		/* Transmit buffer */
#pragma data_alignment = 64
EthernetFrame RxFrame;		/* Receive buffer */
#else
EthernetFrame TxFrame;		/* Transmit buffer */
EthernetFrame RxFrame;		/* Receive buffer */
#endif

/*
 * Buffer descriptors are allocated in uncached memory. The memory is made
 * uncached by setting the attributes appropriately in the MMU table.
 */
#define RXBD_SPACE_BYTES XEmacPs_BdRingMemCalc(XEMACPS_BD_ALIGNMENT, RXBD_CNT)
#define TXBD_SPACE_BYTES XEmacPs_BdRingMemCalc(XEMACPS_BD_ALIGNMENT, TXBD_CNT)


/*
 * Buffer descriptors are allocated in uncached memory. The memory is made
 * uncached by setting the attributes appropriately in the MMU table.
 * The minimum region for which attribute settings take effect is 2MB for
 * arm 64 variants(A53) and 1MB for the rest (R5 and A9). Hence the same
 * is allocated, even if not used fully by this example, to make sure none
 * of the adjacent global memory is affected.
 */
#ifdef __ICCARM__
#if defined __aarch64__
#pragma data_alignment = 0x200000
u8 bd_space[0x200000];
#else
#pragma data_alignment = 0x100000
u8 bd_space[0x100000];
#endif
#else
#if defined __aarch64__
u8 bd_space[0x200000] __attribute__ ((aligned (0x200000)));
#else
u8 bd_space[0x100000] __attribute__ ((aligned (0x100000)));
#endif
#endif

u8 *RxBdSpacePtr;
u8 *TxBdSpacePtr;

#define FIRST_FRAGMENT_SIZE 64

/*
 * Counters to be incremented by callbacks
 */
volatile s32 FramesRx;		/* Frames have been received */
volatile s32 FramesTx;		/* Frames have been sent */
volatile s32 DeviceErrors;	/* Number of errors detected in the device */

u32 TxFrameLength;

#ifndef SDT
#ifndef TESTAPP_GEN
static INTC IntcInstance;
#endif
#endif

#ifdef __ICCARM__
#pragma data_alignment = 64
XEmacPs_Bd BdTxTerminate;
#pragma data_alignment = 64
XEmacPs_Bd BdRxTerminate;
#else
XEmacPs_Bd BdTxTerminate __attribute__ ((aligned(64)));

XEmacPs_Bd BdRxTerminate __attribute__ ((aligned(64)));
#endif

u32 GemVersion;

/*************************** Function Prototypes ****************************/

/*
 * Example
 */
#ifdef SDT
LONG EmacPsDmaIntrExample(XEmacPs *EmacPsInstancePtr, UINTPTR BaseAddress);
#else
LONG EmacPsDmaIntrExample(INTC *IntcInstancePtr,
			  XEmacPs *EmacPsInstancePtr,
			  u16 EmacPsDeviceId);
#endif
LONG EmacPsDmaSingleFrameIntrExample(XEmacPs *EmacPsInstancePtr, u8 loopbackEn, u32 Offset);

/*
 * Interrupt setup and Callbacks for examples
 */
#ifndef SDT
static LONG EmacPsSetupIntrSystem(INTC *IntcInstancePtr,
				  XEmacPs *EmacPsInstancePtr,
				  u16 EmacPsIntrId);

static void EmacPsDisableIntrSystem(INTC *IntcInstancePtr,
				    u16 EmacPsIntrId);
#endif
static void XEmacPsSendHandler(void *Callback);
static void XEmacPsRecvHandler(void *Callback);
static void XEmacPsErrorHandler(void *Callback, u8 direction, u32 word);

/*
 * Utility routines
 */
static LONG EmacPsResetDevice(XEmacPs *EmacPsInstancePtr);
void XEmacPsClkSetup(XEmacPs *EmacPsInstancePtr, u16 EmacPsIntrId);
void XEmacPs_SetMdioDivisor(XEmacPs *InstancePtr, XEmacPs_MdcDiv Divisor);

/*****************************************************************************/
#ifdef SDT
LONG EmacPsDmaIntrExample( XEmacPs *EmacPsInstancePtr, UINTPTR BaseAddress)
#else
LONG EmacPsDmaIntrExample(INTC *IntcInstancePtr,
			  XEmacPs *EmacPsInstancePtr,
			  u16 EmacPsDeviceId)
#endif
{
	LONG Status;
	XEmacPs_Config *Config;	
	u16 EmacPsIntrId;

	/*************************************/
	/* Setup device for first-time usage */
	/*************************************/

	/*
	 *  Initialize instance. Should be configured for DMA
	 *  This example calls _CfgInitialize instead of _Initialize due to
	 *  retiring _Initialize. So in _CfgInitialize we use
	 *  XPAR_(IP)_BASEADDRESS to make sure it is not virtual address.
	 */
#ifdef SDT
	Config = XEmacPs_LookupConfig(BaseAddress);
#else
	Config = XEmacPs_LookupConfig(EmacPsDeviceId);
#endif

	Status = XEmacPs_CfgInitialize(EmacPsInstancePtr, Config,
				       Config->BaseAddress);

	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error in initialize");
		return XST_FAILURE;
	}

#if defined(XPAR_INTC_0_DEVICE_ID)
	EmacPsIntrId = XPAR_AXI_INTC_0_PROCESSING_SYSTEM7_0_IRQ_P2F_ENET0_INTR;
#else
	if ((EmacPsInstancePtr->Config.BaseAddress == ZYNQ_EMACPS_0_BASEADDR) ||
	    (EmacPsInstancePtr->Config.BaseAddress == ZYNQMP_EMACPS_0_BASEADDR) ||
	    (EmacPsInstancePtr->Config.BaseAddress == VERSAL_EMACPS_0_BASEADDR) ||
	    (EmacPsInstancePtr->Config.BaseAddress == VERSAL_NET_EMACPS_0_BASEADDR)) {
		EmacPsIntrId = XPS_GEM0_INT_ID;
	}
	else if ((EmacPsInstancePtr->Config.BaseAddress == ZYNQ_EMACPS_1_BASEADDR) ||
		 (EmacPsInstancePtr->Config.BaseAddress == ZYNQMP_EMACPS_1_BASEADDR) ||
		 (EmacPsInstancePtr->Config.BaseAddress == VERSAL_EMACPS_1_BASEADDR) ||
		 (EmacPsInstancePtr->Config.BaseAddress == VERSAL_NET_EMACPS_1_BASEADDR)) {
		EmacPsIntrId = XPS_GEM1_INT_ID;
	}
	else if (EmacPsInstancePtr->Config.BaseAddress == ZYNQMP_EMACPS_2_BASEADDR) {
#ifdef XPS_GEM2_INT_ID
		EmacPsIntrId = XPS_GEM2_INT_ID;
#endif
	}
	else if (EmacPsInstancePtr->Config.BaseAddress == ZYNQMP_EMACPS_3_BASEADDR) {
#ifdef XPS_GEM3_INT_ID
		EmacPsIntrId = XPS_GEM3_INT_ID;
#endif
	}
#endif

	GemVersion = ((Xil_In32(Config->BaseAddress + 0xFC)) >> 16) & 0xFFF;

	XEmacPsClkSetup(EmacPsInstancePtr, EmacPsIntrId);

	/*
	 * Set the MAC address
	 */
	Status = XEmacPs_SetMacAddress(EmacPsInstancePtr, EmacPsMAC, 1);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error setting MAC address");
		return XST_FAILURE;
	}
	/*
	 * Setup callbacks
	 */
	Status = XEmacPs_SetHandler(EmacPsInstancePtr,
				    XEMACPS_HANDLER_DMASEND,
				    (void *) XEmacPsSendHandler,
				    EmacPsInstancePtr);
	Status |=
		XEmacPs_SetHandler(EmacPsInstancePtr,
				   XEMACPS_HANDLER_DMARECV,
				   (void *) XEmacPsRecvHandler,
				   EmacPsInstancePtr);
	Status |=
		XEmacPs_SetHandler(EmacPsInstancePtr, XEMACPS_HANDLER_ERROR,
				   (void *) XEmacPsErrorHandler,
				   EmacPsInstancePtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error assigning handlers");
		return XST_FAILURE;
	}

	/* Gem IP version on Zynq-7000 */
	if (GemVersion == 2) {
		/*
		 * The BDs need to be allocated in uncached memory. Hence the 1 MB
		 * address range that starts at "bd_space" is made uncached.
		 */
#if !defined(__MICROBLAZE__) && !defined(ARMR5)
		Xil_SetTlbAttributes((INTPTR)bd_space, DEVICE_MEMORY);
#else
		Xil_DCacheDisable();
#endif

	}
	/* Allocate Rx and Tx BD space each */
	RxBdSpacePtr = &(bd_space[0]);
	TxBdSpacePtr = &(bd_space[0x10000]);


	if (GemVersion == 2) {
		XEmacPs_SetMdioDivisor(EmacPsInstancePtr, MDC_DIV_224);
		EmacpsDelay(1);		
		XEmacPs_SetOperatingSpeed(EmacPsInstancePtr, EMACPS_LOOPBACK_SPEED_1G);
	}

    /*
	 * Run the EmacPs DMA Single Frame Interrupt example
	 */
	Status = EmacPsDmaSingleFrameIntrExample(EmacPsInstancePtr,1,0);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}


/****************************************************************************/
/**
*
* This function demonstrates the usage of the EMACPS by sending and
* receiving a single frame in DMA interrupt mode.
* The source packet will be described by two descriptors. It will be
* received into a buffer described by a single descriptor.
*
* @param	EmacPsInstancePtr is a pointer to the instance of the EmacPs
*		driver.
*
* @return	XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note		None.
*
*****************************************************************************/
LONG EmacPsDmaSingleFrameIntrExample(XEmacPs *EmacPsInstancePtr, u8 loopbackEn, u32 Offset)
{
	LONG Status;
	u32 PayloadSize = PAYLOADSIZE + TOTALHEADERSIZE;
	u32 NumRxBuf = 0;
    u32 NumTxBuf = 0;
	u32 RxFrLen;
	XEmacPs_Bd *Bd1Ptr;
	XEmacPs_Bd *BdRxPtr;
    XEmacPs_Bd BdTemplate;
    u32 EthType = loopbackEn? PayloadSize : 0x0800;
    u32 TIMEOUT;
	/*
	 * Setup RxBD space.
	 *
	 * We have already defined a properly aligned area of memory to store
	 * RxBDs at the beginning of this source code file so just pass its
	 * address into the function. No MMU is being used so the physical
	 * and virtual addresses are the same.
	 *
	 * Setup a BD template for the Rx channel. This template will be
	 * copied to every RxBD. We will not have to explicitly set these
	 * again.
	 */
	XEmacPs_BdClear(&BdTemplate);

	/*
	 * Create the RxBD ring
	 */
	Status = XEmacPs_BdRingCreate(&(XEmacPs_GetRxRing
					(EmacPsInstancePtr)),
				      (UINTPTR) RxBdSpacePtr,
				      (UINTPTR) RxBdSpacePtr,
				      XEMACPS_BD_ALIGNMENT,
				      RXBD_CNT);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Error setting up RxBD space, BdRingCreate");
		return XST_FAILURE;
	}

	Status = XEmacPs_BdRingClone(&(XEmacPs_GetRxRing(EmacPsInstancePtr)),
				     &BdTemplate, XEMACPS_RECV);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Error setting up RxBD space, BdRingClone");
		return XST_FAILURE;
	}

	/*
	 * Setup TxBD space.
	 *
	 * Like RxBD space, we have already defined a properly aligned area
	 * of memory to use.
	 *
	 * Also like the RxBD space, we create a template. Notice we don't
	 * set the "last" attribute. The example will be overriding this
	 * attribute so it does no good to set it up here.
	 */
	XEmacPs_BdClear(&BdTemplate);
	XEmacPs_BdSetStatus(&BdTemplate, XEMACPS_TXBUF_USED_MASK);

	/*
	 * Create the TxBD ring
	 */
	Status = XEmacPs_BdRingCreate(&(XEmacPs_GetTxRing
					(EmacPsInstancePtr)),
				      (UINTPTR) TxBdSpacePtr,
				      (UINTPTR) TxBdSpacePtr,
				      XEMACPS_BD_ALIGNMENT,
				      TXBD_CNT);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Error setting up TxBD space, BdRingCreate");
		return XST_FAILURE;
	}
	Status = XEmacPs_BdRingClone(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				     &BdTemplate, XEMACPS_SEND);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Error setting up TxBD space, BdRingClone");
		return XST_FAILURE;
	}

	/*
	 * Set emacps to phy loopback
	 */
    if (loopbackEn)
        EmacPsUtilEnterLoopback(EmacPsInstancePtr, EMACPS_LOOPBACK_SPEED_1G, 1);

	
    /*
	 * Clear variables shared with callbacks
	 */
	FramesRx = 0;
	FramesTx = 0;
	DeviceErrors = 0;

	/*
	 * Calculate the frame length (not including FCS)
	 */
	TxFrameLength = XEMACPS_HDR_SIZE + PayloadSize;

	/*
	 * Setup packet to be transmitted
	 */     
	EmacPsUtilFrameHdrFormatMAC(&TxFrame, EmacPsMAC); 
    
    EmacPsUtilFrameHdrFormatType(&TxFrame, EthType); 

	EmacPsUtilFrameSetPayloadData(&TxFrame, PayloadSize, Offset);

	if (EmacPsInstancePtr->Config.IsCacheCoherent == 0) {
		Xil_DCacheFlushRange((UINTPTR)&TxFrame, sizeof(EthernetFrame));
	}

	/*
	 * Clear out receive packet memory area
	 */
	EmacPsUtilFrameMemClear(&RxFrame);

	if (EmacPsInstancePtr->Config.IsCacheCoherent == 0) {
		Xil_DCacheFlushRange((UINTPTR)&RxFrame, sizeof(EthernetFrame));
	}

	/*
	 * Allocate RxBDs since we do not know how many BDs will be used
	 * in advance, use RXBD_CNT here.
	 */
	Status = XEmacPs_BdRingAlloc(&(XEmacPs_GetRxRing(EmacPsInstancePtr)),
				     RXBD_CNT, &BdRxPtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error allocating RxBD");
		return XST_FAILURE;
	}


	/*
	 * Setup the BD. The XEmacPs_BdRingClone() call will mark the
	 * "wrap" field for last RxBD. Setup buffer address to associated
	 * BD.
	 */

	XEmacPs_BdSetAddressRx(BdRxPtr, (UINTPTR)&RxFrame);

	/*
	 * Enqueue to HW
	 */
	Status = XEmacPs_BdRingToHw(&(XEmacPs_GetRxRing(EmacPsInstancePtr)),
				    RXBD_CNT, BdRxPtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error committing RxBD to HW");
		return XST_FAILURE;
	}

	/*
	 * Allocate, setup, and enqueue TxBDs. The first BD will
	 * describe the first 32 bytes of TxFrame and the rest of BDs
	 * will describe the rest of the frame.
	 *
	 * The function below will allocate 1 adjacent BDs with Bd1Ptr
	 * being set as the lead BD.
	 */
	Status = XEmacPs_BdRingAlloc(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				     1, &Bd1Ptr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error allocating TxBD");
		return XST_FAILURE;
	}

	/*
	 * Setup first TxBD
	 */
	XEmacPs_BdSetAddressTx(Bd1Ptr, (UINTPTR)&TxFrame);
	XEmacPs_BdSetLength(Bd1Ptr, TxFrameLength);
	XEmacPs_BdClearTxUsed(Bd1Ptr);
	XEmacPs_BdSetLast(Bd1Ptr);

    /*
     * Set the rest of TxBD 
    */

	/*
	 * Enqueue to HW
	 */
	Status = XEmacPs_BdRingToHw(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				    1, Bd1Ptr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error committing TxBD to HW");
		return XST_FAILURE;
	}
	if (EmacPsInstancePtr->Config.IsCacheCoherent == 0) {
		Xil_DCacheFlushRange((UINTPTR)Bd1Ptr, 64);
	}
	/*
	 * Set the Queue pointers
	 */
	XEmacPs_SetQueuePtr(EmacPsInstancePtr, EmacPsInstancePtr->RxBdRing.BaseBdAddr, 0, XEMACPS_RECV);
	XEmacPs_SetQueuePtr(EmacPsInstancePtr, EmacPsInstancePtr->TxBdRing.BaseBdAddr, 0, XEMACPS_SEND);

     /*
	 * Setup the interrupt controller and enable interrupts
	 */
    Status = XSetupInterruptSystem(EmacPsInstancePtr, &XEmacPs_IntrHandler,
				       EmacPsInstancePtr->Config.IntrId,
				       EmacPsInstancePtr->Config.IntrParent,
				       XINTERRUPT_DEFAULT_PRIORITY);

	/*
	 * Start the device
	 */
	XEmacPs_Start(EmacPsInstancePtr);

	/* Start transmit */
	XEmacPs_Transmit(EmacPsInstancePtr);
    
    TIMEOUT = 100000;
	/*
	 * Wait for transmission to complete
	 */
	while (!FramesTx) {
       TIMEOUT--;
       if (TIMEOUT == 0) {
           xil_printf ("ethernet frame tx timeout");
           return XST_FAILURE;
       }          
    }

	/*
	 * Now that the frame has been sent, post process our TxBDs.
	 * Since we have only submitted 1 to hardware, then there should
	 * be only 1 ready for post processing.
	 */
    NumTxBuf = XEmacPs_BdRingFromHwTx(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				   1, &Bd1Ptr);

	if ( NumTxBuf == 0) {
		EmacPsUtilErrorTrap
		("TxBDs were not ready for post processing");
		return XST_FAILURE;
	}

	/*
	 * Examine the TxBDs.
	 *
	 * There isn't much to do. The only thing to check would be DMA
	 * exception bits. But this would also be caught in the error
	 * handler. So we just return these BDs to the free list.
	 */


	Status = XEmacPs_BdRingFree(&(XEmacPs_GetTxRing(EmacPsInstancePtr)),
				    NumTxBuf, Bd1Ptr);

	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error freeing up TxBDs");
		return XST_FAILURE;
	}   

    //if ((!loopbackEn) && (Offset + PAYLOADSIZE < ETHERNET_SIZE)){
    if (!loopbackEn) {    
        XEmacPs_Stop(EmacPsInstancePtr);
        return Status;
    }
     
	/*
	 * Wait for Rx indication
	 */
	while (!FramesRx);

	/*
	 * Disable the interrupts for the EmacPs device	
    */
	XDisconnectInterruptCntrl(EmacPsInstancePtr->Config.IntrId,
				  EmacPsInstancePtr->Config.IntrParent);

	/*
	 * Now that the frame has been received, post process our RxBD.
	 * Since we have submitted to hardware, then there should be only 1
	 * ready for post processing.
	 */
	NumRxBuf = XEmacPs_BdRingFromHwRx(&(XEmacPs_GetRxRing
					    (EmacPsInstancePtr)), RXBD_CNT,
					  &BdRxPtr);
	if (0 == NumRxBuf) {
		EmacPsUtilErrorTrap("RxBD was not ready for post processing");
		return XST_FAILURE;
	}
    

    if ((!loopbackEn) && (Offset + PAYLOADSIZE >= ETHERNET_SIZE)){
        // TODO add command loop process from ethernet

        XEmacPs_Stop(EmacPsInstancePtr);
        return Status;
    }

	/*
	 * There is no device status to check. If there was a DMA error,
	 * it should have been reported to the error handler. Check the
	 * receive lengthi against the transmitted length, then verify
	 * the data.
	 */
	RxFrLen = XEmacPs_BdGetLength(BdRxPtr);

	if (RxFrLen != TxFrameLength) {
		EmacPsUtilErrorTrap("Length mismatch");
		return XST_FAILURE;
	}

	if (EmacPsUtilFrameVerify(&TxFrame, &RxFrame) != 0) {
		EmacPsUtilErrorTrap("Data mismatch");
		return XST_FAILURE;
	}

	/*
	 * Return the RxBD back to the channel for later allocation. Free
	 * the exact number we just post processed.
	 */
	Status = XEmacPs_BdRingFree(&(XEmacPs_GetRxRing(EmacPsInstancePtr)),
				    NumRxBuf, BdRxPtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error freeing up RxBDs");
		return XST_FAILURE;
	}
   
	/*
	 * Finished this example. If everything worked correctly, all TxBDs
	 * and RxBDs should be free for allocation. Stop the device.
	 */
	XEmacPs_Stop(EmacPsInstancePtr);

    EmacPsUtilEnterLoopback(EmacPsInstancePtr, EMACPS_LOOPBACK_SPEED_1G, 0);

	return XST_SUCCESS;
}


/****************************************************************************/
/**
* This function resets the device but preserves the options set by the user.
*
* The descriptor list could be reinitialized with the same calls to
* XEmacPs_BdRingClone() as used in main(). Doing this is a matter of
* preference.
* In many cases, an OS may have resources tied up in the descriptors.
* Reinitializing in this case may bad for the OS since its resources may be
* permamently lost.
*
* @param	EmacPsInstancePtr is a pointer to the instance of the EmacPs
*		driver.
*
* @return	XST_SUCCESS if successful, else XST_FAILURE.
*
* @note		None.
*
*****************************************************************************/
static LONG EmacPsResetDevice(XEmacPs *EmacPsInstancePtr)
{
	LONG Status = 0;
	u8 MacSave[6];
	u32 Options;
	XEmacPs_Bd BdTemplate;


	/*
	 * Stop device
	 */
	XEmacPs_Stop(EmacPsInstancePtr);

	/*
	 * Save the device state
	 */
	XEmacPs_GetMacAddress(EmacPsInstancePtr, &MacSave, 1);
	Options = XEmacPs_GetOptions(EmacPsInstancePtr);

	/*
	 * Stop and reset the device
	 */
	XEmacPs_Reset(EmacPsInstancePtr);

	/*
	 * Restore the state
	 */
	XEmacPs_SetMacAddress(EmacPsInstancePtr, &MacSave, 1);
	Status |= XEmacPs_SetOptions(EmacPsInstancePtr, Options);
	Status |= XEmacPs_ClearOptions(EmacPsInstancePtr, ~Options);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error restoring state after reset");
		return XST_FAILURE;
	}

	/*
	 * Setup callbacks
	 */
	Status = XEmacPs_SetHandler(EmacPsInstancePtr,
				    XEMACPS_HANDLER_DMASEND,
				    (void *) XEmacPsSendHandler,
				    EmacPsInstancePtr);
	Status |= XEmacPs_SetHandler(EmacPsInstancePtr,
				     XEMACPS_HANDLER_DMARECV,
				     (void *) XEmacPsRecvHandler,
				     EmacPsInstancePtr);
	Status |= XEmacPs_SetHandler(EmacPsInstancePtr, XEMACPS_HANDLER_ERROR,
				     (void *) XEmacPsErrorHandler,
				     EmacPsInstancePtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap("Error assigning handlers");
		return XST_FAILURE;
	}

	/*
	 * Setup RxBD space.
	 *
	 * We have already defined a properly aligned area of memory to store
	 * RxBDs at the beginning of this source code file so just pass its
	 * address into the function. No MMU is being used so the physical and
	 * virtual addresses are the same.
	 *
	 * Setup a BD template for the Rx channel. This template will be copied
	 * to every RxBD. We will not have to explicitly set these again.
	 */
	XEmacPs_BdClear(&BdTemplate);

	/*
	 * Create the RxBD ring
	 */
	Status = XEmacPs_BdRingCreate(&(XEmacPs_GetRxRing
					(EmacPsInstancePtr)),
				      (UINTPTR) RxBdSpacePtr,
				      (UINTPTR) RxBdSpacePtr,
				      XEMACPS_BD_ALIGNMENT,
				      RXBD_CNT);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Error setting up RxBD space, BdRingCreate");
		return XST_FAILURE;
	}

	Status = XEmacPs_BdRingClone(&
				     (XEmacPs_GetRxRing(EmacPsInstancePtr)),
				     &BdTemplate, XEMACPS_RECV);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Error setting up RxBD space, BdRingClone");
		return XST_FAILURE;
	}

	/*
	 * Setup TxBD space.
	 *
	 * Like RxBD space, we have already defined a properly aligned area of
	 * memory to use.
	 *
	 * Also like the RxBD space, we create a template. Notice we don't set
	 * the "last" attribute. The examples will be overriding this
	 * attribute so it does no good to set it up here.
	 */
	XEmacPs_BdClear(&BdTemplate);
	XEmacPs_BdSetStatus(&BdTemplate, XEMACPS_TXBUF_USED_MASK);

	/*
	 * Create the TxBD ring
	 */
	Status = XEmacPs_BdRingCreate(&(XEmacPs_GetTxRing
					(EmacPsInstancePtr)),
				      (UINTPTR) TxBdSpacePtr,
				      (UINTPTR) TxBdSpacePtr,
				      XEMACPS_BD_ALIGNMENT,
				      TXBD_CNT);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Error setting up TxBD space, BdRingCreate");
		return XST_FAILURE;
	}
	Status = XEmacPs_BdRingClone(&
				     (XEmacPs_GetTxRing(EmacPsInstancePtr)),
				     &BdTemplate, XEMACPS_SEND);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Error setting up TxBD space, BdRingClone");
		return XST_FAILURE;
	}

	/*
	 * Restart the device
	 */
	XEmacPs_Start(EmacPsInstancePtr);

	return XST_SUCCESS;
}


/****************************************************************************/
/**
*
* This function setups the interrupt system so interrupts can occur for the
* EMACPS.
* @param	IntcInstancePtr is a pointer to the instance of the Intc driver.
* @param	EmacPsInstancePtr is a pointer to the instance of the EmacPs
*		driver.
* @param	EmacPsIntrId is the Interrupt ID and is typically
*		XPAR_<EMACPS_instance>_INTR value from xparameters.h.
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note		None.
*
*****************************************************************************/
#ifndef SDT
static LONG EmacPsSetupIntrSystem(INTC *IntcInstancePtr,
				  XEmacPs *EmacPsInstancePtr,
				  u16 EmacPsIntrId)
{
	LONG Status;

#ifdef XPAR_INTC_0_DEVICE_ID

#ifndef TESTAPP_GEN
	/*
	 * Initialize the interrupt controller driver so that it's ready to
	 * use.
	 */
	Status = XIntc_Initialize(IntcInstancePtr, INTC_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
#endif

	/*
	 * Connect the handler that will be called when an interrupt
	 * for the device occurs, the handler defined above performs the
	 * specific interrupt processing for the device.
	 */
	Status = XIntc_Connect(IntcInstancePtr, EmacPsIntrId,
			       (XInterruptHandler) XEmacPs_IntrHandler, EmacPsInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

#ifndef TESTAPP_GEN
	/*
	 * Start the interrupt controller such that interrupts are enabled for
	 * all devices that cause interrupts.
	 */

	Status = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
#endif

	/*
	 * Enable the interrupt from the hardware
	 */
	XIntc_Enable(IntcInstancePtr, EmacPsIntrId);

#ifndef TESTAPP_GEN
	/*
	 * Initialize the exception table.
	 */
	Xil_ExceptionInit();

	/*
	 * Register the interrupt controller handler with the exception table.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
				     (Xil_ExceptionHandler) XIntc_InterruptHandler,
				     IntcInstancePtr);
#endif

#else
#ifndef TESTAPP_GEN
	XScuGic_Config *GicConfig;
	Xil_ExceptionInit();

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	GicConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == GicConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcInstancePtr, GicConfig,
				       GicConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
				     (Xil_ExceptionHandler)XScuGic_InterruptHandler,
				     IntcInstancePtr);
#endif

	/*
	 * Connect a device driver handler that will be called when an
	 * interrupt for the device occurs, the device driver handler performs
	 * the specific interrupt processing for the device.
	 */
	Status = XScuGic_Connect(IntcInstancePtr, EmacPsIntrId,
				 (Xil_InterruptHandler) XEmacPs_IntrHandler,
				 (void *) EmacPsInstancePtr);
	if (Status != XST_SUCCESS) {
		EmacPsUtilErrorTrap
		("Unable to connect ISR to interrupt controller");
		return XST_FAILURE;
	}

	/*
	 * Enable interrupts from the hardware
	 */
	XScuGic_Enable(IntcInstancePtr, EmacPsIntrId);
#endif
#ifndef TESTAPP_GEN
	/*
	 * Enable interrupts in the processor
	 */
	Xil_ExceptionEnable();
#endif
	return XST_SUCCESS;
}


/****************************************************************************/
/**
*
* This function disables the interrupts that occur for EmacPs.
*
* @param	IntcInstancePtr is the pointer to the instance of the ScuGic
*		driver.
* @param	EmacPsIntrId is interrupt ID and is typically
*		XPAR_<EMACPS_instance>_INTR value from xparameters.h.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void EmacPsDisableIntrSystem(INTC *IntcInstancePtr,
				    u16 EmacPsIntrId)
{
	/*
	 * Disconnect and disable the interrupt for the EmacPs device
	 */
#ifdef XPAR_INTC_0_DEVICE_ID
	XIntc_Disconnect(IntcInstancePtr, EmacPsIntrId);
#else
	XScuGic_Disconnect(IntcInstancePtr, EmacPsIntrId);
#endif

}
#endif
/****************************************************************************/
/**
*
* This the Transmit handler callback function and will increment a shared
* counter that can be shared by the main thread of operation.
*
* @param	Callback is the pointer to the instance of the EmacPs device.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void XEmacPsSendHandler(void *Callback)
{
	XEmacPs *EmacPsInstancePtr = (XEmacPs *) Callback;

	/*
	 * Disable the transmit related interrupts
	 */
	//XEmacPs_IntDisable(EmacPsInstancePtr, (XEMACPS_IXR_TXCOMPL_MASK |
	//				       XEMACPS_IXR_TX_ERR_MASK));
	if (GemVersion > 2) {
		XEmacPs_IntQ1Disable(EmacPsInstancePtr, XEMACPS_INTQ1_IXR_ALL_MASK);
	}
	/*
	 * Increment the counter so that main thread knows something
	 * happened.
	 */
	FramesTx++;
}


/****************************************************************************/
/**
*
* This is the Receive handler callback function and will increment a shared
* counter that can be shared by the main thread of operation.
*
* @param	Callback is a pointer to the instance of the EmacPs device.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void XEmacPsRecvHandler(void *Callback)
{
	XEmacPs *EmacPsInstancePtr = (XEmacPs *) Callback;

	/*
	 * Disable the transmit related interrupts
	 */
	XEmacPs_IntDisable(EmacPsInstancePtr, (XEMACPS_IXR_FRAMERX_MASK |
					       XEMACPS_IXR_RX_ERR_MASK));
	/*
	 * Increment the counter so that main thread knows something
	 * happened.
	 */
	FramesRx++;
	if (EmacPsInstancePtr->Config.IsCacheCoherent == 0) {
		Xil_DCacheInvalidateRange((UINTPTR)&RxFrame, sizeof(EthernetFrame));
	}
	if (GemVersion > 2) {
		if (EmacPsInstancePtr->Config.IsCacheCoherent == 0) {
			Xil_DCacheInvalidateRange((UINTPTR)RxBdSpacePtr, 64);
		}
	}
}


/****************************************************************************/
/**
*
* This is the Error handler callback function and this function increments
* the error counter so that the main thread knows the number of errors.
*
* @param	Callback is the callback function for the driver. This
*		parameter is not used in this example.
* @param	Direction is passed in from the driver specifying which
*		direction error has occurred.
* @param	ErrorWord is the status register value passed in.
*
* @return	None.
*
* @note		None.
*
*****************************************************************************/
static void XEmacPsErrorHandler(void *Callback, u8 Direction, u32 ErrorWord)
{
	XEmacPs *EmacPsInstancePtr = (XEmacPs *) Callback;

	/*
	 * Increment the counter so that main thread knows something
	 * happened. Reset the device and reallocate resources ...
	 */
	DeviceErrors++;

	switch (Direction) {
		case XEMACPS_RECV:
			if (ErrorWord & XEMACPS_RXSR_HRESPNOK_MASK) {
				EmacPsUtilErrorTrap("Receive DMA error");
			}
			if (ErrorWord & XEMACPS_RXSR_RXOVR_MASK) {
				EmacPsUtilErrorTrap("Receive over run");
			}
			if (ErrorWord & XEMACPS_RXSR_BUFFNA_MASK) {
				EmacPsUtilErrorTrap("Receive buffer not available");
			}
			break;
		case XEMACPS_SEND:
			if (ErrorWord & XEMACPS_TXSR_HRESPNOK_MASK) {
				EmacPsUtilErrorTrap("Transmit DMA error");
			}
			if (ErrorWord & XEMACPS_TXSR_URUN_MASK) {
				EmacPsUtilErrorTrap("Transmit under run");
			}
			if (ErrorWord & XEMACPS_TXSR_BUFEXH_MASK) {
				EmacPsUtilErrorTrap("Transmit buffer exhausted");
			}
			if (ErrorWord & XEMACPS_TXSR_RXOVR_MASK) {
				EmacPsUtilErrorTrap("Transmit retry excessed limits");
			}
			if (ErrorWord & XEMACPS_TXSR_FRAMERX_MASK) {
				EmacPsUtilErrorTrap("Transmit collision");
			}
			if (ErrorWord & XEMACPS_TXSR_USEDREAD_MASK) {
				EmacPsUtilErrorTrap("Transmit buffer not available");
			}
			break;
	}
	/*
	 * Bypassing the reset functionality as the default tx status for q0 is
	 * USED BIT READ. so, the first interrupt will be tx used bit and it resets
	 * the core always.
	 */
	if (GemVersion == 2) {
		EmacPsResetDevice(EmacPsInstancePtr);
	}
}

/****************************************************************************/
/**
*
* This function sets up the clock divisors for 1000Mbps.
*
* @param	EmacPsInstancePtr is a pointer to the instance of the EmacPs
*			driver.
* @param	EmacPsIntrId is the Interrupt ID and is typically
*			XPAR_<EMACPS_instance>_INTR value from xparameters.h.
* @return	None.
*
* @note		None.
*
*****************************************************************************/
void XEmacPsClkSetup(XEmacPs *EmacPsInstancePtr, u16 EmacPsIntrId)
{
	u32 ClkCntrl;
	u32 BaseAddress = EmacPsInstancePtr->Config.BaseAddress;

	if (GemVersion == 2) {
		/*************************************/
		/* Setup device for first-time usage */
		/*************************************/

		/* SLCR unlock */
		*(volatile unsigned int *)(SLCR_UNLOCK_ADDR) = SLCR_UNLOCK_KEY_VALUE;
		if (BaseAddress == ZYNQ_EMACPS_0_BASEADDR) {
#ifdef XPAR_PS7_ETHERNET_0_ENET_SLCR_1000MBPS_DIV0
			/* GEM0 1G clock configuration*/
			ClkCntrl =
				*(volatile unsigned int *)(SLCR_GEM0_CLK_CTRL_ADDR);
			ClkCntrl &= EMACPS_SLCR_DIV_MASK;
			ClkCntrl |= (EmacPsInstancePtr->Config.S1GDiv1 << 20);
			ClkCntrl |= (EmacPsInstancePtr->Config.S1GDiv0 << 8);
			*(volatile unsigned int *)(SLCR_GEM0_CLK_CTRL_ADDR) =
				ClkCntrl;
#endif
		}
		else if (BaseAddress == ZYNQ_EMACPS_1_BASEADDR) {
#ifdef XPAR_PS7_ETHERNET_1_ENET_SLCR_1000MBPS_DIV1
			/* GEM1 1G clock configuration*/
			ClkCntrl =
				*(volatile unsigned int *)(SLCR_GEM1_CLK_CTRL_ADDR);
			ClkCntrl &= EMACPS_SLCR_DIV_MASK;
			ClkCntrl |= (EmacPsInstancePtr->Config.S1GDiv1 << 20);
			ClkCntrl |= (EmacPsInstancePtr->Config.S1GDiv0 << 8);
			*(volatile unsigned int *)(SLCR_GEM1_CLK_CTRL_ADDR) =
				ClkCntrl;
#endif
		}
		/* SLCR lock */
		*(unsigned int *)(SLCR_LOCK_ADDR) = SLCR_LOCK_KEY_VALUE;
#ifndef __MICROBLAZE__
		sleep(1);
#else
		unsigned long count = 0;
		while (count < 0xffff) {
			count++;
		}
#endif
	}

	if ((GemVersion == GEMVERSION_ZYNQMP) && ((Platform & PLATFORM_MASK) == PLATFORM_SILICON)) {

#ifdef XPAR_PSU_CRL_APB_S_AXI_BASEADDR
		if (BaseAddress == ZYNQMP_EMACPS_0_BASEADDR) {
			/* GEM0 1G clock configuration*/
			ClkCntrl =
				*(volatile unsigned int *)(CRL_GEM0_REF_CTRL);
			ClkCntrl &= ~CRL_GEM_DIV_MASK;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv1 << CRL_GEM_DIV1_SHIFT;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv0 << CRL_GEM_DIV0_SHIFT;
			*(volatile unsigned int *)(CRL_GEM0_REF_CTRL) =
				ClkCntrl;

		}
		if (BaseAddress == ZYNQMP_EMACPS_1_BASEADDR) {

			/* GEM1 1G clock configuration*/
			ClkCntrl =
				*(volatile unsigned int *)(CRL_GEM1_REF_CTRL);
			ClkCntrl &= ~CRL_GEM_DIV_MASK;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv1 << CRL_GEM_DIV1_SHIFT;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv0 << CRL_GEM_DIV0_SHIFT;
			*(volatile unsigned int *)(CRL_GEM1_REF_CTRL) =
				ClkCntrl;
		}
		if (BaseAddress == ZYNQMP_EMACPS_2_BASEADDR) {

			/* GEM2 1G clock configuration*/
			ClkCntrl =
				*(volatile unsigned int *)(CRL_GEM2_REF_CTRL);
			ClkCntrl &= ~CRL_GEM_DIV_MASK;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv1 << CRL_GEM_DIV1_SHIFT;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv0 << CRL_GEM_DIV0_SHIFT;
			*(volatile unsigned int *)(CRL_GEM2_REF_CTRL) =
				ClkCntrl;

		}
		if (BaseAddress == ZYNQMP_EMACPS_3_BASEADDR) {
			/* GEM3 1G clock configuration*/
			ClkCntrl =
				*(volatile unsigned int *)(CRL_GEM3_REF_CTRL);
			ClkCntrl &= ~CRL_GEM_DIV_MASK;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv1 << CRL_GEM_DIV1_SHIFT;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv0 << CRL_GEM_DIV0_SHIFT;
			*(volatile unsigned int *)(CRL_GEM3_REF_CTRL) =
				ClkCntrl;
		}
#endif
	}
	if ((GemVersion == GEMVERSION_VERSAL) &&
	    ((Platform & PLATFORM_MASK_VERSAL) == PLATFORM_VERSALSIL)) {

#ifdef XPAR_PSV_CRL_0_S_AXI_BASEADDR
		if (BaseAddress == VERSAL_EMACPS_0_BASEADDR) {
			/* GEM0 1G clock configuration*/
#if defined (__aarch64__) && (EL1_NONSECURE == 1)
			Xil_Smc(PM_SET_DIVIDER_SMC_FID, (((u64)EmacPsInstancePtr->Config.S1GDiv0 << 32) | CLK_GEM0_REF), 0, 0, 0, 0, 0, 0);
#else
			ClkCntrl = Xil_In32((UINTPTR)CRL_GEM0_REF_CTRL);
			ClkCntrl &= ~CRL_GEM_DIV_VERSAL_MASK;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv0 << CRL_GEM_DIV_VERSAL_SHIFT;
			Xil_Out32((UINTPTR)CRL_GEM0_REF_CTRL, ClkCntrl);
#endif
		}
		if (BaseAddress == VERSAL_EMACPS_1_BASEADDR) {

			/* GEM1 1G clock configuration*/
#if defined (__aarch64__) && (EL1_NONSECURE == 1)
			Xil_Smc(PM_SET_DIVIDER_SMC_FID, (((u64)EmacPsInstancePtr->Config.S1GDiv0 << 32) | CLK_GEM1_REF), 0, 0, 0, 0, 0, 0);
#else
			ClkCntrl = Xil_In32((UINTPTR)CRL_GEM1_REF_CTRL);
			ClkCntrl &= ~CRL_GEM_DIV_VERSAL_MASK;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv0 << CRL_GEM_DIV_VERSAL_SHIFT;
			Xil_Out32((UINTPTR)CRL_GEM1_REF_CTRL, ClkCntrl);
#endif
		}
#endif

#ifdef XPAR_PSX_CRL_0_S_AXI_BASEADDR
		if (BaseAddress == VERSAL_NET_EMACPS_0_BASEADDR) {
			/* GEM0 1G clock configuration*/
#if defined (__aarch64__) && (EL1_NONSECURE == 1)
			Xil_Smc(PM_SET_DIVIDER_SMC_FID, (((u64)EmacPsInstancePtr->Config.S1GDiv0 << 32) | CLK_GEM0_REF), 0, 0, 0, 0, 0, 0);
#else
			ClkCntrl = Xil_In32((UINTPTR)CRL_GEM0_REF_CTRL);
			ClkCntrl &= ~CRL_GEM_DIV_VERSAL_MASK;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv0 << CRL_GEM_DIV_VERSAL_SHIFT;
			Xil_Out32((UINTPTR)CRL_GEM0_REF_CTRL, ClkCntrl);
#endif
		}
		if (BaseAddress == VERSAL_NET_EMACPS_1_BASEADDR) {

			/* GEM1 1G clock configuration*/
#if defined (__aarch64__) && (EL1_NONSECURE == 1)
			Xil_Smc(PM_SET_DIVIDER_SMC_FID, (((u64)EmacPsInstancePtr->Config.S1GDiv0 << 32) | CLK_GEM1_REF), 0, 0, 0, 0, 0, 0);
#else
			ClkCntrl = Xil_In32((UINTPTR)CRL_GEM1_REF_CTRL);
			ClkCntrl &= ~CRL_GEM_DIV_VERSAL_MASK;
			ClkCntrl |= EmacPsInstancePtr->Config.S1GDiv0 << CRL_GEM_DIV_VERSAL_SHIFT;
			Xil_Out32((UINTPTR)CRL_GEM1_REF_CTRL, ClkCntrl);
#endif
		}
#endif
	}
}