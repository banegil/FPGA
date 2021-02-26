#include <s3c44b0x.h>
#include <uart.h>

void uart0_init( void )
{
    UFCON0 = 0x1;
    UMCON0 = 0x0;
    ULCON0 = 0x3;
    UBRDIV0 = 0x22;
    UCON0 = 0x5;
}

void uart0_putchar( char ch )
{
    while( UFSTAT0 & (1<<9) ); // leemos del bit 9 full
    UTXH0 = ch;
}        

char uart0_getchar( void )
{
    while( (UFSTAT0 & 0xf) == 0 ); // leemos del URx fifo
    return URXH0;
}

void uart0_puts( char *s )
{
	while( *s  ) uart0_putchar( *s++ );
}

void uart0_putint( int32 i )
{
	int8 num = 1;
	if(i < 0) {
		num = -1;
		i *= -1;
	}

    char buf[8 + 1];
    char *p = buf + 8;
    int8 c;

    *p = '\0';

    do {
        c = i % 10;
        *--p = '0' + c;
        i /= 10;
    } while( i > 0 );

    if(num == -1) *--p = '-';

    uart0_puts( p );
}

void uart0_puthex( uint32 i )
{
    char buf[8 + 1];
    char *p = buf + 8;
    uint8 c;

    *p = '\0';

    do {
        c = i & 0xf;
        if( c < 10 )
            *--p = '0' + c;
        else
            *--p = 'a' + c - 10;
        i = i >> 4;
    } while( i );

    uart0_puts( p );
}

void uart0_gets( char *s )
{
	int i = 0;
	while( (s[i] = uart0_getchar( )) != '\n' ) i++;
	s[i] = '\0';
}

int32 uart0_getint( void )
{
	int32 num = 0;
	char n = uart0_getchar( );
	int8 neg = 1;

	while( n != '\n' ) {
		if(n == '-') neg = -1;
		else {
			num *= 10;
			num += (n - '0');
		}
		n = uart0_getchar( );
	}
	return num * neg;
}

uint32 uart0_gethex( void )
{
	uint32 num = 0;
	char n = uart0_getchar( );

	while( n != '\n' ) {
		num *= 16;
		if(n - '0' < 10) num += (n - '0');
		else num += ((n - 'A') + 10);
		n = uart0_getchar( );
	}
	return num;
}
