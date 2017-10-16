create database ventas1
ON 
primary
	(name = ventas1primary,
	filename = 'c:\SQL_DB_Pruebas\ventas1primary.mdf',
	size = 50MB,
	Maxsize = 200,
	filegrowth = 20),
filegroup ventas1FG
	(name = ventas1Data1,
	filename = 'c:\SQL_DB_Pruebas\ventas1Data.ndf',
	size = 200MB,
	Maxsize = 800,
	filegrowth = 100)
Log on
	(name = ventas1log,
	filename = 'c:\SQL_DB_Pruebas\ventas1log.ldf',
	size = 300MB,
	Maxsize = 800,
	filegrowth = 20)

--drop database ventas1

use ventas1
-- crear tabla --

create table producto(
	id int not null,
	nombreproducto nvarchar(40),
	Precio nvarchar(100),
	descripcion nvarchar(200))

drop table producto

-- Alterar una tabla --

alter table producto
add
precio int not null

alter table producto
drop column precio

alter table producto
alter column descripcion nvarchar(150)

-- Primary key --

create table producto(
	id int primary key not null,
	nombreproducto nvarchar(40),
	descripcion nvarchar(200))

-- SELECT y Vista de una tabla --

SELECT id, nombre, telefono FROM dbo.Clientes

SELECT * FROM dbo.Clientes

SELECT id AS [ID de cliente], nombre AS [Nombre de cliente], telefono AS [Telefono de cliente]
FROM Clientes
ORDER BY [ID de cliente] DESC

SELECT id, nombreproducto, descripcion
FROM producto
ORDER BY descripcion DESC, id DESC

SELECT id, nombreproducto, Precio
FROM producto
WHERE (Precio >= N'200') AND (Precio <= N'500')
ORDER BY Precio DESC, id DESC

-- Insert --

insert into producto (id,nombreproducto,Precio) values (9,'producto9','600')
insert into producto values (10,'producto10','700')

select * from producto

-- Actualizar datos UPDATE --

update producto set descripcion = 'Producto nuevo'

update producto set nombreproducto = 'automovil', precio = '900', descripcion = 'Auto nuevo'
where id = 1

-- Eliminar datos DELETE --

delete from producto

Bulk
Insert producto
from 'C:\Respaldo_Pruebas_SQL\productos.csv'
with (firstrow=2,fieldterminator=',',rowterminator='\n')

delete from producto where id = 12

-- TOP --

select top(5) * from producto

select top(50)percent * from producto

-- BETWEEN --

select * from producto where (id between 6 and 8)

-- LIKE --

select * from producto where nombreproducto like 'auto%'

select * from producto where nombreproducto like '%uto%'

-- IN --

select * from producto where (nombreproducto IN ('automovil','producto4','producto3'))

-- Consulta Multiple --

select * from Clientes where (nombre like '%os%') or (apellido like '%Cruces%')

-- Foreign Key --

create table infocliente (
id_cliente int foreign key (id_cliente)
references Clientes (id),
direccion nvarchar(50),
cedula int not null)

select * from infocliente

insert into infocliente
values (2,'Edo. Mex.',3895428)

-- Inner Join --

select * from Clientes T3
inner join infocliente T4
on T3.id = T4.id_cliente

-- LEFT, RIGHT, FULL JOIN -- 

select * from Clientes T3
left join infocliente T4
on T3.id = T4.id_cliente

select * from Clientes T3
right join infocliente T4
on T3.id = T4.id_cliente

select * from Clientes T3
full join infocliente T4
on T3.id = T4.id_cliente

-- Union --

create table Clientes2(
	id int not null,
	nombre nvarchar(50),
	telefono int,
	apellido nvarchar(50))

select * from Clientes
UNION
select * from Clientes2

-- AVG Promedio --

SELECT AVG(total) AS Promedio
FROM Ventas

-- SUMA --

SELECT SUM(total) AS [Total de Ventas]
FROM Ventas
WHERE (año = 2017) AND (mes = 1 OR mes = 3)

--MAX y MIN --

select max(total) as [Total máximo]
from Ventas

select min(total) as [Total mínimo]
from Ventas

-- Primero y Ultimo --

select top(1) * from Ventas

select top(1) * from Ventas
order by año, mes, dia desc

-- Count --

select count(id) as [Total de ventas]from Ventas
where mes = 3


use Ventas1

--________Diccionario de datos de una base de datos en Sql server___________

--Un diccionario de datos es un conjunto de metadatos que contiene las
--características lógicas y puntuales de los datos que se van a utilizar 
--en el sistema que se programa, incluyendo nombre, descripción, alias, contenido
-- y organización.

select 
	d.object_id,
	a.name [table], -- identificara la Tabla
	b.name [column], -- identificara la columna
	c.name [type], -- identificara el Tipo
	CASE-- recibe el tipo de columna
	  --cuando c es   numerico  o   c es     decimal   o  c es      Float   entonces se precisa el numero
		WHEN c.name = 'numeric' OR  c.name = 'decimal' OR c.name = 'float'  THEN b.precision
		ELSE null
	END [Precision], 
--  recibe maximo tamaño de b
	b.max_length, 
	CASE -- recibe si la columna acepta nulos
		WHEN b.is_nullable = 0 THEN 'NO'
		ELSE 'SI'
	END [Permite Nulls],
	CASE -- recibe si la columna es identity (autoincrementable)
		WHEN b.is_identity = 0 THEN 'NO'
		ELSE 'SI'
	END [Es Autonumerico],	
	ep.value [Descripcion],-- recibe la descripcion de la columna(si la hay)
	f.ForeignKey, -- recibe si es llave foranea
	f.ReferenceTableName, -- recibe la referencia de la tabla
	f.ReferenceColumnName -- recibe la referencia de la columna
