-- -------------------------------------------------------------------- 
-- (1,5 puntos) Crea un procedimiento almacenado que reciba por
-- argumento el DNI de un alumno y muestre todas las asignaturas en
-- las que esta matriculado el alumno (nombre, numero de creditos y
-- nota), el numero total de creditos matriculados y la nota media del
-- expediente de dicho alumno.  Para calcular la nota media se suman
-- la nota*numCreditosAsignatura de todas las asignaturas aprobadas
-- (nota >= 5) y se divide por el numero de creditos en los que esta
-- matriculado el alumno.  Si el alumno no esta matriculado en ninguna
-- asignatura se mostrara el siguiente mensaje 'El alumno xxx no se ha
-- matriculado de ninguna asignatura'.
-- -------------------------------------------------------------------- 

CREATE OR REPLACE PROCEDURE expedienteAlumno(p_DNIAlumno Alumno.DNI%TYPE) AS
  CURSOR cAsignaturas IS
    SELECT A.Nombre, A.NumCreditos, M.Nota
    FROM Asignatura A 
    JOIN Matricula M ON A.Codigo = M.CodAsignatura
    WHERE M.DNIAlumno = p_DNIAlumno;
  numCreditos NUMBER(6,2);
  notaTotal NUMBER(6,2);
  lAsignaturas cAsignaturas%ROWTYPE;
BEGIN
  OPEN cAsignaturas;
  FETCH cAsignaturas INTO lAsignaturas;
  IF cAsignaturas%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('El alumno ' || p_DNIAlumno ||
      'no se ha matriculado de ninguna asignatura');
  ELSE
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' Asignatura                     NumCr  Nota');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');

    notaTotal := 0;
    numCreditos := 0;
    WHILE cAsignaturas %found LOOP
      DBMS_OUTPUT.PUT_LINE(
      	RPAD(lAsignaturas.Nombre,30) || ' ' ||
        TO_CHAR(lAsignaturas.NumCreditos,'9999') || ' ' ||
        TO_CHAR(lAsignaturas.Nota,'99.99'));

      numCreditos := numCreditos + lAsignaturas.NumCreditos;
      IF (lAsignaturas.Nota >= 5) THEN
        notaTotal := notaTotal +
          (lAsignaturas.NumCreditos * lAsignaturas.Nota);
      END IF;
      FETCH cAsignaturas INTO lAsignaturas;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Creditos Total: ' || numCreditos ||
      '         NotaMedia: ' || notaTotal/numCreditos);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  END IF;
  CLOSE cAsignaturas;
END;
/

-- Bloque anonimo para probar el procedimiento.
SET SERVEROUTPUT ON;
BEGIN
  expedienteAlumno('123456787X');
END;
/

