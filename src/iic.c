#include "main.h"

#define IIC_DEVICE_ID		XPAR_XIICPS_1_DEVICE_ID
#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID
#define IIC_INT_VEC_ID		XPAR_XIICPS_1_INTR

/*
 * The slave address to send to and receive from.
 */
#define IIC_SLAVE_ADDR		0x45
#define IIC_SCLK_RATE		400000

static int SetupInterruptSystem(XIicPs *IicPsPtr);

XScuGic InterruptController; 	/* Instance of the Interrupt Controller */

int iic_init (u8 * RecvBuffer, XIicPs * Iic){
	int Status;
	XIicPs_Config *Config;

    Config = XIicPs_LookupConfig(XPAR_XIICPS_1_BASEADDR);
	if (NULL == Config) {
		return XST_FAILURE;
	}
	Status = XIicPs_CfgInitialize(Iic, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}        
    Status = XIicPs_SelfTest(Iic);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
    Status = SetupInterruptSystem(Iic);
    if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
    	/*
	 * Setup the handlers for the IIC that will be called from the
	 * interrupt context when data has been sent and received, specify a
	 * pointer to the IIC driver instance as the callback reference so
	 * the handlers are able to access the instance data.
	 */
	XIicPs_SetStatusHandler(Iic, (void *) &Iic, Handler);
	XIicPs_SetupSlave(Iic, IIC_SLAVE_ADDR);

	/*
	 * Set the IIC serial clock rate.
	 */
	XIicPs_SetSClk(Iic, IIC_SCLK_RATE);    
    /* Receive data from master.
	 * Receive errors will be singalled through event flag.
	 */
	XIicPs_SlaveRecv(Iic, RecvBuffer, 1);
    return Status;
}


static int SetupInterruptSystem(XIicPs *IicPsPtr)
{
	int Status;
	XScuGic_Config *IntcConfig; /* Instance of the interrupt controller */

	Xil_ExceptionInit();

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(&InterruptController, IntcConfig,
				       IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}


	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the processor.
	 */
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT,
				     (Xil_ExceptionHandler)XScuGic_InterruptHandler,
				     &InterruptController);

	/*
	 * Connect the device driver handler that will be called when an
	 * interrupt for the device occurs, the handler defined above performs
	 * the specific interrupt processing for the device.
	 */
	Status = XScuGic_Connect(&InterruptController, IIC_INT_VEC_ID,
				 (Xil_InterruptHandler)XIicPs_SlaveInterruptHandler,
				 (void *)IicPsPtr);
	if (Status != XST_SUCCESS) {
		return Status;
	}

	/*
	 * Enable the interrupt for the Iic device.
	 */
	XScuGic_Enable(&InterruptController, IIC_INT_VEC_ID);


	/*
	 * Enable interrupts in the Processor.
	 */
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}