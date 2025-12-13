/* ===========================================================
   PROYECTO: Inventario suela BCM (2021–2022)
   AUTOR: Carlos Hernández
   OBJETIVO:
   - Importar datos de movimientos de suela BCM
   - Corregir fechas
   - Crear tabla de hechos con lógica Entrada/Salida
   - Calcular stock acumulado
   =========================================================== */

---------------------------------------------------------------
-- 1. TABLA RAW (IMPORTADA DESDE EXCEL)
---------------------------------------------------------------
-- Nota: esta tabla se crea vacía y se llena con el asistente
-- de importación de SQL Server (desde el archivo Excel).

IF OBJECT_ID('dbo.bcm_movimientos_raw', 'U') IS NOT NULL
    DROP TABLE dbo.bcm_movimientos_raw;
GO

CREATE TABLE dbo.bcm_movimientos_raw (
    id         INT IDENTITY(1,1) PRIMARY KEY,
    fecha      DATE,
    movimiento VARCHAR(20),
    talla_34   INT,
    talla_35   INT,
    talla_36   INT,
    talla_37   INT,
    talla_38   INT,
    talla_39   INT,
    total      INT
);
GO

-- Aquí se importa el Excel con el asistente de SQL Server
-- (Integration Services / Import Data Wizard).
-- Archivo sugerido: 01_data/bcm_movimientos_original.xlsx



---------------------------------------------------------------
-- 2. LIMPIEZA DE FECHAS (CORRECCIÓN DE AÑOS)
---------------------------------------------------------------
-- Supuesto de negocio:
-- - Solo hay movimientos válidos en 2021 y 2022.
-- - A partir del id 389 comienzan los registros de 2022.

-- Registros de 2021 (antes de id 389)
UPDATE dbo.bcm_movimientos_raw
SET fecha = DATEFROMPARTS(2021, MONTH(fecha), DAY(fecha))
WHERE id < 389
  AND (YEAR(fecha) <> 2021);

-- Registros de 2022 (desde id 389 en adelante)
UPDATE dbo.bcm_movimientos_raw
SET fecha = DATEFROMPARTS(2022, MONTH(fecha), DAY(fecha))
WHERE id >= 389
  AND (YEAR(fecha) <> 2022);



---------------------------------------------------------------
-- 3. TABLA LIMPIA FINAL DE MOVIMIENTOS
---------------------------------------------------------------
IF OBJECT_ID('dbo.bcm_movimientos', 'U') IS NOT NULL
    DROP TABLE dbo.bcm_movimientos;
GO

CREATE TABLE dbo.bcm_movimientos (
    id         INT PRIMARY KEY,
    fecha      DATE NOT NULL,
    movimiento VARCHAR(20) NOT NULL,
    talla_34   INT,
    talla_35   INT,
    talla_36   INT,
    talla_37   INT,
    talla_38   INT,
    talla_39   INT,
    total      INT
);
GO

INSERT INTO dbo.bcm_movimientos (
    id,
    fecha,
    movimiento,
    talla_34,
    talla_35,
    talla_36,
    talla_37,
    talla_38,
    talla_39,
    total
)
SELECT
    id,
    fecha,
    UPPER(LTRIM(RTRIM(movimiento))) AS movimiento,
    talla_34,
    talla_35,
    talla_36,
    talla_37,
    talla_38,
    talla_39,
    total
FROM dbo.bcm_movimientos_raw;
GO



---------------------------------------------------------------
-- 4. TABLA DE HECHOS (ENTRADA / SALIDA CON SIGNO)
---------------------------------------------------------------
-- Entradas suman, salidas restan en 'cantidad_real'

IF OBJECT_ID('dbo.bcm_hechos', 'U') IS NOT NULL
    DROP TABLE dbo.bcm_hechos;
GO

CREATE TABLE dbo.bcm_hechos (
    id            INT PRIMARY KEY,
    fecha         DATE NOT NULL,
    movimiento    VARCHAR(20) NOT NULL,
    talla_34      INT,
    talla_35      INT,
    talla_36      INT,
    talla_37      INT,
    talla_38      INT,
    talla_39      INT,
    total         INT,
    cantidad_real INT
);
GO

