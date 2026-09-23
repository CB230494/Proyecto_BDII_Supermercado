-- 03_consultas_analiticas.sql

-- 1. Ventas por mes
SELECT
    t.anio,
    t.mes,
    TRIM(t.nombre_mes) AS mes_nombre,
    SUM(f.monto_venta) AS total_ventas
FROM FACT_VENTAS f
JOIN DIM_TIEMPO t ON t.id_tiempo = f.id_tiempo
GROUP BY t.anio, t.mes, TRIM(t.nombre_mes)
ORDER BY t.anio, t.mes;

-- 2. Productos con mayores ventas
SELECT
    p.producto,
    SUM(f.cantidad) AS unidades,
    SUM(f.monto_venta) AS total_ventas
FROM FACT_VENTAS f
JOIN DIM_PRODUCTO p ON p.id_producto_sk = f.id_producto_sk
GROUP BY p.producto
ORDER BY total_ventas DESC;

-- 3. Ventas por categoria
SELECT
    p.categoria,
    SUM(f.monto_venta) AS total_ventas
FROM FACT_VENTAS f
JOIN DIM_PRODUCTO p ON p.id_producto_sk = f.id_producto_sk
GROUP BY p.categoria
ORDER BY total_ventas DESC;

-- 4. Ventas por sucursal
SELECT
    s.sucursal,
    COUNT(DISTINCT f.id_venta) AS tickets,
    SUM(f.monto_venta) AS total_ventas
FROM FACT_VENTAS f
JOIN DIM_SUCURSAL s ON s.id_sucursal = f.id_sucursal
GROUP BY s.sucursal
ORDER BY total_ventas DESC;

-- 5. Uso de metodos de pago
SELECT
    m.metodo_pago,
    COUNT(DISTINCT f.id_venta) AS cantidad_ventas,
    SUM(f.monto_venta) AS total_ventas
FROM FACT_VENTAS f
JOIN DIM_METODO_PAGO m ON m.id_metodo_pago = f.id_metodo_pago
GROUP BY m.metodo_pago
ORDER BY cantidad_ventas DESC;

-- 6. Ticket promedio
SELECT
    ROUND(AVG(total_ticket), 2) AS ticket_promedio
FROM (
    SELECT id_venta, SUM(monto_venta) AS total_ticket
    FROM FACT_VENTAS
    GROUP BY id_venta
);
