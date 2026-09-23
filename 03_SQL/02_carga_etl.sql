-- 02_carga_etl.sql
-- Ejecutar después de importar los CSV en STG_PRODUCTOS y STG_VENTAS.

-- 1) PRODUCTOS
MERGE INTO DIM_PRODUCTO d
USING (
    SELECT DISTINCT
        TRIM(id_producto) AS codigo_producto,
        INITCAP(TRIM(producto)) AS producto,
        INITCAP(TRIM(categoria)) AS categoria,
        precio_base
    FROM STG_PRODUCTOS
    WHERE id_producto IS NOT NULL
) s
ON (d.codigo_producto = s.codigo_producto)
WHEN NOT MATCHED THEN
    INSERT (codigo_producto, producto, categoria, precio_base)
    VALUES (s.codigo_producto, s.producto, s.categoria, s.precio_base);

-- 2) SUCURSALES
MERGE INTO DIM_SUCURSAL d
USING (
    SELECT DISTINCT INITCAP(TRIM(sucursal)) AS sucursal
    FROM STG_VENTAS
    WHERE sucursal IS NOT NULL
) s
ON (d.sucursal = s.sucursal)
WHEN NOT MATCHED THEN
    INSERT (sucursal) VALUES (s.sucursal);

-- 3) METODOS DE PAGO
MERGE INTO DIM_METODO_PAGO d
USING (
    SELECT DISTINCT UPPER(TRIM(metodo_pago)) AS metodo_pago
    FROM STG_VENTAS
    WHERE metodo_pago IS NOT NULL
) s
ON (d.metodo_pago = s.metodo_pago)
WHEN NOT MATCHED THEN
    INSERT (metodo_pago) VALUES (s.metodo_pago);

-- 4) TIEMPO
MERGE INTO DIM_TIEMPO d
USING (
    SELECT DISTINCT TO_DATE(TRIM(fecha), 'YYYY-MM-DD') AS fecha
    FROM STG_VENTAS
    WHERE REGEXP_LIKE(TRIM(fecha), '^\d{4}-\d{2}-\d{2}$')
) s
ON (d.fecha = s.fecha)
WHEN NOT MATCHED THEN
    INSERT (fecha, dia, mes, nombre_mes, trimestre, anio)
    VALUES (
        s.fecha,
        EXTRACT(DAY FROM s.fecha),
        EXTRACT(MONTH FROM s.fecha),
        TO_CHAR(s.fecha, 'MONTH', 'NLS_DATE_LANGUAGE=SPANISH'),
        'T' || TO_CHAR(s.fecha, 'Q'),
        EXTRACT(YEAR FROM s.fecha)
    );

-- 5) FACT VENTAS
-- Reglas principales:
--   a) Normaliza sucursal con INITCAP + TRIM
--   b) Normaliza método de pago con UPPER + TRIM
--   c) Rechaza cantidad/precio nulos o <= 0
--   d) Rechaza productos inexistentes
--   e) DISTINCT ayuda a evitar duplicados exactos del staging
INSERT INTO FACT_VENTAS (
    id_venta, id_tiempo, id_producto_sk, id_sucursal,
    id_metodo_pago, cantidad, precio_unitario, monto_venta
)
SELECT DISTINCT
    TRIM(v.id_venta),
    t.id_tiempo,
    p.id_producto_sk,
    s.id_sucursal,
    m.id_metodo_pago,
    TO_NUMBER(v.cantidad),
    TO_NUMBER(v.precio_unitario),
    TO_NUMBER(v.cantidad) * TO_NUMBER(v.precio_unitario)
FROM STG_VENTAS v
JOIN DIM_TIEMPO t
  ON t.fecha = TO_DATE(TRIM(v.fecha), 'YYYY-MM-DD')
JOIN DIM_PRODUCTO p
  ON p.codigo_producto = TRIM(v.id_producto)
JOIN DIM_SUCURSAL s
  ON s.sucursal = INITCAP(TRIM(v.sucursal))
JOIN DIM_METODO_PAGO m
  ON m.metodo_pago = UPPER(TRIM(v.metodo_pago))
WHERE REGEXP_LIKE(TRIM(v.cantidad), '^\d+$')
  AND REGEXP_LIKE(TRIM(v.precio_unitario), '^\d+(\.\d+)?$')
  AND TO_NUMBER(v.cantidad) > 0
  AND TO_NUMBER(v.precio_unitario) > 0;

COMMIT;
