-- ---------------------------------------------
-- SOLUCIONES DEL EJERCICIO 3. TABLAS.
-- ---------------------------------------------

-- Creación de tablas
DROP TABLE compraEntradas;
DROP TABLE pases;
DROP TABLE salas;
DROP TABLE cine;
DROP TABLE pelicula;

CREATE TABLE cine (
  cod NUMBER PRIMARY KEY,
  distrito NUMBER(5)
);

CREATE TABLE salas (
  codCine NUMBER REFERENCES cine,
  numSala NUMBER(4),
  aforo NUMBER(4),
  PRIMARY KEY (codCine, numSala)
);

CREATE TABLE pelicula (
  TPelicula VARCHAR2(30) PRIMARY KEY,
  FechaEstreno DATE,
  Precio NUMBER(5,2),
  Duracion NUMBER(4)
);

CREATE TABLE pases (
  codCine NUMBER(4),
  numSala NUMBER(4),
  Hora DATE,
  TPelicula VARCHAR2(30) REFERENCES pelicula,
  entradasVendidas NUMBER(4),
  PRIMARY KEY (codCine, numSala, Hora),
  FOREIGN KEY (codCine, numSala) REFERENCES salas
);
  
CREATE TABLE compraEntradas (
  idCliente NUMBER(4),
  codCine NUMBER(4),
  numSala NUMBER(4),
  Hora DATE,
  TPelicula VARCHAR2(30) REFERENCES pelicula,
  numLocalidades NUMBER(4),
  PRIMARY KEY (idCliente, codCine, numSala, Hora),
  FOREIGN KEY (codCine, numSala, Hora) REFERENCES pases
);

-- Casos de prueba.  
INSERT INTO cine VALUES (1, 24321);
INSERT INTO cine VALUES (2, 24322);
INSERT INTO cine VALUES (3, 28040);
INSERT INTO cine VALUES (4, 28040);

INSERT INTO salas VALUES (1, 1, 125);
INSERT INTO salas VALUES (1, 2, 125);
INSERT INTO salas VALUES (2, 1, 45);
INSERT INTO salas VALUES (3, 1, 125);
INSERT INTO salas VALUES (3, 2, 125);
INSERT INTO salas VALUES (3, 3, 240);
INSERT INTO salas VALUES (4, 1, 250);
INSERT INTO salas VALUES (4, 2, 250);

alter session set nls_date_format = 'DD/MM/YYYY';
INSERT INTO pelicula VALUES ('El libro de la Selva', to_date('01/01/2014'), 6.80, 135);
INSERT INTO pelicula VALUES ('Lo que el viento se llevo', to_date('01/01/2016'), 6.80, 135);
INSERT INTO pelicula VALUES ('Tiempos Modernos', to_date('01/01/1936'), 9.00, 87);

alter session set nls_date_format = 'HH24:MI:SS';
INSERT INTO pases VALUES (1, 1, to_date('18:00:00'), 'Lo que el viento se llevo', 0);
INSERT INTO pases VALUES (1, 2, to_date('18:00:00'), 'El libro de la Selva', 4);
INSERT INTO pases VALUES (1, 2, to_date('21:00:00'), 'Tiempos Modernos', 4);
INSERT INTO pases VALUES (2, 1, to_date('18:00:00'), 'Lo que el viento se llevo', 16);
INSERT INTO pases VALUES (3, 1, to_date('18:00:00'), 'El libro de la Selva', 0);
INSERT INTO pases VALUES (3, 1, to_date('21:00:00'), 'Tiempos Modernos', 0);
INSERT INTO pases VALUES (3, 2, to_date('18:30:00'), 'Lo que el viento se llevo', 0);
INSERT INTO pases VALUES (3, 3, to_date('21:00:00'), 'El libro de la Selva', 23);
INSERT INTO pases VALUES (4, 1, to_date('18:00:00'), 'El libro de la Selva', 2);
INSERT INTO pases VALUES (4, 1, to_date('22:00:00'), 'Tiempos Modernos', 7);

commit;
