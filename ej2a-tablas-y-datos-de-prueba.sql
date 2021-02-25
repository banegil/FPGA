-- -----------------------------------------------------
-- SOLUCIONES DEL EJERCICIO 2. TABLAS Y DATOS DE PRUEBA.
-- -----------------------------------------------------

-- Creación de tablas
DROP TABLE matricula;
DROP TABLE alumno;
DROP TABLE asignatura;

CREATE TABLE asignatura (
  codigo NUMBER PRIMARY KEY,
  nombre VARCHAR2(50),
  numCreditos NUMBER(3)
);

CREATE TABLE alumno (
  DNI VARCHAR2(10) PRIMARY KEY,
  nombre VARCHAR2(50),
  edad NUMBER(3),
  numCredAprobados NUMBER(3)
);

CREATE TABLE matricula (
  DNIalumno VARCHAR2(10) REFERENCES alumno,
  codAsignatura NUMBER REFERENCES asignatura,
  nota NUMBER(4,2)
);

-- Casos de prueba.  
INSERT INTO asignatura VALUES (1, 'Fundamentos de la Programación', 12);
INSERT INTO asignatura VALUES (2, 'Estructuras de Datos y Algoritmos', 9);
INSERT INTO asignatura VALUES (3, 'Bases de Datos', 6);
INSERT INTO asignatura VALUES (4, 'Tecnología de la Programación', 12);
INSERT INTO asignatura VALUES (5, 'MTP', 12);
INSERT INTO asignatura VALUES (123, 'Administración de Bases de Datos', 6);

INSERT INTO alumno VALUES ('123456789X', 'Manuela Malasaña', 22, 85);
INSERT INTO alumno VALUES ('123456788X', 'Alonso Martínez', 24, 144);
INSERT INTO alumno VALUES ('123456787X', 'Eugenia de Montijo', 33, 77);
INSERT INTO alumno VALUES ('123456786X', 'Concha Espina', 25, 234);
INSERT INTO alumno VALUES ('123456785X', 'Núñez de Balboa', 22, 64);
INSERT INTO alumno VALUES ('123456784X', 'Antón Martín', 35, 64);
INSERT INTO alumno VALUES ('123456783X', 'Arturo Soria', 27, 88);

INSERT INTO matricula VALUES ('123456787X', 5, 7.8);
INSERT INTO matricula VALUES ('123456787X', 3, 8.9);
INSERT INTO matricula VALUES ('123456786X', 5, 6.4);
INSERT INTO matricula VALUES ('123456788X', 5, 4.3);
INSERT INTO matricula VALUES ('123456785X', 5, 3.7);
INSERT INTO matricula VALUES ('123456789X', 3, 5.9);
INSERT INTO matricula VALUES ('123456784X', 123, 6.7);
INSERT INTO matricula VALUES ('123456787X', 123, 7.8);

commit;
