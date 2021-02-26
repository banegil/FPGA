#define SEGS (*(volatile unsigned char *) 0x2140000 )

const unsigned char hex2segs[16] = {0x12, 0x9f, 0x31, 0x15, 0x9c, 0x54, 0x50, 0x1f, 0x10, 0x1c, 0x18, 0xd0, 0xf1, 0x91, 0x70, 0x78};

void main(void) 
{

    unsigned char i;
    unsigned int j;

    SEGS = 0xff;
    while( 1 )
        for( i=0; i<16; i++ )
        {
            for( j=0; j<300000; j++ )
                SEGS = hex2segs[i];
        }
}
