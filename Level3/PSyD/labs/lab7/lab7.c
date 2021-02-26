/*-------------------------------------------------------------------
**
**  Fichero:
**    lab7.c  5/3/2015
**
**    (c) J.M. Mendias
**    Programaci�n de Sistemas y Dispositivos
**    Facultad de Inform�tica. Universidad Complutense de Madrid
**
**  Prop�sito:
**    Test del laboratorio 7
**
**  Notas de dise�o:
**
**-----------------------------------------------------------------*/

#include <s3c44b0x.h>
#include <common_types.h>
#include <system.h>
#include <lcd.h>

/*
** Direcciones en donde se encuentran cargados los BMP tras la ejecucion en
** la consola del depurador los comandos:
**   cd <ruta>
**   source load_bmp.txt
*/

#define ARBOL      ((uint8 *)0x0c210000)
#define PADRINO    ((uint8 *)0x0c220000)
#define PICACHU    ((uint8 *)0x0c230000)
#define HARRY      ((uint8 *)0x0c240000)
#define CHAPLIN    ((uint8 *)0x0c250000)
#define PULP       ((uint8 *)0x0c260000)
#define MAPA       ((uint8 *)0x0c270000)

void delay( void );

void main( void )
{
    sys_init();
    lcd_init();
    
    lcd_clear();
    lcd_on();
    
    while( 1 )
    {
        /************************************/
        lcd_draw_box( 10, 10, 310, 230, BLACK, 5 );

        /************************************/
        lcd_puts( 20, 16, BLACK, "ABCDEFGHIJKLMN�OPQRSTUVWXYZ" );
        delay();
        lcd_puts( 20, 32, BLACK, "abcdefghijklmn�opqrstuvwxyz" );
        delay();
        lcd_puts( 20, 48, BLACK, "0123456789!$%&/()=^*+{}-.,;: " );
        delay();
        lcd_putint( 20, 64, BLACK, 1234567890 );
        delay();
        lcd_puthex( 130, 64, BLACK, 0xabcdef );

        /************************************/
        delay();
        lcd_puts_x2( 20, 80, BLACK, "ABCDEFGHIJKLMN�OP" );
        delay();
        lcd_puts_x2( 20, 112, BLACK, "abcdefghijklmn�op" );
        delay();
        lcd_puts_x2( 20, 144, BLACK, "0123456789!$%&/()" );
        delay();
        lcd_putint_x2( 20, 176, BLACK, 1234567890 );
        delay();
        lcd_puthex_x2( 196, 176, BLACK, 0xabcdef );

        /************************************/

        delay();
        lcd_putWallpaper( ARBOL );
        delay();
        lcd_putWallpaper( PADRINO );
        delay();
        lcd_putWallpaper( PICACHU );
        delay();
        lcd_putWallpaper( HARRY );
        delay();
        lcd_putWallpaper( CHAPLIN );
        delay();
        lcd_putWallpaper( PULP );
        delay();
        lcd_putWallpaper( MAPA );

        /************************************/

        delay();
        lcd_clear();
    }
}

void delay( void )
{
    register uint32 i;

    for( i=0; i<2000000; i++ );
}
