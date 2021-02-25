-- -----------------------------------------------------------------------------
-- Dada la tabla VENTAS(TPelicula, EntradasVendidas) vacia considera
-- la ejecucion de la siguiente lista de instrucciones SQLDeveloper
-- asumiendo que autocommit= off.

-- a) Describe que valor tiene EntradasVendidas para la fila
-- 'Blancanitos' exactamente en el momento indicado por cada
-- comentario -- paso N -- (aunque todavia no sea un valor
-- definitivo).

-- b) Indica con que instruccion empieza cada una de las transacciones
-- de la secuencia.

-- c) Se produce algun error? Si lo hay, indica en que instruccion y
-- por que.

-- d) Que tablas quedan al final de la ejecucion?
-- -----------------------------------------------------------------------------

savepoint paso_uno;  
INSERT INTO VENTAS  VALUES ('Blancanitos', 200);  -- b) Inicio de 1a transaccion. 

-- paso 1  -- a) fila 'Blancanitos' con valor 200.

savepoint paso_dos;
update VENTAS
 set EntradasVendidas = EntradasVendidas + 100
where TPelicula = 'Blancanitos';

-- paso 2  -- a) fila 'Blancanitos' con valor 300.

rollback to savepoint paso_dos;  

-- paso 3  -- a) fila 'Blancanitos' con valor 200.

update VENTAS
 set EntradasVendidas = EntradasVendidas + 200
where TPelicula = 'Blancanitos';

-- paso 4  -- a) fila 'Blancanitos' con valor 400.

rollback; 

-- paso 5  -- a) Deshace todos los cambios. No existe fila 'Blancanitos'
           -- (Fin de transaccion.  No hay transaccion activa).

INSERT INTO VENTAS  VALUES ('Blancanitos', 1000); -- b) Inicio 2a transaccion.

update VENTAS
 set EntradasVendidas = EntradasVendidas + 300
where TPelicula = 'Blancanitos';

-- paso 6  -- a) fila 'Blancanitos' con valor 1300.

savepoint paso_tres;
commit;
           -- (Fin de transaccion.  No hay transaccion activa).

-- paso 7  -- a) fila 'Blancanitos' con valor 1300.

create table superventas(Tpeli varchar(20), TotEntradas number(5));
   --  b) Inicio 3a transaccion, pero termina porque tiene 
   --  un commit implicito. Se queda sin transaccion activa.

Insert into superventas values('Enanieves', 100); --  b) Inicio 4a transaccion.

rollback to savepoint paso_tres;  
-- paso 8  -- a) fila 'Blancanitos' con valor 1300.
           -- c) Se produce error ORA-01086, no existe la transaccion 
           --    con ese save_point (y no cambia la transaccion).

select * from  SUPERVENTAS  where TPeli = 'Enanieves';    

rollback;
-- paso 9  -- a) fila 'Blancanitos' con valor 1300.
           -- Elimina los cambios DML desde el paso 7.
	   -- (Fin de transaccion.  No hay transaccion activa).
           -- d) Los rollback no eliminan ninguna tabla por ser DDL.
	   --    Permanecen ambas tablas: VENTAS y SUPERVENTAS.


