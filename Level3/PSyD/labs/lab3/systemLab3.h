/*-------------------------------------------------------------------
**
**  Fichero:
**    systemLab3.h  19/3/2014
**
**    (c) J.M. Mendias
**    Programaci�n de Sistemas y Dispositivos
**    Facultad de Inform�tica. Universidad Complutense de Madrid
**
**  Prop�sito:
**    Contiene las definiciones de los prototipos de las funciones
**    para la inicializaci�n del sistema
**
**  Notas de dise�o:
**    Versi�n reducida orientada al desarrollo del lab3
**
**-----------------------------------------------------------------*/

#ifndef __SYSTEM_H__
#define __SYSTEM_H__

/*
**  Inicializa el sistema (versi�n lab3)
**    Configura los puertos de E/S
*/

#define USRMODE (0x10)

#define SET_OPMODE( mode ) \
asm volatile ( "mrs r0, cpsr" : : : "r0" ); \
asm volatile ( "bic r0, r0, #0x1f" ); \
asm volatile ( "orr r0, r0, %0" : : "i" (mode) ); \
asm volatile ( "msr cpsr_c, r0" );

void sys_init( void );

#endif
