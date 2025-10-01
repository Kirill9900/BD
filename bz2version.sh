CREATE SCHEMA IF NOT EXISTS transport;
SET search_path TO transport, public;

-- ========================================
-- 1. СПРАВОЧНЫЕ ТАБЛИЦЫ (2 сущности)
-- ========================================

-- Таблица типов транспортных средств
CREATE TABLE vehicle_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    fuel_type VARCHAR(20) NOT NULL CHECK (fuel_type IN ('Бензин', 'Дизель', 'Электричество', 'Гибрид')),
    avg_consumption DECIMAL(5,2) CHECK (avg_consumption >= 0)
);

-- Таблица подразделений
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE,
    contact_phone VARCHAR(15) CHECK (contact_phone ~ '^\+?[0-9\-\(\)\s]+$')
);

-- ========================================
-- 2. ОСНОВНЫЕ СУЩНОСТИ (4 сущности)
-- ========================================

-- Таблица транспортных средств
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    license_plate VARCHAR(10) NOT NULL UNIQUE CHECK (license_plate ~ '^[А-Я0-9]+$'),
    model VARCHAR(50) NOT NULL,
    year INTEGER NOT NULL CHECK (year BETWEEN 1990 AND EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    type_id INTEGER NOT NULL REFERENCES vehicle_types(type_id) ON DELETE RESTRICT,
    dept_id INTEGER NOT NULL REFERENCES departments(dept_id) ON DELETE RESTRICT
);

-- Таблица водителей
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    license_number VARCHAR(20) NOT NULL UNIQUE,
    phone VARCHAR(15) CHECK (phone ~ '^\+?[0-9\-\(\)\s]+$'),
    dept_id INTEGER NOT NULL REFERENCES departments(dept_id) ON DELETE RESTRICT
);

-- Таблица маршрутов
CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL,
    start_point VARCHAR(200) NOT NULL,
    end_point VARCHAR(200) NOT NULL,
    distance_km DECIMAL(8,2) NOT NULL CHECK (distance_km > 0)
);

-- Таблица поездок (центральная таблица)
CREATE TABLE trips (
    trip_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    driver_id INTEGER NOT NULL REFERENCES drivers(driver_id) ON DELETE RESTRICT,
    route_id INTEGER REFERENCES routes(route_id) ON DELETE SET NULL,
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    trip_status VARCHAR(20) NOT NULL DEFAULT 'В пути' 
        CHECK (trip_status IN ('Запланирована', 'В пути', 'Завершена', 'Отменена')),
    CHECK (end_time IS NULL OR end_time > start_time)
);

-- ========================================
-- 3. ОПЕРАЦИОННЫЕ ТАБЛИЦЫ (4 сущности)
-- ========================================

-- Таблица GPS-трекинга (партиционирована по времени)
CREATE TABLE gps_tracking (
    tracking_id SERIAL,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    trip_id INTEGER REFERENCES trips(trip_id) ON DELETE CASCADE,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10,8) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude DECIMAL(11,8) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    speed_kmh DECIMAL(5,2) CHECK (speed_kmh >= 0),
    PRIMARY KEY (tracking_id, timestamp)
) PARTITION BY RANGE (timestamp);

-- Создание партиций для GPS-трекинга (текущий и следующий год)
DO $$
DECLARE
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
    current_year INTEGER;
BEGIN
    current_year := EXTRACT(YEAR FROM CURRENT_DATE);
    
    -- Создаем партиции для текущего и следующего года
    FOR year IN current_year..(current_year + 1) LOOP
        FOR month IN 1..12 LOOP
            start_date := DATE(year || '-' || LPAD(month::TEXT, 2, '0') || '-01');
            end_date := start_date + INTERVAL '1 month';
            partition_name := 'gps_tracking_' || year || '_' || LPAD(month::TEXT, 2, '0');
            
            EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF gps_tracking FOR VALUES FROM (%L) TO (%L)',
                          partition_name, start_date, end_date);
        END LOOP;
    END LOOP;
END $$;

-- Таблица расхода топлива
CREATE TABLE fuel_consumption (
    fuel_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    trip_id INTEGER REFERENCES trips(trip_id) ON DELETE SET NULL,
    fuel_amount_liters DECIMAL(6,2) NOT NULL CHECK (fuel_amount_liters > 0),
    fuel_cost_rub DECIMAL(8,2) NOT NULL CHECK (fuel_cost_rub > 0),
    fuel_station VARCHAR(100) NOT NULL,
    refuel_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Таблица технического обслуживания
CREATE TABLE maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    maintenance_type VARCHAR(50) NOT NULL 
        CHECK (maintenance_type IN ('ТО-1', 'ТО-2', 'Ремонт', 'Диагностика', 'Замена масла', 'Прочее')),
    maintenance_date DATE NOT NULL DEFAULT CURRENT_DATE,
    cost_rub DECIMAL(8,2) CHECK (cost_rub >= 0),
    service_provider VARCHAR(100) NOT NULL
);

