# Proyecto BDII - Supermercado Nova

Proyecto de práctica para construir un Data Mart de ventas usando:
- Oracle Database
- SQL / PL/SQL
- Archivos CSV
- Oracle APEX

## Flujo
CSV -> STAGING -> ETL/ELT -> DIMENSIONES -> FACT_VENTAS -> CONSULTAS -> APEX

## Estructura
- 01_Documentacion/
- 02_Datos/
- 03_SQL/
- 04_Modelo/
- 05_Evidencias/

## Orden de ejecución
1. Ejecutar `03_SQL/01_creacion_datamart.sql`
2. Importar `02_Datos/productos.csv` y `02_Datos/ventas.csv` a las tablas STG correspondientes.
3. Ejecutar `03_SQL/02_carga_etl.sql`
4. Ejecutar `03_SQL/03_consultas_analiticas.sql`
5. Construir el dashboard en Oracle APEX.
