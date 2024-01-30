USE base;

-- Creamos la tabla donde se podran las novedades de ventas 
CREATE TABLE IF NOT EXISTS venta_novedades (
	IdVenta				INTEGER,
	Fecha				DATE NOT NULL,
	Fecha_Entrega 		DATE NOT NULL,
	IdCanal				INTEGER, 
	IdCliente			INTEGER, 
	IdSucursal			INTEGER,
	IdEmpleado			INTEGER,
	IdProducto			INTEGER,
	Precio				VARCHAR(30),
	Cantidad			VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Venta_Actualizado.csv' 
INTO TABLE `venta_novedades` 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY '' 
LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

SELECT * FROM venta_novedades ORDER BY Fecha DESC;

-- Creamos la tabla donde se podran las novedades de clientes 
CREATE TABLE IF NOT EXISTS cliente_novedades (
	ID					INTEGER,
	Provincia			VARCHAR(50),
	Nombre_y_Apellido	VARCHAR(80),
	Domicilio			VARCHAR(150),
	Telefono			VARCHAR(30),
	Edad				VARCHAR(5),
	Localidad			VARCHAR(80),
	X					VARCHAR(30),
	Y					VARCHAR(30),
    Fecha_Alta			DATE NOT NULL,
    Usuario_Alta		VARCHAR(20),
    Fecha_Ultima_Modificacion		DATE NOT NULL,
    Usuario_Ultima_Modificacion		VARCHAR(20),
    Marca_Baja			TINYINT,
	col10				VARCHAR(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Clientes_Actualizado.csv'
INTO TABLE cliente_novedades
CHARACTER SET latin1
FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT * FROM cliente_novedades Order by ID Desc;

/*Se procede primero, a actualizar el Maestro de Clientes, ya que, debido a que están creadas las restricciones,
no sería posible ingestar registros en la tabla venta que no estén presentes en la tabla cliente*/
        
ALTER TABLE cliente_novedades	ADD Latitud DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER Y, 
						ADD Longitud DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER Latitud;
                        
UPDATE cliente_novedades SET Y = '0' WHERE Y = '';
UPDATE cliente_novedades SET X = '0' WHERE X = '';

UPDATE cliente_novedades SET Latitud = REPLACE(Y,',','.');
UPDATE cliente_novedades SET Longitud = REPLACE(X,',','.'); -- da error por valores vacios 
SELECT * FROM cliente_novedades; -- vemos que no cargo ningun valor en longitud
SELECT ID, X FROM cliente_novedades WHERE X = ''; -- tiene valores en blanco con lo cual se van a reemplazar por 0.0 para no tener que eliminar la informacion 
UPDATE cliente_novedades SET X = '0.0' WHERE X = ''; -- reemplazamos valores en blanco por 0.0
UPDATE cliente_novedades SET Longitud = REPLACE(X,',','.'); -- volvemos a reemplazar los datos 

ALTER TABLE cliente_novedades DROP Y;
ALTER TABLE cliente_novedades DROP X;

ALTER TABLE cliente_novedades DROP col10;

UPDATE cliente_novedades SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE cliente_novedades SET Localidad = 'Sin Dato' WHERE TRIM(Localidad) = "" OR ISNULL(Localidad);
UPDATE cliente_novedades SET Nombre_y_Apellido = 'Sin Dato' WHERE TRIM(Nombre_y_Apellido) = "" OR ISNULL(Nombre_y_Apellido);
UPDATE cliente_novedades SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);

ALTER TABLE cliente_novedades ADD IdLocalidad INT NOT NULL DEFAULT '0' AFTER Localidad;

UPDATE cliente_novedades c JOIN aux_localidad a
	ON (c.Provincia = a.Provincia_Original AND c.Localidad = a.Localidad_Original)
SET c.IdLocalidad = a.IdLocalidad;

/*Se chequea que no haya localidades nuevas no detectadas, de ser así, debe ser dada de alta en las tablas respectivas*/
SELECT * FROM cliente_novedades WHERE IdLocalidad = 0; -- esta dando errores por como subio los datos ejemplo en vez de cordoba subio 'CÃ³rdoba' en algunos registros
-- procedemos a solucionarlo
UPDATE cliente_novedades SET Provincia = 'Cordoba' WHERE Provincia = 'CÃ³rdoba'; 
UPDATE cliente_novedades SET Provincia = 'Entre Rios' WHERE Provincia = 'Entre RÃ­os'; 
UPDATE cliente_novedades SET Provincia = 'Neuquen' WHERE Provincia = 'NeuquÃ©n'; 
UPDATE cliente_novedades SET Provincia = 'Tucuman' WHERE Provincia = 'TucumÃ¡n';
UPDATE cliente_novedades SET Provincia = 'Tucuman' WHERE Provincia = 'TucumÃ¡n'; -- con esto solucionamos 533 registros  
-- nos que dan las localidades que estan dando error 
UPDATE cliente_novedades SET Localidad = 'VILLA PORTEÑA' WHERE Localidad = 'VILLA PORTEÃ‘A'; 
UPDATE cliente_novedades SET Localidad = 'EL JAGÜEL' WHERE Localidad = 'EL JAGÃœEL'; 
UPDATE cliente_novedades SET Localidad = 'SAENZ PEÑA'  WHERE Localidad = 'SAENZ PEÃ‘A'; 
UPDATE cliente_novedades SET Localidad = 'CAÑUELAS'  WHERE Localidad = 'CAÃ‘UELAS';
UPDATE cliente_novedades SET Localidad = 'PIÑEYRO'  WHERE Localidad = 'PIÃ‘EYRO' ;
UPDATE cliente_novedades SET Localidad = 'MUÑIZ' WHERE Localidad = 'MUÃ‘IZ';
UPDATE cliente_novedades SET Localidad = 'LAS CAÑAS' WHERE Localidad = 'LAS CAÃ‘AS' ;
UPDATE cliente_novedades SET Localidad = 'CAÑADA DE ROCA' WHERE Localidad = 'CAÃ‘ADA DE ROCA' ;
UPDATE cliente_novedades SET Localidad = '2º SECCION DE ISLAS' WHERE Localidad = '2Âº SECCION DE ISLAS' ;
UPDATE cliente_novedades SET Localidad = '3º SECCION DE ISLAS' WHERE Localidad = '3Âº SECCION DE ISLAS';
UPDATE cliente_novedades SET Localidad = 'MALAGUEÑO' WHERE Localidad = 'MALAGUEÃ‘O' ;
UPDATE cliente_novedades SET Localidad = 'VILLA ESPAÑA' WHERE Localidad = 'VILLA ESPAÃ‘A';
UPDATE cliente_novedades SET Localidad = 'CAPILLA DEL SEÑOR'  WHERE Localidad = 'CAPILLA DEL SEÃ‘OR' ;
UPDATE cliente_novedades SET Localidad = 'CHARIGÊE' WHERE Localidad = 'CHARIGÃŠE';
UPDATE cliente_novedades SET Localidad = 'LAS CAÑAS (GUAYMALLEN)' WHERE Localidad = 'LAS CAÃ‘AS (GUAYMALLEN)';
UPDATE cliente_novedades SET Localidad = 'EL CHAÑAR' WHERE Localidad = 'EL CHAÃ‘AR' ;
UPDATE cliente_novedades SET Localidad = 'CAÑADA DE ALZOGARAY' WHERE Localidad = 'CAÃ‘ADA DE ALZOGARAY';
UPDATE cliente_novedades SET Localidad = 'CAÑADA DE YERBA BUENA' WHERE Localidad = 'CAÃ‘ADA DE YERBA BUENA';

ALTER TABLE cliente_novedades
  DROP Provincia,
  DROP Localidad;
  
ALTER TABLE cliente_novedades ADD Rango_Etario VARCHAR(20) NOT NULL DEFAULT '-' AFTER Edad;

UPDATE cliente_novedades SET Rango_Etario = '1_Hasta 30 años' WHERE Edad <= 30;
UPDATE cliente_novedades SET Rango_Etario = '2_De 31 a 40 años' WHERE Edad <= 40 AND Rango_Etario = '-';
UPDATE cliente_novedades SET Rango_Etario = '3_De 41 a 50 años' WHERE Edad <= 50 AND Rango_Etario = '-';
UPDATE cliente_novedades SET Rango_Etario = '4_De 51 a 60 años' WHERE Edad <= 60 AND Rango_Etario = '-';
UPDATE cliente_novedades SET Rango_Etario = '5_Desde 60 años' WHERE Edad > 60 AND Rango_Etario = '-';

CREATE TABLE IF NOT EXISTS aux_cliente (
	IdCliente			INTEGER,
	Latitud				DOUBLE,
	Longitud			DOUBLE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO aux_cliente (IdCliente, Latitud, Longitud)
SELECT 	ID, Latitud, Longitud
FROM cliente_novedades WHERE Latitud < -55;

SELECT * FROM aux_cliente;

UPDATE cliente_novedades c JOIN aux_cliente ac
	ON (c.ID = ac.IdCliente)
SET c.Latitud = ac.Longitud, c.Longitud = ac.Latitud;

UPDATE cliente_novedades SET Latitud = Latitud * -1 WHERE Latitud > 0;
UPDATE cliente_novedades SET Longitud = Longitud * -1 WHERE Longitud > 0;

/*Validación de Modificaciones:*/
USE base;

/*la tabla clientes y ventas originales viene sin las siguientes columnas Fecha_Alta, Usuario_Alta, Usuario_Ultima_Modificacion, Marca_Baja con lo que se agregaran*/
ALTER TABLE cliente 
ADD COLUMN Fecha_Alta DATE, 
ADD COLUMN Usuario_Alta VARCHAR(20), 
ADD COLUMN Fecha_Ultima_Modificacion DATETIME DEFAULT NULL, 
ADD COLUMN Usuario_Ultima_Modificacion VARCHAR(20), 
ADD COLUMN Marca_Baja TINYINT;

ALTER TABLE cliente CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci; -- Se cambia porque daba error

-- al pasar y ver la novedades a actualizar se nota que la tabla clientes tiene valores positivos en longitud y latitud se pasa a negativos como tiene que ser 
UPDATE cliente SET Latitud = Latitud * -1 WHERE Latitud > 0;
UPDATE cliente SET Longitud = Longitud * -1 WHERE Longitud > 0;


SELECT c.*, cn.* 
-- SELECT COUNT(*)
FROM cliente c, cliente_novedades cn
WHERE c.IdCliente = cn.ID
AND (c.Nombre_Y_Apellido <> cn.Nombre_Y_Apellido OR
	c.Domicilio <> cn.Domicilio OR
    c.Telefono <> cn.Telefono OR
    c.Edad <> cn.Edad OR
    c.Rango_Etario <> cn.Rango_Etario OR
    c.IdLocalidad <> cn.IdLocalidad OR
    c.Latitud <> cn.Latitud OR
    c.Longitud <> cn.Longitud OR
    c.Fecha_Ultima_Modificacion <> cn.Fecha_Ultima_Modificacion OR
    c.Usuario_Ultima_Modificacion <> cn.Usuario_Ultima_Modificacion OR
    c.Marca_Baja <> cn.Marca_Baja);

UPDATE cliente c, cliente_novedades cn
SET c.Nombre_Y_Apellido = cn.Nombre_Y_Apellido,
	c.Domicilio = cn.Domicilio,
    c.Telefono = cn.Telefono,
    c.Edad = cn.Edad,
    c.Rango_Etario = cn.Rango_Etario,
    c.IdLocalidad = cn.IdLocalidad,
    c.Latitud = cn.Latitud,
    c.Longitud = cn.Longitud,
    c.Fecha_Ultima_Modificacion = cn.Fecha_Ultima_Modificacion,
    c.Usuario_Ultima_Modificacion = cn.Usuario_Ultima_Modificacion,
    c.Marca_Baja = cn.Marca_Baja
WHERE c.IdCliente = cn.ID
AND (c.Nombre_Y_Apellido <> cn.Nombre_Y_Apellido OR
	c.Domicilio <> cn.Domicilio OR
    c.Telefono <> cn.Telefono OR
    c.Edad <> cn.Edad OR
    c.Rango_Etario <> cn.Rango_Etario OR
    c.IdLocalidad <> cn.IdLocalidad OR
    c.Latitud <> cn.Latitud OR
    c.Longitud <> cn.Longitud OR
    c.Fecha_Ultima_Modificacion <> cn.Fecha_Ultima_Modificacion OR
    c.Usuario_Ultima_Modificacion <> cn.Usuario_Ultima_Modificacion OR
    c.Marca_Baja <> cn.Marca_Baja);

DELETE FROM cliente_novedades cn WHERE cn.ID IN (SELECT c.IdCliente FROM cliente c);

/*Se cargan las novedades en la tabla de Clientes:*/
INSERT INTO cliente (IdCliente, 
					Nombre_Y_Apellido, 
                    Domicilio, 
                    Telefono, 
                    Edad, 
                    Rango_Etario, 
                    IdLocalidad, 
                    Latitud, 
                    Longitud,
					Fecha_Alta,
					Usuario_Alta,
					Fecha_Ultima_Modificacion,
					Usuario_Ultima_Modificacion,
					Marca_Baja)
SELECT	ID, 
		Nombre_Y_Apellido, 
		Domicilio, 
		Telefono, 
		Edad, 
		Rango_Etario, 
		IdLocalidad, 
		Latitud, 
		Longitud,
		Fecha_Alta,
		Usuario_Alta,
		Fecha_Ultima_Modificacion,
		Usuario_Ultima_Modificacion,
		Marca_Baja
FROM 	cliente_novedades;

/*Se procede con el procesado de los datos de la tabla venta_novedades que no hayan sido cargados con anterioridad:*/
DELETE FROM venta_novedades WHERE IdVenta IN (SELECT IdVenta FROM venta);

SELECT * FROM venta_novedades;

UPDATE venta_novedades set Precio = 0 WHERE Precio = '';
ALTER TABLE venta_novedades CHANGE Precio Precio DECIMAL(15,3) NOT NULL DEFAULT '0';

UPDATE venta_novedades v JOIN producto p ON (v.IdProducto = p.IdProducto) 
SET v.Precio = p.Precio
WHERE v.Precio = 0;

UPDATE venta_novedades SET Cantidad = REPLACE(Cantidad, '\r', '');

INSERT INTO aux_venta (IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, 0, 1
FROM venta_novedades WHERE Cantidad = '' or Cantidad is null;

UPDATE venta_novedades SET Cantidad = '1' WHERE Cantidad = '' or Cantidad is null;
ALTER TABLE venta_novedades CHANGE Cantidad Cantidad INTEGER NOT NULL DEFAULT '0';

INSERT INTO aux_venta (IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT v.IdVenta, v.Fecha, v.Fecha_Entrega, v.IdCliente, v.IdSucursal, v.IdEmpleado, v.IdProducto, v.Precio, v.Cantidad, 2
FROM venta_novedades v 
JOIN (SELECT IdProducto, AVG(Cantidad) As Promedio, STDDEV(Cantidad) as Desv FROM venta_novedades GROUP BY IdProducto) v2
	on (v.IdProducto = v2.IdProducto)
WHERE v.Cantidad > (v2.Promedio + (3 * v2.Desv)) OR v.Cantidad < 0;

INSERT INTO aux_venta (IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT v.IdVenta, v.Fecha, v.Fecha_Entrega, v.IdCliente, v.IdSucursal, v.IdEmpleado, v.IdProducto, v.Precio, v.Cantidad, 3
FROM venta_novedades v 
JOIN (SELECT IdProducto, AVG(Precio) As Promedio, STDDEV(Precio) as Desv FROM venta_novedades GROUP BY IdProducto) v2
	on (v.IdProducto = v2.IdProducto)
WHERE v.Precio > (v2.Promedio + (3 * v2.Desv)) OR v.Precio < 0;

select * from aux_venta where Motivo = 2; -- outliers de cantidad
select * from aux_venta where Motivo = 3; -- outliers de precio

ALTER TABLE venta_novedades ADD Outlier TINYINT NOT NULL DEFAULT '1' AFTER Cantidad;

UPDATE venta_novedades v JOIN aux_venta a
	ON (v.IdVenta = a.IdVenta AND a.Motivo IN (2,3))
SET v.Outlier = 0;

UPDATE venta_novedades SET IdEmpleado = (IdSucursal * 1000000) + IdEmpleado;

/*Se cargan las novedades en la tabla de Ventas:*/
INSERT INTO venta (IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Outlier)
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Outlier
FROM venta_novedades;