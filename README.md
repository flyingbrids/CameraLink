This project use Zynq 7000 SoC to interface two image sensors with cameralink base and cameralink medium interface.
The image data is streamed by DMA to the external DDR3 memory. Each frame trigger is controlled by the embedded ARM processor, and it will instruct DMA to start moving data when data is received.
