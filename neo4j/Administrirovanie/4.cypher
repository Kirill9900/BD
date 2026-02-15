// Уникальность номера водительского удостоверения
CREATE CONSTRAINT driver_license_unique IF NOT EXISTS
FOR (d:Driver) REQUIRE d.licenseNumber IS UNIQUE;

// Уникальность госномера
CREATE CONSTRAINT vehicle_plate_unique IF NOT EXISTS
FOR (v:Vehicle) REQUIRE v.licensePlate IS UNIQUE;

// Обязательное поле (EXISTS)
CREATE CONSTRAINT driver_name_exists IF NOT EXISTS
FOR (d:Driver) REQUIRE d.firstName IS NOT NULL;

// Проверка созданных ограничений
SHOW CONSTRAINTS;


// Индекс по имени водителя (для быстрого поиска)
CREATE INDEX driver_name_index IF NOT EXISTS
FOR (d:Driver) ON (d.firstName, d.lastName);

PROFILE MATCH (d:Driver {firstName: 'Сергей'}) RETURN d;

// Индекс по году выпуска транспорта
CREATE INDEX vehicle_year_index IF NOT EXISTS
FOR (v:Vehicle) ON (v.year);

PROFILE MATCH (v:Vehicle {year: 2020}) RETURN v;

// Удалить индекс по имени и фамилии водителя
DROP INDEX driver_name_index IF EXISTS;

// Удалить индекс по году выпуска транспорта
DROP INDEX vehicle_year_index IF EXISTS;

// Просмотр индексов
SHOW INDEXES;


