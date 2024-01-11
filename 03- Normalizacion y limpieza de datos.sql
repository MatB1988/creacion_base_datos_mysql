/*Tabla ventas limpieza y normalizacion*/
USE base;

SELECT * FROM venta -- Vemos registros con precios vacios o cantidad vacia
WHERE Precio = '' or Cantidad = '';

SELECT COUNT(*) FROM venta;

SET SQL_SAFE_UPDATES = 0; -- NO ME CORRIA DEBI EJECUTAR ESTO PARA QUE NO ME TOME QUE POR ERROR PUEDO MODIFICAR UN GRAN NUMERO DE FILAS 

-- Al no tener mejor metodo se reemplaza precio por el precio del producto de la tabla poductos 
UPDATE venta v 
JOIN producto p ON (v.IdProducto = p.ID_Producto) 
SET v.Precio = p.Precio
WHERE v.Precio = 0;

-- Cantidad en Cero

DROP TABLE IF EXISTS aux_venta;
CREATE TABLE IF NOT EXISTS aux_venta (
	IdVenta				INTEGER,
	Fecha				DATE NOT NULL,
	Fecha_Entrega 		DATE NOT NULL,
	IdCliente			INTEGER, 
	IdSucursal			INTEGER,
	IdEmpleado			INTEGER,
	IdProducto			INTEGER,
	Precio				FLOAT,
	Cantidad			INTEGER,
	Motivo				INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

UPDATE venta SET Cantidad = REPLACE(Cantidad, '\r', '');

INSERT INTO aux_venta (IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, Cantidad, Motivo)
SELECT IdVenta, Fecha, Fecha_Entrega, IdCliente, IdSucursal, IdEmpleado, IdProducto, Precio, 0, 1
FROM venta WHERE Cantidad = '' or Cantidad is null;

UPDATE venta SET Cantidad = '1' WHERE Cantidad = '' or Cantidad is null;
ALTER TABLE `venta` CHANGE `Cantidad` `Cantidad` INTEGER NOT NULL DEFAULT '0';

/*Chequeo de claves duplicadas*/
SELECT IdCliente, COUNT(*) FROM cliente GROUP BY IdCliente HAVING COUNT(*) > 1;
SELECT IdSucursal, COUNT(*) FROM sucursales GROUP BY IdSucursal HAVING COUNT(*) > 1;
SELECT IdEmpleado, COUNT(*) FROM empleado GROUP BY IdEmpleado HAVING COUNT(*) > 1; -- se detecta que IdEmpleado tiene duplicados
SELECT IdProveedor, COUNT(*) FROM proveedor GROUP BY IdProveedor HAVING COUNT(*) > 1;
SELECT IdProducto, COUNT(*) FROM producto GROUP BY IdProducto HAVING COUNT(*) > 1;

SELECT COUNT(*) FROM empleado;

SELECT e.*, s.IdSucursal, s.Sucursal 
FROM empleado e 
JOIN sucursales s ON (e.Sucursal COLLATE utf8mb4_general_ci = s.Sucursal COLLATE utf8mb4_general_ci);

SELECT DISTINCT Sucursal FROM empleado
WHERE Sucursal COLLATE utf8mb4_general_ci NOT IN (SELECT Sucursal COLLATE utf8mb4_general_ci FROM sucursales);

/*Generacion de clave única tabla empleado mediante creacion de clave subrogada*/
UPDATE empleado SET Sucursal = 'Mendoza1' WHERE Sucursal = 'Mendoza 1';
UPDATE empleado SET Sucursal = 'Mendoza2' WHERE Sucursal = 'Mendoza 2';
UPDATE empleado SET Sucursal = 'Córdoba Quiroz' WHERE Sucursal = 'Cordoba Quiroz';

ALTER TABLE empleado ADD IdSucursal INT NULL DEFAULT '0' AFTER Sucursal;

UPDATE empleado e
JOIN sucursales s	ON (e.Sucursal COLLATE utf8mb4_general_ci = s.Sucursal COLLATE utf8mb4_general_ci)
SET e.IdSucursal = s.IdSucursal;

SELECT * FROM empleado;

ALTER TABLE empleado DROP Sucursal;

ALTER TABLE empleado ADD CodigoEmpleado INT NULL DEFAULT '0' AFTER IdEmpleado;

UPDATE empleado SET CodigoEmpleado = IdEmpleado;
UPDATE empleado SET IdEmpleado = (IdSucursal * 1000000) + CodigoEmpleado;

/*Chequeo de claves duplicadas*/
SELECT * FROM empleado;
SELECT IdEmpleado, COUNT(*) FROM empleado GROUP BY IdEmpleado HAVING COUNT(*) > 1;

/*Modificacion de la clave foranea de empleado en venta*/
UPDATE venta SET IdEmpleado = (IdSucursal * 1000000) + IdEmpleado;

/*Normalizacion tabla empleado*/
DROP TABLE IF EXISTS `cargo`;
CREATE TABLE IF NOT EXISTS `cargo` (
   `IdCargo` int NOT NULL AUTO_INCREMENT,
   `Cargo` varchar(50) NOT NULL,
   PRIMARY KEY (`IdCargo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS `sector`;
CREATE TABLE IF NOT EXISTS `sector` (
  `IdSector` int NOT NULL AUTO_INCREMENT,
  `Sector` varchar(50) NOT NULL,
  PRIMARY KEY (`IdSector`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO cargo (Cargo) SELECT DISTINCT Cargo FROM empleado ORDER BY 1;
INSERT INTO sector (Sector) SELECT DISTINCT Sector FROM empleado ORDER BY 1;

/* Chequeo las tablas y normalizacion de sector, cargo */ 	
SELECT * FROM cargo;
SELECT * FROM sector;

ALTER TABLE empleado ADD IdSector INT NOT NULL DEFAULT '0' AFTER IdSucursal, 
					 ADD IdCargo INT NOT NULL DEFAULT '0' AFTER IdSector;
                        
UPDATE empleado e JOIN cargo c ON (c.Cargo = e.Cargo) SET e.IdCargo = c.IdCargo;
UPDATE empleado e JOIN sector s ON (s.Sector = e.Sector) SET e.IdSector = s.IdSector;

ALTER TABLE empleado DROP `Cargo`;
ALTER TABLE empleado DROP `Sector`;

SELECT * FROM empleado;

/*Normalización tabla producto*/
ALTER TABLE producto ADD IdTipoProducto INT NOT NULL DEFAULT '0' AFTER Precio;

DROP TABLE IF EXISTS tipo_producto;
CREATE TABLE IF NOT EXISTS tipo_producto (
  IdTipoProducto INT NOT NULL AUTO_INCREMENT,
  TipoProducto varchar(50) NOT NULL,
  PRIMARY KEY (IdTipoProducto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO tipo_producto (TipoProducto) SELECT DISTINCT Tipo FROM producto ORDER BY 1;

UPDATE producto p JOIN tipo_producto t ON (p.Tipo = t.TipoProducto) SET p.IdTipoProducto = t.IdTipoProducto;

SELECT * FROM producto;

ALTER TABLE producto DROP Tipo;

/*Normalización Localidad Provincia*/
DROP TABLE IF EXISTS aux_Localidad;
CREATE TABLE IF NOT EXISTS aux_Localidad (
	Localidad_Original	VARCHAR(80),
	Provincia_Original	VARCHAR(50),
	Localidad_Normalizada	VARCHAR(80),
	Provincia_Normalizada	VARCHAR(50),
	IdLocalidad			INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO aux_localidad (Localidad_Original, Provincia_Original, Localidad_Normalizada, Provincia_Normalizada, IdLocalidad)
SELECT DISTINCT Localidad COLLATE utf8mb4_general_ci, Provincia COLLATE utf8mb4_general_ci, Localidad COLLATE utf8mb4_general_ci, Provincia COLLATE utf8mb4_general_ci, 0 FROM cliente 
UNION
SELECT DISTINCT Localidad COLLATE utf8mb4_general_ci, Provincia COLLATE utf8mb4_general_ci, Localidad COLLATE utf8mb4_general_ci, Provincia COLLATE utf8mb4_general_ci, 0 FROM sucursales 
UNION
SELECT DISTINCT Ciudad COLLATE utf8mb4_general_ci, Provincia COLLATE utf8mb4_general_ci, Ciudad COLLATE utf8mb4_general_ci, Provincia COLLATE utf8mb4_general_ci, 0 FROM proveedor 
ORDER BY 2, 1;

SELECT * FROM aux_localidad ORDER BY Provincia_Original;

UPDATE aux_localidad SET Provincia_Normalizada = 'Buenos Aires'
WHERE Provincia_Original IN ('B. Aires',
                            'B.Aires',
                            'Bs As',
                            'Bs.As.',
                            'Buenos Aires',
                            'C Debuenos Aires',
                            'Caba',
                            'Ciudad De Buenos Aires',
                            'Pcia Bs As',
                            'Prov De Bs As.',
                            'Provincia De Buenos Aires');
							
UPDATE aux_localidad SET Localidad_Normalizada = 'Capital Federal'
WHERE Localidad_Original IN ('Boca De Atencion Monte Castro',
                            'Caba',
                            'Cap.   Federal',
                            'Cap. Fed.',
                            'Capfed',
                            'Capital',
                            'Capital Federal',
                            'Cdad De Buenos Aires',
                            'Ciudad De Buenos Aires')
AND Provincia_Normalizada = 'Buenos Aires';
							
UPDATE aux_localidad SET Localidad_Normalizada = 'Córdoba'
WHERE Localidad_Original IN ('Coroba',
                            'Cordoba',
							'Cã³rdoba')
AND Provincia_Normalizada = 'Córdoba';

DROP TABLE IF EXISTS localidad;
CREATE TABLE IF NOT EXISTS localidad (
	IdLocalidad INT NOT NULL AUTO_INCREMENT,
	Localidad varchar(80) NOT NULL,
	Provincia varchar(80) NOT NULL,
	IdProvincia INT NOT NULL,
  PRIMARY KEY (IdLocalidad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

DROP TABLE IF EXISTS provincia;
CREATE TABLE IF NOT EXISTS provincia (
	IdProvincia INT NOT NULL AUTO_INCREMENT,
	Provincia varchar(50) NOT NULL,
  PRIMARY KEY (IdProvincia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO Localidad (Localidad, Provincia, IdProvincia)
SELECT	DISTINCT Localidad_Normalizada, Provincia_Normalizada, 0
FROM aux_localidad
ORDER BY Provincia_Normalizada, Localidad_Normalizada;

INSERT INTO provincia (Provincia)
SELECT DISTINCT Provincia_Normalizada
FROM aux_localidad
ORDER BY Provincia_Normalizada;

SELECT * FROM provincia;
SELECT * FROM localidad;

UPDATE localidad l
JOIN provincia p ON (l.Provincia = p.Provincia)
SET l.IdProvincia = p.IdProvincia;

UPDATE aux_localidad a
JOIN localidad l ON (l.Localidad = a.Localidad_Normalizada
                 AND a.Provincia_Normalizada = l.Provincia)
SET a.IdLocalidad = l.IdLocalidad;

SELECT * FROM aux_localidad;

ALTER TABLE cliente ADD IdLocalidad INT NOT NULL DEFAULT '0' AFTER Localidad;
ALTER TABLE proveedor ADD IdLocalidad INT NOT NULL DEFAULT '0' AFTER Departamento;
ALTER TABLE sucursales ADD IdLocalidad INT NOT NULL DEFAULT '0' AFTER Provincia;

ALTER TABLE cliente MODIFY Provincia VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
ALTER TABLE cliente MODIFY Localidad VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;

UPDATE cliente c JOIN aux_localidad a
	ON (c.Provincia = a.Provincia_Original AND c.Localidad = a.Localidad_Original)
SET c.IdLocalidad = a.IdLocalidad;

ALTER TABLE sucursales MODIFY Provincia VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
ALTER TABLE sucursales MODIFY Localidad VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;

UPDATE sucursales s JOIN aux_localidad a
	ON (s.Provincia = a.Provincia_Original AND s.Localidad = a.Localidad_Original)
SET s.IdLocalidad = a.IdLocalidad;

UPDATE proveedor p JOIN aux_localidad a
	ON (p.Provincia = a.Provincia_Original AND p.Ciudad = a.Localidad_Original)
SET p.IdLocalidad = a.IdLocalidad;

SELECT * FROM cliente;
SELECT * FROM proveedor;
SELECT * FROM sucursales;

/*Elimino columnas normalizadas de las distintas tablas solamente dejamos IdLocalidad */
ALTER TABLE cliente
  DROP Provincia,
  DROP Localidad;
  
ALTER TABLE proveedor
	DROP Ciudad,
	DROP Provincia,
	DROP Pais,
	DROP Departamento;
  
ALTER TABLE sucursales
	DROP Localidad,
	DROP Provincia;
  
ALTER TABLE localidad
	DROP Provincia;
  
SELECT * FROM cliente;
SELECT * FROM proveedor;
SELECT * FROM sucursales;
SELECT * FROM localidad;
SELECT * FROM provincia;

/*Discretización*/
ALTER TABLE cliente ADD Rango_Etario VARCHAR(20) NOT NULL DEFAULT '-' AFTER Edad;

UPDATE cliente SET Rango_Etario = '1_Hasta 30 años' WHERE Edad <= 30;
UPDATE cliente SET Rango_Etario = '2_De 31 a 40 años' WHERE Edad <= 40 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '3_De 41 a 50 años' WHERE Edad <= 50 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '4_De 51 a 60 años' WHERE Edad <= 60 AND Rango_Etario = '-';
UPDATE cliente SET Rango_Etario = '5_Desde 60 años' WHERE Edad > 60 AND Rango_Etario = '-';

SELECT Rango_Etario, COUNT(*) FROM cliente
GROUP BY Rango_Etario;

SELECT * FROM venta
UNION ALL
SELECT * FROM aux_venta;
