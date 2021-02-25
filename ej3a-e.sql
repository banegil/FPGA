
-- a. (0,5 puntos) Escribe una consulta en lenguaje SQL que muestre el
-- nombre de los trenes de mas de trescientos asientos que operan en
-- los trayectos con origen Madrid y destino Malaga.

SELECT t.nombre 
FROM tren t 
JOIN operacion o ON t.tid = o.tid
JOIN trayecto v ON o.vid = v.vid
WHERE t.numplazas > 300 AND v.origen = 'Madrid' AND v.destino = 'Malaga';

-- Sol. alternativa con NATURAL JOIN:

SELECT DISTINCT t.nombre 
FROM tren t 
NATURAL JOIN operacion o
NATURAL JOIN trayecto v
WHERE t.numplazas > 300 AND v.origen = 'Madrid' AND v.destino = 'Malaga';

-- b. (0,5 puntos) Escribe una consulta en lenguaje SQL que muestre
-- los trayectos (vid, origen y destino) con una distancia de mas de
-- 250 kilometros en los que se ofertan mas de 800 asientos en total
-- entre los distintos trenes.

SELECT v.vid, v.origen, v.destino
FROM trayecto v
JOIN operacion o ON v.vid = o.vid
JOIN tren t ON t.tid = o.tid
WHERE v.distancia > 250
GROUP BY v.vid, v.origen, v.destino
HAVING sum(t.numplazas) > 800;

-- c. (0,5 puntos) Escribe una consulta en lenguaje SQL que muestre
-- para todos los empleados el nombre y el numero de trayectos para
-- los que estan acreditados. Si un empleado no esta acreditado para
-- ningun trayecto, debe mostrar un 0.

SELECT e.nombre, NVL(t.numtrayectos, 0)
FROM empleado e
LEFT JOIN (SELECT a.eid, COUNT(DISTINCT o.vid) numtrayectos
      FROM acreditacion a
      JOIN operacion o ON a.tid = o.tid
      GROUP BY a.eid) t 
    ON e.eid = t.eid;
    
-- Sol. alternativa sin utilizar subconsulta en FROM:

SELECT e.nombre, NVL(Count(distinct o.vid), 0)
FROM Empleado e LEFT JOIN (Acreditacion a 
JOIN operacion o ON a.tid = o.tid) ON e.eid = a.eid
GROUP BY e.eid, e.nombre;

-- Sol. alternativa utilizando UNION pero sin utilizar LEFT JOIN:

SELECT e.nombre, Count(distinct o.vid)
FROM Empleado e JOIN Acreditacion a ON e.eid = a.eid
JOIN operacion o ON a.tid = o.tid 
GROUP BY e.eid, e.nombre
UNION
SELECT e.nombre, 0
FROM Empleado e 
WHERE eid NOT IN 
  (SELECT a2.eid FROM Acreditacion a2
    JOIN operacion o2 ON a2.tid = o2.tid);


-- d. (0,75 puntos) Escribe una consulta en lenguaje SQL que muestre
-- el origen y destino de los trayectos en los que todos los trenes
-- que operan son modelos 'Altaria' (es decir, que el nombre del tren
-- contenga esta cadena).

SELECT DISTINCT v.vid, v.origen, v.destino
FROM trayecto v
JOIN operacion o ON v.vid = o.vid
JOIN tren t ON o.tid = t.tid
WHERE t.nombre LIKE '%Altaria%'
AND v.vid NOT IN
    (SELECT v.vid
    FROM trayecto v
    JOIN operacion o ON v.vid = o.vid
    JOIN tren t ON o.tid = t.tid
    WHERE t.nombre NOT LIKE '%Altaria%');

-- Sol. alternativa utilizando MINUS:

(SELECT vid, origen, destino
FROM Trayecto
JOIN operacion USING (vid))
MINUS
(SELECT vid, origen, destino
FROM Tren JOIN Operacion USING (tid) JOIN Trayecto USING (vid)
WHERE nombre NOT LIKE '%Altaria%');

-- e. (0,75 puntos) Escribe una consulta en lenguaje SQL que muestre,
-- para cada trayecto operado por algun tren, el identificador del
-- trayecto, y el nombre del tren con mayor autonomia en ese trayecto.

SELECT o.vid, t.nombre
FROM operacion o JOIN tren t ON o.tid = t.tid
WHERE t.autonomia >= ALL (
      SELECT t2.autonomia
      FROM operacion o2 JOIN tren t2 ON o2.tid = t2.tid
      WHERE o.vid = o2.vid);

-- Sol. alternativa:
SELECT o.vid, t.nombre
FROM operacion o JOIN tren t ON o.tid = t.tid
WHERE t.autonomia = (
      SELECT MAX(t2.autonomia)
      FROM operacion o2 JOIN tren t2 ON o2.tid = t2.tid
      WHERE o.vid = o2.vid);

-- Otra sol. alternativa:

SELECT vid, nombre, maxAuto
FROM (SELECT vid, MAX(autonomia) maxAuto
      FROM Trayecto JOIN Operacion USING(vid)
      JOIN Tren USING(tid)
      GROUP BY vid) 
  JOIN Operacion USING (vid)
  JOIN Tren USING (tid)
WHERE maxAuto = autonomia;

