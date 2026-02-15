// ШАГ 1: Минимум 3 узла и 2 связи с использованием MERGE

// Создание транспорта (Vehicle)
MERGE (v1:Vehicle {licensePlate: 'Р205ХВ58'})
SET v1.model = 'МАЗ 5440',
    v1.year = 2022,
    v1.vinNumber = 'HD94LK6FA7AYSBEL9',
    v1.type = 'Грузовик малый',
    v1.fuelType = 'Дизель',
    v1.isActive = true,

MERGE (v2:Vehicle {licensePlate: 'А123ВС99'})
SET v2.model = 'КАМАЗ 6520',
    v2.year = 2021,
    v2.type = 'Грузовик большой',
    v2.fuelType = 'Дизель',
    v2.isActive = true;

MERGE (v3:Vehicle {licensePlate: 'Т456МН77'})
SET v3.model = 'ГАЗель NEXT',
    v3.year = 2023,
    v3.type = 'Фургон',
    v3.fuelType = 'Бензин',
    v3.isActive = true;

// Создание водителей (Driver)
MERGE (d1:Driver {licenseNumber: '16АА538858'})
SET d1.firstName = 'Сергей',
    d1.lastName = 'Петров',
    d1.middleName = 'Владимирович',
    d1.phone = '+7-911-503-48-58',
    d1.departmentName = 'Пассажирские перевозки',
    d1.experienceYears = 8;

MERGE (d2:Driver {licenseNumber: '77ВВ912345'})
SET d2.firstName = 'Иван',
    d2.lastName = 'Иванов',
    d2.middleName = 'Петрович',
    d2.phone = '+7-905-123-45-67',
    d2.departmentName = 'Отдел логистики',
    d2.experienceYears = 12;

MERGE (d3:Driver {licenseNumber: '50СС778899'})
SET d3.firstName = 'Алексей',
    d3.lastName = 'Смирнов',
    d3.middleName = 'Николаевич',
    d3.phone = '+7-921-555-66-77',
    d3.departmentName = 'Срочные доставки',
    d3.experienceYears = 5;

// Создание маршрутов (Route)
MERGE (r1:Route {name: 'Казань - Владимир'})
SET r1.startPoint = 'Казань, ул. Складская 76',
    r1.endPoint = 'Владимир, ул. Промышленная 54',
    r1.distanceKm = 1262,
    r1.estimatedTimeMinutes = 1262;

MERGE (r2:Route {name: 'Москва - Санкт-Петербург'})
SET r2.startPoint = 'Москва, МКАД',
    r2.endPoint = 'Санкт-Петербург, КАД',
    r2.distanceKm = 705,
    r2.estimatedTimeMinutes = 600;

MERGE (r3:Route {name: 'Нижний Новгород - Казань'})
SET r3.startPoint = 'Нижний Новгород, ул. Московская',
    r3.endPoint = 'Казань, ул. Складская 76',
    r3.distanceKm = 420,
    r3.estimatedTimeMinutes = 380;

// Создание базовых связей
MERGE (d1)-[dr1:DRIVES {since: date('2023-09-02'), primaryDriver: true}]->(v1);
MERGE (d2)-[dr2:DRIVES {since: date('2022-01-15'), primaryDriver: true}]->(v2);
MERGE (d3)-[dr3:DRIVES {since: date('2023-06-10'), primaryDriver: false}]->(v3);

// Проверка созданных узлов
MATCH (n) RETURN labels(n) as Type, count(n) as Count;
