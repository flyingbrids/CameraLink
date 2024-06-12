#include "xparameters.h"
#include "xil_printf.h"
#include "xdebug.h"

#define RegisterBase 0x43c00000

#define FPGA_WriteReg(RegNum, Data) \
    *(volatile u32*)((RegisterBase) + (RegNum<<2)) = (u32)(Data)

#define FPGA_ReadReg(RegNum) \
    *(volatile u32*)((RegisterBase) + (RegNum<<2))

 void FPGARegisterInit();
 u32 GetOwlImageSize ();
 u32 GetHawkImageSize ();
 u32 IsTestMode ();
 void SelectOwl ();
 void SelectHawk ();
 void SetCaptureTimeOut (int timeoutval);
 void NewFrameCapture ();
 u32 ReadPLVersion ();
 u32 ReadCameraLinkStatus ();
 u32 ReadImageTransferStatus();
 u32 ReadImageDMABytesXfered ();
 u32 ReadSwitchValue();
 u32 IsOwlSelected();
 void NewXbandFrame ();
 void SetXbandRecBytes (int NumofBytes);