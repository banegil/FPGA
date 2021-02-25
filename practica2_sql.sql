SET SERVEROUTPUT ON SIZE 1000000;

CREATE OR REPLACE PROCEDURE pr_empleados_tlf(p_tlf teléfonos.teléfono%TYPE) AS    
        CURSOR c_tlf IS
            SELECT nombre, dni, teléfono
            FROM teléfonos NATURAL JOIN empleados
            WHERE  p_tlf = teléfono;

        v_tlf c_tlf%ROWTYPE;
        e_multiple EXCEPTION;
        e_ninguno EXCEPTION;
        v_cont INTEGER;
        
BEGIN
    v_cont := 0;
    FOR ROW IN c_tlf LOOP 
        v_cont := v_cont + 1; 
    END LOOP; 
    
    OPEN c_tlf;
    FETCH c_tlf INTO v_tlf;
    IF v_cont = 0 THEN
        RAISE   e_ninguno;
    ELSIF v_cont > 1 THEN
        RAISE   e_multiple;
    ELSE
        DBMS_OUTPUT.PUT_LINE('El empleado con el teléfono ' || p_tlf || ' es: '
        || v_tlf.nombre || ', con DNI: ' || v_tlf.dni || '.');
    END IF;
    CLOSE c_tlf;

EXCEPTION
    WHEN e_ninguno THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el empleado con el teléfono ' ||
        p_tlf || '.');
        CLOSE c_tlf;
        
    WHEN e_multiple THEN
        DBMS_OUTPUT.PUT_LINE('Hay más de un empleado con el teléfono ' ||
        p_tlf || '.');
        CLOSE c_tlf;
END;

/

CREATE OR REPLACE PROCEDURE pr_comprobar_poblaciones AS
    excepcion EXCEPTION;
    v_poblacion "Códigos postales".población%TYPE;

    CURSOR c_cursor IS
        SELECT población
        FROM (SELECT DISTINCT población, provincia
            FROM "Códigos postales")
        GROUP BY población
        HAVING COUNT (población) > 1;
BEGIN
    OPEN c_cursor;
    LOOP
        FETCH c_cursor INTO v_poblacion;
        EXIT WHEN c_cursor%NOTFOUND;
        RAISE excepcion;
    END LOOP;
    CLOSE c_cursor;
    DBMS_OUTPUT.PUT_LINE('No hay dos o mas provincias que compartan la misma poblacion');

    EXCEPTION
        WHEN excepcion THEN
            DBMS_OUTPUT.PUT_LINE('A la poblacion Arganda no le corresponde siempre la misma provincia.');
            CLOSE c_cursor;
END;

/

CREATE OR REPLACE PROCEDURE pr_empleados_CP AS    
    CURSOR c_emp(p_codigos domicilios."Código postal"%TYPE) IS
        SELECT nombre, calle, sueldo
        FROM empleados NATURAL JOIN domicilios
        WHERE "Código postal" = p_codigos;

    CURSOR c_codigos IS
        SELECT "Código postal",
            COUNT(*) AS empleados,
            AVG(sueldo) AS sueldoMedio
        FROM empleados NATURAL JOIN domicilios
        GROUP BY "Código postal"
        ORDER BY "Código postal";
        
    v_codigos c_codigos%ROWTYPE;
    v_emp c_emp%ROWTYPE;
    v_cont INTEGER := 0;
    excepcion EXCEPTION;
        
BEGIN
    OPEN c_codigos;
    LOOP 
        FETCH c_codigos INTO v_codigos;
        IF c_codigos%ROWCOUNT = 0 THEN
            RAISE excepcion;
        ELSE
            EXIT WHEN c_codigos%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('Código postal: ' || v_codigos."Código postal");
            OPEN c_emp(v_codigos."Código postal");
            LOOP
                FETCH c_emp INTO v_emp;
                EXIT WHEN c_emp%NOTFOUND;
                DBMS_OUTPUT.PUT_LINE(v_emp.nombre || ', ' || v_emp.calle || ', ' || v_emp.sueldo);
                v_cont := v_cont + 1;
            END LOOP;
            CLOSE c_emp;
            DBMS_OUTPUT.PUT_LINE('Nº empleados: ' || v_codigos.empleados || ', Sueldo medio: ' || v_codigos.sueldoMedio);
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total empleados: ' || v_cont);
    CLOSE c_codigos;
    
    EXCEPTION
        WHEN excepcion THEN
            DBMS_OUTPUT.PUT_LINE('No hay datos');
            CLOSE c_codigos;
END;

/
        
EXECUTE pr_empleados_tlf(913333333);
EXECUTE pr_empleados_tlf(913333333);
EXECUTE pr_empleados_tlf(913333333);

EXECUTE pr_comprobar_poblaciones;
INSERT INTO "Códigos postales"("Código postal", población, provincia) 
VALUES ('41008','Arganda','Sevilla');
EXECUTE pr_comprobar_poblaciones;
DELETE FROM "Códigos postales" WHERE "Código postal"= '41008';

EXECUTE pr_empleados_CP;

