
-- Ejercicio 3. Tablas y datos de prueba.
-- -------------------------------------------------------------

drop table acreditacion cascade constraints;
drop table operacion cascade constraints;
drop table trayecto cascade constraints;
drop table tren cascade constraints;
drop table empleado cascade constraints;

create table trayecto(
    vid number(9,0) primary key,
    origen varchar2(40),
    destino varchar2(40),
    distancia number(6,0)
);

create table tren(
    tid number(9,0) primary key,
    nombre varchar2(30),
    numPlazas number(4,0),
    autonomia number(6,0) -- distancia maxima que puede recorrer.
);

create table empleado(
    eid number(9,0) primary key,
    nombre varchar2(30),
    salario number(10,2)
);

create table acreditacion(
    eid number(9,0),
    tid number(9,0),
    primary key(eid,tid),
    foreign key(eid) references empleado,
    foreign key(tid) references tren
);

create table operacion(
    tid number(9,0),
    vid number(9,0),
    primary key(tid,vid),
    foreign key(vid) references trayecto,
    foreign key(tid) references tren
);

INSERT INTO trayecto VALUES (1, 'Madrid', 'Malaga', 540);
INSERT INTO trayecto VALUES (2, 'Zaragoza', 'Barcelona', 320);
INSERT INTO trayecto VALUES (3, 'Alcala de Henares', 'Guadalajara', 27);

INSERT INTO tren VALUES (101, 'Altaria 2000', 450, 2500);
INSERT INTO tren VALUES (102, 'Altaria 2800', 275, 1550);
INSERT INTO tren VALUES (103, 'Alaris Max', 310, 880);
INSERT INTO tren VALUES (104, 'Talgo 2000', 660, 1400);
INSERT INTO tren VALUES (105, 'Ave serie 103', 460, 1200);
INSERT INTO tren VALUES (106, 'Serie 596 Tamagotchi', 890, 250);

INSERT INTO operacion VALUES (101, 1);
INSERT INTO operacion VALUES (102, 1);
INSERT INTO operacion VALUES (102, 2);
INSERT INTO operacion VALUES (103, 2);
INSERT INTO operacion VALUES (104, 2);
INSERT INTO operacion VALUES (105, 2);
INSERT INTO operacion VALUES (106, 3);
INSERT INTO operacion VALUES (101, 3);

insert into empleado values (201,'Margarita Sanchez', 23456);
insert into empleado values (202,'Angel Garcia', 77569);
insert into empleado values (203,'Pedro Santillana', 12345);
insert into empleado values (204,'Rosa Prieto', 48963);
insert into empleado values (205,'Ambrosio Perez', 12245);
insert into empleado values (206,'Lola Arribas', 24448 );

insert into acreditacion values (201,101);
insert into acreditacion values (201,102);
insert into acreditacion values (201,104);
insert into acreditacion values (201,105);
insert into acreditacion values (202,103);
insert into acreditacion values (202,104);
insert into acreditacion values (202,105);
insert into acreditacion values (203,101);
insert into acreditacion values (204,102);

commit;
