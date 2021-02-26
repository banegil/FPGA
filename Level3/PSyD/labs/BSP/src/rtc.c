
#include <s3c44b0x.h>
#include <s3cev40.h>
#include <rtc.h>

extern void isr_TICK_dummy( void );

unsigned int BCDtoI(unsigned int BCD){
unsigned int result;
    result=(BCD>>12)*1000;
    result+=((BCD>>8)&0x0f)*100;
    result+=((BCD>>4)&0x0f)*10;
    result+=((BCD)&0x0f);
    return result;
}

void rtc_init( void )
{
    TICNT   = 0x0;
    RTCALM  = 0x0;
    RTCRST  = 0x0;
        
    RTCCON  |= (1<<0);
    
    BCDYEAR = 0x13;
    BCDMON  = 0x01;
    BCDDAY  = 0x01;
    BCDDATE = 0x02;
    BCDHOUR = 0x00;
    BCDMIN  = 0x00;
    BCDSEC  = 0x00;

    ALMYEAR = 0x00;
    ALMMON  = 0x00;
    ALMDAY  = 0x00;
    ALMHOUR = 0x00;
    ALMMIN  = 0x00;
    ALMSEC  = 0x00;

    RTCCON &= 0x0;
}

void rtc_puttime( rtc_time_t *rtc_time )
{
    RTCCON |= 0x1;

    BCDYEAR = ((rtc_time->year / 10) << 4) | (rtc_time->year % 10);
    BCDMON  = ((rtc_time->mon / 10) << 4) | (rtc_time->mon % 10);
    BCDDAY  = ((rtc_time->mday / 10) << 4) | (rtc_time->mday % 10);
    BCDDATE = ((rtc_time->wday / 10) << 4) | (rtc_time->wday % 10);
    BCDHOUR = ((rtc_time->hour / 10) << 4) | (rtc_time->hour % 10);
    BCDMIN  = ((rtc_time->min / 10) << 4) | (rtc_time->min % 10);
    BCDSEC  = ((rtc_time->sec / 10) << 4) | (rtc_time->sec % 10);
        
    RTCCON &= 0x0;
}

void rtc_gettime( rtc_time_t *rtc_time )
{
    RTCCON |= 0x1;
    
    rtc_time->year = BCDtoI(BCDYEAR);
    rtc_time->mon  = BCDtoI(BCDMON);
    rtc_time->mday = BCDtoI(BCDDAY);
    rtc_time->wday = BCDtoI(BCDDATE);
    rtc_time->hour = BCDtoI(BCDHOUR);
    rtc_time->min  = BCDtoI(BCDMIN);
    rtc_time->sec  = BCDtoI(BCDSEC);
    if( ! rtc_time->sec ){
        rtc_time->year = BCDtoI(BCDYEAR);
        rtc_time->mon  = BCDtoI(BCDMON);
        rtc_time->mday = BCDtoI(BCDDAY);
        rtc_time->wday = BCDtoI(BCDDATE);
        rtc_time->hour = BCDtoI(BCDHOUR);
        rtc_time->min  = BCDtoI(BCDMIN);
        rtc_time->sec  = BCDtoI(BCDSEC);
    };

    RTCCON &= 0x0;
}


void rtc_open( void (*isr)(void), uint8 tick_count )
{
    pISR_TICK =  (uint32) isr;
    I_ISPC    |= BIT_TICK;
    INTMSK   &= ~(BIT_TICK | BIT_GLOBAL);
    TICNT     = ((1 << 7) | tick_count);
}

void rtc_close( void )
{
    TICNT     = 0x0;
    INTMSK   |= BIT_TICK;
    pISR_TICK = (uint32) isr_TICK_dummy;
}
