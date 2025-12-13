# Análisis de Inventario — Suela BCM (2021–2022)

**Autor:** Carlos Hernández Godoy  
**Perfil:** Analista de Datos | Ingeniero Industrial  
**Año:** 2025  

## Contexto del proyecto

Este proyecto analiza el inventario histórico de la **suela BCM** durante los años **2021 y 2022**, utilizando datos operativos reales generados en un entorno de producción de calzado.

El análisis se enfoca en transformar registros transaccionales de inventario en información estructurada y accionable para **operaciones, compras y planificación**, permitiendo evaluar niveles de stock, rotación por talla y riesgos de desabastecimiento.

El enfoque es **operativo y ejecutivo**, orientado a apoyar la toma de decisiones relacionadas con continuidad productiva, control de inventarios y reabastecimiento.

## Objetivos del análisis

- Calcular el **stock acumulado** y el stock actual disponible.
- Analizar la **evolución del inventario** en el tiempo.
- Identificar **picos de inventario** y **caídas críticas**.
- Evaluar la **rotación histórica por talla**.
- Estimar el **consumo mensual promedio por talla**.
- Detectar **riesgos de quiebre de stock**.
- Proponer **cantidades recomendadas de compra** para 1–2 meses de demanda.

## Estructura del repositorio

inventario-suelas-bcm-2021-2022/
├── 01_data/
│ ├── bcm_movimientos_original.xlsx
│ └── bcm_movimientos_limpio.xlsx
├── 02_dax/
│ └── medidas_bcm_dax.txt
├── 03_img/
│ └── dashboard_bcm.png
├── 04_pbix/
│ └── bcm-inventario-bcm-dashboard.pbix
├── 05_sql/
│ └── sql_modelado_y_analisis_bcm.sql
└── 06_README.md

## Datos utilizados

- **Fuente:** Registros internos de movimientos de inventario.
- **Periodo analizado:** 2021–2022.
- **Variables clave:**
  - Fecha
  - Movimiento (Entrada / Salida)
  - Cantidades por talla (34 a 39)
  - Total de pares por movimiento

**Nota:**  
Durante la fase de limpieza se corrigieron inconsistencias en el año de algunas fechas, manteniendo intactos los valores operativos de entradas y salidas.

## Tecnologías y herramientas

### SQL Server
- Limpieza y validación de datos.
- Corrección de fechas y estandarización de valores.
- Modelado de datos:
  - Tabla de movimientos
  - Tabla de hechos con lógica de signo (entradas positivas, salidas negativas)
- Cálculo de **stock acumulado** mediante funciones ventana.
- Consultas analíticas para consumo y rotación.
- Archivo: `05_sql/sql_modelado_y_analisis_bcm.sql`

### Power BI
- Power Query para transformación y limpieza ligera.
- Creación de tabla calendario y tabla de tallas.
- Medidas DAX para:
  - Stock actual
  - Stock por talla
  - Entradas y salidas
  - Consumo mensual
  - Consumo mensual promedio por talla
- Construcción de dashboard interactivo orientado a decisión.
- Archivo: `04_pbix/bcm-inventario-bcm-dashboard.pbix`

### IA (ChatGPT)
- Apoyo en la estructuración del análisis.
- Validación de enfoques analíticos y métricas.
- Asistencia en documentación y narrativa técnica.
- Utilizada como **herramienta de apoyo**, no como sustituto del criterio del analista.

## Modelado y lógica analítica

El análisis se basa en una **tabla de hechos** donde cada movimiento de inventario se traduce en una cantidad real:

- **Entrada:** valor positivo  
- **Salida:** valor negativo  

El **stock acumulado** se calcula de forma cronológica para reflejar el nivel real de inventario en cada fecha.

Para el análisis por talla:
- Se evalúa la rotación histórica.
- Se calcula el consumo mensual promedio.
- Se compara el stock actual contra la demanda promedio para identificar riesgos de desabastecimiento.

## Medidas DAX (resumen)

Las principales medidas incluyen:
- Stock Actual
- Stock Actual por Talla
- Entradas
- Salidas
- Consumo Mensual por Talla
- Consumo Mensual Promedio por Talla

Documentadas en `02_dax/medidas_bcm_dax.txt`.

## Dashboard — Resumen Ejecutivo

El dashboard presenta:

- KPI de **stock actual total**.
- Evolución del stock en el tiempo.
- Entradas y salidas por mes.
- Distribución del **stock actual por talla**.
- **Consumo mensual promedio por talla**.
- Visualizaciones orientadas a identificar riesgos operativos.

Captura disponible en `03_img/dashboard_bcm.png`.

## Principales insights

- El **stock actual total** es de **624 pares**, con una distribución desigual entre tallas.
- Las tallas **36 y 37** presentan la **mayor rotación**, con consumos promedio de ~571 y ~592 pares/mes.
- Se identificaron **picos de inventario** superiores a 8,000 pares debido a entradas masivas.
- Se registraron múltiples **caídas críticas**, siendo la más baja cercana a 178 pares.
- Las tallas **36 y 37** mostraron riesgo recurrente de quiebre de stock.
- Las tallas **34 y 39** presentan menor rotación relativa.

## Recomendaciones

- Priorizar el reabastecimiento de las tallas **36 y 37**.
- Definir **niveles mínimos de stock** basados en el consumo mensual promedio.
- Evitar sobreinventario en tallas de baja rotación.
- Implementar seguimiento periódico del inventario para anticipar quiebres.
- Mejorar la estandarización del registro de movimientos de inventario.

## Nota sobre variaciones entre SQL y Power BI

En el cálculo del **consumo mensual promedio por talla** puede observarse una variación mínima (±1 par) entre SQL y Power BI.

Esto se debe a diferencias en cómo cada herramienta agrupa y promedia los meses con y sin consumo real. Esta variación es **normal** y **no afecta las conclusiones del análisis**.

## Conclusión

Análisis integral de inventarios que combina **SQL, modelado de datos, lógica analítica y visualización en Power BI**, proporcionando una visión clara del comportamiento del stock y sirviendo como apoyo directo para decisiones de compras y planificación operativa.

## Contacto

Carlos Hernández Godoy  
Analista de Datos | SQL + Power BI | Ingeniero Industrial  
**Correo:** carloshernandez.data@gmail.com
