
#include <s3c44b0x.h>
#include <s3cev40.h>
#include <pbs.h>
#include <timers.h>

extern void isr_PB_dummy( void );

void pbs_init( void )
{
    timers_init();
}

uint8 pb_scan( void )
{
    if((PDATG & PB_LEFT) == 0)
        return PB_LEFT;
    else if((PDATG & PB_RIGHT)  == 0)
        return PB_RIGHT;
    else
        return PB_FAILURE;
}

uint8 pb_status( uint8 scancode )
{
	if (scancode == PB_LEFT) {
		if ((pb_scan() == PB_LEFT))return PB_DOWN;
		else return PB_UP;
	} else if (scancode == PB_RIGHT) {
		if (pb_scan() == PB_RIGHT)return PB_DOWN;
		else return PB_UP;
	}
	else return PB_FAILURE;
}

void pb_wait_keydown( uint8 scancode )
{
	if (scancode == PB_LEFT) while (PDATG & PB_LEFT);
	else while (PDATG & PB_RIGHT);

}

void pb_wait_keyup( uint8 scancode )
{
	if (scancode == PB_LEFT) {
		while ((PDATG & PB_LEFT));
		sw_delay_ms(PB_KEYDOWN_DELAY);
		while (!(PDATG & PB_LEFT));
	} else {
		while ((PDATG & PB_RIGHT));
		sw_delay_ms(PB_KEYDOWN_DELAY);
		while (!(PDATG & PB_RIGHT));
	}
}

void pb_wait_any_keydown( void )
{
	while ((PDATG & PB_LEFT)|| (PDATG & PB_RIGHT));
}

void pb_wait_any_keyup( void )
{
	while ((PDATG & PB_LEFT)|| (PDATG & PB_RIGHT));
	sw_delay_ms(PB_KEYDOWN_DELAY);

	while(!(PDATG & PB_LEFT) && !(PDATG & PB_RIGHT));
}

uint8 pb_getchar( void )
{
	uint8 scancode;

	while ((PDATG & PB_LEFT) && (PDATG & PB_RIGHT));
	sw_delay_ms(PB_KEYDOWN_DELAY);

	scancode = pb_scan();
	while (!(PDATG & PB_LEFT) || !(PDATG & PB_RIGHT));
	sw_delay_ms(PB_KEYUP_DELAY);

	return scancode;
}

uint8 pb_getchartime( uint16 *ms )
{
    uint8 scancode;
    
    while ( (PDATG & 0xc0) == 0xc0 );
    timer3_start();
    sw_delay_ms( PB_KEYDOWN_DELAY );
    
    scancode = pb_scan();
    
    while (!(PDATG & PB_LEFT) || !(PDATG & PB_RIGHT));
    *ms = timer3_stop() / 10;
    sw_delay_ms( PB_KEYUP_DELAY );

    return scancode;
}

uint8 pb_timeout_getchar( uint16 ms )
{
	uint8 scancode;

	if(ms < 6554){

		timer3_start_timeout(10*ms);
		while((PDATG & PB_LEFT)|| (PDATG & PB_RIGHT) || (timer3_timeout()!= 0));

		if (timer3_timeout()!= 0)return PB_FAILURE;
		else{
			sw_delay_ms(PB_KEYDOWN_DELAY);
			scancode = pb_scan();

			while (!(PDATG & PB_LEFT) || !(PDATG & PB_RIGHT));
			sw_delay_ms(PB_KEYUP_DELAY);

			return scancode;
		}
	}

	return PB_FAILURE;
}

void pbs_open( void (*isr)(void) )
{
	pISR_PB = (uint32) isr;
	EXTINTPND = (BIT_EINT6 | BIT_EINT7);
	I_ISPC = BIT_EINT4567;
	INTMSK &= ~(BIT_GLOBAL | (1 << 21));
}

void pbs_close( void )
{
	INTMSK |= (1 << 21);
	pISR_PB = (uint32) isr_PB_dummy;
}
