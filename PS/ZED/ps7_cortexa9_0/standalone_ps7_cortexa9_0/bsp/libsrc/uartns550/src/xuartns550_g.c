#include "xuartns550.h"

XUartNs550_Config XUartNs550_ConfigTable[] __attribute__ ((section (".drvcfg_sec"))) = {

	{
		"xlnx,axi-uart16550-2.0", /* compatible */
		0x43c10000, /* reg */
		0x0, /* xlnx,clock-freq */
		0x0, /* current-speed */
		0xffff, /* interrupts */
		0xffff /* interrupt-parent */
	},
	 {
		 NULL
	}
};