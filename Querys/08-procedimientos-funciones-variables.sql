USE base;

-- Creamos un procedimiento que recibe como argumento una fecha y muestre el listado de productos que se vendieron en esa fecha.
DROP PROCEDURE IF EXISTS listaProductos;
DELIMITER $$
CREATE PROCEDURE listaProductos (fechaVenta DATE)
BEGIN
    SELECT DISTINCT p.Producto
    FROM venta v
    JOIN producto p ON p.ID_Producto = v.IdProducto
    WHERE v.Fecha = fechaVenta;
END $$
DELIMITER ;

CALL listaProductos('2018-12-28');

-- Creamos una función que calcule el valor nominal de un margen bruto determinado por el usuario a partir del precio de lista de los productos.
DELIMITER $$
CREATE FUNCTION margenBruto(precio DECIMAL(15,2), margen DECIMAL(8,2)) 
RETURNS DECIMAL (15,2) 
DETERMINISTIC
BEGIN  
    DECLARE margenBruto DECIMAL(15,2);     
    SET margenBruto = precio * margen;     
    RETURN margenBruto; 
END $$
DELIMITER ;

SELECT margenBruto(100, 1.2); -- pruebo de la funcion

SELECT c.Fecha, pr.nombre as Proveedor, p.Producto, c.Precio as Precio_Compra, margenBruto(c.Precio, 1.2) as precio_con_margen
FROM compra c
JOIN producto p ON(p.ID_Producto = c.IdProducto)
JOIN proveedor pr ON(pr.IdProveedor = c.IdProveedor); -- probamos con un listado de productos

-- Obtnemos un listado de productos de IMPRESION y utilizarlo para cálcular el valor nominal de un margen bruto del 20% de cada uno de los productos
SELECT p.ID_Producto, p.Producto, p.Precio, margenBruto(p.Precio, 1.2) as precio_con_margen
FROM producto p
JOIN tipo_producto tp ON(p.IdTipoProducto = tp.IdTipoProducto AND TipoProducto = 'Impresión');

-- Creamos un procedimiento que permita listar los productos vendidos desde fact_venta a partir de un "Tipo" que determine el usuario.
DROP PROCEDURE IF EXISTS listaProductosCategoria;
DELIMITER $$
CREATE PROCEDURE listaProductosCategoria (categoria VARCHAR(30))
BEGIN
	SELECT v.*, p.Producto
    FROM venta v
    JOIN producto p ON(p.ID_Producto = v.IdProducto)
    JOIN tipo_producto tp ON(tp.IdTipoProducto = p.IdTipoProducto AND TipoProducto collate utf8mb4_spanish_ci = categoria);
END $$
DELIMITER ;

CALL listaProductosCategoria('Limpieza');

-- Creamos un procedimiento que permita realizar la insercción de datos en la tabla fact_venta.
DELIMITER $$
CREATE PROCEDURE cargarFact_venta()
BEGIN
	INSERT INTO fact_venta
    SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
    FROM venta
    WHERE Outlier = 1
    LIMIT 10;
END $$
DELIMITER ;

CALL cargarFact_venta;

-- Creamos un procedimiento almacenado que reciba un grupo etario y devuelta el total de ventas para ese grupo.
DELIMITER $$
CREATE PROCEDURE ventasGrupoEtario(rango_etario VARCHAR(30))
BEGIN
	SELECT c.Rango_Etario, SUM(v.Precio * v.Cantidad) AS total_ventas
    FROM venta v
    JOIN cliente c ON(c.IdCliente = v.IdCliente AND c.Rango_Etario collate utf8mb4_spanish_ci LIKE concat('%', rango_etario, '%'))
    GROUP BY c.Rango_Etario;
END $$
DELIMITER ;

CALL ventasGrupoEtario('51%60');

