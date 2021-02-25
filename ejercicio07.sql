/multiline on
/type_casting off
/date_format YYYY-MM-DD
-- /display_answer on

SELECT 0 FROM dual;

SELECT sqrt(2) FROM dual;

SELECT current_time FROM dual;

WITH naturales(N) AS (
  SELECT 0 FROM dual )
SELECT * FROM naturales;

-- La siguiente consulta debe ciclar:
-- WITH naturales(N) AS (
--   SELECT 0 FROM dual
--   UNION
--   SELECT N+1 FROM naturales )
-- SELECT * FROM naturales;

-- Control de la terminación con TOP y WHERE:
WITH naturales(N) AS (
  SELECT 0 FROM dual
  UNION
  SELECT N+1 FROM naturales )
SELECT TOP 10 N FROM naturales;

WITH naturales(N) AS (
  SELECT 0 FROM dual
  UNION
  SELECT N+1 FROM naturales WHERE N < 10 )
SELECT N FROM naturales;

CREATE VIEW números_naturales AS
  WITH naturales(N) AS (
    SELECT 0 FROM dual
    UNION
    SELECT N+1 FROM naturales )
SELECT N FROM naturales;

SELECT TOP 5 N FROM números_naturales;

SELECT TOP 20 N FROM números_naturales WHERE N MOD 2 = 0;

WITH
   RECURSIVE naturales(N) AS (
     SELECT 0 FROM dual
     UNION
     SELECT N+1 FROM naturales WHERE N < 10 )
SELECT N FROM naturales;

WITH
  naturales(N) AS (
    SELECT 0 FROM dual
    UNION ALL
    SELECT N+1 FROM naturales WHERE N < 10 )
SELECT N FROM naturales;

-- Ejercicio R1
WITH impares(N) AS (
  SELECT 1 FROM dual
  UNION
  SELECT N+2 FROM impares WHERE N < 19)
SELECT N FROM impares;

CREATE VIEW números_impares AS
WITH impares(N) AS (
  SELECT 1 FROM dual
  UNION
  SELECT N+2 FROM impares)
SELECT TOP 15 N FROM impares;

SELECT TOP 15 N FROM números_impares;

-- Ejemplo Greatest Hits

CREATE TABLE hits (
  theme varchar(50) NOT NULL,
  copies int NOT NULL,
  PRIMARY KEY (theme, copies));

INSERT INTO hits (theme, copies) VALUES
  ('I Will Always Love You', 20),
  ('If I Didn''t Care', 19),
  ('In the Summertime', 31),
  ('It''s Now or Never', 20),
  ('My Heart will Go On', 25),
  ('Rock Around the Clock', 25),
  ('Silent Night', 30),
  ('We Are the World', 20),
  ('White Christmas', 50);

WITH 
  rec(ranking, copies, theme) AS (
    SELECT 1, copies, theme FROM hits 
    UNION  
    SELECT ranking+1, hits.copies, hits.theme
    FROM hits, rec 
    WHERE hits.copies < rec.copies )
SELECT *
FROM rec;

WITH 
  rec(ranking, copies, theme) AS (
    SELECT 1, copies, theme FROM hits 
    UNION  
    SELECT ranking+1, hits.copies, hits.theme
    FROM hits, rec 
    WHERE hits.copies < rec.copies )
SELECT ranking, MAX(copies)
FROM rec
GROUP BY ranking;

WITH 
  rec(ranking, copies) AS (
    SELECT 1, copies FROM hits 
    UNION  
    SELECT ranking+1, hits.copies
    FROM hits, rec 
    WHERE hits.copies < rec.copies ),
  ranks(ranking, copies) AS (
    SELECT ranking, MAX(copies)
    FROM rec
    GROUP BY ranking )
SELECT ranking, copies, theme
FROM hits NATURAL JOIN ranks
ORDER BY ranking, copies, theme;

-- Ejercicio R2
WITH 
  rec(ranking, copies, theme) AS (
    SELECT 1, copies, theme FROM hits 
    UNION  
    SELECT ranking+1, hits.copies, hits.theme
    FROM hits, rec 
    WHERE hits.copies < rec.copies )  
SELECT ranking, hits.copies, theme
FROM hits,
  (SELECT ranking AS ranking, MAX(copies) AS copies
    FROM rec
    GROUP BY ranking) ranks
WHERE hits.copies=ranks.copies
ORDER BY ranking, hits.copies, theme;

-- Lo siguiente daba error (ya está corregido en la nueva versión):
WITH 
  rec(ranking, copies, theme) AS (
    SELECT 1, copies, theme FROM hits 
    UNION  
    SELECT ranking+1, hits.copies, hits.theme
    FROM hits, rec 
    WHERE hits.copies < rec.copies )  
