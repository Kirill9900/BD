// ШАГ 2: Создание 100+ связей через Trip и Maintenance

// Дополнительные водители (всего будет 10)
MERGE (d4:Driver {licenseNumber: '01АА111222'})
SET d4.firstName = 'Дмитрий', d4.lastName = 'Козлов', d4.phone = '+7-912-111-22-33', d4.experienceYears = 6;

MERGE (d5:Driver {licenseNumber: '78ВВ333444'})
SET d5.firstName = 'Михаил', d5.lastName = 'Новиков', d5.phone = '+7-913-222-33-44', d5.experienceYears = 10;

MERGE (d6:Driver {licenseNumber: '99СС555666'})
SET d6.firstName = 'Андрей', d6.lastName = 'Волков', d6.phone = '+7-914-333-44-55', d6.experienceYears = 4;

MERGE (d7:Driver {licenseNumber: '23АА777888'})
SET d7.firstName = 'Владимир', d7.lastName = 'Морозов', d7.phone = '+7-915-444-55-66', d7.experienceYears = 15;

MERGE (d8:Driver {licenseNumber: '45ВВ999000'})
SET d8.firstName = 'Павел', d8.lastName = 'Соколов', d8.phone = '+7-916-555-66-77', d8.experienceYears = 7;

MERGE (d9:Driver {licenseNumber: '67СС121314'})
SET d9.firstName = 'Николай', d9.lastName = 'Лебедев', d9.phone = '+7-917-666-77-88', d9.experienceYears = 9;

MERGE (d10:Driver {licenseNumber: '89АА151617'})
SET d10.firstName = 'Евгений', d10.lastName = 'Кузнецов', d10.phone = '+7-918-777-88-99', d10.experienceYears = 11;

// Дополнительные транспортные средства (всего будет 15)
MERGE (v4:Vehicle {licensePlate: 'В789КЛ50'})
SET v4.model = 'Volvo FH', v4.year = 2020, v4.type = 'Грузовик большой', v4.fuelType = 'Дизель';

MERGE (v5:Vehicle {licensePlate: 'М012НО78'})
SET v5.model = 'Mercedes Actros', v5.year = 2021, v5.type = 'Грузовик большой', v5.fuelType = 'Дизель';

MERGE (v6:Vehicle {licensePlate: 'К345ПР99'})
SET v6.model = 'Scania R450', v6.year = 2019, v6.type = 'Грузовик большой', v6.fuelType = 'Дизель';

MERGE (v7:Vehicle {licensePlate: 'Н678СТ77'})
SET v7.model = 'ГАЗель NEXT', v7.year = 2022, v7.type = 'Фургон', v7.fuelType = 'Бензин';

MERGE (v8:Vehicle {licensePlate: 'О901УФ50'})
SET v8.model = 'Ford Transit', v8.year = 2023, v8.type = 'Фургон', v8.fuelType = 'Дизель';

MERGE (v9:Vehicle {licensePlate: 'П234ХЦ78'})
SET v9.model = 'Hyundai Porter', v9.year = 2021, v9.type = 'Грузовик малый', v9.fuelType = 'Дизель';

MERGE (v10:Vehicle {licensePlate: 'Р567ЧШ99'})
SET v10.model = 'Isuzu NQR', v10.year = 2020, v10.type = 'Грузовик средний', v10.fuelType = 'Дизель';

MERGE (v11:Vehicle {licensePlate: 'С890ЩЭ77'})
SET v11.model = 'MAN TGX', v11.year = 2022, v11.type = 'Грузовик большой', v11.fuelType = 'Дизель';

MERGE (v12:Vehicle {licensePlate: 'Т123ЮЯ50'})
SET v12.model = 'DAF XF', v12.year = 2021, v12.type = 'Грузовик большой', v12.fuelType = 'Дизель';

MERGE (v13:Vehicle {licensePlate: 'У456АБ78'})
SET v13.model = 'Renault Master', v13.year = 2023, v13.type = 'Фургон', v13.fuelType = 'Дизель';

MERGE (v14:Vehicle {licensePlate: 'Ф789ВГ99'})
SET v14.model = 'Peugeot Boxer', v14.year = 2022, v14.type = 'Фургон', v14.fuelType = 'Дизель';

