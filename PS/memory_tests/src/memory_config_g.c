/******************************************************************************
* Copyright (c) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
#include "memory_config.h"

struct memory_range_s memory_ranges[] = {
	/* ps7_ram_0 memory will not be tested since application resides in the same memory */
	{
        	"ps7_ram_1",
        	"ps7_ram_1",
        	0xffff0000,
        	0xfe00,
          },
	 {
        	"ps7_ddr_0",
        	"ps7_ddr_0",
        	0x100000,
        	0x3ff00000,
          },
	 
};

int n_memory_ranges = 2;
