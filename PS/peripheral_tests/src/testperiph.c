
#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"

#include "xaxidma.h"
#include "axidma_header.h"

#include "xdmaps.h"
#include "dmaps_header.h"

#include "xqspips.h"
#include "qspips_header.h"

#include "xscutimer.h"
#include "scutimer_header.h"

#include "xscuwdt.h"
#include "scuwdt_header.h"

#include "xspips.h"
#include "spips_header.h"

#include "xuartns550.h"
#include "uartns550_header.h"

#include "xuartps.h"
#include "uartps_header.h"
int main ()
{

    static XAxiDma axi_dma_0;
    static XAxiDma axi_dma_1;
    static XDmaPs dmac_s;
    static XQspiPs qspi;
    static XScuTimer scutimer;
    static XScuWdt scuwdt;
    static XSpiPs spi1;
    static XUartNs550 axi_uart16550_0;
    static XUartPs uart1;

    print("---Entering main---\n\r");

    {
        int status;
        print("\r\nRunning AxiDMASelfTestExample for axi_dma_0 ... \r\n");
        status = AxiDMASelfTestExample(XPAR_AXI_DMA_0_BASEADDR);
        if (status == 0) {
            print("AxiDMASelfTestExample PASSED \r\n");
        } else {
            print("AxiDMASelfTestExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning AxiDMASelfTestExample for axi_dma_1 ... \r\n");
        status = AxiDMASelfTestExample(XPAR_AXI_DMA_1_BASEADDR);
        if (status == 0) {
            print("AxiDMASelfTestExample PASSED \r\n");
        } else {
            print("AxiDMASelfTestExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning XDmaPs_Example_W_Intr for dmac_s ... \r\n");
        status = XDmaPs_Example_W_Intr(&dmac_s, XPAR_DMAC_S_BASEADDR);
        if (status == 0) {
            print("XDmaPs_Example_W_Intr PASSED \r\n");
        } else {
            print("XDmaPs_Example_W_Intr FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning QspiPsSelfTestExample for qspi ... \r\n");
        status = QspiPsSelfTestExample(XPAR_QSPI_BASEADDR);
        if (status == 0) {
            print("QspiPsSelfTestExample PASSED \r\n");
        } else {
            print("QspiPsSelfTestExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning ScuTimerPolledExample for scutimer ... \r\n");
        status = ScuTimerPolledExample(&scutimer, XPAR_SCUTIMER_BASEADDR);
        if (status == 0) {
            print("ScuTimerPolledExample PASSED \r\n");
        } else {
            print("ScuTimerPolledExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning ScuTimerIntrExample for scutimer ... \r\n");
        status = ScuTimerIntrExample(&scutimer, XPAR_SCUTIMER_BASEADDR);
        if (status == 0) {
            print("ScuTimerIntrExample PASSED \r\n");
        } else {
            print("ScuTimerIntrExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning ScuWdtIntrExample for scuwdt ... \r\n");
        status = ScuWdtIntrExample(&scuwdt, XPAR_SCUWDT_BASEADDR);
        if (status == 0) {
            print("ScuWdtIntrExample PASSED \r\n");
        } else {
            print("ScuWdtIntrExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning ScuWdtPolledExample for scuwdt ... \r\n");
        status = ScuWdtPolledExample(&scuwdt, XPAR_SCUWDT_BASEADDR);
        if (status == 0) {
            print("ScuWdtPolledExample PASSED \r\n");
        } else {
            print("ScuWdtPolledExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning SpiPsSelfTestExample for spi1 ... \r\n");
        status = SpiPsSelfTestExample(XPAR_SPI1_BASEADDR);
        if (status == 0) {
            print("SpiPsSelfTestExample PASSED \r\n");
        } else {
            print("SpiPsSelfTestExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning UartNs550SelfTestExample for axi_uart16550_0 ... \r\n");
        status = UartNs550SelfTestExample(XPAR_AXI_UART16550_0_BASEADDR);
        if (status == 0) {
            print("UartNs550SelfTestExample PASSED \r\n");
        } else {
            print("UartNs550SelfTestExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning UartPsPolledExample for uart1 ... \r\n");
        status = UartPsPolledExample(&uart1, XPAR_UART1_BASEADDR);
        if (status == 0) {
            print("UartPsPolledExample PASSED \r\n");
        } else {
            print("UartPsPolledExample FAILED \r\n");
        }
    }

    {
        int status;
        print("\r\nRunning UartPsIntrExample for uart1 ... \r\n");
        status = UartPsIntrExample(&uart1, XPAR_UART1_BASEADDR);
        if (status == 0) {
            print("UartPsIntrExample PASSED \r\n");
        } else {
            print("UartPsIntrExample FAILED \r\n");
        }
    }

    print("---Exiting main---");
    return 0;
}
