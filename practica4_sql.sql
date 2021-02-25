
alter session set nls_date_format = 'DD/MM/YYYY';

-- a. Escribe una consulta en lenguaje SQL que muestre el nombre de
-- los autores de noticias publicadas el 1/06/2018 con más de 1000
-- visitas, así como el nombre de los periodicos en los que han
-- publicado las noticias.

SELECT DISTINCT a.nombre, p.nombre
FROM autor a
JOIN noticia n ON a.aid = n.aid
JOIN periodico p ON n.pid = p.pid
WHERE n.fecha = TO_DATE('01/06/2018') AND numVisitas > 1000;

-- b. Escribe una consulta en lenguaje SQL que muestre, para cada
-- autor que haya publicado más de dos noticias en un mismo día, su
-- nombre y el número total de visitas recibidas por esas noticias.

SELECT a.nombre, sum(numVisitas)
FROM autor a
JOIN noticia n ON a.aid = n.aid
GROUP BY a.aid, a.nombre, n.fecha -- Fecha no puede contener información de la hora.
HAVING count(*) > 2;

-- c. Escribe una consulta en lenguaje SQL que muestre el nombre de
-- todos los autores y el nombre de los periódicos donde han publicado
-- noticias. Si un autor no ha publicado en ningún periódico, debe
-- mostrar el texto '(ninguno)' en la columna del nombre del
-- periódico.

SELECT DISTINCT a.nombre, NVL(p.nombre,'(ninguno)')
FROM autor a
LEFT JOIN (noticia n JOIN periodico p ON n.pid = p.pid)
ON a.aid = n.aid;

    
-- d. Escribe una consulta en lenguaje SQL que muestre las fechas
-- en las que todos los medios han publicado alguna noticia, junto
-- con el número de noticias que se han publicado en esa fecha
-- y el número total de visitas recibidas.

SELECT n.fecha, count(*), sum(n.numVisitas)
FROM noticia n
GROUP BY n.fecha
HAVING NOT EXISTS
  (SELECT p.pid
  FROM periodico p
  WHERE p.pid NOT IN
    (SELECT p2.pid
    FROM periodico p2
    JOIN noticia n2 ON p2.pid = n2.pid
    WHERE n2.fecha = n.fecha));

-- Solución alternativa:

SELECT n.fecha, count(*), sum(n.numVisitas)
FROM noticia n
GROUP BY n.fecha
HAVING count(distinct pid) = (select count(*) from periodico);

-- e. Escribe una consulta en lenguaje SQL que muestre el nombre de los
-- autores que no han publicado noticias en ningún periódico en el
-- que haya publicado el autor 'Pedro Santillana'.

SELECT a.nombre 
FROM autor a
WHERE a.aid NOT IN 
  (SELECT n.aid
  FROM noticia n
  WHERE n.pid IN 
    (SELECT n2.pid
    FROM noticia n2
    JOIN autor a2 ON n2.aid = a2.aid
    WHERE a2.nombre = 'Pedro Santillana'));

-- Solución alternativa:

SELECT a.nombre FROM autor a WHERE NOT EXISTS
  (SELECT n.pid FROM noticia n WHERE n.aid = a.aid
    intersect
    SELECT n2.pid FROM noticia n2 JOIN autor a2 ON n2.aid = a2.aid
      WHERE a2.nombre = 'Pedro Santillana');

-- f. Crea un procedimiento almacenado llamado noticiasAutor que
-- reciba como parámetro el id de un autor (idAutor) y muestre por
-- pantalla sus datos personales (aid, nombre y sección), junto con un
-- listado con las noticias (titular y fecha) que ha publicado
-- ordenadas crecientemente por fecha. En caso de error (el id del
-- autor no existe o no hay noticias para ese autor), deberá mostrarse
-- por pantalla un mensaje de advertencia explicando el tipo de error
-- (el autor no existe o no tiene noticias publicadas). Al finalizar
-- el listado se deberá mostrar la suma de las visitas de todas las
-- noticias del cliente.

