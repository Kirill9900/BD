-- data_generation_fixed.sql
-- Исправленная версия генерации базовых данных (departments, vehicle_types, routes, vehicles, drivers, trips)
-- НЕ выполняет тяжелой генерации GPS (это делаем bash-скриптом отдельно)

SET search_path TO transport;
\timing on

-- Очистка (если надо) — аккуратно: удаляет все данные и сбрасывает sequences
TRUNCATE TABLE
    transport.sensor_data,
    transport.gps_tracking,
    transport.fuel_consumption,
    transport.maintenance,
    transport.trips,
    transport.drivers,
    transport.vehicles,
    transport.routes,
    transport.vehicle_types,
    transport.departments
RESTART IDENTITY CASCADE;

-- 1) departments (50)
INSERT INTO transport.departments (dept_name, contact_phone)
SELECT 'Подразделение №' || i,
       -- короткий формат телефона без дефисов, чтобы поместиться в VARCHAR(15): +7XXXXXXXXXX (12 символов)
       '+7' || LPAD((9000000000 + i)::text, 10, '0')
FROM generate_series(1,50) i;

-- 2) vehicle_types (15) — явные значения
INSERT INTO transport.vehicle_types (type_name, fuel_type, avg_consumption) VALUES
('Легковой малый', 'Бензин', 6.5),
('Легковой средний', 'Бензин', 8.5),
('Легковой премиум', 'Бензин', 11.0),
('Кроссовер', 'Бензин', 9.5),
('Внедорожник', 'Бензин', 12.5),
('Микроавтобус', 'Дизель', 10.0),
('Грузовик до 3.5т', 'Дизель', 12.0),
('Грузовик до 10т', 'Дизель', 18.0),
('Грузовик свыше 10т', 'Дизель', 25.0),
('Автобус городской', 'Дизель', 28.0),
('Автобус междугородний', 'Дизель', 22.0),
('Эвакуатор', 'Дизель', 15.0),
('Спецтехника', 'Дизель', 20.0),
('Электромобиль', 'Электричество', 0.0),
('Гибрид', 'Гибрид', 4.5);

-- 3) routes (200)
INSERT INTO transport.routes (route_name, start_point, end_point, distance_km)
SELECT
    CASE WHEN i % 4 = 0 THEN 'Городской маршрут №' || i
         WHEN i % 4 = 1 THEN 'Межгород маршрут №' || i
         WHEN i % 4 = 2 THEN 'Доставка №' || i
         ELSE 'Служебный №' || i END,
    CASE (i % 10)
        WHEN 0 THEN 'Москва, ул. Тверская, ' || (i % 100)
        WHEN 1 THEN 'СПб, Невский пр., ' || (i % 100)
        WHEN 2 THEN 'Екатеринбург, ул. Ленина, ' || (i % 100)
        WHEN 3 THEN 'Новосибирск, ул. Красный пр., ' || (i % 100)
        WHEN 4 THEN 'Казань, ул. Баумана, ' || (i % 100)
        WHEN 5 THEN 'Нижний Новгород, ул. Горького, ' || (i % 100)
        WHEN 6 THEN 'Челябинск, ул. Кирова, ' || (i % 100)
        WHEN 7 THEN 'Самара, ул. Молодогвардейская, ' || (i % 100)
        WHEN 8 THEN 'Уфа, ул. Ленина, ' || (i % 100)
        ELSE 'Ростов-на-Дону, пр. Буденновский, ' || (i % 100)
    END,
    CASE (i % 8)
        WHEN 0 THEN 'Склад №' || (i % 20 + 1)
        WHEN 1 THEN 'Офис №' || (i % 15 + 1)
        WHEN 2 THEN 'Магазин №' || (i % 50 + 1)
        WHEN 3 THEN 'Завод №' || (i % 10 + 1)
        WHEN 4 THEN 'Автовокзал'
        WHEN 5 THEN 'Аэропорт'
        WHEN 6 THEN 'ЖД вокзал'
        ELSE 'Логистический центр'
    END,
    CASE WHEN i % 4 = 0 THEN (5 + (i % 25))::DECIMAL(8,2)
         WHEN i % 4 = 1 THEN (50 + (i % 500))::DECIMAL(8,2)
         WHEN i % 4 = 2 THEN (10 + (i % 40))::DECIMAL(8,2)
         ELSE (15 + (i % 60))::DECIMAL(8,2) END
