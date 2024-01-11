USE base;

SELECT IdProducto, AVG(Precio) AS promedio, AVG(Precio) + (3 * STDDEV(Precio)) AS maximo
FROM venta
GROUP BY IdProducto;

SELECT IdProducto, AVG(Precio) AS promedio, AVG(Precio) + (3 * STDDEV(Precio)) AS minimo
FROM venta
GROUP BY IdProducto;

-- Detección de Outliers
SELECT v.*, o.promedio, o.maximo
FROM venta v
JOIN(SELECT IdProducto, AVG(Precio) as promedio, AVG(Precio) + (3 * STDDEV(Precio)) as maximo
	FROM VENTA
    GROUP BY  IdProducto) o
ON (v.IdProducto = o.IdProducto)
WHERE v.Precio > o.maximo;

SELECT *
FROM venta
WHERE IdProducto = 42890;

SELECT v.*, o.promedio, o.maximo 
FROM venta v
JOIN (SELECT IdProducto, AVG(Cantidad) AS promedio, AVG(Cantidad) + (3 * STDDEV(Cantidad)) AS maximo
	FROM venta
	GROUP BY IdProducto) o
ON (v.IdProducto = o.IdProducto)
WHERE v.Cantidad > o.maximo;

SELECT *
FROM venta
WHERE IdProducto = 42883;

SELECT cantidad, COUNT(*)
FROM venta
GROUP BY cantidad
ORDER BY 1;

-- Introducimos los outliers de cantidad en la tabla aux_venta

INSERT INTO aux_venta
SELECT v.IdVenta, v.Fecha, v.Fecha_Entrega, v.IdCliente, v.IdSucursal, v.IdEmpleado,
v.IdProducto, v.Precio, v.Cantidad, 2
FROM venta v
JOIN (SELECT IdProducto, AVG(Cantidad) AS promedio, stddev(Cantidad) AS Desv
	FROM venta
	GROUP BY IdProducto) v2
ON (v.IdProducto = v2.IdProducto)
WHERE v.Cantidad > (v2.Promedio + (3*v2.Desv)) OR v.Cantidad < (v2.Promedio - (3*v2.Desv)) OR v.Cantidad < 0;

-- Introducimos los outliers de precio en la tabla aux_venta
INSERT INTO aux_venta
SELECT v.IdVenta, v.Fecha, v.Fecha_Entrega, v.IdCliente, v.IdSucursal,
v.IdEmpleado, v.IdProducto, v.Precio, v.Cantidad, 3
FROM venta v
JOIN (SELECT IdProducto, AVG(Precio) AS promedio, stddev(Precio) AS Desv
	FROM venta
	GROUP BY IdProducto) v2
ON (v.IdProducto = v2.IdProducto)
WHERE v.Precio > (v2.Promedio + (3*v2.Desv)) OR v.Precio < (v2.Promedio - (3*v2.Desv)) OR v.Precio < 0;

-- Agrego 0 a los outliers en la tabla venta
ALTER TABLE venta ADD Outlier TINYINT  NOT NULL DEFAULT '1' AFTER Cantidad;
UPDATE venta v
JOIN aux_venta a
ON (v.IdVenta = a.IdVenta AND a.Motivo IN (2,3))
SET v.Outlier = 0;

-- Ventas con y sin outliers
SELECT 	co.TipoProducto,
		co.PromedioVentaConOutliers,
        so.PromedioVentaSinOutliers
FROM
	(SELECT 	tp.TipoProducto,
			AVG(v.Precio * v.Cantidad) AS PromedioVentaConOutliers
	FROM 	venta v JOIN producto p
		ON (v.IdProducto = p.ID_Producto)
			JOIN tipo_producto tp
		ON (p.IdTipoProducto = tp.IdTipoProducto)
	GROUP BY tp.TipoProducto) co
JOIN
	(SELECT 	tp.TipoProducto,
			AVG(v.Precio * v.Cantidad) AS PromedioVentaSinOutliers
	FROM 	venta v JOIN producto p
		ON (v.IdProducto = p.ID_Producto AND v.Outlier = 1)
			JOIN tipo_producto tp
		ON (p.IdTipoProducto = tp.IdTipoProducto)
	GROUP BY tp.TipoProducto) so
ON co.TipoProducto = so.TipoProducto;

-- KPI: Margen de Ganancia por producto superior a 20%
SELECT 	venta.Producto, 
		venta.SumaVentas, 
        venta.CantidadVentas, 
        venta.SumaVentasOutliers,
        compra.SumaCompras, 
        compra.CantidadCompras,
        ((venta.SumaVentas / compra.SumaCompras - 1) * 100) AS margen
FROM
	(SELECT 	p.Producto,
			SUM(v.Precio * v.Cantidad * v.Outlier) 	AS 	SumaVentas,
			SUM(v.Outlier) 							AS	CantidadVentas,
			SUM(v.Precio * v.Cantidad) 				AS 	SumaVentasOutliers,
			COUNT(*) 								AS	CantidadVentasOutliers
	FROM venta v JOIN producto p
		ON (v.IdProducto = p.ID_Producto
			AND YEAR(v.Fecha) = 2019)
	GROUP BY p.Producto) AS venta
JOIN
	(SELECT 	p.Producto,
			SUM(c.Precio * c.Cantidad) 				AS SumaCompras,
			COUNT(*)								AS CantidadCompras
	FROM compra c JOIN producto p
		ON (c.IdProducto = p.ID_Producto
			AND YEAR(c.Fecha) = 2019)
	GROUP BY p.Producto) AS compra
ON (venta.Producto = compra.Producto);