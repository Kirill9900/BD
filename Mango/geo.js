db.trips.updateMany(
  { status: "Завершена" },
  [{
    $set: {
      plannedArrival: {
        $dateAdd: {
          startDate: "$startTime",
          unit: "minute",
          amount: "$route.estimatedTimeMinutes"
        }
      },
      actualArrival: "$endTime"
    }
  }]
)

// Добавим поле delayMinutes (опоздание)
db.trips.updateMany(
  { status: "Завершена", actualArrival: { $exists: true } },
  [{
    $set: {
      delayMinutes: {
        $round: [{
          $divide: [
            { $subtract: ["$actualArrival", "$plannedArrival"] },
            60000  // миллисекунды в минуты
          ]
        }, 0]
      }
    }
  }]
)


db.vehicles.createIndex({ currentLocation: "2dsphere" }, { name: "idx_geo_location" })


db.vehicles.aggregate([
  {
    $geoNear: {
      near: { type: "Point", coordinates: [37.6173, 55.7558] },  
      distanceField: "distanceMeters",
      maxDistance: 100000,  
      spherical: true,
      query: { isActive: true }
    }
  },
  { $limit: 5 },
  {
    $project: {
      licensePlate: 1,
      model: 1,
      "type.name": 1,
      "department.name": 1,
      distanceKm: { $round: [{ $divide: ["$distanceMeters", 1000] }, 2] },
      _id: 0
    }
  }
])




db.trips.aggregate([
  { $match: { 
    status: "Завершена",
    delayMinutes: { $exists: true }
  }},
  { $group: {
    _id: { lastName: "$driver.lastName", firstName: "$driver.firstName" },
    totalTrips: { $sum: 1 },
    avgDelay: { $avg: "$delayMinutes" },
    maxDelay: { $max: "$delayMinutes" },
    lateTrips: { 
      $sum: { $cond: [{ $gt: ["$delayMinutes", 15] }, 1, 0] }  
    }
  }},
  { $project: {
    driver: { $concat: ["$_id.lastName", " ", "$_id.firstName"] },
    totalTrips: 1,
    avgDelayMinutes: { $round: ["$avgDelay", 0] },
    maxDelayMinutes: "$maxDelay",
    lateTrips: 1,
    onTimePercent: { 
      $round: [{ 
        $multiply: [
          { $divide: [{ $subtract: ["$totalTrips", "$lateTrips"] }, "$totalTrips"] },
          100
        ]
      }, 1]
    },
    _id: 0
  }},
  { $sort: { avgDelayMinutes: -1 } },
  { $limit: 10 }
])





db.trips.aggregate([
  { $match: { 
    status: "Завершена",
    delayMinutes: { $exists: true }
  }},
  { $group: {
    _id: "$route.name",
    trips: { $sum: 1 },
    avgDelay: { $avg: "$delayMinutes" },
    plannedTime: { $first: "$route.estimatedTimeMinutes" },
    avgActualTime: { 
      $avg: { 
        $divide: [
          { $subtract: ["$actualArrival", "$startTime"] },
          60000
        ]
      }
    }
  }},
  { $match: { trips: { $gte: 2 } } },  
  { $project: {
    route: "$_id",
    trips: 1,
    plannedTimeMin: "$plannedTime",
    avgActualTimeMin: { $round: ["$avgActualTime", 0] },
    avgDelayMin: { $round: ["$avgDelay", 0] },
    _id: 0
  }},
  { $sort: { avgDelayMin: -1 } },
  { $limit: 10 }
])