-- generate_remaining_data.sql
-- Заполняет sensor_data, fuel_consumption и maintenance, если они пустые.
SET search_path TO transport;
\timing on

BEGIN;

-- 1) Данные датчиков (взять каждую 4-ю GPS-запись)
SET search_path TO transport;

DO $$
DECLARE
    cnt BIGINT;
BEGIN
    SELECT COUNT(*) INTO cnt FROM sensor_data;
    IF cnt = 0 THEN
        RAISE NOTICE 'sensor_data пустой — начинаю вставку...';
        INSERT INTO sensor_data (vehicle_id, trip_id, timestamp, engine_temperature, oil_pressure, battery_voltage)
        SELECT
            gt.vehicle_id,
            gt.trip_id,
            gt.timestamp,
            ROUND((70 + random()*50 + CASE WHEN gt.speed_kmh > 80 THEN 10 ELSE 0 END)::numeric, 2) AS engine_temperature,
            ROUND((2.5 + random()*2.5)::numeric, 2) AS oil_pressure,
            ROUND((12.0 + random()*2.8)::numeric, 2) AS battery_voltage
        FROM (
            SELECT vehicle_id, trip_id, timestamp, speed_kmh,
                   ROW_NUMBER() OVER (PARTITION BY trip_id ORDER BY timestamp) as rn
            FROM gps_tracking
        ) gt
        WHERE gt.rn % 4 = 1; -- каждая 4-я запись
        RAISE NOTICE 'Вставлено записей в sensor_data: %', (SELECT COUNT(*) FROM sensor_data);
    ELSE
        RAISE NOTICE 'sensor_data не пустой (%), пропускаю вставку', cnt;
    END IF;
END
$$;

-- 2) Заправки
DO $$
DECLARE
    cnt BIGINT;
BEGIN
    SELECT COUNT(*) INTO cnt FROM fuel_consumption;
    IF cnt = 0 THEN
        RAISE NOTICE 'fuel_consumption пустой — начинаю вставку...';
        INSERT INTO fuel_consumption (vehicle_id, trip_id, fuel_amount_liters, fuel_cost_rub, fuel_station, refuel_timestamp)
        SELECT 
            t.vehicle_id,
            t.trip_id,
            ROUND(
              CASE 
                WHEN vt.type_name LIKE '%Легковой%' THEN (30 + random()*30)
                WHEN vt.type_name LIKE '%Грузовик%' THEN (80 + random()*120)
                WHEN vt.type_name LIKE '%Автобус%' THEN (100 + random()*150)
                ELSE (40 + random()*40)
              END::numeric, 2
            )::numeric(6,2) AS fuel_amount_liters,
            ROUND(((30 + random()*30) * (55 + random()*10))::numeric, 2)::numeric(8,2) AS fuel_cost_rub,
            (ARRAY['Лукойл','Роснефть','Газпром нефть','Татнефть','Shell','BP','Total'])[(floor(random()*7)+1)::int] || ' АЗС' AS fuel_station,
            t.start_time + (t.end_time - t.start_time) * random() AS refuel_timestamp
        FROM trips t
        JOIN vehicles v ON t.vehicle_id = v.vehicle_id
        JOIN vehicle_types vt ON v.type_id = vt.type_id
        WHERE t.trip_status = 'Завершена'
          AND random() < 0.15;
        RAISE NOTICE 'Вставлено записей в fuel_consumption: %', (SELECT COUNT(*) FROM fuel_consumption);
    ELSE
        RAISE NOTICE 'fuel_consumption не пустой (%), пропускаю вставку', cnt;
    END IF;
END
$$;


-- 3) Техобслуживание — 1-2 записи на автомобиль 
DO $$
DECLARE
    cnt BIGINT;
BEGIN
    SELECT COUNT(*) INTO cnt FROM maintenance;
    IF cnt = 0 THEN
        RAISE NOTICE 'maintenance пустой — начинаю вставку...';
        INSERT INTO maintenance (vehicle_id, maintenance_type, maintenance_date, cost_rub, service_provider)
        SELECT 
            v.vehicle_id,
            (ARRAY['ТО-1','ТО-2','Ремонт','Диагностика','Замена масла'])[(floor(random()*5)+1)::int] AS maintenance_type,
            CURRENT_DATE - (floor(random()*365))::INT AS maintenance_date,
            ROUND(
              CASE WHEN v.year >= 2020 THEN (5000 + random()*15000)
                   WHEN v.year >= 2015 THEN (8000 + random()*25000)
                   ELSE (12000 + random()*40000) END::numeric, 2
            )::numeric(8,2) AS cost_rub,
            'СТО №' || (floor(random()*200)+1)::INT AS service_provider
        FROM vehicles v
        CROSS JOIN generate_series(1,2) gs;
        RAISE NOTICE 'Вставлено записей в maintenance: %', (SELECT COUNT(*) FROM maintenance);
    ELSE
        RAISE NOTICE 'maintenance не пустой (%), пропускаю вставку', cnt;
    END IF;
END
$$;

COMMIT;

ANALYZE sensor_data;
ANALYZE fuel_consumption;
ANALYZE maintenance;

SELECT 'counts' AS what,
       (SELECT COUNT(*) FROM sensor_data) AS sensor_rows,
       (SELECT COUNT(*) FROM fuel_consumption) AS fuel_rows,
       (SELECT COUNT(*) FROM maintenance) AS maintenance_rows;
\timing off