FROM generate_series(1,200) i;

-- 4) vehicles (1500) — следим, чтобы license_plate был в пределах VARCHAR(10)
INSERT INTO transport.vehicles (license_plate, model, year, type_id, dept_id)
SELECT
    -- составной госномер, всего <=10 символов; шаблон: XNNNXNNN  (пример: А123БВ199) => 9 символов
    (ARRAY['А','В','Е','К','М','Н','О','Р','С','Т','У','Х'])[1 + ( (i-1) % 12 )]
    || LPAD((100 + ((i-1) % 900))::text,3,'0')
    || (ARRAY['А','В','Е','К','М','Н','О','Р','С','Т','У','Х'])[1 + (((i-1)/12)::int % 12)],
    CASE ((i-1) % 15) + 1
        WHEN 1 THEN (ARRAY['Lada Granta','Lada Vesta','Hyundai Solaris','Kia Rio','Renault Logan'])[1 + ((i-1) % 5)]
        WHEN 2 THEN (ARRAY['Toyota Camry','Honda Accord','Mazda 6','Skoda Octavia','VW Passat'])[1 + ((i-1) % 5)]
        WHEN 3 THEN (ARRAY['Mercedes S-Class','BMW 7-series','Audi A8','Lexus LS','Genesis G90'])[1 + ((i-1) % 5)]
        WHEN 4 THEN (ARRAY['Toyota RAV4','Honda CR-V','Hyundai Tucson','Kia Sportage','Nissan Qashqai'])[1 + ((i-1) % 5)]
        WHEN 5 THEN (ARRAY['Toyota Land Cruiser','Range Rover','BMW X5','Mercedes GLS','Audi Q7'])[1 + ((i-1) % 5)]
        WHEN 6 THEN (ARRAY['Ford Transit','Mercedes Sprinter','Iveco Daily','Fiat Ducato','Hyundai H350'])[1 + ((i-1) % 5)]
        WHEN 7 THEN (ARRAY['ГАЗель Next','Ford Transit','Isuzu NPR','Hyundai HD78','BAW Fenix'])[1 + ((i-1) % 5)]
        WHEN 8 THEN (ARRAY['КАМАЗ-4308','МАЗ-4370','Volvo FL','Iveco Eurocargo','Isuzu Forward'])[1 + ((i-1) % 5)]
        WHEN 9 THEN (ARRAY['КАМАЗ-65115','МАЗ-6430','Volvo FH','Scania R-series','Mercedes Actros'])[1 + ((i-1) % 5)]
        WHEN 10 THEN (ARRAY['ЛиАЗ-5256','НефАЗ-5299','ПАЗ-320402','Mercedes Citaro','Volvo 7900'])[1 + ((i-1) % 5)]
        WHEN 11 THEN (ARRAY['Tesla Model 3','Nissan Leaf','BMW i3','Hyundai Ioniq','Kia Soul EV'])[1 + ((i-1) % 5)]
        WHEN 12 THEN (ARRAY['Toyota Prius','Honda Insight','Lexus CT200h','Camry Hybrid','RAV4 Hybrid'])[1 + ((i-1) % 5)]
        WHEN 13 THEN (ARRAY['Opel Astra','Ford Focus','Renault Megane','Peugeot 308','Seat Leon'])[1 + ((i-1) % 5)]
        WHEN 14 THEN (ARRAY['Skoda Fabia','Citroen C3','Kia Picanto','Hyundai i10','Datsun on-DO'])[1 + ((i-1) % 5)]
        ELSE (ARRAY['Generic Model A','Generic Model B','Generic Model C','Generic Model D','Generic Model E'])[1 + ((i-1) % 5)]
    END,
    CASE
        WHEN (i % 100) < 30 THEN 2020 + ((i-1) % 4)
        WHEN (i % 100) < 50 THEN 2017 + ((i-1) % 3)
        WHEN (i % 100) < 70 THEN 2014 + ((i-1) % 3)
        WHEN (i % 100) < 85 THEN 2010 + ((i-1) % 4)
        ELSE 2005 + ((i-1) % 5)
    END,
    ((i-1) % 15) + 1,
    ((i-1) % 50) + 1
