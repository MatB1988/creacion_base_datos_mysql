/* Creo la base de datos*/  
CREATE DATABASE base; 

/* Me posiciono sobre la base*/
USE base;

/*Catalogo de funciones y procedimientos*/
SET GLOBAL log_bin_trust_function_creators = 1;
DROP FUNCTION IF EXISTS `UC_Words`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `UC_Words`( str VARCHAR(255) ) RETURNS varchar(255) CHARSET utf8
BEGIN  
  DECLARE c CHAR(1);  
  DECLARE s VARCHAR(255);  
  DECLARE i INT DEFAULT 1;  
  DECLARE bool INT DEFAULT 1;  
  DECLARE punct CHAR(17) DEFAULT ' ()[]{},.-_!@;:?/';  
  SET s = LCASE( str );  
  WHILE i < LENGTH( str ) DO  
     BEGIN  
       SET c = SUBSTRING( s, i, 1 );  
       IF LOCATE( c, punct ) > 0 THEN  
        SET bool = 1;  
      ELSEIF bool=1 THEN  
        BEGIN  
          IF c >= 'a' AND c <= 'z' THEN  
             BEGIN  
               SET s = CONCAT(LEFT(s,i-1),UCASE(c),SUBSTRING(s,i+1));  
               SET bool = 0;  
             END;  
           ELSEIF c >= '0' AND c <= '9' THEN  
            SET bool = 0;  
          END IF;  
        END;  
      END IF;  
      SET i = i+1;  
    END;  
  END WHILE;  
  RETURN s;  
END$$
DELIMITER ;

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


/*Creo la tabla gastos para importar los registros*/ 
DROP TABLE IF EXISTS `gasto`;
CREATE TABLE `gasto`(
    IdGasto INT,
    IdSucursal INT,
    IdTipoGasto INT,
    Fecha DATE,
    Monto DECIMAL(10 , 2 )
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

/* Importo los registros*/ 
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Gasto.csv'
INTO TABLE `gasto`
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(IdGasto, IdSucursal, IdTipoGasto, Fecha, Monto);

/* Veo como quedaron los datos*/ 
SELECT * FROM gasto;

/*Creo la tabla de cliente*/
CREATE TABLE cliente(
	ID					INTEGER,
	Provincia			VARCHAR(50),
	Nombre_y_Apellido	VARCHAR(80),
	Domicilio			VARCHAR(150),
	Telefono			VARCHAR(30),
	Edad				VARCHAR(5),
	Localidad			VARCHAR(80),
	X					VARCHAR(30),
	Y					VARCHAR(30),
	col10				VARCHAR(1)
);

/* Importo los registros*/ 
LOAD DATA infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Clientes.csv'
into table cliente
fields terminated by ';' enclosed by ''
lines terminated by '\n' ignore 1
lines (ID,Provincia,Nombre_y_Apellido,Domicilio,Telefono,Edad,Localidad,X,Y,col10);

SELECT * FROM cliente;

/*Creo la tabla de compra*/
CREATE TABLE compra (
    IdCompra INT,
    Fecha DATE,
    IdProducto INT,
    Cantidad INT,
    Precio DECIMAL(10 , 2 ),
    IdProveedor INT
);

/* Importo los registros*/ 
LOAD DATA infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Compra.csv'
into table compra
fields terminated by ',' enclosed by ''
lines terminated by '\n' ignore 1
lines (IdCompra,Fecha,IdProducto,Cantidad,Precio,IdProveedor);

/*Creo la tabla de sucursales*/
CREATE TABLE sucursales (
	ID			INTEGER,
	Sucursal	VARCHAR(40),
	Direccion	VARCHAR(150),
	Localidad	VARCHAR(80),
	Provincia	VARCHAR(50),
	Latitud		VARCHAR(30),
	Longitud	VARCHAR(30)
);

/* Importo los registros*/ 
LOAD DATA infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Sucursales.csv'
into table sucursales
fields terminated by ';' enclosed by ''
lines terminated by '\n' ignore 1
lines (ID,Sucursal,Direccion,Localidad,Provincia,Latitud,Longitud);

SELECT * FROM sucursales;

/*Creo la tabla de tipo_gasto*/
CREATE TABLE tipo_gasto(
	IdTipoGasto INT,
    Descripcion VARCHAR(20),
    Monto_Aproximado INT
);

/* Importo los registros*/ 
LOAD DATA infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TiposDeGasto.csv'
into table tipo_gasto
fields terminated by ',' enclosed by ''
lines terminated by '\n' ignore 1
lines (IdTipoGasto,Descripcion,Monto_Aproximado);

SELECT * FROM tipo_gasto;

/*Creo la tabla de venta*/
CREATE TABLE venta(
	IdVenta INT,
    Fecha DATE,
    Fecha_Entrega DATE,
    IdCanal INT,
    IdCliente INT,
    IdSucursal INT,
    IdEmpleado INT,
    IdProducto INT,
    Precio VARCHAR(30),
    Cantidad VARCHAR(30)
);

/* Importo los registros*/ 
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Venta.csv' 
INTO TABLE venta 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES  
(IdVenta,Fecha,Fecha_Entrega,IdCanal,IdCliente,IdSucursal,IdEmpleado,IdProducto,@Precio,Cantidad) 
SET Precio = IF(@Precio = '', 0, REPLACE(@Precio, ',', '.'));

SELECT * FROM venta;

/*Creo la tabla de canal_venta*/
DROP TABLE `canal_venta`;
CREATE TABLE IF NOT EXISTS `canal_venta` (
`IdCanal`				INTEGER,
`Canal` 				VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

INSERT INTO canal_venta (IdCanal,Canal) VALUES
(1, 'Telefónica'),
(2, 'OnLine'),
(3, 'Presencial');

DROP TABLE IF EXISTS empleado;
CREATE TABLE IF NOT EXISTS empleado (
    ID_empleado		INTEGER,
    Apellido		VARCHAR(100),
    Nombre 			VARCHAR(100),
    Sucursal 		VARCHAR(50),
    Sector 			VARCHAR(50),
    Cargo 			VARCHAR(50),
    Salario 		DECIMAL(10, 2) -- Cambiado a DECIMAL para datos numéricos
) DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

/* Importo los registros*/ 
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Empleados.csv'
INTO TABLE `empleado`
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ID_empleado, Apellido, Nombre, Sucursal, Sector, Cargo, @Salario)
SET Salario = REPLACE(REPLACE(@Salario, '\"', ''), ',', '.');

SELECT * FROM empleado;

DROP TABLE IF EXISTS proveedor;
CREATE TABLE IF NOT EXISTS proveedor (
	IDProveedor		INTEGER,
	Nombre			VARCHAR(80),
	Domicilio		VARCHAR(150),
	Ciudad			VARCHAR(80),
	Provincia		VARCHAR(50),
	Pais			VARCHAR(20),
	Departamento	VARCHAR(80)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

/* Importo los registros*/ 
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Proveedores.csv' 
INTO TABLE proveedor
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT * FROM proveedor;

Use base; 
DROP TABLE IF EXISTS producto;
CREATE TABLE IF NOT EXISTS producto (
	ID_Producto					INTEGER,
	Concepto					VARCHAR(100),
	Tipo						VARCHAR(50),
	Precio						DECIMAL(20,2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;

/* Importo los registros*/ 
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\PRODUCTOS_modificado.csv' 
INTO TABLE `producto` 
FIELDS TERMINATED BY ',' ENCLOSED BY '\"' ESCAPED BY '\"' 
LINES TERMINATED BY '\n' IGNORE 1 LINES;

SELECT  * FROM producto; 