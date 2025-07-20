-- =================================================================================================
-- PASO 1: CREAR UN STREAM PARA LEER LOS DATOS DE ORIGEN EN FORMATO AVRO
-- =================================================================================================
-- Este stream se conecta al topic 'sales_transactions', que es alimentado por el conector JDBC.

CREATE STREAM SALES_SOURCE_STREAM (
  transaction_id VARCHAR,
  product_id VARCHAR,
  category VARCHAR,
  quantity INT,
  price DECIMAL(10, 2), -- Definición clave para decodificar el precio
  `timestamp` BIGINT
) WITH (
  KAFKA_TOPIC = 'sales_transactions', -- <-- CORRECCIÓN APLICADA AQUÍ
  VALUE_FORMAT = 'AVRO'
);

-- =================================================================================================
-- PASO 2: CREAR LA TABLA AGREGADA CON SALIDA EN FORMATO JSON
-- =================================================================================================
-- Esta tabla lee del stream anterior (SALES_SOURCE_STREAM)
-- Agrupa los datos por 'category' en ventanas de 1 minuto (WINDOW TUMBLING).

CREATE TABLE SALES_SUMMARY_BY_CATEGORY
  WITH (KAFKA_TOPIC='sales-summary', VALUE_FORMAT='JSON') AS
  SELECT
    category,
    SUM(quantity) AS total_quantity,
    SUM(quantity * price) AS total_revenue
  FROM SALES_SOURCE_STREAM
  WINDOW TUMBLING (SIZE 1 MINUTE)
  GROUP BY category
  EMIT CHANGES;