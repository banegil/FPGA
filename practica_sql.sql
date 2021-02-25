--Alberto Ba�egil Diaz

/abolish
/sql

create table programadores(dni VARCHAR2(9)  primary key, nombre VARCHAR2(50), direcci�n VARCHAR2(60), tel�fono VARCHAR2(10));
insert into programadores values('1','Jacinto','Jazm�n 4','91-8888888');
insert into programadores values('2','Herminia','Rosa 4','91-7777777');
insert into programadores values('3','Calixto','Clavel 3','91-1231231');
insert into programadores values('4','Teodora','Petunia 3','91-6666666');

create table analistas(dni VARCHAR2(9) primary key, nombre VARCHAR2(50), direcci�n VARCHAR2(60), tel�fono VARCHAR2(10));
insert into analistas values('4','Teodora','Petunia 3','91-6666666');
insert into analistas values('5','Evaristo','Luna 1','91-1111111');
insert into analistas values('6','Luciana','J�piter 2','91-8888888');
insert into analistas values('7','Nicodemo','Plut�n 3',NULL);

create table distribuci�n(c�digoPr CHAR(2), dniEmp VARCHAR2(9), horas int, primary key (c�digoPr, dniEmp));
insert into distribuci�n values('P1','1',10);
insert into distribuci�n values('P1','2',40);
insert into distribuci�n values('P1','4',5);
insert into distribuci�n values('P2','4',10);
insert into distribuci�n values('P3','1',10);
insert into distribuci�n values('P3','3',40);
insert into distribuci�n values('P3','4',5);
insert into distribuci�n values('P3','5',30);
insert into distribuci�n values('P4','4',20);
insert into distribuci�n values('P4','5',10);

create table proyectos(c�digo CHAR(2) primary key, descripci�n VARCHAR2(60), dniDir VARCHAR2(9));
insert into proyectos values('P1','N�mina','4');
insert into proyectos values('P2','Contabilidad','4');
insert into proyectos values('P3','Producci�n','5');
insert into proyectos values('P4','Clientes','5');
insert into proyectos values('P5','Ventas','6');


CREATE VIEW vista1 AS SELECT dni, nombre FROM programadores UNION SELECT dni, nombre FROM analistas;

CREATE VIEW vista2 AS SELECT p.dni FROM programadores p, analistas a WHERE
p.dni = a.dni;

CREATE VIEW vista3 AS SELECT dni, nombre FROM (SELECT dni, nombre, tel�fono FROM programadores UNION SELECT dni, nombre, tel�fono FROM analistas) WHERE tel�fono IS NULL;

create view vista4 as select v.dni from vista1 v left join proyectos p on v.dni = p.dniDir left join distribuci�n d on v.dni = d.dniEmp where d.dniEmp is null and p.dniDir is null;

create view vista5 as select c�digoPr from distribuci�n left join analistas on dniEmp = dni;

create view vista6 as select distinct a.dni from analistas a join proyectos p on a.dni = p.dniDir left join programadores pr on a.dni = pr.dni where pr.dni is null;

create view vista7 as select distinct p.descripci�n, pr.nombre, d.horas from proyectos p join programadores pr on p.dniDir = pr.dni join distribuci�n d on p.dniDir = d.dniEmp;

create view vista8 as select p.tel�fono from programadores p join analistas a on p.tel�fono = a.tel�fono where p.nombre != a.nombre;

create view vista9 as select v.dni, v.nombre, nvl(t.Htotales, 0) from vista1 v full join (select dniEmp, sum(horas) as Htotales from distribuci�n group by dniEmp) t on v.dni = t.dniEmp;

create view vista10 as select dni, nombre, c�digoPr from vista1 full join distribuci�n on dni = dniEmp;

--He hecho select de mas columnas para demostrarlo
create view vista11 as select emp.c�digoPr, emp.dniEmp as dniE, emp.horas as dniH, dir.dniEmp, dir.horas from (select dniEmp, c�digoPr, horas from distribuci�n left join proyectos on dniEmp = dniDir where dniDir is null) emp, (select dniEmp, c�digoPr, horas from distribuci�n, proyectos where dniEmp = dniDir) dir where emp.c�digoPr = dir.c�digoPr and emp.horas > dir.horas;

--La 12, 13 y 14 entendiendo que no trabajan como
--que no son ni directores ni estan asignados
create view vista12 as select dni, nombre from programadores left join distribuci�n on dni = dniEmp left join proyectos on dni = dniDir where dniEmp is null and dniDir is null union select dni, nombre from analistas left join distribuci�n on dni = dniEmp left join proyectos on dni = dniDir where dniEmp is null and dniDir is null;

create view vista13 as select * from vista1 where dni not in (select dniEmp from distribuci�n) and dni not in (select dniDir from proyectos);

create view vista14 as select * from vista1 v where not exists (select dniEmp from distribuci�n where dniEmp = v.dni) and not exists (select dniDir from proyectos where dniDir = v.dni);

create view vista15 as select descripci�n, trabajadores, horas from (select c�digoPr, count(*) as trabajadores, sum(horas) as horas from distribuci�n group by c�digoPr) full join proyectos on c�digoPr = c�digo;

create view vista16 as select descripci�n, trabajadores, horas from (select c�digoPr, count(*) as trabajadores, sum(horas) as horas from distribuci�n group by c�digoPr having count(*) > 1) left join proyectos on c�digoPr = c�digo;

create view vista17 as select nombre, c�digo from vista1, proyectos where dni = dniDir;

create view vista18 as select nombre from vista17 join (select c�digoPr from distribuci�n group by c�digoPr having count(*) > 2) on c�digoPr = c�digo;

create view vista19 as select c�digoPr from distribuci�n where horas = (select max(horas) from distribuci�n);

create view vista20 as select d1.dniEmp MaxHoras, d2.dniEmp MaxProyectos from (select top 1 dniEmp from distribuci�n group by dniEmp order by sum(horas) desc) d1, (select top 1 dniEmp from distribuci�n group by dniEmp order by count(*) desc) d2;

create view vista21 as select nombre from vista1 where dni = (select dniEmp from distribuci�n group by dniEmp having count(*) > 1);

select dni from vista1;
select * from vista2;
select * from vista3;
select * from vista4;
select * from vista5;
select * from vista6;
select * from vista7;
select * from vista8;
select * from vista9;
select * from vista10;
select dni from vista11;
select * from vista12;
select * from vista13;
select * from vista14;
select * from vista15;
select * from vista16;
select * from vista17;
select * from vista18;
select * from vista19;
select * from vista20;
select * from vista21;

