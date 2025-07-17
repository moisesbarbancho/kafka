-- Este script crea una alarma cuando la temperatura supera los 35°C o la humedad es inferior al 20%.
-- alertas.ksql
CREATE STREAM sensor_readings (
    sensor_id VARCHAR,
    timestamp BIGINT,
    temperature DOUBLE,
    humidity DOUBLE,
    soil_fertility DOUBLE
) WITH (
    KAFKA_TOPIC='sensor-telemetry-fixed',
    VALUE_FORMAT='AVRO'
);

CREATE STREAM sensor_alerts 
WITH (
    KAFKA_TOPIC='sensor-alerts',
    VALUE_FORMAT='JSON'
) AS
SELECT 
    sensor_id,
    CASE 
        WHEN temperature > 35.0 THEN 'HIGH_TEMPERATURE'
        WHEN humidity < 20.0 THEN 'LOW_HUMIDITY'
    END as alert_type,
    timestamp,
    CASE 
        WHEN temperature > 35.0 THEN CONCAT('Temperature exceeded 35°C (', CAST(temperature AS STRING), '°C)')
        WHEN humidity < 20.0 THEN CONCAT('Humidity below 20% (', CAST(humidity AS STRING), '%)')
    END as details
FROM sensor_readings
WHERE temperature > 35.0 OR humidity < 20.0;