MERGE (v15:Vehicle {licensePlate: 'Х012ДЕ77'})
SET v15.model = 'Iveco Daily', v15.year = 2020, v15.type = 'Фургон', v15.fuelType = 'Дизель';

// Дополнительные маршруты (всего будет 12)
MERGE (r4:Route {name: 'Москва - Нижний Новгород'})
SET r4.startPoint = 'Москва, МКАД', r4.endPoint = 'Нижний Новгород, ул. Московская', r4.distanceKm = 420, r4.estimatedTimeMinutes = 360;

MERGE (r5:Route {name: 'Санкт-Петербург - Москва'})
SET r5.startPoint = 'Санкт-Петербург, КАД', r5.endPoint = 'Москва, МКАД', r5.distanceKm = 705, r5.estimatedTimeMinutes = 600;

MERGE (r6:Route {name: 'Казань - Самара'})
SET r6.startPoint = 'Казань, ул. Складская 76', r6.endPoint = 'Самара, ул. Заводская', r6.distanceKm = 370, r6.estimatedTimeMinutes = 330;

MERGE (r7:Route {name: 'Самара - Волгоград'})
SET r7.startPoint = 'Самара, ул. Заводская', r7.endPoint = 'Волгоград, пр-т Ленина', r7.distanceKm = 550, r7.estimatedTimeMinutes = 500;

MERGE (r8:Route {name: 'Волгоград - Ростов-на-Дону'})
SET r8.startPoint = 'Волгоград, пр-т Ленина', r8.endPoint = 'Ростов-на-Дону, ул. Портовая', r8.distanceKm = 480, r8.estimatedTimeMinutes = 430;

MERGE (r9:Route {name: 'Москва - Екатеринбург'})
SET r9.startPoint = 'Москва, МКАД', r9.endPoint = 'Екатеринбург, ул. Автовокзальная', r9.distanceKm = 1780, r9.estimatedTimeMinutes = 1500;

MERGE (r10:Route {name: 'Екатеринбург - Челябинск'})
SET r10.startPoint = 'Екатеринбург, ул. Автовокзальная', r10.endPoint = 'Челябинск, пр-т Ленина', r10.distanceKm = 210, r10.estimatedTimeMinutes = 180;

MERGE (r11:Route {name: 'Челябинск - Уфа'})
SET r11.startPoint = 'Челябинск, пр-т Ленина', r11.endPoint = 'Уфа, ул. Транспортная', r11.distanceKm = 420, r11.estimatedTimeMinutes = 380;

MERGE (r12:Route {name: 'Уфа - Казань'})
SET r12.startPoint = 'Уфа, ул. Транспортная', r12.endPoint = 'Казань, ул. Складская 76', r12.distanceKm = 530, r12.estimatedTimeMinutes = 480;

// Создание дополнительных связей DRIVES (водители могут управлять несколькими ТС) указываем водилу и транспорт и связь поулчается
MATCH (d:Driver {licenseNumber: '16АА538858'}), (v:Vehicle {licensePlate: 'В789КЛ50'})
MERGE (d)-[:DRIVES {since: date('2024-01-10'), primaryDriver: false}]->(v);

MATCH (d:Driver {licenseNumber: '77ВВ912345'}), (v:Vehicle {licensePlate: 'М012НО78'})
MERGE (d)-[:DRIVES {since: date('2023-05-15'), primaryDriver: true}]->(v);

MATCH (d:Driver {licenseNumber: '50СС778899'}), (v:Vehicle {licensePlate: 'К345ПР99'})
MERGE (d)-[:DRIVES {since: date('2024-03-20'), primaryDriver: false}]->(v);

MATCH (d:Driver {licenseNumber: '01АА111222'}), (v:Vehicle {licensePlate: 'Н678СТ77'})
MERGE (d)-[:DRIVES {since: date('2023-08-01'), primaryDriver: true}]->(v);

MATCH (d:Driver {licenseNumber: '78ВВ333444'}), (v:Vehicle {licensePlate: 'О901УФ50'})
MERGE (d)-[:DRIVES {since: date('2024-02-12'), primaryDriver: true}]->(v);

MATCH (d:Driver {licenseNumber: '99СС555666'}), (v:Vehicle {licensePlate: 'П234ХЦ78'})
MERGE (d)-[:DRIVES {since: date('2023-11-25'), primaryDriver: true}]->(v);

