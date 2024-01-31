/* Duplico la base para trabajar en la copia por seguridad*/ 
USE base;

/* Nombres campos */ 

ALTER TABLE cliente CHANGE ID IdCliente INT(11) NOT NULL;  
ALTER TABLE empleado CHANGE ID_Empleado IdEmpleado INT(11) NOT NULL;
ALTER TABLE proveedor CHANGE IDProveedor IdProveedor INT(11) NOT NULL;
ALTER TABLE sucursales CHANGE ID IdSucursal INT(11) NOT NULL;
ALTER TABLE tipo_gasto CHANGE Descripcion Tipo_Gasto VARCHAR(100) NOT NULL;
ALTER TABLE producto CHANGE IDProducto IdProducto INT(11) NOT NULL;
ALTER TABLE producto CHANGE Concepto Producto VARCHAR(100) NOT NULL; 

/* Tipos de datos */
SET SQL_SAFE_UPDATES = 0; -- NO ME CORRIA DEBI EJECUTAR ESTO PARA QUE NO ME TOME QUE POR ERROR PUEDO MODIFICAR UN GRAN NUMERO DE FILAS 

SELECT * FROM cliente;

ALTER TABLE cliente 	ADD Latitud DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER Y, 
						ADD Longitud DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER X;
                        
UPDATE cliente SET Y = '0' WHERE Y = '';
    
UPDATE cliente SET X = '0' WHERE  X = '';
    
UPDATE cliente SET Latitud = REPLACE(Y, ',', '.');
UPDATE cliente SET Longitud = REPLACE(X, ',', '.');
    
ALTER TABLE cliente DROP Y;
ALTER TABLE cliente DROP X;

ALTER TABLE empleado ADD Salario2 DECIMAL(10,2) NOT NULL DEFAULT '0' AFTER Salario;

UPDATE empleado SET Salario2 = REPLACE(Salario, ',', '.');
    
ALTER TABLE empleado DROP Salario;

SELECT * FROM empleado;
    
ALTER TABLE producto ADD Precio2 DECIMAL(15,3) NOT NULL DEFAULT '0' AFTER Precio;

UPDATE producto SET Precio2 = REPLACE(Precio, ',', '.');
    
ALTER TABLE producto DROP Precio2;

SELECT * FROM producto;

ALTER TABLE sucursales 	ADD Latitud2 DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER Latitud, 
						ADD Longitud2 DECIMAL(13,10) NOT NULL DEFAULT '0' AFTER Longitud;

UPDATE sucursales SET Latitud2 = REPLACE(Latitud, ',', '.');
UPDATE sucursales SET Longitud2 = REPLACE(Longitud, ',', '.');
    
ALTER TABLE sucursales DROP Latitud;
ALTER TABLE sucursales DROP Longitud;

SELECT * FROM sucursales;

UPDATE venta SET `Precio` = 0 WHERE Precio = '';
    
ALTER TABLE venta CHANGE Precio Precio DECIMAL(15,3) NOT NULL DEFAULT '0';

SELECT * FROM venta;

/*Columnas sin usar*/

ALTER TABLE cliente DROP col10;

SELECT * FROM cliente;

/*Imputar Valores Faltantes*/
UPDATE cliente SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE cliente SET Localidad = 'Sin Dato' WHERE TRIM(Localidad) = "" OR ISNULL(Localidad);
UPDATE cliente SET Nombre_y_Apellido = 'Sin Dato' WHERE TRIM(Nombre_y_Apellido) = "" OR ISNULL(Nombre_y_Apellido);
UPDATE cliente SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);

UPDATE empleado SET Apellido = 'Sin Dato' WHERE TRIM(Apellido) = "" OR ISNULL(Apellido);
UPDATE empleado SET Nombre = 'Sin Dato' WHERE TRIM(Nombre) = "" OR ISNULL(Nombre);
UPDATE empleado SET Sucursal = 'Sin Dato' WHERE TRIM(Sucursal) = "" OR ISNULL(Sucursal);
UPDATE empleado SET Sector = 'Sin Dato' WHERE TRIM(Sector) = "" OR ISNULL(Sector);
UPDATE empleado SET Cargo = 'Sin Dato' WHERE TRIM(Cargo) = "" OR ISNULL(Cargo);

UPDATE producto SET Producto = 'Sin Dato' WHERE TRIM(Producto) = "" OR ISNULL(Producto);
UPDATE producto SET Tipo = 'Sin Dato' WHERE TRIM(Tipo) = "" OR ISNULL(Tipo);

UPDATE proveedor SET Nombre = 'Sin Dato' WHERE TRIM(Nombre) = "" OR ISNULL(Nombre);
UPDATE proveedor SET Domicilio = 'Sin Dato' WHERE TRIM(Domicilio) = "" OR ISNULL(Domicilio);
UPDATE proveedor SET Ciudad = 'Sin Dato' WHERE TRIM(Ciudad) = "" OR ISNULL(Ciudad);
UPDATE proveedor SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);
UPDATE proveedor SET Pais = 'Sin Dato' WHERE TRIM(Pais) = "" OR ISNULL(Pais);
UPDATE proveedor SET Departamento = 'Sin Dato' WHERE TRIM(Departamento) = "" OR ISNULL(Departamento);

UPDATE sucursales SET Direccion = 'Sin Dato' WHERE TRIM(Direccion) = "" OR ISNULL(Direccion);
UPDATE sucursales SET Sucursal = 'Sin Dato' WHERE TRIM(Sucursal) = "" OR ISNULL(Sucursal);
UPDATE sucursales SET Provincia = 'Sin Dato' WHERE TRIM(Provincia) = "" OR ISNULL(Provincia);
UPDATE sucursales SET Localidad = 'Sin Dato' WHERE TRIM(Localidad) = "" OR ISNULL(Localidad);