-- Creamos una variable que se pase como valor para realizar una filtro sobre Rango_etario en una consulta génerica a dim_cliente.
SET @grupo_etario = '4_De 51 a 60 años' collate utf8mb4_spanish_ci;
SELECT *
FROM dim_cliente
WHERE Rango_Etario  = @grupo_etario;

SET GLOBAL log_bin_trust_function_creators = 1;

/*Función y Procedimiento provistos*/

-- Elimino la función si existe
DROP FUNCTION IF EXISTS UC_Words;

-- Creo la función nuevamente
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `UC_Words`(str VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4
BEGIN
  DECLARE c CHAR(1);
  DECLARE s VARCHAR(255);
  DECLARE i INT DEFAULT 1;
  DECLARE bool INT DEFAULT 1;
  DECLARE punct CHAR(17) DEFAULT ' ()[]{},.-_!@;:?/';
  
  SET s = LCASE(str);
  
  WHILE i <= LENGTH(str) DO
    SET c = SUBSTRING(s, i, 1);
    
    IF LOCATE(c, punct) > 0 THEN
      SET bool = 1;
    ELSE
      IF bool=1 THEN
        IF c >= 'a' AND c <= 'z' THEN
          SET s = CONCAT(LEFT(s, i-1), UCASE(c), SUBSTRING(s, i+1));
          SET bool = 0;
        ELSEIF c >= '0' AND c <= '9' THEN
          SET bool = 0;
        END IF;
      END IF;
    END IF;
    
    SET i = i+1;
  END WHILE;
  
  RETURN s;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS Llenar_dimension_calendario;

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
            DATE_FORMAT(currentdate,'%M')
        );
        SET currentdate = ADDDATE(currentdate, INTERVAL 1 DAY);
    END WHILE;
END$$
DELIMITER ;

DROP TABLE calendario;

/*Se genera la dimension calendario*/
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

ALTER TABLE calendario ADD UNIQUE(fecha);

/*Normalizacion a Letra Capital*/
UPDATE cliente SET  Domicilio = UC_Words(TRIM(Domicilio)),
                    Nombre_y_Apellido = UC_Words(TRIM(Nombre_y_Apellido));
					
UPDATE sucursales SET Direccion = UC_Words(TRIM(Direccion)),
                    Sucursal = UC_Words(TRIM(Sucursal));
					
UPDATE proveedor SET Nombre = UC_Words(TRIM(Nombre)),
                    Domicilio = UC_Words(TRIM(Domicilio));

UPDATE producto SET Producto = UC_Words(TRIM(Producto));

UPDATE tipo_producto SET TipoProducto = UC_Words(TRIM(TipoProducto));
					
UPDATE empleado SET Nombre = UC_Words(TRIM(Nombre)),
                    Apellido = UC_Words(TRIM(Apellido));

UPDATE sector SET Sector = UC_Words(TRIM(Sector));

UPDATE cargo SET Cargo = UC_Words(TRIM(Cargo));
                    
UPDATE localidad SET Localidad = UC_Words(TRIM(Localidad));

UPDATE provincia SET Provincia = UC_Words(TRIM(Provincia));

UPDATE dim_cliente SET 	Domicilio = UC_Words(TRIM(Domicilio)),
                    Nombre_y_Apellido = UC_Words(TRIM(Nombre_y_Apellido));

UPDATE dim_producto SET Producto = UC_Words(TRIM(Producto));

/*TRUNCATE TABLE calendario;*/
CALL Llenar_dimension_calendario('2015-01-01','2021-01-01');
SELECT * FROM calendario;

ALTER TABLE venta ADD CONSTRAINT venta_fk_fecha FOREIGN KEY (fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT; 
ALTER TABLE compra ADD CONSTRAINT compra_fk_fecha FOREIGN KEY (Fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE gasto ADD CONSTRAINT gasto_fk_fecha FOREIGN KEY (Fecha) REFERENCES calendario (fecha) ON DELETE RESTRICT ON UPDATE RESTRICT;