alter session set nls_date_format = "DD/MM/YYYY HH24:MI";

-- a. (3 puntos) Escribe las siguientes consultas en lenguaje SQL:
-- (0,5 puntos) Mostrar el DNI de los alumnos (sin repeticiones) de
-- mas de 30 anios matriculados en una asignatura de 6 creditos.

SELECT DISTINCT A.DNI
FROM (Matricula M JOIN Alumno A ON M.DNIAlumno=A.DNI) JOIN Asignatura S
ON M.CodAsignatura = S.Codigo
WHERE A.Edad > 30
AND S.NumCreditos = 6;

-- (0,5 puntos) Mostrar el nombre de las asignaturas de 12 creditos
-- con mas de 300 alumnos.  
-- (se ha modificado la consulta para mostrar las asignaturas con 
-- mas de 3 alumnos para poder probar con pocos datos).

SELECT A.Nombre
FROM Matricula M JOIN Asignatura A ON M.CodAsignatura = A.Codigo
WHERE A.NumCreditos = 12
GROUP BY A.Nombre
HAVING COUNT(*) > 3;

-- (0,5 puntos) Mostrar para todos los alumnos el nombre y el numero
-- de asignaturas en las que esta matriculado. Si algun alumno no esta
-- matriculado en ninguna asignatura se debe de mostrar un 0.

SELECT A.Nombre, NVL(NumAsig,0)
FROM Alumno A LEFT OUTER JOIN (
     SELECT M.DNIAlumno, COUNT(*) as NumAsig
     FROM Matricula M
     GROUP BY M.DNIAlumno
) ON A.DNI = DNIAlumno;

-- Esta consulta tambien se puede resolver sin reuniones externas
-- mediante UNION ALL:

SELECT A.Nombre, count(*) as NumAsig
FROM Matricula M JOIN Alumno A ON M.DNIAlumno = A.DNI
GROUP BY A.Nombre
UNION ALL
SELECT A.Nombre, 0 as NumAsig
FROM Alumno A
WHERE A.DNI NOT IN (SELECT M2.DNIAlumno FROM Matricula M2);


-- (0,75 puntos) Mostrar el DNI de los alumnos que solo tienen
-- asignaturas matriculadas de 6 creditos.

SELECT DISTINCT Ma.DNIALUMNO
FROM Matricula Ma
WHERE NOT EXISTS (
      SELECT *
      FROM Matricula M JOIN Asignatura A ON M.CodAsignatura=A.Codigo
      WHERE M.DNIAlumno = Ma.DNIAlumno
      AND A.NumCreditos <> 6);

-- (0,75 puntos) Mostrar el nombre del alumno de mayor edad
-- matriculado en la asignatura de codigo 123.

SELECT A.nombre
FROM Alumno A JOIN Matricula M ON A.DNI = M.DNIALUMNO
WHERE M.CodAsignatura = '123'
AND A.Edad >= ALL (SELECT A2.Edad 
    	      	   FROM Alumno A2 JOIN Matricula M ON A2.DNI = M.DNIALUMNO
		   WHERE M.CodAsignatura = '123');

-- Tambien se puede hacer la subconsulta con una funcion de agregacion:

SELECT A.nombre
FROM Alumno A JOIN Matricula M ON A.DNI = M.DNIALUMNO
WHERE M.CodAsignatura = '123'
AND A.Edad = (SELECT MAX(A2.Edad)
    	     FROM Alumno A2 JOIN Matricula M2 ON A2.DNI = M2.DNIALUMNO
	     WHERE M2.CodAsignatura = '123');