-- Таблица данных датчиков (партиционирована по времени)
CREATE TABLE sensor_data (
    sensor_id SERIAL,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(vehicle_id) ON DELETE CASCADE,
    trip_id INTEGER REFERENCES trips(trip_id) ON DELETE CASCADE,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    engine_temperature DECIMAL(5,2) CHECK (engine_temperature BETWEEN -50 AND 200),
    oil_pressure DECIMAL(5,2) CHECK (oil_pressure >= 0),
    battery_voltage DECIMAL(4,2) CHECK (battery_voltage BETWEEN 8 AND 16),
    PRIMARY KEY (sensor_id, timestamp)
) PARTITION BY RANGE (timestamp);

-- Партиции для датчиков (аналогично GPS)
DO $$
DECLARE
    start_date DATE;
    end_date DATE;
    partition_name TEXT;
    current_year INTEGER;
BEGIN
    current_year := EXTRACT(YEAR FROM CURRENT_DATE);
    
    FOR year IN current_year..(current_year + 1) LOOP
        FOR month IN 1..12 LOOP
            start_date := DATE(year || '-' || LPAD(month::TEXT, 2, '0') || '-01');
            end_date := start_date + INTERVAL '1 month';
            partition_name := 'sensor_data_' || year || '_' || LPAD(month::TEXT, 2, '0');
            
            EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF sensor_data FOR VALUES FROM (%L) TO (%L)',
                          partition_name, start_date, end_date);
        END LOOP;
    END LOOP;
END $$;

-- ========================================
-- 4. ИНДЕКСЫ ДЛЯ ОПТИМИЗАЦИИ
-- ========================================

-- Основные индексы
CREATE INDEX idx_vehicles_license ON vehicles(license_plate);
CREATE INDEX idx_vehicles_type_dept ON vehicles(type_id, dept_id);

CREATE INDEX idx_drivers_license ON drivers(license_number);
CREATE INDEX idx_drivers_dept ON drivers(dept_id);

CREATE INDEX idx_trips_vehicle_time ON trips(vehicle_id, start_time);
CREATE INDEX idx_trips_driver_time ON trips(driver_id, start_time);
CREATE INDEX idx_trips_status ON trips(trip_status);

-- Индексы для партиционированных таблиц
CREATE INDEX idx_gps_vehicle_time ON gps_tracking(vehicle_id, timestamp);
CREATE INDEX idx_gps_location ON gps_tracking(latitude, longitude);

CREATE INDEX idx_sensor_vehicle_time ON sensor_data(vehicle_id, timestamp);

CREATE INDEX idx_fuel_vehicle_date ON fuel_consumption(vehicle_id, refuel_timestamp);
CREATE INDEX idx_fuel_timestamp ON fuel_consumption(refuel_timestamp);

CREATE INDEX idx_maintenance_vehicle_date ON maintenance(vehicle_id, maintenance_date);

-- ========================================
-- 5. ПРЕДСТАВЛЕНИЯ (VIEWS)
-- ========================================

-- Представление активных транспортных средств с полной информацией
CREATE VIEW active_vehicles AS
SELECT 
    v.vehicle_id,
    v.license_plate,
    v.model,
    v.year,
    vt.type_name,
    vt.fuel_type,
    d.dept_name
FROM vehicles v
JOIN vehicle_types vt ON v.type_id = vt.type_id
JOIN departments d ON v.dept_id = d.dept_id;

-- Представление водителей с подразделениями
CREATE VIEW drivers_info AS
SELECT 
    dr.driver_id,
    dr.last_name || ' ' || dr.first_name as full_name,
    dr.license_number,
    dr.phone,
    d.dept_name
FROM drivers dr
JOIN departments d ON dr.dept_id = d.dept_id;

-- Представление текущих активных поездок
CREATE VIEW current_trips AS
SELECT 
    t.trip_id,
    v.license_plate,
    dr.last_name || ' ' || dr.first_name as driver_name,
    r.route_name,
    t.start_time,
    t.trip_status,
    EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - t.start_time))/3600 as hours_in_progress
FROM trips t
JOIN vehicles v ON t.vehicle_id = v.vehicle_id
JOIN drivers dr ON t.driver_id = dr.driver_id
LEFT JOIN routes r ON t.route_id = r.route_id
WHERE t.trip_status IN ('Запланирована', 'В пути');

-- Представление последних GPS позиций
CREATE VIEW last_gps_positions AS
WITH ranked_positions AS (
    SELECT 
        vehicle_id,
        latitude,
        longitude,
        speed_kmh,
        timestamp,
        ROW_NUMBER() OVER (PARTITION BY vehicle_id ORDER BY timestamp DESC) as rn
    FROM gps_tracking
    WHERE timestamp >= CURRENT_TIMESTAMP - INTERVAL '24 hours'
)
SELECT 
    rp.vehicle_id,
    v.license_plate,
    rp.latitude,
    rp.longitude,
    rp.speed_kmh,
    rp.timestamp
