-- ----------------------------------------------------------------------
-- (1 punto) Dada la tabla Matricula(DNI, Asignatura, Creditos) vacia
-- considera la ejecucion de la siguiente lista de instrucciones
-- SQLDeveloper asumiendo que autocommit=off
-- 
-- a) Describe que valor tiene Creditos para la fila '23456789X'
-- exactamente en el momento indicado por cada comentario -- paso N --
-- (aunque todavia no sea un valor definitivo).
-- b) Indica con que instruccion empieza cada una de las transacciones
-- de la secuencia.
-- c) Se produce algun error? Si lo hay, indica en que instruccion y
-- por que.
-- d) Que tablas quedan al final de la ejecucion?
-- ----------------------------------------------------------------------


savepoint paso_uno; -- b) Inicio de la primera transaccion
INSERT INTO MATRICULA VALUES ('123456789X', 'BBDD', 6);
-- paso 1 --
-- a) 1 fila en la tabla MATRICULA con valores ('123456789X', 'BBDD', 6).
savepoint paso_dos;
update MATRICULA
set Creditos= Creditos+ 1
where DNI= '123456789X' and asignatura='BBDD';
-- paso 2 --
-- a) 1 fila en la tabla MATRICULA con valores ('123456789X', 'BBDD', 7).
rollback to savepoint paso_dos;
-- paso 3 --
-- a) 1 fila en la tabla MATRICULA con valores ('123456789X', 'BBDD', 6)
update MATRICULA
set Creditos= Creditos+ 2
where DNI= '123456789X' and asignatura='BBDD';

-- paso 4 --
-- a) 1 fila en la tabla MATRICULA con valores ('123456789X', 'BBDD',8)
rollback;

-- paso 5 --
-- a) 0 filas en la tabla MATRICULA.
-- b) Fin de transaccion. No hay transaccion activa.

INSERT INTO MATRICULA VALUES ('123456789X', 'BBDD', 12);
update MATRICULA
set Creditos= Creditos+ 3
where DNI= '123456789X' and asignatura='BBDD';
-- b) Inicio de la segunda transaccion.

-- paso 6 --
-- a) 1 fila en la tabla MATRICULA con valores ('123456789X', 'BBDD',15)

savepoint paso_tres;
commit;
-- paso 7 --
-- a) 1 fila en la tabla MATRICULA con valores ('123456789X', 'BBDD',15).
-- b) Fin de la segunda transaccion.

create table EXPEDIENTE(DNI varchar(20) PRIMARY KEY, MatriculaTotal number(5));
-- b) Inicio y fin de la tercera transaccion (DDL tiene commit implicito).

Insert into Expediente values('00000000P', 45);
-- b) Inicio de la cuarta transaccion.

rollback to savepoint paso_tres;

-- paso 8 --
-- a) 1 fila en la tabla MATRICULA con valores ('123456789X', 'BBDD',15).
-- c) Error: ORA-01086, no existe la transaccion con ese savepoint.
-- b) Se mantiene la cuarta transaccion.

select * from Expediente where DNI = '00000000P';

rollback;

-- paso 9 --
-- a) 1 fila en la tabla MATRICULA con valores ('123456789X', 'BBDD',15).
-- a) 0 filas en la tabla EXPEDIENTE.
-- b) fin de la cuarta transaccion.
-- d) Quedan las dos tablas MATRICULA y EXPEDIENTE. Rollback no deshace las instrucciones DDL.