SELECT ranking, hits.copies, theme
FROM hits NATURAL JOIN
  (SELECT ranking AS ranking, MAX(copies) AS copies
    FROM rec
    GROUP BY ranking) AS ranks
ORDER BY ranking, copies, theme;


-- Ejercicio R3
-- /type_casting off, con on da error (!)
WITH 
  REC(RANKING, BONUS) AS (
    SELECT 1, BONUS FROM EMPLOYEE 
    UNION  
    SELECT RANKING+1, EMPLOYEE.BONUS
    FROM EMPLOYEE, REC 
    WHERE EMPLOYEE.BONUS < REC.BONUS )  
SELECT TOP 10 RANKING AS RANKING, BONUS AS BONUS, FIRSTNAME+' '+LASTNAME AS NAME
FROM EMPLOYEE,
  (SELECT RANKING AS RANKING, MAX(BONUS) AS MAXBONUS
    FROM REC
    GROUP BY RANKING) RANKS
WHERE BONUS=MAXBONUS
ORDER BY RANKING, EMPLOYEE.BONUS, LASTNAME;

-- Ejemplo jerarquías
CREATE TABLE jefes(
  empleado STRING PRIMARY KEY,
  jefe STRING REFERENCES jefes(empleado));
  
INSERT INTO jefes VALUES 
  ('E1',NULL),
  ('E2','E1'),
  ('E3','E1'),
  ('E4','E2'),
  ('E5','E2'),
  ('E6','E2'),
  ('E7','E3'),
  ('E8','E3'),
  ('E9','E4'),
  ('E10','E4'),
  ('E11','E4'),
  ('E12','E6'),
  ('E13','E6'),
  ('E14','E6'),
  ('E15','E8'),
  ('E16','E8'),
  ('E17','E8'),
  ('E18','E8'),
  ('E19','E8');
  
WITH tiene_jefe(empleado, jefe) AS (
  SELECT empleado, jefe FROM jefes
  UNION    
  SELECT tiene_jefe.empleado, jefes.jefe
  FROM tiene_jefe JOIN jefes ON tiene_jefe.jefe = jefes.empleado
  WHERE jefes.jefe IS NOT NULL )
SELECT * FROM tiene_jefe;

WITH tiene_jefe(empleado, jefe, nivel) AS (
  SELECT empleado, jefe, 1 FROM jefes
  UNION    
  SELECT tiene_jefe.empleado, jefes.jefe, tiene_jefe.nivel+1
  FROM tiene_jefe JOIN jefes ON tiene_jefe.jefe = jefes.empleado
  WHERE jefes.jefe IS NOT NULL )
SELECT * FROM tiene_jefe;

-- Ejercicio R4
CREATE VIEW jefes_de(jefe, empleado) AS 
  WITH tiene_jefe(empleado, jefe) AS (
    SELECT empleado, jefe FROM jefes
    UNION    
    SELECT tiene_jefe.empleado, jefes.jefe
    FROM tiene_jefe JOIN jefes ON tiene_jefe.jefe = jefes.empleado
    WHERE jefes.jefe IS NOT NULL )
  SELECT jefe, empleado FROM tiene_jefe;

SELECT * FROM jefes_de WHERE empleado = 'E5';

-- Ejemplo Bill Of Materials
DROP TABLE PARTLIST;

CREATE TABLE PARTLIST (
  PART     CHAR(2) NOT NULL,
  SUBPART  CHAR(2) NOT NULL,
  QUANTITY INT,
  PRIMARY KEY (PART, SUBPART));
  
INSERT INTO PARTLIST VALUES
  ('00','01',5),
  ('00','05',3),
  ('01','02',2),
  ('01','03',3),
  ('01','04',4),
  ('01','06',3),
  ('02','05',7),
  ('02','06',6),
  ('03','07',6),
  ('04','08',10),
  ('04','09',11),
  ('05','10',10),
  ('05','11',10),
  ('06','12',10),
  ('06','13',10),
  ('07','12',8),
  ('07','14',8);

WITH RPL(PART, SUBPART, QUANTITY) AS (
  SELECT PART, SUBPART, QUANTITY 
  FROM PARTLIST
  WHERE PART = '01'
  
  UNION ALL
  
  SELECT PARENT.PART, CHILD.SUBPART, 
         CHILD.QUANTITY * PARENT.QUANTITY 
  FROM RPL AS PARENT, PARTLIST AS CHILD
  WHERE PARENT.SUBPART = CHILD.PART )

SELECT PART, SUBPART, SUM(QUANTITY) AS QUANTITY 
FROM RPL
GROUP BY PART, SUBPART;

-- Ejercicio R5