FROM generate_series(1,1500) i;

-- 5) drivers (800) — phone в формате +7XXXXXXXXXX (12 символов)
INSERT INTO transport.drivers (first_name, last_name, license_number, phone, dept_id)
SELECT
    (ARRAY['Александр','Дмитрий','Максим','Сергей','Андрей','Алексей','Артём','Илья','Кирилл','Михаил',
           'Никита','Матвей','Роман','Егор','Арсений','Иван','Денис','Евгений','Даниил','Тимофей',
           'Владислав','Игорь','Владимир','Павел','Руслан','Марк','Лука','Константин','Леонид','Фёдор'])[1 + ((i-1) % 30)],
    (ARRAY['Смирнов','Иванов','Кузнецов','Соколов','Попов','Лебедев','Козлов','Новиков','Морозов','Петров',
           'Волков','Соловьёв','Васильев','Зайцев','Павлов','Семёнов','Голубев','Виноградов','Богданов','Воробьёв',
           'Фёдоров','Михайлов','Беляев','Тарасов','Белов','Комаров','Орлов','Киселёв','Макаров','Андреев'])[1 + ((i-1) % 30)],
    LPAD((77 + ((i-1) % 22))::text,2,'0') ||
      (ARRAY['AA','AB','AE','AK','AM','AN','AO','AR','AS','AT','VA','VB','VE','VK','VM'])[1 + ((i-1) % 15)]
      || LPAD((100000 + i)::text,6,'0'),
    '+7' || LPAD((9000000000 + i)::text,10,'0'),
    ((i-1) % 50) + 1
FROM generate_series(1,800) i;

-- 6) trips (150000 поездок — можно изменить число)
-- ВНИМАНИЕ: выбери разумное значение; 150000 даёт хорошую базу для миллионов GPS
INSERT INTO transport.trips (vehicle_id, driver_id, route_id, start_time, end_time, trip_status)
SELECT
    ( (i-1) % 1500 ) + 1,
    ( (i-1) % 800 ) + 1,
    ( (i-1) % 200 ) + 1,
    CURRENT_DATE - INTERVAL '90 days' + ( (i-1) % 90 ) * INTERVAL '1 day' + (6 + ((i-1) % 16)) * INTERVAL '1 hour' + ((i-1) % 60) * INTERVAL '1 minute',
    -- end_time = start_time + (0.5 .. 8) hours
    (CURRENT_DATE - INTERVAL '90 days' + ( (i-1) % 90 ) * INTERVAL '1 day' + (6 + ((i-1) % 16)) * INTERVAL '1 hour' + ((i-1) % 60) * INTERVAL '1 minute')
      + ((0.5 + ((i-1) % 75) * 0.1) * INTERVAL '1 hour'),
    CASE WHEN (i % 100) < 95 THEN 'Завершена' ELSE 'В пути' END
FROM generate_series(1,150000) i;

-- Обновляем статистику
ANALYZE transport.trips;

-- Финальная нотификация
DO $$
BEGIN
  RAISE NOTICE 'БАЗОВЫЕ ДАННЫЕ СГЕНЕРИРОВАНЫ: Departments, vehicle_types, routes, vehicles, drivers, trips';
END$$;

\timing off
