// ЗАПРОС 1: Найти все активные транспортные средства типа "Грузовик большой"
MATCH (v:Vehicle)
WHERE v.type = 'Грузовик большой' AND v.isActive = true
RETURN v.licensePlate, v.model, v.year, v.fuelType
ORDER BY v.year DESC;

// ЗАПРОС 2: Найти всех водителей с опытом более 10 лет, которые управляют дизельными грузовиками
MATCH (d:Driver)-[dr:DRIVES]->(v:Vehicle)
WHERE d.experienceYears > 10 AND v.fuelType = 'Дизель' AND v.type CONTAINS 'Грузовик'
RETURN d.firstName, d.lastName, d.experienceYears, v.licensePlate, v.model, dr.primaryDriver
ORDER BY d.experienceYears DESC;

// ЗАПРОС 3: Найти все завершенные поездки за декабрь 2024 с расстоянием более 500 км
MATCH (t:Trip)-[f:FOLLOWS]->(r:Route)
WHERE t.status = 'Завершена' 
  AND t.startTime >= datetime('2024-12-01T00:00:00Z')
  AND t.startTime < datetime('2025-01-01T00:00:00Z')
  AND r.distanceKm > 500
RETURN t.tripId, r.name, r.distanceKm, t.startTime, t.endTime
ORDER BY r.distanceKm DESC;

// ЗАПРОС 4: Найти транспортные средства, которые проходили ремонт, с затратами более 30000 руб
MATCH (v:Vehicle)-[s:SERVICED]->(m:Maintenance)
WHERE m.type = 'Ремонт' AND m.costRub > 30000 AND m.isCompleted = true
RETURN v.licensePlate, v.model, m.maintenanceId, m.date, m.costRub, m.odometerReading
ORDER BY m.costRub DESC;

// ЗАПРОС 5: Найти все поездки "В пути" с водителями и их транспортом
MATCH (t:Trip)-[:PERFORMED_BY]->(d:Driver),
      (t)-[:USES_VEHICLE]->(v:Vehicle)
WHERE t.status = 'В пути'
RETURN t.tripId, d.firstName + ' ' + d.lastName as Driver, 
       v.licensePlate, v.model, t.startTime
ORDER BY t.startTime;

// ЗАПРОС 6: Найти сервисные центры с рейтингом выше 4.5, которые выполняли ТО
MATCH (m:Maintenance)-[:PERFORMED_AT]->(sc:ServiceCenter)
WHERE sc.rating >= 4.5 AND m.type = 'ТО'
RETURN DISTINCT sc.name, sc.city, sc.rating, count(m) as MaintenanceCount
ORDER BY sc.rating DESC, MaintenanceCount DESC;