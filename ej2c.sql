-- --------------------------------------------------------------------
-- (1,5 puntos) Escribe un disparador que mantenga el numero de
-- creditos aprobados de la tabla Alumno actualizado. Es decir, cada
-- vez que se modifique una nota de la tabla Matricula se comprobara
-- si la nota es igual o superior a 5 y si lo es se actualizaran los
-- creditos aprobados del alumno.
-- --------------------------------------------------------------------

create or replace TRIGGER creditosAprobados
AFTER INSERT OR DELETE OR UPDATE OF Nota ON Matricula
FOR EACH ROW
DECLARE
  CodAsig Matricula.CodAsignatura%TYPE; -- Asignatura a considerar
  DNIAl Matricula.DNIAlumno%TYPE;       -- DNI del alumno
  NumCred Asignatura.NumCreditos%TYPE;  -- Num creditos a sumar/restar
  Operacion INTEGER := 0; -- Operacion a realizar: 1=suma; -1=resta; 0=no modificar
BEGIN
  IF INSERTING OR UPDATING THEN
    DNIAl := :NEW.DNIAlumno;
    CodAsig := :NEW.CodAsignatura;
    IF INSERTING AND (:NEW.Nota >= 5)
      OR UPDATING AND (:NEW.Nota >= 5 AND :OLD.Nota < 5) THEN
      Operacion := 1;
    ELSIF UPDATING AND (:NEW.Nota < 5 AND :OLD.Nota >= 5) THEN
      Operacion := -1;
    END IF;
  ELSIF DELETING THEN
    DNIAl := :OLD.DNIAlumno;
    CodAsig := :OLD.CodAsignatura;
    Operacion := -1;
  END IF;

  IF Operacion != 0 THEN
    SELECT NumCreditos
    INTO NumCred
    FROM Asignatura
    WHERE Codigo = CodAsig;

    UPDATE Alumno
    SET NumCredAprobados = NumCredAprobados + Operacion*NumCred
    WHERE DNI = DNIAl;
  END IF;
END;
/

-- Para probar el trigger consultamos un alumno y modificamos la
-- la matricula de un alumno con distintas operaciones consultando 
-- despues de cada una de ellas los datos del alumno.

SELECT * FROM Alumno WHERE DNI = '123456785X';

UPDATE Matricula SET Nota = 6.5 WHERE DNIAlumno = '123456785X' AND CodAsignatura = 5;
INSERT INTO matricula VALUES ('123456785X', 123, 8);
DELETE FROM matricula WHERE DNIAlumno = '123456785X' AND CodAsignatura = 123;



