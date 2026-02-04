db.trips.aggregate([
  // Начальная фильтрация
  { $match: { status: "Завершена" } },
  
  // $facet — параллельные pipeline
  { $facet: {
    
    // ОТЧЁТ 1: Статистика по типам ТС ($lookup)
    "vehicleTypeStats": [
      // JOIN с vehicles
      { $lookup: {
        from: "vehicles",
        localField: "vehicleId",
        foreignField: "_id",
        as: "vehicle"
      }},
      { $unwind: "$vehicle" },
      
      // Группируем по типу ТС
      { $group: {
        _id: "$vehicle.type.name",
        trips: { $sum: 1 },
        totalDistance: { $sum: "$actualDistanceKm" },
        totalFuel: { $sum: "$fuelConsumedLiters" },
        avgFuelPer100km: { 
          $avg: { 
            $multiply: [
              { $divide: ["$fuelConsumedLiters", "$actualDistanceKm"] },
              100
            ]
          }
        }
      }},
      
      { $project: {
        _id: 0,
        vehicleType: "$_id",
        trips: 1,
        totalDistanceKm: { $round: ["$totalDistance", 0] },
        totalFuelLiters: { $round: ["$totalFuel", 0] },
        avgFuelPer100km: { $round: ["$avgFuelPer100km", 1] }
      }},
      
      { $sort: { totalDistanceKm: -1 } }
    ],
    
    // ОТЧЁТ 2: Топ-5 водителей
    "topDrivers": [
      { $group: {
        _id: {
          lastName: "$driver.lastName",
          firstName: "$driver.firstName"
        },
        trips: { $sum: 1 },
        totalKm: { $sum: "$actualDistanceKm" },
        avgDelayMin: { $avg: "$delayMinutes" }
      }},
      
      { $project: {
        _id: 0,
        driver: { $concat: ["$_id.lastName", " ", "$_id.firstName"] },
        trips: 1,
        totalKm: { $round: ["$totalKm", 0] },
        avgDelayMin: { $round: ["$avgDelayMin", 0] }
      }},
      
      { $sort: { totalKm: -1 } },
      { $limit: 5 }
    ],
    
    // ОТЧЁТ 3: Распределение по дистанции ($bucket)
    "distanceBuckets": [
      { $bucket: {
        groupBy: "$actualDistanceKm",
        boundaries: [0, 100, 300, 500, 1000, 2000],
        default: "2000+",
        output: {
          count: { $sum: 1 },
          avgFuel: { $avg: "$fuelConsumedLiters" },
          trips: { $push: "$$ROOT._id" }
        }
      }},
      
      { $project: {
        _id: 0,
        range: {
          $switch: {
            branches: [
              { case: { $eq: ["$_id", 0] }, then: "0-100 км" },
              { case: { $eq: ["$_id", 100] }, then: "100-300 км" },
              { case: { $eq: ["$_id", 300] }, then: "300-500 км" },
              { case: { $eq: ["$_id", 500] }, then: "500-1000 км" },
              { case: { $eq: ["$_id", 1000] }, then: "1000-2000 км" }
            ],
            default: "2000+ км"
          }
        },
        tripsCount: "$count",
        avgFuelLiters: { $round: ["$avgFuel", 1] }
      }}
    ],
    
    // ОТЧЁТ 4: Связь ТС → Обслуживание ($lookup + $unwind)
    "maintenanceCosts": [
      { $lookup: {
        from: "vehicles",
        localField: "vehicleId",
        foreignField: "_id",
        as: "vehicle"
      }},
      { $unwind: "$vehicle" },
      
      // Второй $lookup — обслуживание
      { $lookup: {
        from: "maintenance",
        localField: "vehicleId",
        foreignField: "vehicleId",
        as: "maintenanceRecords"
      }},
      
      { $group: {
        _id: "$vehicle.licensePlate",
        trips: { $sum: 1 },
        totalDistance: { $sum: "$actualDistanceKm" },
        maintenanceCount: { $sum: { $size: "$maintenanceRecords" } },
        totalMaintenanceCost: { $sum: { $sum: "$maintenanceRecords.costRub" } }
      }},
      
      { $project: {
        _id: 0,
        licensePlate: "$_id",
        trips: 1,
        totalDistanceKm: { $round: ["$totalDistance", 0] },
        maintenanceCount: 1,
        totalMaintenanceCost: { $round: ["$totalMaintenanceCost", 0] },
        costPerKm: { 
          $round: [
            { $divide: ["$totalMaintenanceCost", "$totalDistance"] },
            2
          ]
        }
      }},
      
      { $sort: { totalMaintenanceCost: -1 } },
      { $limit: 10 }
    ]
  }}
])