MATCH (d:Driver {licenseNumber: '23АА777888'}), (v:Vehicle {licensePlate: 'Р567ЧШ99'})
MERGE (d)-[:DRIVES {since: date('2024-04-05'), primaryDriver: true}]->(v);

MATCH (d:Driver {licenseNumber: '45ВВ999000'}), (v:Vehicle {licensePlate: 'С890ЩЭ77'})
MERGE (d)-[:DRIVES {since: date('2023-12-18'), primaryDriver: true}]->(v);

MATCH (d:Driver {licenseNumber: '67СС121314'}), (v:Vehicle {licensePlate: 'Т123ЮЯ50'})
MERGE (d)-[:DRIVES {since: date('2024-01-30'), primaryDriver: true}]->(v);

MATCH (d:Driver {licenseNumber: '89АА151617'}), (v:Vehicle {licensePlate: 'У456АБ78'})
MERGE (d)-[:DRIVES {since: date('2023-10-08'), primaryDriver: true}]->(v);

// Создание поездок (Trip) - 40 поездок
MERGE (t1:Trip {tripId: 'TRIP001'})
SET t1.status = 'Завершена', t1.startTime = datetime('2024-12-11T09:53:46Z'), 
    t1.endTime = datetime('2024-12-11T17:30:42Z'), t1.mongo_id = '692003c15a35ee4d24ce5f79';

MERGE (t2:Trip {tripId: 'TRIP002'})
SET t2.status = 'В пути', t2.startTime = datetime('2024-12-15T08:00:00Z');

MERGE (t3:Trip {tripId: 'TRIP003'})
SET t3.status = 'Запланирована', t3.startTime = datetime('2024-12-20T10:00:00Z');

MERGE (t4:Trip {tripId: 'TRIP004'})
SET t4.status = 'Завершена', t4.startTime = datetime('2024-12-10T07:15:00Z'), 
    t4.endTime = datetime('2024-12-10T15:45:00Z');

MERGE (t5:Trip {tripId: 'TRIP005'})
SET t5.status = 'Завершена', t5.startTime = datetime('2024-12-09T06:30:00Z'), 
    t5.endTime = datetime('2024-12-09T16:20:00Z');

MERGE (t6:Trip {tripId: 'TRIP006'})
SET t6.status = 'В пути', t6.startTime = datetime('2024-12-16T09:00:00Z');

MERGE (t7:Trip {tripId: 'TRIP007'})
SET t7.status = 'Запланирована', t7.startTime = datetime('2024-12-22T11:30:00Z');

MERGE (t8:Trip {tripId: 'TRIP008'})
SET t8.status = 'Завершена', t8.startTime = datetime('2024-12-08T08:45:00Z'), 
    t8.endTime = datetime('2024-12-08T14:10:00Z');

MERGE (t9:Trip {tripId: 'TRIP009'})
SET t9.status = 'Отменена', t9.startTime = datetime('2024-12-12T10:00:00Z');

MERGE (t10:Trip {tripId: 'TRIP010'})
SET t10.status = 'Завершена', t10.startTime = datetime('2024-12-07T07:00:00Z'), 
    t10.endTime = datetime('2024-12-07T18:30:00Z');

// Продолжение создания поездок (11-40)
FOREACH (i IN range(11, 40) |
  MERGE (t:Trip {tripId: 'TRIP' + substring('000' + toString(i), size(toString(i)))})
  SET t.status = CASE WHEN i % 3 = 0 THEN 'Завершена' WHEN i % 3 = 1 THEN 'В пути' ELSE 'Запланирована' END,
      t.startTime = datetime('2024-12-' + substring('0' + toString((i % 28) + 1), size(toString((i % 28) + 1)) - 1) + 'T08:00:00Z')
);

// ============================================================================
// ЦИКЛИЧЕСКОЕ СОЗДАНИЕ СВЯЗЕЙ ДЛЯ ВСЕХ 40 ПОЕЗДОК (гарантия 100+ связей)
// ============================================================================

// Связи Trip с Driver (PERFORMED_BY) - ВСЕ 40 поездок
MATCH (d:Driver)
WITH collect(d) as drivers
UNWIND range(1, 40) as i
WITH i, drivers, drivers[(i-1) % size(drivers)] as driver
MATCH (t:Trip {tripId: 'TRIP' + substring('000' + toString(i), size(toString(i)))})
MERGE (t)-[:PERFORMED_BY {assignedDate: date('2024-12-' + substring('0' + toString((i % 28) + 1), size(toString((i % 28) + 1)) - 1))}]->(driver);

