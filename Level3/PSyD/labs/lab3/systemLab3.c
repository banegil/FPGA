#include <s3c44b0x.h>
#include "systemLab3.h"    

static void port_init( void )
{
    PDATA = ~0;
    PCONA = 0x3FF;

    PDATB = ~0;
	PCONB &= ~( (1<<10) | 1<<9 );  // PB[10] = out, PF[9] = out

    PDATC = ~0;
    PCONC = 0xAAAAAAAA;
    PUPC  = 0x0000;

    PDATD = ~0;
    PCOND = 0x0000;
    PUPD  = 0x00;
    
    PDATE = ~0;
    PCONE = 0x00000;
    PUPE  = 0x000;

    PDATF = ~0;
    PCONF = 0x0000;
    PUPF  = 0x000;
    
    PDATG = ~0;
    PCONG = 0x0000;
    PUPG  = 0x00;

    SPUCR = 0x4;
    
    EXTINT = 0x00000000;
}

void sys_init( void )
{
    port_init();    
}