from sys.tables a   
      --          //    Seleciona y muestra toda la informacion   \\          --
	inner join sys.columns b on a.object_id= b.object_id 
	inner join sys.systypes c on b.system_type_id= c.xtype 
	inner join sys.objects d on a.object_id= d.object_id 
	LEFT JOIN sys.extended_properties ep ON d.object_id = ep.major_id AND b.column_Id = ep.minor_id
	LEFT JOIN (SELECT 
				f.name AS ForeignKey,
				OBJECT_NAME(f.parent_object_id) AS TableName,
				COL_NAME(fc.parent_object_id,fc.parent_column_id) AS ColumnName,
				OBJECT_NAME (f.referenced_object_id) AS ReferenceTableName,
				COL_NAME(fc.referenced_object_id,fc.referenced_column_id) AS ReferenceColumnName
				FROM sys.foreign_keys AS f
				INNER JOIN sys.foreign_key_columns AS fc ON f.OBJECT_ID = fc.constraint_object_id) 	f ON f.TableName =a.name AND f.ColumnName =b.name
WHERE a.name <> 'sysdiagrams' 
ORDER BY a.name,b.column_Id

--Stored Procedures -- procedimientos almacenados

create procedure sp_consulta @nombre nvarchar(20), @telefono int
as
begin

select * from Clientes
where nombre = @nombre and telefono = @telefono;

print 'Hecho correctamente';

end

exec sp_consulta 'Oscar',26515118

-- Identity --

create table pruebaidentity (
	id int primary key identity(20,5) not null,
	nombre nvarchar(50))

insert into pruebaidentity
values('Jose')

select * from pruebaidentity

-- Drop y Truncate --

delete from prueba2 -- No formatea la tabla

insert into prueba2 values ('Edgar')

truncate table prueba2 -- Formatea la tabla, reinicia identity

select * from prueba2

drop table prueba2

--Mayusculas y minusculas (upper y Lower)--

create table palabras(
	palabar1 nvarchar(20) not null,
	palabra2 nvarchar(20) not null)

insert into palabras values ('hola', 'MUNDO')

select upper(palabar1) as MAYUSCULAS, lower(palabra2) as minusculas from palabras

-- TSQL (Transact-SQL)--
-- Variables --

declare @texto nvarchar(20)
set @texto = 'hola mundo'
declare @numero int
set @numero = 35

print 'T-SQL dice: ' + @texto + ' y el número ' + convert(nvarchar(20),@numero)

-- T-SQL combinado con SQL --

declare @textos nvarchar(20)
declare @edad int
--set @textos = 'dd'

--create table tsql(
--	nombre nvarchar(20),
--	edad int)

--insert into tsql values ('luis',22)
select @textos = nombre, @edad = edad from tsql where edad = 22

print @textos + ' ' +convert(nvarchar(15), @edad)

-- Operadores  + - * / %(mod)--

declare @num1 int
declare @num2 int

set @num1 = 10
set @num2 = 3

print @num1 / @num2
print @num1 % @num2

-- While --

declare @cont int
set @cont = 0

	while (@cont <=10)
	begin
		print 'hola,soy el número: ' +  convert(nvarchar(20),@cont)
		set @cont = @cont + 1
	end

-- Case (switch) TSQL--

declare @avion nvarchar(40)
declare @estado nvarchar(40)
declare @aviso nvarchar(40)

set @avion = 'Condor'
set @estado = 'Volando'

set @aviso = (case @estado
	when 'volando' then 'El avión: ' + @avion + ' esta volando'
	when 'detenido' then 'El avión: ' + @avion + ' esta detenido'
	when 'cargando' then 'El avión: ' + @avion + ' esta cargando'
end
)

-- Cursor --

declare Cursorejemplo Cursor scroll
for select * from Clientes

open Cursorejemplo
fetch next from Cursorejemplo
fetch prior from Cursorejemplo
fetch last from Cursorejemplo
fetch first from Cursorejemplo

close Cursorejemplo
deallocate Cursorejemplo

-- Ejemplo Cursor --

declare @nombreC nvarchar(50)
declare @telefonoC int
declare @apellidoC nvarchar(50)

declare Cursorejemplo Cursor scroll
for select nombre,telefono,apellido from Clientes

open Cursorejemplo
fetch next from Cursorejemplo  into @nombreC,@telefonoC,@apellidoC

while (@@FETCH_STATUS = 0)
begin
	--print @nombreC + ' ' + @apellidoC + ' ' + cast(@telefonoC as nvarchar(50))
	insert into ClientesInsertCursor values (@nombreC,@apellidoC,@telefonoC) 
	fetch next from Cursorejemplo into @nombreC,@telefonoC,@apellidoC
end

close Cursorejemplo
deallocate Cursorejemplo

-- Triggers (disparadores) --

create trigger tr_clientes_insert_insteadof
on Clientes
--for | after | instead of insert | update | delete
instead of insert
as
print 'Istead of: no hubo cambios';

insert into Clientes values (12,'Enrrique',15489632,'Cruz')

-- Ejemplo trigger insertar el log (historial) --

create trigger tr_clientes_insert_for
	on Clientes
	for insert
	as
	begin
		set nocount on -- Evita mostrar cambios en una tabla --
		insert into log_historial(
		nombre,fecha,descripcion) select nombre,GETDATE(),'Se insertaron datos en la tabla'
		from inserted
	end

insert into Clientes values (13,'Eduardo',51698542,'Soto')

