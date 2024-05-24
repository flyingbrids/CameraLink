#include "xcanps.h"

XCanPs_Config XCanPs_ConfigTable[] __attribute__ ((section (".drvcfg_sec"))) = {

	{
		"xlnx,zynq-can-1.0", /* compatible */
		0xe0008000, /* reg */
		0x401c, /* interrupts */
		0xf8f01000 /* interrupt-parent */
	},
	{
		"xlnx,zynq-can-1.0", /* compatible */
		0xe0009000, /* reg */
		0x4033, /* interrupts */
		0xf8f01000 /* interrupt-parent */
	},
	 {
		 NULL
	}
};