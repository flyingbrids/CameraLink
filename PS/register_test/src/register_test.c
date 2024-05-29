#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_io.h"

#define FPGA_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset<<2)) = (u32)(Data)

#define FPGA_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset<<2))


 int main () {
     while (1){
     u32 switch_val = FPGA_ReadReg(0x43c00000,64);
     u32 led_val = switch_val;
     FPGA_WriteReg (0x43c00000,4,led_val);
     }
     return 1;
 }   