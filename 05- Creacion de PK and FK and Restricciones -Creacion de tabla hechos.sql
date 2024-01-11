USE base;

/*Creamos indices de las tablas determinando claves primarias y foraneas*/
ALTER TABLE venta ADD PRIMARY KEY(IdVenta);
ALTER TABLE venta ADD INDEX(IdProducto);
ALTER TABLE venta ADD INDEX(IdEmpleado);
ALTER TABLE venta ADD INDEX(Fecha);
ALTER TABLE venta ADD INDEX(Fecha_Entrega);
ALTER TABLE venta ADD INDEX(IdCliente);
ALTER TABLE venta ADD INDEX(IdSucursal);
ALTER TABLE venta ADD INDEX(IdCanal);

/*Creacion de la tabla calendario*/
DROP PROCEDURE IF EXISTS `Llenar_dimension_calendario`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Llenar_dimension_calendario`(IN `startdate` DATE, IN `stopdate` DATE)
BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;
    WHILE currentdate < stopdate DO
        INSERT INTO calendario VALUES (
                        YEAR(currentdate)*10000+MONTH(currentdate)*100 + DAY(currentdate),
                        currentdate,
                        YEAR(currentdate),
                        MONTH(currentdate),
                        DAY(currentdate),
                        QUARTER(currentdate),
                        WEEKOFYEAR(currentdate),
                        DATE_FORMAT(currentdate,'%W'),
                        DATE_FORMAT(currentdate,'%M'));
        SET currentdate = ADDDATE(currentdate,INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

/*Se genera la dimension calendario*/
DROP TABLE IF EXISTS `calendario`;
CREATE TABLE calendario (
        id                      INTEGER PRIMARY KEY,  -- year*10000+month*100+day
        fecha                 	DATE NOT NULL,
        anio                    INTEGER NOT NULL,
        mes                   	INTEGER NOT NULL, -- 1 to 12
        dia                     INTEGER NOT NULL, -- 1 to 31
        trimestre               INTEGER NOT NULL, -- 1 to 4
        semana                  INTEGER NOT NULL, -- 1 to 52/53
        dia_nombre              VARCHAR(9) NOT NULL, -- 'Monday', 'Tuesday'...
        mes_nombre              VARCHAR(9) NOT NULL -- 'January', 'February'...
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

CALL Llenar_dimension_calendario('2015-01-01','2020-12-31');

SELECT * FROM calendario;

ALTER TABLE calendario ADD UNIQUE(fecha);

/* Sigo poniendo PK */
ALTER TABLE canal_venta ADD PRIMARY KEY(IdCanal);

ALTER TABLE producto ADD PRIMARY KEY(ID_Producto);
ALTER TABLE producto ADD INDEX(IdTipoProducto);

ALTER TABLE tipo_producto ADD PRIMARY KEY(IdTipoProducto); 

ALTER TABLE sucursales ADD PRIMARY KEY(IdSucursal);
ALTER TABLE sucursales ADD INDEX(IdLocalidad);

ALTER TABLE empleado ADD PRIMARY KEY(IdEmpleado); 
ALTER TABLE empleado ADD INDEX(IdSucursal);
ALTER TABLE empleado ADD INDEX(IdSector);
ALTER TABLE empleado ADD INDEX(IdCargo);

ALTER TABLE localidad ADD INDEX(IdProvincia);

ALTER TABLE proveedor ADD PRIMARY KEY(IdProveedor);
ALTER TABLE proveedor ADD INDEX(IdLocalidad);

DELETE g1 -- eliminO las lineas duplicadas de IdGasto 
FROM gasto g1 
JOIN (SELECT IdGasto 
      FROM gasto 
      GROUP BY IdGasto 
      HAVING COUNT(*) > 1) g2 
ON g1.IdGasto = g2.IdGasto;

ALTER TABLE gasto ADD PRIMARY KEY(IdGasto); -- tengo un id duplicado 4221
ALTER TABLE gasto ADD INDEX(IdSucursal);
ALTER TABLE gasto ADD INDEX(IdTipoGasto);
ALTER TABLE gasto ADD INDEX(Fecha);

ALTER TABLE cliente ADD PRIMARY KEY(IdCliente);
ALTER TABLE cliente ADD INDEX(IdLocalidad);

ALTER TABLE compra ADD PRIMARY KEY(IdCompra);
ALTER TABLE compra ADD INDEX(Fecha);
ALTER TABLE compra ADD INDEX(IdProducto);
ALTER TABLE compra ADD INDEX(IdProveedor);

/*Creo las relaciones entre las tablas, y con ellas las restricciones*/
ALTER TABLE venta ADD CONSTRAINT venta_fk_cliente FOREIGN KEY (IdCliente) REFERENCES cliente (IdCliente) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT venta_fk_sucursal FOREIGN KEY (IdSucursal) REFERENCES sucursales (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT venta_fk_producto FOREIGN KEY (IdProducto) REFERENCES producto (ID_Producto) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE venta ADD CONSTRAINT venta_fk_empleado FOREIGN KEY (IdEmpleado) REFERENCES empleado (IdEmpleado) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE canal_venta ADD PRIMARY KEY(IdCanal);
ALTER TABLE venta ADD CONSTRAINT venta_fk_canal FOREIGN KEY (IdCanal) REFERENCES canal_venta (IdCanal) ON DELETE RESTRICT ON UPDATE RESTRICT; -- Me daba error porque no estaba definida la pk

ALTER TABLE producto ADD CONSTRAINT producto_fk_tipoproducto FOREIGN KEY (IdTipoProducto) REFERENCES tipo_producto (IdTipoProducto) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE empleado ADD CONSTRAINT empleado_fk_sector FOREIGN KEY (IdSector) REFERENCES sector (IdSector) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleado ADD CONSTRAINT empleado_fk_cargo FOREIGN KEY (IdCargo) REFERENCES cargo (IdCargo) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleado ADD CONSTRAINT empleado_fk_sucursal FOREIGN KEY (IdSucursal) REFERENCES sucursales (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE cliente ADD CONSTRAINT liente_fk_localidad FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE proveedor ADD CONSTRAINT proveedor_fk_localidad FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE sucursales ADD CONSTRAINT sucursal_fk_localidad FOREIGN KEY (IdLocalidad) REFERENCES localidad (IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE localidad ADD CONSTRAINT localidad_fk_provincia FOREIGN KEY (IdProvincia) REFERENCES provincia (IdProvincia) ON DELETE RESTRICT ON UPDATE RESTRICT;

-- ALTER TABLE compra ADD CONSTRAINT compra_fk_producto FOREIGN KEY (IdProducto) REFERENCES producto (IdProducto) ON DELETE RESTRICT ON UPDATE RESTRICT;
/* Proveedor 8 no tenia el nombre y  el resto de los datos coincidia con el proveedor 7 con lo cual se elimino de la tabla y es lo que ahora nos esta dando error
con lo cual se procede a reemplazar de la tabla compra IdProveedor 8 por 7 

SELECT *
FROM compra
WHERE IdProveedor NOT IN (SELECT IdProveedor FROM proveedor);

SELECT * FROM proveedor; 

UPDATE compra SET IdProveedor = 7 WHERE IdProveedor = 8;*/

ALTER TABLE compra ADD CONSTRAINT compra_fk_proveedor FOREIGN KEY (IdProveedor) REFERENCES proveedor (IdProveedor) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE gasto ADD CONSTRAINT gasto_fk_sucursal FOREIGN KEY (IdSucursal) REFERENCES sucursales (IdSucursal) ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE tipo_gasto ADD INDEX idx_tipo_gasto_IdTipoGasto (IdTipoGasto); -- No estaba seteado como INDEX con lo cual lo hago
ALTER TABLE gasto ADD CONSTRAINT gasto_fk_tipogasto FOREIGN KEY (IdTipoGasto) REFERENCES tipo_gasto (IdTipoGasto) ON DELETE RESTRICT ON UPDATE RESTRICT;

/*Cracion de Tablas de Hechos para modelo Estrella*/
DROP TABLE IF EXISTS fact_venta;
CREATE TABLE IF NOT EXISTS fact_venta (
	IdVenta				INTEGER,
	Fecha 				DATE NOT NULL,
	Fecha_Entrega 		DATE NOT NULL,
	IdCanal				INTEGER, 
	IdCliente			INTEGER, 
	IdEmpleado			INTEGER,
	IdProducto			INTEGER,
	Precio				DECIMAL(15,2),
	Cantidad			INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO fact_venta
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
FROM venta
WHERE YEAR(Fecha) = 2020;

ALTER TABLE `fact_venta` ADD PRIMARY KEY(`IdVenta`);
ALTER TABLE `fact_venta` ADD INDEX(`IdProducto`);
ALTER TABLE `fact_venta` ADD INDEX(`IdEmpleado`);
ALTER TABLE `fact_venta` ADD INDEX(`Fecha`);
ALTER TABLE `fact_venta` ADD INDEX(`Fecha_Entrega`);
ALTER TABLE `fact_venta` ADD INDEX(`IdCliente`);
ALTER TABLE `fact_venta` ADD INDEX(`IdCanal`);

DROP TABLE IF EXISTS dim_cliente;
CREATE TABLE IF NOT EXISTS dim_cliente (
	IdCliente			INTEGER,
	Nombre_y_Apellido	VARCHAR(80),
	Domicilio			VARCHAR(150),
	Telefono			VARCHAR(30),
	Rango_Etario		VARCHAR(20),
	IdLocalidad			INTEGER,
	Latitud				DECIMAL(13,10),
	Longitud			DECIMAL(13,10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO dim_cliente
SELECT IdCliente, Nombre_y_Apellido, Domicilio, Telefono, Rango_Etario, IdLocalidad, Latitud, Longitud
FROM cliente
WHERE IdCliente IN (SELECT distinct IdCliente FROM fact_venta);

DROP TABLE IF EXISTS dim_producto;
CREATE TABLE IF NOT EXISTS dim_producto (
	IdProducto					INTEGER,
	Producto					VARCHAR(100),
	IdTipoProducto				VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO dim_producto
SELECT ID_Producto, Producto, IdTipoProducto
FROM producto
WHERE ID_Producto IN (SELECT distinct IdProducto FROM fact_venta);
