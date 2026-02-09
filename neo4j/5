// ЗАПРОС 1: Подсчитать количество поездок для каждого водителя
MATCH (d:Driver)<-[:PERFORMED_BY]-(t:Trip)
RETURN d.firstName + ' ' + d.lastName as Driver,
       d.licenseNumber,
       count(t) as TotalTrips,
       collect(t.tripId) as TripIds
ORDER BY TotalTrips DESC
LIMIT 10;

// ЗАПРОС 2: Подсчитать общую стоимость обслуживания для каждого транспорта
MATCH (v:Vehicle)-[:SERVICED]->(m:Maintenance)
WHERE m.isCompleted = true
RETURN v.licensePlate,
       v.model,
       count(m) as MaintenanceCount,
       sum(m.costRub) as TotalCost,
       avg(m.costRub) as AvgCost,
       collect(m.type) as MaintenanceTypes
ORDER BY TotalCost DESC
LIMIT 15;

// ЗАПРОС 3: Найти самые популярные маршруты (по количеству поездок)
MATCH (r:Route)<-[:FOLLOWS]-(t:Trip)
RETURN r.name as Route,
       r.distanceKm,
       count(t) as TripCount,
       collect(DISTINCT t.status) as Statuses
ORDER BY TripCount DESC, r.distanceKm DESC
LIMIT 10;

// ЗАПРОС 4: Статистика по сервисным центрам (количество обслуживаний и средняя стоимость)
MATCH (sc:ServiceCenter)<-[:PERFORMED_AT]-(m:Maintenance)
RETURN sc.name,
       sc.city,
       sc.rating,
       count(m) as ServiceCount,
       sum(m.costRub) as TotalRevenue,
       avg(m.costRub) as AvgServiceCost,
       collect(DISTINCT m.type) as ServiceTypes
ORDER BY ServiceCount DESC, TotalRevenue DESC
LIMIT 10;

//Запрос 5
MATCH (d:Driver)-[dr:DRIVES]->(v:Vehicle)
RETURN d.firstName + ' ' + d.lastName as Driver,
       d.experienceYears,
       count(v) as VehicleCount,
       collect(v.licensePlate) as Vehicles,
       collect(dr.primaryDriver) as IsPrimary
ORDER BY VehicleCount DESC, d.experienceYears DESC
LIMIT 10;