#include "main.h" 


void IPV4HeaderInit (u32 length, unsigned char *IPV4Header){
	// IP Header //
	IPV4Header[0] = 0x45;       // Version 4 IP, 5 words length for this IP Header (Each word is 32 bits)
	IPV4Header[1] = 0x00;       // Service Type (4 Byte) = 0    
    // Total Length ([IP Header Length (20-bytes)] + [User Data Length], all in Bytes) (2 Bytes)
	IPV4Header[2] = (length >>8) & 0xff;		
	IPV4Header[3] =  length & 0xff;
    // Identification (2 Bytes) <Propose 0, we are not using this for fragmenting. Or are we?>
	IPV4Header[4] = 0x00;            
	IPV4Header[5] = 0x00;
    // Flags and Fragment Offset <Flags is defined properly as do not fragment (0x4 over most significant 3 bits).> <Propose 0 for Fragment Offset>
	IPV4Header[6] = 0x40;            
	IPV4Header[7] = 0x00;            
    // TTL <Using minimum of 0, Is this detrimental?> <Should we keep the max of 255?> <Or maybe 1?>
	IPV4Header[8] = 0x00;          
    // Protocol (UDP => 17 = 0x11)  
	IPV4Header[9] = 0x11;         
    // Checksum, will be filled later by hardware (checksum offload)
    IPV4Header[10] = 0x00;
    IPV4Header[11] = 0x00;
    // Source IP Address (4 Bytes) 192.168.00.02
	IPV4Header[12] = 0xc0;            
	IPV4Header[13] = 0xa8;
	IPV4Header[14] = 0x00;
	IPV4Header[15] = 0x02;
     // Destination IP Address (4 Bytes) 192.168.00.03
	IPV4Header[16] = 0xc0;           
	IPV4Header[17] = 0xa8;
	IPV4Header[18] = 0x00;
	IPV4Header[19] = 0x03;

    //CalculateIPV4checksum();
}

void UDPHeaderInit (u32 length, unsigned char *UDPHeader) {
    // Source Port (2 Bytes)
    UDPHeader[0] = 0x07;
    UDPHeader[1] = 0xd0;    
    // Destination Port (2 Bytes)
    UDPHeader[2] = 0x07;
    UDPHeader[3] = 0xd0;    
    // length
    UDPHeader[4] = (length >>8) & 0xff;		
	UDPHeader[5] =  length & 0xff;
    // Checksum, will be filled later by hardware (checksum offload)
    UDPHeader[6] = 0x00;
    UDPHeader[7] = 0x00;
}
