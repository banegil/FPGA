#include <s3c44b0x.h>
#include <leds.h>

static uint8 stateR, stateL;

void leds_init( void )
{
	led_off(LEFT_LED);
	led_off(RIGHT_LED);
}

void led_on( uint8 led )
{
	if(led & RIGHT_LED) {
		PDATB &= ~(1<<10);
		stateR = ON;
	}
	else {
		PDATB &= ~(1<<9);
		stateL = ON;
	}
}

void led_off( uint8 led )
{
	if(led & RIGHT_LED){
		PDATB |= (1<<10);
		stateR = OFF;
	}
	else {
		PDATB |= (1<<9);
		stateL = OFF;
	}
}

void led_toggle( uint8 led )
{
	if(led & RIGHT_LED){
		if (stateR == OFF) led_on(led);
		else led_off(led);
	}
	else {
		if (stateL == OFF) led_on(led);
		else led_off(led);
	}
}

uint8 led_status( uint8 led )
{
    return led & RIGHT_LED? stateR: stateL;
}
