// ШАГ 6: Переписать JOIN/LOOKUP запросы на Cypher

/*
=====================================================================
СЦЕНАРИЙ 1: Получить информацию о поездках с данными водителя и транспорта
=====================================================================
*/

-- PostgreSQL (с множественными JOIN):
-- SELECT 
--     t.trip_id, t.status, t.start_time,
--     d.first_name, d.last_name, d.phone,
--     v.license_plate, v.model, v.type,
--     r.name as route_name, r.distance_km
-- FROM trips t
-- INNER JOIN drivers d ON t.driver_id = d.id
-- INNER JOIN vehicles v ON t.vehicle_id = v.id
-- INNER JOIN routes r ON t.route_id = r.id
-- WHERE t.status = 'Завершена'
-- ORDER BY t.start_time DESC
-- LIMIT 10;

// MongoDB (с $lookup):
db.trips.aggregate([
  { $match: { status: "Завершена" } },

  {
    $lookup: {
      from: "drivers",
      localField: "driverId",
      foreignField: "_id",
      as: "driver"
    }
  },
  { $unwind: "$driver" },

  {
    $lookup: {
      from: "vehicles",
      localField: "vehicleId",
      foreignField: "_id",
      as: "vehicle"
    }
  },
  { $unwind: "$vehicle" },

  {
    $lookup: {
      from: "routes",
      localField: "routeId",
      foreignField: "_id",
      as: "route"
    }
  },
  { $unwind: "$route" },

  {
    $project: {
      tripId: 1,
      status: 1,
      startTime: 1,
      firstName: "$driver.firstName",
      lastName: "$driver.lastName",
      phone: "$driver.phone",
      licensePlate: "$vehicle.licensePlate",
      model: "$vehicle.model",
      type: "$vehicle.type",
      routeName: "$route.name",
      distanceKm: "$route.distanceKm"
    }
  },

  { $sort: { startTime: -1 } },

  { $limit: 10 }
])


// Neo4j Cypher (естественный граф):
MATCH (t:Trip)-[:PERFORMED_BY]->(d:Driver),
      (t)-[:USES_VEHICLE]->(v:Vehicle),
      (t)-[:FOLLOWS]->(r:Route)
WHERE t.status = 'Завершена'
RETURN t.tripId, t.status, t.startTime,
       d.firstName, d.lastName, d.phone,
       v.licensePlate, v.model, v.type,
       r.name as routeName, r.distanceKm
ORDER BY t.startTime DESC
LIMIT 10;

// ВЫВОД: В Neo4j запрос проще и нагляднее - связи явно видны в структуре MATCH.
// Нет необходимости указывать ключи для JOIN, граф сам знает свои связи.


/*
=====================================================================
СЦЕНАРИЙ 2: Найти транспорт с историей обслуживания и сервисными центрами
=====================================================================
*/

-- PostgreSQL:
-- SELECT 
--     v.license_plate, v.model,
--     m.type as maintenance_type, m.date, m.cost_rub,
--     sc.name as service_center, sc.city
-- FROM vehicles v
-- INNER JOIN maintenance m ON v.id = m.vehicle_id
-- INNER JOIN service_centers sc ON m.service_center_id = sc.id
-- WHERE m.is_completed = true AND m.cost_rub > 20000
-- ORDER BY m.date DESC;

// MongoDB:
db.vehicles.aggregate([
  {
    $lookup: {
      from: "maintenance",
      localField: "_id",
      foreignField: "vehicleId",
      as: "m"
    }
  },
  { $unwind: "$m" },
  {
    $lookup: {
      from: "servicecenters",
      localField: "m.serviceCenterId",   
      foreignField: "_id",
      as: "sc"
    }
  },
  { $unwind: "$sc" },
  {
    $match: {
      "m.isCompleted": true,
      "m.costRub": { $gt: 20000 }
    }
  },
  {
    $project: {
      licensePlate: 1,
      model: 1,
      maintenanceType: "$m.type",
      date: "$m.date",
      costRub: "$m.costRub",
      serviceCenter: "$sc.name",
      city: "$sc.city"
    }
  }
])

// Neo4j Cypher:
MATCH (v:Vehicle)-[:SERVICED]->(m:Maintenance)-[:PERFORMED_AT]->(sc:ServiceCenter)
WHERE m.isCompleted = true AND m.costRub > 20000
RETURN v.licensePlate, v.model,
       m.type as maintenanceType, m.date, m.costRub,
       sc.name as serviceCenter, sc.city
ORDER BY m.date DESC;

// ВЫВОД: Neo4j значительно короче и читабельнее. Цепочка связей 
// v->m->sc читается как естественное описание: "транспорт обслужен в центре".