CREATE OR REPLACE PROCEDURE noticiasAutor(p_aid autor.aid%TYPE) AS
  CURSOR c_noticias IS
    SELECT a.titular, a.fecha, a.numVisitas
    FROM noticia a
    WHERE a.aid = p_aid
    ORDER BY a.fecha ASC;
  v_totalVisitas NUMBER := 0;
  v_nombre autor.nombre%TYPE;
  v_noticia c_noticias%ROWTYPE;
BEGIN
  -- Comprueba si existe el autor.
  SELECT nombre INTO v_nombre FROM autor WHERE aid = p_aid;
  OPEN c_noticias;
  FETCH c_noticias INTO v_noticia;
  -- Comprueba si tiene alguna noticia (tb. se puede hacer con
  -- un bucle FOR .. LOOP de cursor y una variable contador).
  IF c_noticias%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Author ' || p_aid ||
      ' has not published any noticia');
  ELSE
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE(' Fecha       Visit Titular ');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    WHILE c_noticias%found LOOP
      DBMS_OUTPUT.PUT_LINE(TO_CHAR(v_noticia.fecha,'DD-MM-YYYY') || '  ' ||
        TO_CHAR(v_noticia.numVisitas,'9G999') || ' ' ||
        v_noticia.titular);

      v_totalVisitas := v_totalVisitas + v_noticia.numVisitas;
      FETCH c_noticias INTO v_noticia;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total:      ' || TO_CHAR(v_totalVisitas,'9G999'));
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
  END IF;
  CLOSE c_noticias;
END;
/

-- Bloque anonimo para probar el procedimiento.
SET SERVEROUTPUT ON;
BEGIN
  noticiasAutor(204);
END;
/


-- g. Viendo los logs de accesos a nuestra base de datos hemos visto
-- que el número de visitas por autor es algo muy demandado por lo que
-- hemos decidido añadir una nueva columna a la tabla autor que guarde
-- el número de visitas de todos los artículos escritos por cada
-- autor. Para que nuestra base de datos recoja esta nueva información
-- necesitamos que hagas lo siguiente:
-- 
-- - Modificar la tabla autor para añadir una nueva columna llamada numVisitas.
-- 
-- - Crear un disparador que, cada vez que en la tabla noticias se
--   inserte una noticia o se actualice el número de visitas de una
--   noticia, se cambie automáticamente el número de visitas del autor
--   de la noticia en la tabla autor.

ALTER TABLE autor ADD (numVisitas INTEGER DEFAULT 0);
-- (actualizamos la tabla con el valor correcto de numero de visitas
-- para que sea consistente cuando se hagan inserciones o modificaciones). 
UPDATE autor a 
SET numVisitas = (SELECT NVL(SUM(numVisitas),0) FROM noticia na WHERE na.aid = a.aid);


create or replace TRIGGER ActualizaNumVisitasAutor
AFTER INSERT OR UPDATE OF numVisitas ON noticia
FOR EACH ROW
DECLARE
BEGIN
  IF INSERTING THEN
    UPDATE autor
    SET numVisitas = numVisitas + :NEW.numVisitas
    WHERE aid = :NEW.aid;
  ELSIF UPDATING THEN
    UPDATE autor
    SET numVisitas = numVisitas - :OLD.numVisitas + :NEW.numVisitas
    WHERE aid = :NEW.aid;
  END IF;
END;
/

-- Debemos probar este trigger con sentencias INSERT y UPDATE.
SELECT * FROM autor;

INSERT INTO noticia VALUES (109, 'noticia 109',
       	    	    	   'noticia 109...',
			   'http://www.gacetaguadalajara.es/deportes33',
			   3,204, TO_DATE('10/01/2019'), 44);

UPDATE noticia SET numVisitas = 37 WHERE nid = 109;



