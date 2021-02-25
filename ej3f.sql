
-- f. (1,5 puntos) Crea un procedimiento almacenado que reciba como
-- parametro el identificador de un empleado y actualice su salario
-- anual, siguiendo estas condiciones: por cada acreditacion que tenga
-- el empleado de un tren cuya autonomia es de mas de 600 km le
-- corresponden 40 euros/plaza; si es entre 400 y 600 km, son 20
-- euros/plaza; y si es hasta 400 son 10 euros/plaza. Asi que, para
-- calcular la cantidad a asignar por tren, se multiplican los
-- euros/plaza por el total de plazas. Solo se cuentan los trenes de
-- mas de 200 plazas.  El procedimiento debe listar por consola cada
-- acreditacion con el codigo de tren, su autonomia, numero de plazas
-- y la cantidad de euros total que corresponde como salario para ese
-- tren. Debe estar ordenado por autonomia de forma descendente. Para
-- terminar, se lista el identificador del empleado y el salario total
-- obtenido. Si no existe el empleado se da un mensaje indicandolo y,
-- si hay cualquier otro error, se emite un mensaje diciendo que ese
-- identificador de empleado ha fallado.


CREATE OR REPLACE PROCEDURE recalcularSalario(p_eid IN empleado.eid%TYPE) IS
  CURSOR cr_acr IS
    SELECT t.tid, t.nombre, t.autonomia, t.numPlazas 
    FROM tren t
    JOIN acreditacion a ON t.tid = a.tid
    WHERE a.eid = p_eid AND t.numPlazas > 200
    ORDER BY t.autonomia DESC;
  v_incrSalario empleado.salario%TYPE := 0;
  v_NuevoSalario empleado.salario%TYPE := 0;
  v_nombre empleado.nombre%TYPE;
BEGIN
  -- Consulta para comprobar que existe el empleado.  Si no existe, NO_DATA_FOUND
  SELECT nombre INTO v_nombre FROM empleado e WHERE e.eid = p_eid;
  
  DBMS_OUTPUT.PUT_LINE('Incremento salarial del empleado: ' || TO_CHAR(p_eid));
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
  FOR r_acr IN cr_acr LOOP
    v_incrSalario := CASE 
      WHEN r_acr.autonomia < 400 THEN 10 * r_acr.numPlazas
      WHEN r_acr.autonomia >= 400 AND r_acr.autonomia < 600 THEN 20 * r_acr.numPlazas
      WHEN r_acr.autonomia >= 600 THEN 40 * r_acr.numPlazas
      END;
    DBMS_OUTPUT.PUT_LINE('  ' || TO_CHAR(r_acr.tid,'99999') ||
    			 '  ' || RPAD(r_acr.nombre,25) ||
    			 '  ' || TO_CHAR(r_acr.autonomia,'9G999') ||
    			 '  ' || TO_CHAR(r_acr.numPlazas,'9G999') ||
    			 '  ' || TO_CHAR(v_incrSalario,'999G999D99'));
    v_NuevoSalario := v_NuevoSalario + v_incrSalario;
  END LOOP;
  
  UPDATE empleado 
  SET salario = v_NuevoSalario
  WHERE eid = p_eid;
  
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
  DBMS_OUTPUT.PUT_LINE(' Nuevo salario de empleado: ' || p_eid ||
  		       ' : ' || TO_CHAR(v_NuevoSalario, '9G999G999D99'));
  DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No existe el empleado con eid: ' || TO_CHAR(p_eid));
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('HA FALLADO LA ACTUALIZACION DEL EMPLEADO: ' || TO_CHAR(p_eid));
END;
/

-- Bloque anonimo para probar el procedimiento.

SET SERVEROUTPUT ON;
BEGIN
  recalcularSalario(201);
  recalcularSalario(222);
END;
/

