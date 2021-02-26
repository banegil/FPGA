/*-------------------------------------------------------------------
**
**  Fichero:
**    systemLab3.h  19/3/2014
**
**    (c) J.M. Mendias
**    Programación de Sistemas y Dispositivos
**    Facultad de Informática. Universidad Complutense de Madrid
**
**  Propósito:
**    Contiene las definiciones de los prototipos de las funciones
**    para la inicialización del sistema
**
**  Notas de diseño:
**    Versión reducida orientada al desarrollo del lab3
**
**-----------------------------------------------------------------*/

#ifndef __SYSTEM_H__
#define __SYSTEM_H__

/*
**  Inicializa el sistema (versión lab3)
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
