#include "FPGARegisterConfig.h"
#include "sleep.h"

void SetOwlImageSize (int ImageWidth, int ImageHeight) {
     u32 data = (u32)ImageWidth + ((u32) ImageHeight << 16);
     FPGA_WriteReg(2,data);
}

u32 GetOwlImageSize (){     
     FPGA_ReadReg(2);
}

void SetHawkImageSize (int ImageWidth, int ImageHeight) {
     u32 data = (u32)ImageWidth + ((u32) ImageHeight << 16);
     FPGA_WriteReg(1,data);
}

void SetXbandRecBytes (int NumofBytes) {
     u32 data  = NumofBytes;
     FPGA_WriteReg(5,data);
}

u32 GetHawkImageSize (){     
     FPGA_ReadReg(1);
}

void EnableTestMode () 
{
      u32 data = FPGA_ReadReg(0);
      data = data | 0x00000002;
      FPGA_WriteReg(0,data);
}

void DisableTestMode () 
{
      u32 data = FPGA_ReadReg(0);
      data = data & 0xFFFFFFFD;
      FPGA_WriteReg(0,data);
}

u32 IsTestMode () {
    return FPGA_ReadReg(0) & 0x00000002;    
}

void SelectOwl () 
{
      u32 data = FPGA_ReadReg(0);
      data = data | 0x00000004;
      FPGA_WriteReg(0,data);
}

u32 IsOwlSelected () 
{
      return FPGA_ReadReg(0) & 0x00000004;
}

void SelectHawk () 
{
      u32 data = FPGA_ReadReg(0);
      data = data & 0xFFFFFFFB;
      FPGA_WriteReg(0,data);
}

void SetCaptureTimeOut (int timeoutval) {
     u32 data = (u32) timeoutval;
     FPGA_WriteReg(3,data);
}

void NewFrameCapture (){
     u32 data = FPGA_ReadReg(0);
     data = data & 0xFFFFFFFE;         
     FPGA_WriteReg(0,data);
     data = data + 0x1;
     FPGA_WriteReg(0,data);
}

void NewXbandFrame () {
     u32 data = FPGA_ReadReg(0);
     data = data & 0xFFFFFFEF;         
     FPGA_WriteReg(0,data);
     data = data + 0x10;
     FPGA_WriteReg(0,data);
}

void FPGARegisterInit () 
{ 
   SetOwlImageSize(1280,1024);
   SetHawkImageSize(1944,1472);
   SelectOwl();
   EnableTestMode();
   SetCaptureTimeOut(0x0000FFFF);   
}

u32 ReadPLVersion () {
    return FPGA_ReadReg(31)>>8;
}

u32 ReadCameraLinkStatus () {
    return FPGA_ReadReg(30) & 0x00000002;
}

u32 ReadImageTransferStatus(){
    return FPGA_ReadReg(30) & 0x00000001;
}

u32 ReadImageDMABytesXfered (){
    return FPGA_ReadReg(29)<<3;
}

u32 ReadSwitchValue() {
    u32 sample0 = 0x01;
    u32 sample1 = 0x00;
    while (sample1 != sample0) {
         sample0 = FPGA_ReadReg(31);
         usleep(500);
         sample1 = FPGA_ReadReg(31);
    }
    return sample0;
}

void SetXbandLocalLoopback () {
     FPGA_WriteReg(0,0x00000020);
}

void SetXbandRemoteLoopback () {
     FPGA_WriteReg(0,0x00000040);
}