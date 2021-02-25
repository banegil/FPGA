
-- g. (1,5 puntos) Sin tener en cuenta el procedimiento anterior, se
-- pide hacer un disparador que actualice el salario de un empleado
-- automaticamente despues de crear una nueva acreditacion, subiendo
-- un 10% su salario. Si se elimina una acreditacion, se le baja un
-- 10% el salario y si se modifica una acreditacion, el salario
-- permanece sin modificaciones. En todos los casos solo se actua si
-- el tren correspondiente tiene una autonomia superior a 200 km.

CREATE OR REPLACE TRIGGER UPDSALARIO
AFTER INSERT OR DELETE ON ACREDITACION
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    UPDATE empleado SET salario = salario * 1.1
    WHERE eid = :NEW.eid AND :NEW.tid IN (
      SELECT tid FROM tren WHERE autonomia > 200);
  ELSIF DELETING THEN
    UPDATE empleado SET salario = salario * 0.9
    WHERE eid = :OLD.eid AND :OLD.tid IN (
      SELECT tid FROM tren WHERE autonomia > 200);
  END IF;
END;
/

-- Instrucciones para probar el trigger.

select * from empleado where eid = 201;
INSERT INTO acreditacion VALUES (201,106);
select * from empleado where eid = 201;
DELETE FROM acreditacion WHERE eid = 201 AND tid = 106;
select * from empleado where eid = 201;


