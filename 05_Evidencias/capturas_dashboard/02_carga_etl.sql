/* ============================================================
   SUPERMERCADO NOVA
   PROCESO ETL / ELT
   ============================================================ */


/* ============================================================
   1. CARGA DE DIMENSIÓN PRODUCTO
   Origen: STG_PRODUCTOS
   ============================================================ */

INSERT INTO DIM_PRODUCTO
    (CODIGO_PRODUCTO, PRODUCTO, CATEGORIA, PRECIO_BASE)
SELECT DISTINCT
    TRIM(ID_PRODUCTO),
    TRIM(PRODUCTO),
    TRIM(CATEGORIA),
    PRECIO_BASE
FROM STG_PRODUCTOS
WHERE ID_PRODUCTO IS NOT NULL
  AND PRODUCTO IS NOT NULL;


/* ============================================================
   2. CARGA DE DIMENSIÓN SUCURSAL
   ============================================================ */

INSERT INTO DIM_SUCURSAL (SUCURSAL)
SELECT DISTINCT TRIM(SUCURSAL)
FROM STG_VENTAS
WHERE SUCURSAL IS NOT NULL;


/* ============================================================
   3. CARGA DE DIMENSIÓN MÉTODO DE PAGO
   ============================================================ */

INSERT INTO DIM_METODO_PAGO (METODO_PAGO)
SELECT DISTINCT TRIM(METODO_PAGO)
FROM STG_VENTAS
WHERE METODO_PAGO IS NOT NULL;


/* ============================================================
   4. CARGA DE DIMENSIÓN TIEMPO
   Convierte FECHA desde VARCHAR2 a DATE
   ============================================================ */

INSERT INTO DIM_TIEMPO
    (FECHA, DIA, MES, NOMBRE_MES, TRIMESTRE, ANIO)
SELECT DISTINCT
    FECHA_CONVERTIDA,
    EXTRACT(DAY FROM FECHA_CONVERTIDA),
    EXTRACT(MONTH FROM FECHA_CONVERTIDA),
    TO_CHAR(FECHA_CONVERTIDA, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH'),
    'T' || TO_CHAR(FECHA_CONVERTIDA, 'Q'),
    EXTRACT(YEAR FROM FECHA_CONVERTIDA)
FROM (
    SELECT
        TO_DATE(TRIM(FECHA), 'YYYY-MM-DD') AS FECHA_CONVERTIDA
    FROM STG_VENTAS
    WHERE VALIDATE_CONVERSION(
              TRIM(FECHA) AS DATE,
              'YYYY-MM-DD'
          ) = 1
);


/* ============================================================
   5. LIMPIEZA Y CARGA DE FACT_VENTAS

   Controles aplicados:
   - Cantidad no nula y mayor que cero.
   - Precio unitario mayor que cero.
   - Producto existente en DIM_PRODUCTO.
   - Eliminación de registros duplicados.
   - Conversión de tipos de datos.
   ============================================================ */

INSERT INTO FACT_VENTAS
(
    ID_VENTA,
    ID_TIEMPO,
    ID_PRODUCTO_SK,
    ID_SUCURSAL,
    ID_METODO_PAGO,
    CANTIDAD,
    PRECIO_UNITARIO,
    MONTO_VENTA
)
SELECT
    x.ID_VENTA,
    dt.ID_TIEMPO,
    dp.ID_PRODUCTO_SK,
    ds.ID_SUCURSAL,
    dm.ID_METODO_PAGO,
    x.CANTIDAD_NUM,
    x.PRECIO_NUM,
    x.CANTIDAD_NUM * x.PRECIO_NUM
FROM
(
    SELECT
        ID_VENTA,
        FECHA,
        ID_PRODUCTO,
        SUCURSAL,
        METODO_PAGO,

        TO_NUMBER(TRIM(CANTIDAD)) AS CANTIDAD_NUM,
        TO_NUMBER(TRIM(PRECIO_UNITARIO)) AS PRECIO_NUM,

        ROW_NUMBER() OVER (
            PARTITION BY
                ID_VENTA,
                FECHA,
                ID_PRODUCTO,
                CANTIDAD,
                PRECIO_UNITARIO,
                SUCURSAL,
                METODO_PAGO
            ORDER BY ROWID
        ) AS NUM_REPETICION

    FROM STG_VENTAS

    WHERE CANTIDAD IS NOT NULL

      AND VALIDATE_CONVERSION(
              TRIM(CANTIDAD) AS NUMBER
          ) = 1

      AND TO_NUMBER(TRIM(CANTIDAD)) > 0

      AND PRECIO_UNITARIO IS NOT NULL

      AND VALIDATE_CONVERSION(
              TRIM(PRECIO_UNITARIO) AS NUMBER
          ) = 1

      AND TO_NUMBER(TRIM(PRECIO_UNITARIO)) > 0

      AND VALIDATE_CONVERSION(
              TRIM(FECHA) AS DATE,
              'YYYY-MM-DD'
          ) = 1

) x

JOIN DIM_PRODUCTO dp
    ON dp.CODIGO_PRODUCTO = TRIM(x.ID_PRODUCTO)

JOIN DIM_SUCURSAL ds
    ON ds.SUCURSAL = TRIM(x.SUCURSAL)

JOIN DIM_METODO_PAGO dm
    ON dm.METODO_PAGO = TRIM(x.METODO_PAGO)

JOIN DIM_TIEMPO dt
    ON dt.FECHA = TO_DATE(TRIM(x.FECHA), 'YYYY-MM-DD')

WHERE x.NUM_REPETICION = 1;


/* ============================================================
   6. CONFIRMACIÓN DE LA TRANSACCIÓN
   ============================================================ */

COMMIT;


/* ============================================================
   7. CONSULTAS DE VERIFICACIÓN
   ============================================================ */

SELECT COUNT(*) AS PRODUCTOS
FROM DIM_PRODUCTO;

SELECT COUNT(*) AS SUCURSALES
FROM DIM_SUCURSAL;

SELECT COUNT(*) AS METODOS_PAGO
FROM DIM_METODO_PAGO;

SELECT COUNT(*) AS FECHAS
FROM DIM_TIEMPO;

SELECT COUNT(*) AS VENTAS_CARGADAS
FROM FACT_VENTAS;