// Связи Trip с Vehicle (USES_VEHICLE) - ВСЕ 40 поездок
MATCH (v:Vehicle)
WITH collect(v) as vehicles
UNWIND range(1, 40) as i
WITH i, vehicles, vehicles[(i-1) % size(vehicles)] as vehicle
MATCH (t:Trip {tripId: 'TRIP' + substring('000' + toString(i), size(toString(i)))})
MERGE (t)-[:USES_VEHICLE]->(vehicle);

// Связи Trip с Route (FOLLOWS) - ВСЕ 40 поездок
MATCH (r:Route)
WITH collect(r) as routes
UNWIND range(1, 40) as i
WITH i, routes, routes[(i-1) % size(routes)] as route
MATCH (t:Trip {tripId: 'TRIP' + substring('000' + toString(i), size(toString(i)))})
MERGE (t)-[:FOLLOWS {plannedDuration: route.estimatedTimeMinutes}]->(route);

// Создание сервисных центров (ServiceCenter) для обслуживания
MERGE (sc1:ServiceCenter {name: 'ТехЦентр Профи'})
SET sc1.city = 'Москва', sc1.address = 'ул. Автомобильная 12', sc1.rating = 4.5;

MERGE (sc2:ServiceCenter {name: 'АвтоСервис Люкс'})
SET sc2.city = 'Санкт-Петербург', sc2.address = 'пр-т Обуховской обороны 78', sc2.rating = 4.8;

MERGE (sc3:ServiceCenter {name: 'МастерАвто'})
SET sc3.city = 'Казань', sc3.address = 'ул. Промышленная 25', sc3.rating = 4.2;

MERGE (sc4:ServiceCenter {name: 'СпецТранс Сервис'})
SET sc4.city = 'Нижний Новгород', sc4.address = 'ул. Заводская 56', sc4.rating = 4.6;

MERGE (sc5:ServiceCenter {name: 'Автодом'})
SET sc5.city = 'Екатеринбург', sc5.address = 'ул. Монтажников 33', sc5.rating = 4.3;

// Создание записей обслуживания (Maintenance) - 30 записей
MERGE (m1:Maintenance {maintenanceId: 'MAINT001'})
SET m1.type = 'Ремонт', m1.date = date('2024-03-18'), m1.costRub = 45561, 
    m1.isCompleted = true, m1.odometerReading = 140216, m1.mongo_id = '692003c25a35ee4d24ce60a5';

MERGE (m2:Maintenance {maintenanceId: 'MAINT002'})
SET m2.type = 'ТО', m2.date = date('2024-05-10'), m2.costRub = 12000, 
    m2.isCompleted = true, m2.odometerReading = 155320;

MERGE (m3:Maintenance {maintenanceId: 'MAINT003'})
SET m3.type = 'Заправка', m3.date = date('2024-12-01'), m3.costRub = 5400, 
    m3.isCompleted = true, m3.odometerReading = 178900;

MERGE (m4:Maintenance {maintenanceId: 'MAINT004'})
SET m4.type = 'Замена шин', m4.date = date('2024-10-15'), m4.costRub = 28000, 
    m4.isCompleted = true, m4.odometerReading = 165000;

MERGE (m5:Maintenance {maintenanceId: 'MAINT005'})
SET m5.type = 'ТО', m5.date = date('2024-06-20'), m5.costRub = 15000, 
    m5.isCompleted = true, m5.odometerReading = 120000;

// Продолжение создания обслуживания (6-30)
FOREACH (i IN range(6, 30) |
  MERGE (m:Maintenance {maintenanceId: 'MAINT' + substring('000' + toString(i), size(toString(i)))})
  SET m.type = CASE WHEN i % 4 = 0 THEN 'ТО' WHEN i % 4 = 1 THEN 'Ремонт' WHEN i % 4 = 2 THEN 'Заправка' ELSE 'Замена деталей' END,
      m.date = date('2024-' + substring('0' + toString((i % 12) + 1), size(toString((i % 12) + 1)) - 1) + '-15'),
      m.costRub = toFloat(10000 + (i * 1000)),
      m.isCompleted = (i % 3 <> 0),
      m.odometerReading = 100000 + (i * 5000)
);

