# Proyecto de Base de Datos

![Logo](img/Logo%20.png)

Este repositorio contiene el código necesario para la creación y gestión de una base de datos utilizando MySQL.

En la carpeta csv se tiene todos los arhivos para realizar la carga de los datos de la base de datos.

A continuación, se detalla la estructura del proyecto y los pasos para utilizarlo.

## Contenido

- [Proyecto de Base de Datos](#proyecto-de-base-de-datos)
  - [Contenido](#contenido)
  - [Creación de la Base de Datos](#creación-de-la-base-de-datos)
  - [Imputacion de valores faltantes](#imputacion-de-valores-faltantes)
  - [Normalización](#normalización)
  - [Deteccion de outliers](#deteccion-de-outliers)
  - [Creacion de PF y FK, resticciones y tablas de dimenciones y hechos](#creacion-de-pf-y-fk-resticciones-y-tablas-de-dimenciones-y-hechos)
  - [ETL - CARGA INCREMENTAL](#etl---carga-incremental)
  - [Tablas auditoria](#tablas-auditoria)
- [Procedimiento, funciones y variables](#procedimiento-funciones-y-variables)

## Creación de la Base de Datos

Este conjunto de scripts SQL tiene como objetivo la creación de una base de datos MySQL llamada "base" y la configuración de diversas tablas relacionadas, así como la importación de datos desde archivos CSV. [Consulta](https://github.com/tu_usuario/tu_repositorio/blob/main/Querys/01-creacion-carga-datos.sql)


## Imputacion de valores faltantes

Se realiza diversas operaciones de limpieza y ajuste en la base de datos "base". A continuación, se presenta una explicación general de las principales acciones realizadas. [Consulta](https://github.com/tu_usuario/tu_repositorio/blob/main/Querys/02-Nombres-de-los-campos-Tipos-de-datos-Imputacion-de-valores-faltantes-Eliminacion-de-columnas-sin-uso.sql)

## Normalización

Se sigue haciendo una serie de operaciones de limpieza y normalización en la base de datos existente. [Consulta](https://github.com/tu_usuario/tu_repositorio/blob/main/Querys/03-Normalizacion-limpieza-de-datos.sql)

## Deteccion de outliers

En esta seccion  se realiza un análisis estadístico y de detección de outliers en las ventas de productos, seguido por cálculos de KPI para evaluar el rendimiento de los productos en términos de margen de ganancia. [Consulta](https://github.com/tu_usuario/tu_repositorio/blob/main/Querys/04-Detección-de-Outliers.sql)

## Creacion de PF y FK, resticciones y tablas de dimenciones y hechos

Se sigue con la configuración y preparación de la base de datos, incluyendo la optimización de índices, la creación de una dimensión de tiempo (tabla calendario), la resolución de duplicados, y la creación de tablas de hechos y dimensiones para un modelo estrella en un esquema de data warehousing. Además, se establecen restricciones y relaciones para mantener la integridad de los datos en la base de datos. [Consulta](https://github.com/tu_usuario/tu_repositorio/blob/main/Querys/05-Creacion-de-PK-FK-Restricciones-Creacion-de-tabla-hechos.sql)

## ETL - CARGA INCREMENTAL

Se realiza una serie de transformaciones y validaciones en las tablas cliente_novedades y venta_novedades antes de cargar las novedades en las tablas maestras cliente y venta. También se realiza la identificación y manejo de outliers en la tabla de novedades de ventas. [Consulta](https://github.com/tu_usuario/tu_repositorio/blob/main/Querys/06-Carga-Incremental-ETL.sql)

## Tablas auditoria

Esencialmente, se establece mecanismos de auditoría y registro para el seguimiento de cambios en la tabla fact_venta, tanto a nivel de inserción como de actualización, y también realiza algunas operaciones de carga y trazabilidad de registros en otras tablas. [Consulta](https://github.com/tu_usuario/tu_repositorio/blob/main/Querys/07-Tablas-Auditoria.sql)

# Procedimiento, funciones y variables

Se realiza diversas operaciones, incluyendo consultas, procedimientos almacenados, funciones y normalización de datos en varias tablas. Además, se asegura la integridad referencial mediante el uso de claves foráneas. [Consulta](https://github.com/tu_usuario/tu_repositorio/blob/main/Querys/08-procedimientos-funciones-variables.sql)
