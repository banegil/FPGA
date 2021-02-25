DROP TABLE pedidos;
DROP TABLE contiene;
DROP TABLE auditoria;
DROP TABLE resumenClientes;

CREATE TABLE pedidos(
    código  CHAR(6) PRIMARY KEY,
    fecha CHAR(10),
    importe NUMBER(6,2),
    cliente CHAR(20),
    notas CHAR(1024));
    
CREATE TABLE contiene(
    pedido CHAR(6) NOT NULL,
    plato CHAR(20) NOT NULL,
    precio NUMBER(6,2),
    unidades NUMBER(2,0),
    PRIMARY KEY(pedido, plato)
    );
    
CREATE TABLE auditoria(
    operación CHAR(6),
    tabla CHAR(50),
    fecha CHAR(10),
    hora CHAR(8));

CREATE TABLE resumenClientes(
    cliente CHAR(20),
    numPedidos INTEGER,
    sumaImportes NUMBER(8,2)
    );
    
/

SET TIMING OFF;
--------------------------------------------------------------------------------
--Apartado 1. Disparador por tabla
--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trigger_pedidos
AFTER INSERT OR DELETE OR UPDATE ON pedidos
BEGIN
    IF INSERTING THEN
       INSERT INTO auditoria VALUES
       ('INSERT','pedidos',to_char(sysdate,'dd/mm/yyyy'),to_char(sysdate,'hh:mi:ss'));
    ELSIF DELETING THEN
        INSERT INTO auditoria VALUES
       ('DELETE','pedidos',to_char(sysdate,'dd/mm/yyyy'),to_char(sysdate,'hh:mi:ss'));
    ELSIF UPDATING THEN
        INSERT INTO auditoria VALUES
       ('UPDATE','pedidos',to_char(sysdate,'dd/mm/yyyy'),to_char(sysdate,'hh:mi:ss'));
    END IF; 
END;

/

ALTER TRIGGER trigger_pedidos DISABLE;
delete from pedidos;
delete from auditoria;
ALTER TRIGGER trigger_pedidos ENABLE;

INSERT INTO pedidos VALUES ('123', to_char(sysdate,'dd/mm/yyyy'), 24, 'Juan', 'Sin pepperoni');
SELECT * FROM pedidos;
SELECT * FROM auditoria;

UPDATE pedidos SET notas = 'Con peperonni' WHERE código = '123';
SELECT * FROM pedidos;
SELECT * FROM auditoria;

DELETE FROM pedidos WHERE código = '123';
SELECT * FROM pedidos;
SELECT * FROM auditoria;

ALTER TRIGGER trigger_pedidos DISABLE;

/

/*
RESULTADO Apartado 1. Disparador por tabla:

Trigger TRIGGER_PEDIDOS compilado
Trigger TRIGGER_PEDIDOS alterado.
2 filas eliminado
32 filas eliminado
Trigger TRIGGER_PEDIDOS alterado.
1 fila insertadas.


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
123    30/12/2020         24 Juan                 Sin pepperoni                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   


OPERAC TABLA                                              FECHA      HORA    
------ -------------------------------------------------- ---------- --------
INSERT pedidos                                            30/12/2020 02:36:23


1 fila actualizadas.


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
123    30/12/2020         24 Juan                 Con peperonni                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   


OPERAC TABLA                                              FECHA      HORA    
------ -------------------------------------------------- ---------- --------
INSERT pedidos                                            30/12/2020 02:36:23
UPDATE pedidos                                            30/12/2020 02:36:23


1 fila eliminado

no se ha seleccionado ninguna fila

OPERAC TABLA                                              FECHA      HORA    
------ -------------------------------------------------- ---------- --------
INSERT pedidos                                            30/12/2020 02:36:23
UPDATE pedidos                                            30/12/2020 02:36:23
DELETE pedidos                                            30/12/2020 02:36:23
*/

--------------------------------------------------------------------------------
--Apartado 2. Disparador por fila
--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trigger_contiene
AFTER INSERT OR DELETE OR UPDATE ON contiene
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE pedidos SET importe = importe + :NEW.precio * :NEW.unidades
        WHERE pedidos.código = :NEW.pedido;
    ELSIF UPDATING THEN
        IF :NEW.unidades - :OLD.unidades <> 0 THEN
            UPDATE pedidos SET importe = importe + :NEW.precio * (:NEW.unidades - :OLD.unidades)
            WHERE código = :NEW.pedido;
        ELSIF :NEW.precio - :OLD.precio <> 0 THEN
            UPDATE pedidos SET importe = importe + :NEW.unidades * (:NEW.precio - :OLD.precio)
            WHERE código = :NEW.pedido;
        END IF;
    ELSIF DELETING THEN
        UPDATE pedidos SET importe = importe - :OLD.precio * :OLD.unidades
        WHERE código = :OLD.pedido;
    END IF; 
