# Tarea - Entorno Kafka Streaming

## Descripción del Entorno

Este proyecto implementa un entorno completo de Apache Kafka con arquitectura distribuida usando **Confluent Platform 7.8.0**. El sistema está diseñado para el procesamiento de datos en tiempo real de FarmIA, incluyendo telemetría de sensores y transacciones de ventas.

## Arquitectura del Sistema Kafka

### 📐 Componentes Principales

```
┌─────────────────────────────────────────────────────┐
│                           KAFKA CLUSTER             │
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │Controller-1 │  │Controller-2 │  │Controller-3 │  │
│  │   :9095     │  │   :9096     │  │   :9097     │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  Broker-1   │  │  Broker-2   │  │  Broker-3   │  │
│  │   :9092     │  │   :9093     │  │   :9094     │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  |
└─────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌───────────────────────────────────────────────────────────┐
│                        CONFLUENT ECOSYSTEM                │
│                                                           │
│  ┌────────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │Schema Registry │  │Kafka Connect │  │ KsqlDB Server│   │
│  │    :8081       │  │    :8083     │  │    :8088     │   │
│  └──────────v─────┘  └──────────────┘  └──────────────┘   │
│                                                           │
│  ┌──────────────┐  ┌──────────────┐                       │
│  │Control Center│  │  KsqlDB CLI  │                       │
│  │    :9021     │  │              │                       │
│  └──────────────┘  └──────────────┘                       │
└───────────────────────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────┐
│                          DATA STORAGE   │
│                                         │
│  ┌──────────────┐  ┌──────────────┐     │
│  │    MySQL     │  │  phpMyAdmin  │     │
│  │    :3306     │  │    :8080     │     │
│  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────┘
```

### 🏗️ Detalles de Arquitectura

#### **Kafka Cluster (KRaft Mode)**
- **Controllers**: 3 nodos dedicados para metadatos y coordinación
  - Quorum distribuido para alta disponibilidad
  - Cluster ID: `Nk018hRAQFytWskYqtQduw`
- **Brokers**: 3 nodos para almacenamiento y distribución de mensajes
  - Replicación configurada para tolerancia a fallos
  - Load balancing automático

#### **Confluent Platform Services**
- **Schema Registry**: Gestión centralizada de esquemas Avro
- **Kafka Connect**: Integración con sistemas externos
- **KsqlDB**: Procesamiento de streams en tiempo real
- **Control Center**: Monitoreo y gestión del cluster

#### **Persistencia de Datos**
- **MySQL 8.3**: Base de datos transaccional
- **phpMyAdmin**: Interfaz web para administración

## 🔗 Enlaces de Servicios

### Servicios Web
- **Confluent Control Center**: [http://localhost:9021](http://localhost:9021)
- **Schema Registry**: [http://localhost:8081](http://localhost:8081)
- **Kafka Connect**: [http://localhost:8083](http://localhost:8083)
- **KsqlDB Server**: [http://localhost:8088](http://localhost:8088)
- **phpMyAdmin**: [http://localhost:8080](http://localhost:8080)

### Endpoints Kafka
- **Broker-1**: `localhost:9092`
- **Broker-2**: `localhost:9093`
- **Broker-3**: `localhost:9094`

### Base de Datos
- **MySQL**: `localhost:3306`
  - Usuario: `root` / Password: `password`
  - Base de datos: `db`
  - Usuario aplicación: `user` / Password: `password`

## 🚀 Flujo de Datos

### Conectores Implementados
1. **source-datagen-_transactions**: Genera transacciones sintéticas
2. **sink-mysql-_transactions**: Almacena transacciones en MySQL

### Conectores a Desarrollar
1. **source-datagen-sensor-telemetry**: Telemetría de sensores IoT
2. **source-mysql-transactions**: Lectura incremental de transacciones

### Streams Processing
- **SalesSummaryApp**: Agregación de ventas por ubicación
- **SensorAlerterApp**: Alertas basadas en telemetría


*******************************************************************************************
*******************************************************************************************

## Creacion del DataGen sensor-telemetry: 
1. Definicion en source-datagen-sensor-telemetry
2. Schema en sensor-telemtry.avsc

## Alarma: 

He creado con exito la alarma que nos informa cuando la temperatura sea superior a 35grados o la humedad por debajo de 20%. 

![til](./assets/KSQLDB-flow.png)
![til](./assets/KSQLDB-streams.png)
![til](./assets/Topic-sensor-alerts.png)
![til](./assets/Topic-sensor-alerts-details.png)

El codigo de alarma Ksql esta en el archivo: sensor-telemetry-alarm.sql

## Conector MySQL Source - Transacciones de Ventas

Se ha implementado exitosamente el conector **source-mysql-transactions** que:

### ✅ Estado del Sistema
- **Conector**: ✅ RUNNING (modo bulk)
- **Autenticación**: ✅ mysql_native_password configurado
- **Topic destino**: `sales_transactions`
- **Registros procesados**: 803 transacciones sincronizadas

### 📊 Flujo de Datos Verificado
1. **DataGen** → `_datagen_transactions` topic
2. **MySQL Sink** → tabla `sales_transactions` (803 registros)
3. **MySQL Source** → topic `sales_transactions` (803 mensajes)
4. **Formato**: Avro con keys (transaction_id)

### 🎯 Datos Distribuidos
- **Categorías**: 6 (equipment, fertilizers, pesticides, seeds, soil, supplies)
- **Rango temporal**: 2025-07-17 07:34:30 → 07:41:53
- **Distribución**: ~100 transacciones por minuto
- **Sin lag**: Sincronización perfecta MySQL ↔ Kafka

### 🔄 Próximo Paso
Crear agregación en ksqlDB para sumarizar ventas por categoría y minuto, publicando al topic `sales-summary`.


