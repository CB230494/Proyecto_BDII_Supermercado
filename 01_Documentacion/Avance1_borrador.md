# Avance 1 - Borrador

## Nombre del proyecto
Data Mart de Ventas - Supermercado Nova

## Organización
Supermercado Nova es una organización ficticia con tres sucursales: Cartago, Oreamuno y Paraiso.

## Proceso seleccionado
Ventas.

## Problema
El supermercado registra sus ventas, pero no dispone de una estructura analítica que permita analizar históricamente el comportamiento por producto, categoría, sucursal, período y método de pago.

## Objetivo general
Construir un Data Mart que permita integrar, organizar y analizar las ventas del supermercado para apoyar el análisis comercial.

## Preguntas analíticas
1. ¿Cuánto dinero se vende por mes?
2. ¿Qué productos generan mayores ventas?
3. ¿Qué categorías generan mayores ingresos?
4. ¿Cómo se comportan las ventas entre sucursales?
5. ¿Qué métodos de pago utilizan más los clientes?

## Fuentes
- productos.csv
- ventas.csv

## Arquitectura
CSV -> STAGING -> ETL/ELT -> Data Mart -> Consultas analíticas -> Oracle APEX

## Modelo dimensional preliminar
- FACT_VENTAS
- DIM_TIEMPO
- DIM_PRODUCTO
- DIM_SUCURSAL
- DIM_METODO_PAGO