END;

/

ALTER TRIGGER trigger_contiene DISABLE;
delete from contiene;
delete from pedidos;
ALTER TRIGGER trigger_contiene ENABLE;

/*Como el enunciado no dice que insertemos en el trigger, inserto en "pedidos" como si lo hiciese el trabajador.
Por otro lado el código de "contiene" debe ser el mismo para cada cliente, ya que puede haber dos clientes
que se llamen exactamente igual. En este caso, Juan decide comprar una Pizza 4Quesos y Barbacoa, y obviamente,
las dos pizzas llegarán a la misma casa, por lo tanto, es el mismo pedido, con el mismo código.
Si la primary key hubiese sido (cliente) lo habría implementado de otro modo.
*/

INSERT INTO pedidos VALUES ('123', to_char(sysdate,'dd/mm/yyyy'), 0, 'Juan', 'Con salsas');
INSERT INTO pedidos VALUES ('258', to_char(sysdate,'dd/mm/yyyy'), 0, 'Pedro', 'Sin bebidas');
--Inserto pedidos
INSERT INTO contiene VALUES ('123', 'Pizza 4Quesos', 12, 2);
INSERT INTO contiene VALUES ('123', 'Pizza Barbacoa', 10, 3);
INSERT INTO contiene VALUES ('258', 'Pizza Mediterránea', 9, 1);
SELECT * FROM pedidos;
SELECT * FROM contiene;

--Bajo el precio de la Pizza 4Quesos del pedido '123' de 12 a 8 por descuento
UPDATE contiene SET precio = 8 WHERE pedido = '123' AND plato = 'Pizza 4Quesos';
SELECT * FROM pedidos;
SELECT * FROM contiene;

--Cambio las unidades de Pizza 4Quesos de 2 a 4
UPDATE contiene SET unidades = 4 WHERE pedido = '123' AND plato = 'Pizza 4Quesos';
SELECT * FROM pedidos;
SELECT * FROM contiene;

--Elimino las 3 Pizzas Barbacoas del pedido '123'
DELETE FROM contiene WHERE pedido = '123' AND plato = 'Pizza Barbacoa';
SELECT * FROM pedidos;
SELECT * FROM contiene;

ALTER TRIGGER trigger_contiene DISABLE;
/

/*
RESULTADO Apartado 2. Disparador por fila:

Trigger TRIGGER_CONTIENE compilado
Trigger TRIGGER_CONTIENE alterado.
2 filas eliminado
2 filas eliminado
Trigger TRIGGER_CONTIENE alterado.
1 fila insertadas.
1 fila insertadas.
1 fila insertadas.
1 fila insertadas.
1 fila insertadas.


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
123    30/12/2020         54 Juan                 Con salsas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
258    30/12/2020          9 Pedro                Sin bebidas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     


PEDIDO PLATO                    PRECIO   UNIDADES
------ -------------------- ---------- ----------
123    Pizza 4Quesos                12          2
123    Pizza Barbacoa               10          3
258    Pizza Mediterránea            9          1


1 fila actualizadas.


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
123    30/12/2020         46 Juan                 Con salsas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
258    30/12/2020          9 Pedro                Sin bebidas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     


PEDIDO PLATO                    PRECIO   UNIDADES
------ -------------------- ---------- ----------
123    Pizza 4Quesos                 8          2
123    Pizza Barbacoa               10          3
258    Pizza Mediterránea            9          1


1 fila actualizadas.


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
123    30/12/2020         62 Juan                 Con salsas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
258    30/12/2020          9 Pedro                Sin bebidas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     


PEDIDO PLATO                    PRECIO   UNIDADES
------ -------------------- ---------- ----------
123    Pizza 4Quesos                 8          4
123    Pizza Barbacoa               10          3
258    Pizza Mediterránea            9          1


1 fila eliminado


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
123    30/12/2020         32 Juan                 Con salsas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
258    30/12/2020          9 Pedro                Sin bebidas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     


PEDIDO PLATO                    PRECIO   UNIDADES
------ -------------------- ---------- ----------
123    Pizza 4Quesos                 8          4
258    Pizza Mediterránea            9          1
*/

