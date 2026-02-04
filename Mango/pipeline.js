// Статистика поездок по статусам
// Стадии: $match, $group, $sort, $project

db.trips.aggregate([
  // 1. Фильтруем поездки за 2024 год
  { $match: { 
    startTime: { $gte: new Date("2024-01-01"), $lt: new Date("2025-01-01") }
  }},
  
  // 2. Группируем по статусу
  { $group: {
    _id: "$status",
    count: { $sum: 1 },
    totalDistance: { $sum: "$actualDistanceKm" },
    avgDistance: { $avg: "$actualDistanceKm" },
    totalFuel: { $sum: "$fuelConsumedLiters" }
  }},
  
  // 3. Сортируем по количеству
  { $sort: { count: -1 } },
  
  // 4. Форматируем вывод
  { $project: {
    status: "$_id",
    count: 1,
    totalDistanceKm: { $round: ["$totalDistance", 1] },
    avgDistanceKm: { $round: ["$avgDistance", 1] },
    totalFuelLiters: { $round: ["$totalFuel", 1] },
    _id: 0
  }}
])



// Топ-5 водителей по пробегу
// Стадии: $match, $group, $sort, $limit, $project

db.trips.aggregate([
  // 1. Только завершённые поездки
  { $match: { status: "Завершена" } },
  
  // 2. Группируем по водителю
  { $group: {
    _id: { 
      lastName: "$driver.lastName", 
      firstName: "$driver.firstName" 
    },
    tripsCount: { $sum: 1 },
    totalDistance: { $sum: "$actualDistanceKm" },
    totalFuel: { $sum: "$fuelConsumedLiters" },
    avgSpeed: { $avg: "$lastSensorData.engineTemperature" }
  }},
  
  // 3. Сортируем по пробегу
  { $sort: { totalDistance: -1 } },
  
  // 4. Берём топ-5
  { $limit: 5 },
  
  // 5. Форматируем
  { $project: {
    driver: { $concat: ["$_id.lastName", " ", "$_id.firstName"] },
    tripsCount: 1,
    totalDistanceKm: { $round: ["$totalDistance", 0] },
    totalFuelLiters: { $round: ["$totalFuel", 1] },
    _id: 0
  }}
])



// Анализ GPS-треков: средняя скорость по поездкам
// Стадии: $match, $unwind, $group, $sort, $limit

db.trips.aggregate([
  // 1. Завершённые поездки с GPS
  { $match: { 
    status: "Завершена",
    "gpsTrack.0": { $exists: true }
  }},
  
  // 2. Разворачиваем массив GPS-точек
  { $unwind: "$gpsTrack" },
  
  // 3. Группируем обратно, считаем среднюю скорость
  { $group: {
    _id: "$_id",
    routeName: { $first: "$route.name" },
    driverName: { $first: { $concat: ["$driver.lastName", " ", "$driver.firstName"] } },
    pointsCount: { $sum: 1 },
    avgSpeed: { $avg: "$gpsTrack.speedKmh" },
    maxSpeed: { $max: "$gpsTrack.speedKmh" }
  }},
  
  // 4. Сортируем по средней скорости
  { $sort: { avgSpeed: -1 } },
  
  // 5. Топ-10
  { $limit: 10 },
  
  // 6. Форматируем
  { $project: {
    routeName: 1,
    driverName: 1,
    gpsPoints: "$pointsCount",
    avgSpeedKmh: { $round: ["$avgSpeed", 1] },
    maxSpeedKmh: { $round: ["$maxSpeed", 1] },
    _id: 0
  }}
])




// Расходы на обслуживание по типам ТС
// Стадии: $lookup (1 -> N), $unwind, $group, $sort, $project

db.vehicles.aggregate([
  // 1. Только активные ТС
  { $match: { isActive: true } },
  
  // 2. JOIN с maintenance (1 vehicle -> N maintenance)
  { $lookup: {
    from: "maintenance",
    localField: "_id",
    foreignField: "vehicleId",
    as: "maintenanceRecords"
  }},
  
  // 3. Разворачиваем записи обслуживания
  { $unwind: { 
    path: "$maintenanceRecords",
    preserveNullAndEmptyArrays: false  // только с ТО
  }},
  
  // 4. Группируем по типу ТС
  { $group: {
    _id: "$type.name",
    vehiclesCount: { $addToSet: "$_id" },
    totalMaintenances: { $sum: 1 },
    totalCost: { $sum: "$maintenanceRecords.costRub" },
    avgCost: { $avg: "$maintenanceRecords.costRub" }
  }},
  
  // 5. Считаем уникальные ТС
  { $project: {
    vehicleType: "$_id",
    vehiclesCount: { $size: "$vehiclesCount" },
    totalMaintenances: 1,
    totalCostRub: { $round: ["$totalCost", 0] },
    avgCostRub: { $round: ["$avgCost", 0] },
    _id: 0
  }},
  
  // 6. Сортируем по расходам
  { $sort: { totalCostRub: -1 } }
])




// Отчёт: поездки с данными о ТС и обслуживании
// Стадии: $lookup (N -> N через 2 коллекции), $match, $project, $limit

db.trips.aggregate([
  // 1. Завершённые поездки
  { $match: { status: "Завершена" } },
  
  // 2. JOIN с vehicles
  { $lookup: {
    from: "vehicles",
    localField: "vehicleId",
    foreignField: "_id",
    as: "vehicle"
  }},
  
  // 3. Разворачиваем vehicle (1:1)
  { $unwind: "$vehicle" },
  
  // 4. JOIN с maintenance для этого ТС
  { $lookup: {
    from: "maintenance",
    localField: "vehicleId",
    foreignField: "vehicleId",
    as: "vehicleMaintenance"
  }},
  
  // 5. Форматируем отчёт
  { $project: {
    tripId: "$_id",
    route: "$route.name",
    driver: { $concat: ["$driver.lastName", " ", "$driver.firstName"] },
    distanceKm: "$actualDistanceKm",
    fuelLiters: "$fuelConsumedLiters",
    vehicle: {
      plate: "$vehicle.licensePlate",
      model: "$vehicle.model",
      type: "$vehicle.type.name"
    },
    maintenanceCount: { $size: "$vehicleMaintenance" },
    _id: 0
  }},
  
  // 6. Лимит
  { $limit: 10 },
  
  // 7. Сортируем
  { $sort: { distanceKm: -1 } }
])