// ============================================================================
// ЦИКЛИЧЕСКОЕ СОЗДАНИЕ СВЯЗЕЙ ДЛЯ ВСЕХ 30 ОБСЛУЖИВАНИЙ
// ============================================================================

// Связи Maintenance с Vehicle (SERVICED) - ВСЕ 30 обслуживаний
MATCH (v:Vehicle)
WITH collect(v) as vehicles
UNWIND range(1, 30) as i
WITH i, vehicles, vehicles[(i-1) % size(vehicles)] as vehicle
MATCH (m:Maintenance {maintenanceId: 'MAINT' + substring('000' + toString(i), size(toString(i)))})
MERGE (vehicle)-[:SERVICED {scheduledDate: m.date}]->(m);

// Связи Maintenance с ServiceCenter (PERFORMED_AT) - ВСЕ 30 обслуживаний
MATCH (sc:ServiceCenter)
WITH collect(sc) as serviceCenters
UNWIND range(1, 30) as i
WITH i, serviceCenters, serviceCenters[(i-1) % size(serviceCenters)] as serviceCenter
MATCH (m:Maintenance {maintenanceId: 'MAINT' + substring('000' + toString(i), size(toString(i)))})
MERGE (m)-[:PERFORMED_AT {duration: 60 + (i * 10)}]->(serviceCenter);

// ============================================================================
// ПОДСЧЕТ ИТОГОВЫХ СВЯЗЕЙ (должно быть 100+)
// ============================================================================

// Подсчет общего количества связей
MATCH ()-[r]->() 
RETURN count(r) as TotalRelationships;

// Подсчет по типам связей
MATCH ()-[r]->() 
RETURN type(r) as RelationType, count(r) as Count 
ORDER BY Count DESC;

// Подсчет узлов
MATCH (n) 
RETURN labels(n)[0] as NodeType, count(n) as Count 
ORDER BY Count DESC;

MATCH (d:Driver {licenseNumber:'16АА538858'}), (v:Vehicle {licensePlate:'Р205ХВ58'})
MERGE (d)-[:DRIVES {since: date('2024-01-01'), primaryDriver: false}]->(v);

MATCH (d:Driver {licenseNumber:'01АА111222'}), (v:Vehicle {licensePlate:'Р205ХВ58'})
MERGE (d)-[:DRIVES {since: date('2024-02-01'), primaryDriver: false}]->(v);

// Найдём конкретных водителей и транспорт, чтобы добавить связи
MATCH (d1:Driver {licenseNumber:'16АА538858'}), 
      (d2:Driver {licenseNumber:'01АА111222'}),
      (v:Vehicle {licensePlate:'Р205ХВ58'})

// Создадим две поездки, которые будут связывать этих водителей через один транспорт
MERGE (tA:Trip {tripId:'TRIP_SPECIAL1'})
  SET tA.status='Завершена', tA.startTime=datetime('2024-12-01T08:00:00Z')

MERGE (tB:Trip {tripId:'TRIP_SPECIAL2'})
  SET tB.status='В пути', tB.startTime=datetime('2024-12-02T08:00:00Z')

// Связи: d1 -> tA, tA -> v
MERGE (d1)-[:PERFORMED_BY]->(tA)
MERGE (tA)-[:USES_VEHICLE]->(v)

// Связи: d2 -> tB, tB -> v
MERGE (d2)-[:PERFORMED_BY]->(tB)
MERGE (tB)-[:USES_VEHICLE]->(v)

// Создаём транспорт
MERGE (v:Vehicle {licensePlate:'TEST123'}) 
SET v.model='TestModel'

// Создаём двух водителей из одного отдела
MERGE (d1:Driver {licenseNumber:'D001'})
SET d1.firstName='Ivan', d1.lastName='Petrov', d1.departmentName='Logistics'
MERGE (d2:Driver {licenseNumber:'D002'})
SET d2.firstName='Petr', d2.lastName='Ivanov', d2.departmentName='Logistics'

// Связываем их с одним транспортом
MERGE (d1)-[:DRIVES {primaryDriver:true}]->(v)
MERGE (d2)-[:DRIVES {primaryDriver:false}]->(v)