--------------------------------------------------------------------------------
--Apartado 3. Disparador en cadena
--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trigger_actualiza
AFTER INSERT OR DELETE OR UPDATE ON pedidos
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO resumenClientes VALUES
        (:NEW.cliente, (SELECT COUNT(*) FROM contiene WHERE pedido = :NEW.código), :NEW.importe);
    ELSIF UPDATING THEN
        UPDATE resumenClientes SET numPedidos = (SELECT COUNT(*) FROM contiene WHERE pedido = :NEW.código),
        sumaImportes = :NEW.importe WHERE :NEW.cliente = cliente;
    ELSIF DELETING THEN
        DELETE FROM resumenClientes WHERE :OLD.cliente = cliente;
    END IF; 
END;

/

ALTER TRIGGER trigger_actualiza DISABLE;
delete from contiene;
delete from pedidos;
delete from resumenClientes;
ALTER TRIGGER trigger_actualiza ENABLE;

--Inserto pedidos
INSERT INTO contiene VALUES ('123', 'Pizza 4Quesos', 12, 2);
INSERT INTO contiene VALUES ('123', 'Pizza Barbacoa', 10, 3);
INSERT INTO contiene VALUES ('258', 'Pizza Mediterránea', 9, 2);
INSERT INTO pedidos VALUES ('123', to_char(sysdate,'dd/mm/yyyy'), 54, 'Juan', 'Con salsas');
INSERT INTO pedidos VALUES ('258', to_char(sysdate,'dd/mm/yyyy'), 18, 'Pedro', 'Sin bebidas');

SELECT * FROM pedidos;
SELECT * FROM contiene;
SELECT * FROM resumenClientes;

--Modifico pedidos, quito el pedido de Piza 4Quesos de Juan
DELETE FROM contiene WHERE pedido = '123' AND plato = 'Pizza 4Quesos';
UPDATE pedidos SET importe = importe - 24 WHERE código = '123';

SELECT * FROM pedidos;
SELECT * FROM contiene;
SELECT * FROM resumenClientes;

--Elimino pedidos
DELETE FROM pedidos WHERE código = '123';
DELETE FROM contiene WHERE pedido = '123';

SELECT * FROM pedidos;
SELECT * FROM contiene;
SELECT * FROM resumenClientes;

/*
RESULTADO Apartado 3. Disparador en cadena:

Trigger TRIGGER_ACTUALIZA compilado
Trigger TRIGGER_ACTUALIZA alterado.
3 filas eliminado
2 filas eliminado
2 filas eliminado
Trigger TRIGGER_ACTUALIZA alterado.
1 fila insertadas.
1 fila insertadas.
1 fila insertadas.
1 fila insertadas.
1 fila insertadas.


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
123    30/12/2020         54 Juan                 Con salsas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
258    30/12/2020         18 Pedro                Sin bebidas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     


PEDIDO PLATO                    PRECIO   UNIDADES
------ -------------------- ---------- ----------
123    Pizza 4Quesos                12          2
123    Pizza Barbacoa               10          3
258    Pizza Mediterránea            9          2


CLIENTE              NUMPEDIDOS SUMAIMPORTES
-------------------- ---------- ------------
Juan                          2           54
Pedro                         1           18


1 fila eliminado
1 fila actualizadas.


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
123    30/12/2020         30 Juan                 Con salsas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
258    30/12/2020         18 Pedro                Sin bebidas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     


PEDIDO PLATO                    PRECIO   UNIDADES
------ -------------------- ---------- ----------
123    Pizza Barbacoa               10          3
258    Pizza Mediterránea            9          2


CLIENTE              NUMPEDIDOS SUMAIMPORTES
-------------------- ---------- ------------
Juan                          1           30
Pedro                         1           18


1 fila eliminado
1 fila eliminado


CÓDIGO FECHA         IMPORTE CLIENTE              NOTAS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
------ ---------- ---------- -------------------- -------------
258    30/12/2020         18 Pedro                Sin bebidas                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     


PEDIDO PLATO                    PRECIO   UNIDADES
------ -------------------- ---------- ----------
258    Pizza Mediterránea            9          2


CLIENTE              NUMPEDIDOS SUMAIMPORTES
-------------------- ---------- ------------
Pedro                         1           18
*/
