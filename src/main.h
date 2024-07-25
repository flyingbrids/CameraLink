#define UART_DEBUG
#define HEO_CAMERA_SINGLE_FRAME_CAPTURE ('0')
#define OWL_CAMERA_SINGLE_FRAME_CAPTURE ('1')
#define HAWK_CAMERA_SINGLE_FRAME_CAPTURE ('2')
#define OWL_CAMERA_TEST_CAPTURE ('3')
#define HAWK_CAMERA_TEST_CAPTURE ('4')
#define XBAND_STROBE ('5')

void make_crc_table();
int Uart_HEO_init ();
void Uart_HEO_trigger ();
int spips_int ();
void spips_read ();
