#include "main.h" 

void camera_link_receive (u32 camera_val) {
     u32 imageSize = GetHawkImageSize();
     int totalImageBytes;     
     int imagePixels;
     int status;
     u32 current_camera_val = IsOwlSelected(); 
     u8 sensor_1[20] = "Owl Camera";
     u8 sensor_0[20] = "Hawk Camera";
     u8 sensor[20];
     if (camera_val)
         memcpy (sensor, sensor_1,20);
     else 
         memcpy (sensor, sensor_0,20);

     // trigger routine             
    if ((current_camera_val == 0) & (camera_val != 0)) {
        SelectOwl();     
        imageSize = GetOwlImageSize(); 
        usleep(15000); // delay to allow cameralink switching and re-calibration
    }  
    else if ((current_camera_val == 0) & (camera_val == 0)) {
        imageSize = GetHawkImageSize();  
    }  
    else if ((current_camera_val != 0) & (camera_val != 0)) {
        imageSize = GetOwlImageSize();  
    } 
    else if ((current_camera_val != 0) & (camera_val == 0)) {
        SelectHawk ();
        imageSize = GetHawkImageSize();
        usleep(15000); 
    }                  
    imagePixels = (imageSize >> 16) *(imageSize & 0xffff);
    totalImageBytes = (imagePixels * 3) >> 1; // each pixel is (12bits) 1.5 bytes 
    if((IsTestMode() !=0) || (ReadCameraLinkStatus() !=0)){ 
        status = ImageReceive(totalImageBytes,sensor);
        if (status == XST_SUCCESS)
            xil_printf("successfully transfered 1 frame of image, total bytes %d\r\n", ReadImageDMABytesXfered()); 
        else 
            xil_printf("transfer total bytes %d\r\n", ReadImageDMABytesXfered());           
    }  
    else 
        xil_printf("camera is not ready! \r\n");
}