INSERT INTO dbo.bcm_hechos (
    id,
    fecha,
    movimiento,
    talla_34,
    talla_35,
    talla_36,
    talla_37,
    talla_38,
    talla_39,
    total,
    cantidad_real
)
SELECT
    id,
    fecha,
    movimiento,
    talla_34,
    talla_35,
    talla_36,
    talla_37,
    talla_38,
    talla_39,
    total,
    CASE
        WHEN movimiento = 'ENTRADA' THEN total
        WHEN movimiento = 'SALIDA'  THEN -1 * total
        ELSE 0
    END AS cantidad_real
FROM dbo.bcm_movimientos;
GO



---------------------------------------------------------------
-- 5. TABLA DE STOCK ACUMULADO
---------------------------------------------------------------
-- Calcula el stock acumulado a lo largo del tiempo
-- usando la columna 'cantidad_real'.

IF OBJECT_ID('dbo.bcm_stock', 'U') IS NOT NULL
    DROP TABLE dbo.bcm_stock;
GO

CREATE TABLE dbo.bcm_stock (
    id              INT PRIMARY KEY,
    fecha           DATE NOT NULL,
    movimiento      VARCHAR(20) NOT NULL,
    total           INT,
    cantidad_real   INT,
    stock_acumulado INT
);
GO

INSERT INTO dbo.bcm_stock (
    id,
    fecha,
    movimiento,
    total,
    cantidad_real,
    stock_acumulado
)
SELECT
    h.id,
    h.fecha,
    h.movimiento,
    h.total,
    h.cantidad_real,
    SUM(h.cantidad_real) OVER (
        ORDER BY h.fecha, h.id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS stock_acumulado
FROM dbo.bcm_hechos AS h;
GO



---------------------------------------------------------------
-- 6. CONSULTAS DE ANÁLISIS (EJEMPLOS)
---------------------------------------------------------------

-- 6.1 Evolución del stock por fecha
SELECT
    fecha,
    stock_acumulado
FROM dbo.bcm_stock
ORDER BY fecha, id;


-- 6.2 Entradas y salidas por mes
SELECT
    YEAR(fecha) AS anio,
    MONTH(fecha) AS mes,
    SUM(CASE WHEN movimiento = 'ENTRADA' THEN total ELSE 0 END) AS total_entradas,
    SUM(CASE WHEN movimiento = 'SALIDA'  THEN total ELSE 0 END) AS total_salidas
FROM dbo.bcm_movimientos
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY anio, mes;


-- 6.3 Consumo (salidas) mensual por talla
SELECT
    YEAR(fecha) AS anio,
    MONTH(fecha) AS mes,
    SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_34 ELSE 0 END) AS consumo_34,
    SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_35 ELSE 0 END) AS consumo_35,
    SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_36 ELSE 0 END) AS consumo_36,
    SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_37 ELSE 0 END) AS consumo_37,
    SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_38 ELSE 0 END) AS consumo_38,
    SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_39 ELSE 0 END) AS consumo_39
FROM dbo.bcm_movimientos
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY anio, mes;



---------------------------------------------------------------
-- 7. PROMEDIO MENSUAL DE CONSUMO POR TALLA
---------------------------------------------------------------

WITH ConsumosMensuales AS (
    SELECT
        YEAR(fecha) AS anio,
        MONTH(fecha) AS mes,
        SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_34 ELSE 0 END) AS consumo_34,
        SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_35 ELSE 0 END) AS consumo_35,
        SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_36 ELSE 0 END) AS consumo_36,
        SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_37 ELSE 0 END) AS consumo_37,
        SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_38 ELSE 0 END) AS consumo_38,
        SUM(CASE WHEN movimiento = 'SALIDA' THEN talla_39 ELSE 0 END) AS consumo_39
    FROM dbo.bcm_movimientos
    GROUP BY YEAR(fecha), MONTH(fecha)
)
SELECT
    AVG(consumo_34) AS promedio_mensual_34,
    AVG(consumo_35) AS promedio_mensual_35,
    AVG(consumo_36) AS promedio_mensual_36,
    AVG(consumo_37) AS promedio_mensual_37,
    AVG(consumo_38) AS promedio_mensual_38,
    AVG(consumo_39) AS promedio_mensual_39
FROM ConsumosMensuales;