-- Ejemplo RPL con contro de recursión
WITH RPL(PART, SUBPART, QUANTITY, LEVEL) AS (
  SELECT PART, SUBPART, QUANTITY, 1
  FROM PARTLIST
  WHERE PART = '01'
  
  UNION ALL
  
  SELECT PARENT.PART, CHILD.SUBPART, 
         CHILD.QUANTITY * PARENT.QUANTITY, PARENT.LEVEL + 1 
  FROM RPL AS PARENT, PARTLIST AS CHILD
  WHERE PARENT.SUBPART = CHILD.PART AND LEVEL < 2 )

SELECT PART, SUBPART, SUM(QUANTITY) AS QUANTITY 
FROM RPL
GROUP BY PART, SUBPART;

-- Ejemplo de grafos
CREATE TABLE vías(
  origen STRING, 
  destino STRING,
  km INTEGER, 
  kph INTEGER,
  PRIMARY KEY(origen, destino)
);

INSERT INTO vías VALUES
  ('Madrid',      'Guadalajara',   50, 110), 
  ('Guadalajara', 'Zaragoza',     100, 120), 
  ('Madrid',      'Segovia',       70, 120), 
  ('Segovia',     'Valladolid',   100,  90), 
  ('Valladolid',  'Burgos',       120, 115), 
  ('Burgos',      'Vitoria',      100, 110), 
  ('Vitoria',     'Bilbao',        50,  90),
  ('Zaragoza',    'Logroño',      160, 100), 
  ('Logroño',     'Vitoria',       50,  85), 
  ('Logroño',     'Pamplona',      80,  75), 
  ('Pamplona',    'San Sebastián', 65,  80), 
  ('Bilbao',      'San Sebastián', 80,  75);

WITH conecta(origen, destino) AS (
   SELECT origen, destino 
   FROM vías
   UNION 
   SELECT conecta.origen, vías.destino
   FROM conecta JOIN vías ON conecta.destino=vías.origen )
SELECT * FROM conecta;

-- Ejercicio R6
CREATE VIEW rutas AS
WITH conecta(origen, destino) AS (
   SELECT origen, destino 
   FROM vías
   UNION 
   SELECT conecta.origen, vías.destino
   FROM conecta JOIN vías ON conecta.destino=vías.origen )
SELECT * FROM conecta;

SELECT * FROM rutas WHERE origen='Madrid' AND destino='San Sebastián';

SELECT * FROM rutas WHERE origen = 'San Sebastián' AND destino = 'Madrid';

CREATE OR REPLACE VIEW rutas AS
WITH conecta(origen, destino) AS (
   SELECT origen, destino 
   FROM vías
   UNION 
   SELECT conecta.origen, vías.destino
   FROM conecta JOIN vías ON conecta.destino=vías.origen )
SELECT origen, destino FROM conecta
UNION 
SELECT destino, origen FROM conecta;

SELECT * FROM rutas WHERE origen = 'San Sebastián' AND destino = 'Madrid';

-- Ejercicio R7
WITH conecta(origen, destino, km) AS (
   SELECT origen, destino, km
   FROM vías
   UNION 
   SELECT conecta.origen, vías.destino, conecta.km + vías.km
   FROM conecta JOIN vías ON conecta.destino=vías.origen )
SELECT origen, destino, km FROM conecta
UNION 
SELECT destino, origen, km FROM conecta;

-- Ejercicio R8
WITH conecta(origen, destino, horas) AS (
   SELECT origen, destino, km/kph
   FROM vías
   UNION 
   SELECT conecta.origen, vías.destino, conecta.horas + vías.km/vías.kph
   FROM conecta JOIN vías ON conecta.destino=vías.origen )
SELECT origen, destino, ROUND(horas,2) FROM conecta
UNION 
SELECT destino, origen, ROUND(horas,2) FROM conecta;

SELECT MIN(horas) AS horas 
FROM (
  WITH conecta(origen, destino, horas) AS (
     SELECT origen, destino, km/kph
     FROM vías
     UNION 
     SELECT conecta.origen, vías.destino, conecta.horas + vías.km/vías.kph
     FROM conecta JOIN vías ON conecta.destino=vías.origen )
  SELECT origen, destino, ROUND(horas,2) AS horas FROM conecta
  UNION 
  SELECT destino, origen, ROUND(horas,2) AS horas FROM conecta )
WHERE origen='Madrid' AND destino='San Sebastián';


/open_db db2

DROP TABLE vías;

CREATE TABLE vías(origen CHAR(1), destino CHAR(1));

INSERT INTO vías VALUES
  ('a','b'),
  ('b','c'),
  ('b','a');

-- Esta consulta cicla y hay que reiniciar la consola
WITH conecta(origen, destino) AS (
   SELECT origen, destino 
   FROM vías
   UNION 
   SELECT conecta.origen, vías.destino
   FROM conecta, vías WHERE conecta.destino=vías.origen )
SELECT origen, destino FROM conecta;

/close_db db2
