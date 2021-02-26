
#include <s3c44b0x.h>
#include <s3cev40.h>
#include <timers.h>
#include <adc.h>
#include <lcd.h>
#include <ts.h>

#define PX_ERROR    (5)

static uint16 Vxmin = 0;
static uint16 Vxmax = 0;
static uint16 Vymin = 0;
static uint16 Vymax = 0;

static uint8 state;

extern void isr_TS_dummy( void );

static void ts_scan( uint16 *Vx, uint16 *Vy );
static void ts_calibrate( void );
static void ts_sample2coord( uint16 Vx, uint16 Vy, uint16 *x, uint16 *y );

void ts_init( void )
{
    lcd_init();
    adc_init();
    PDATE = (0xB << 4);
    ts_on();
    ts_calibrate();
    ts_off();
}

void ts_on( void )
{
	state = TS_ON;
	adc_on();
}

void ts_off( void )
{
	state = TS_OFF;
	adc_off();
}

uint8 ts_status( void )
{
	return adc_status();
}

static void ts_calibrate( void )
{
	uint16 x, y;
	uint16 Vx, Vy;

	lcd_on();
	do {
		lcd_clear();
		lcd_draw_box(0,0,2,2,BLACK,1);

		while ((PDATG & (1 << 2)));
		sw_delay_ms( TS_DOWN_DELAY );
		ts_scan( &Vxmin, &Vymax );
		while (!(PDATG & (1 << 2)));

		lcd_clear();
		lcd_draw_box(318,238,320,240,BLACK,1);

		while ((PDATG & (1 << 2)));
		sw_delay_ms( TS_DOWN_DELAY );
		ts_scan( &Vxmax, &Vymin );
		while (!(PDATG & (1 << 2)));

		lcd_clear();
		lcd_draw_box(158,118,162,122,BLACK,1);

		while ((PDATG & (1 << 2)));
		sw_delay_ms( TS_DOWN_DELAY );
		ts_scan( &Vx, &Vy );
		while (!(PDATG & (1 << 2)));
		ts_sample2coord( Vx, Vy, &x, &y );

	} while( (x > 160+PX_ERROR) || (x < 160-PX_ERROR) || (y > 120+PX_ERROR) || (y < 120-PX_ERROR) );

}

void ts_wait_down( void )
{
	while (PDATG & (1 << 2));
}

void ts_wait_up( void )
{
	while (!(PDATG & (1 << 2)));
}

void ts_getpos( uint16 *x, uint16 *y )
{
	uint16 ejeX, ejeY;

	while ((PDATG & (1 << 2)));
	sw_delay_ms(TS_DOWN_DELAY);

	ts_scan(&ejeX, &ejeY);

	while (!(PDATG & (1 << 2)));
	ts_sample2coord(ejeX, ejeY, x, y);
}

void ts_getpostime( uint16 *x, uint16 *y, uint16 *ms )
{
	uint16 ejeX, ejeY;

	while ((PDATG & (1 << 2)));
	timer3_start();
	sw_delay_ms(TS_DOWN_DELAY);

	ts_scan(&ejeX, &ejeY);

	while (!(PDATG & (1 << 2)));
	*ms =timer3_stop()/10;
	ts_sample2coord(ejeX, ejeY, x, y);
}

uint8 ts_timeout_getpos( uint16 *x, uint16 *y, uint16 ms )
{
	uint8 error = TS_TIMEOUT;
	uint16 ejeX, ejeY;

	timer3_start_timeout(ms);

	while ((PDATG & (1 << 2)) & timer3_timeout());
	if(!timer3_timeout()){
		sw_delay_ms(TS_DOWN_DELAY);
		ts_scan(&ejeX, &ejeY);
		ts_sample2coord(ejeX, ejeY, x, y);
		error = 0;
	}

	return error;
}

static void ts_scan( uint16 *Vx, uint16 *Vy )
{
    PDATE = (0x6 << 4);
    sw_delay_ms(1);
    *Vx = adc_getSample( ADC_AIN1 );

    PDATE = (0x9 << 4);
    sw_delay_ms(1);
    *Vy = adc_getSample( ADC_AIN0 );

    PDATE = (0xb << 4);
    sw_delay_ms(1);
}

static void ts_sample2coord( uint16 Vx, uint16 Vy, uint16 *x, uint16 *y )
{
    if( Vx < Vxmin )
        *x = 0;
    else if( Vx > Vxmax )
        *x = LCD_WIDTH-1;
    else
        *x = LCD_WIDTH*(Vx-Vxmin) / (Vxmax-Vxmin);
	if( Vy < Vymin )
		*y = LCD_HEIGHT-1;
	else if( Vy > Vymax )
		*y = 0;
	else
		*y = LCD_HEIGHT*(Vy-Vymax) / (Vymin-Vymax);
}

void ts_open( void (*isr)(void) )
{
	pISR_TS = (uint32) isr;
	I_ISPC = BIT_TS;
	INTMSK &= ~(BIT_GLOBAL | BIT_TS);
}

void ts_close( void )
{
	INTMSK |= BIT_TS;
	pISR_BDMA0 =isr_TS_dummy;
}