FROM ranked_positions rp
JOIN vehicles v ON rp.vehicle_id = v.vehicle_id
WHERE rp.rn = 1;

-- ========================================
-- 6. ФУНКЦИИ ДЛЯ БИЗНЕС-ЛОГИКИ
-- ========================================

-- Функция подсчета общего количества поездок автомобиля
CREATE OR REPLACE FUNCTION get_vehicle_trips_count(p_vehicle_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    trips_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO trips_count
    FROM trips
    WHERE vehicle_id = p_vehicle_id;
    
    RETURN trips_count;
END;
$$ LANGUAGE plpgsql;

-- Функция получения среднего расхода топлива за период
CREATE OR REPLACE FUNCTION get_avg_fuel_consumption(
    p_vehicle_id INTEGER,
    p_days INTEGER DEFAULT 30
)
RETURNS DECIMAL(5,2) AS $$
DECLARE
    avg_consumption DECIMAL(5,2);
BEGIN
    SELECT 
        CASE 
            WHEN COUNT(*) > 0 
            THEN AVG(fuel_amount_liters)
            ELSE 0 
        END
    INTO avg_consumption
    FROM fuel_consumption
    WHERE vehicle_id = p_vehicle_id
    AND refuel_timestamp >= CURRENT_DATE - INTERVAL '1 day' * p_days;
    
    RETURN COALESCE(avg_consumption, 0);
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 7. РОЛИ И ПРАВА ДОСТУПА
-- ========================================

-- Создание ролей
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'transport_admin') THEN
        CREATE ROLE transport_admin;
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'transport_dispatcher') THEN
        CREATE ROLE transport_dispatcher;
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'transport_driver') THEN
        CREATE ROLE transport_driver;
    END IF;
END
$$;

-- Предоставление прав
GRANT ALL ON ALL TABLES IN SCHEMA transport TO transport_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA transport TO transport_admin;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA transport TO transport_admin;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA transport TO transport_dispatcher;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA transport TO transport_dispatcher;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA transport TO transport_dispatcher;

GRANT SELECT ON vehicles, routes, trips TO transport_driver;
GRANT INSERT ON gps_tracking, sensor_data TO transport_driver;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA transport TO transport_driver;

-- ========================================
-- 8. ТЕСТОВЫЕ ДАННЫЕ
-- ========================================

-- Вставка справочных данных
INSERT INTO vehicle_types (type_name, fuel_type, avg_consumption) VALUES
('Легковой', 'Бензин', 8.5),
('Грузовик малый', 'Дизель', 12.0),
('Грузовик средний', 'Дизель', 15.5),
('Автобус', 'Дизель', 18.0);

INSERT INTO departments (dept_name, contact_phone) VALUES
('Отдел логистики', '+7-495-123-45-67'),
('Служба доставки', '+7-495-234-56-78'),
('Пассажирские перевозки', '+7-495-345-67-89');

-- Тестовые автомобили
INSERT INTO vehicles (license_plate, model, year, type_id, dept_id) VALUES
('А123БВ199', 'Toyota Camry', 2020, 1, 1),
('В456ГД199', 'ГАЗель Next', 2021, 2, 2),
('Е789ЖЗ199', 'Volvo FH', 2019, 3, 1);

-- Тестовые водители
INSERT INTO drivers (first_name, last_name, license_number, phone, dept_id) VALUES
('Иван', 'Иванов', '77МК123456', '+7-916-123-45-67', 1),
('Петр', 'Петров', '77МК654321', '+7-916-234-56-78', 2),
('Сидор', 'Сидоров', '77МК789012', '+7-916-345-67-89', 1);

-- Тестовые маршруты
INSERT INTO routes (route_name, start_point, end_point, distance_km) VALUES
('Москва-Подольск', 'г. Москва, ул. Тверская', 'г. Подольск, пр. Ленина', 45.2),
('Офис-Склад', 'Офис центральный', 'Склад №1', 12.8),
('Кольцевая линия', 'Автовокзал', 'Микрорайон Север', 25.5);

COMMIT;

-- Сообщение о завершении
DO $$
BEGIN
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Упрощенная БД "Мониторинг транспорта" создана';
    RAISE NOTICE 'Сущностей: 10';
    RAISE NOTICE 'Схема: transport';
    RAISE NOTICE 'Партиционирование: GPS и датчики по месяцам';
    RAISE NOTICE 'Представления: 4 готовых view';
    RAISE NOTICE 'Функции: 2 бизнес-функции';
    RAISE NOTICE 'Роли: admin, dispatcher, driver';
    RAISE NOTICE 'Тестовые данные: добавлены';
    RAISE NOTICE '===========================================';
END $$;