// ============================================
// REST API для MongoDB Transport Monitoring
// Файл: server.js
// ============================================

const express = require('express');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
app.use(express.json());

// Подключение к MongoDB
const uri = 'mongodb://root:rootpass@localhost:27017';
const client = new MongoClient(uri);
let db;

async function connect() {
  await client.connect();
  db = client.db('transport_monitoring');
  console.log('Connected to MongoDB');
}

// ================== ENDPOINT 1 ==================
// GET /api/vehicles - список ТС с фильтрами
// Пример: /api/vehicles?isActive=true&fuelType=Дизель

app.get('/api/vehicles', async (req, res) => {
  try {
    const filter = {};
    
    if (req.query.isActive !== undefined) {
      filter.isActive = req.query.isActive === 'true';
    }
    if (req.query.fuelType) {
        filter['type.fuelType'] = { $regex: new RegExp(`^${req.query.fuelType}$`, 'i') };
    }
    if (req.query.department) {
      filter['department.name'] = req.query.department;
    }
    
    const vehicles = await db.collection('vehicles')
      .find(filter)
      .project({ licensePlate: 1, model: 1, year: 1, 'type.name': 1, isActive: 1 })
      .limit(50)
      .toArray();
    
    res.json({ count: vehicles.length, data: vehicles });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// ================== ENDPOINT 2 ==================
// GET /api/trips/stats - статистика поездок (aggregation)

app.get('/api/trips/stats', async (req, res) => {
  try {
    const stats = await db.collection('trips').aggregate([
      { $match: { status: 'Завершена' } },
      { $group: {
        _id: null,
        totalTrips: { $sum: 1 },
        totalDistance: { $sum: '$actualDistanceKm' },
        totalFuel: { $sum: '$fuelConsumedLiters' },
        avgDistance: { $avg: '$actualDistanceKm' }
      }},
      { $project: {
        _id: 0,
        totalTrips: 1,
        totalDistanceKm: { $round: ['$totalDistance', 0] },
        totalFuelLiters: { $round: ['$totalFuel', 0] },
        avgDistanceKm: { $round: ['$avgDistance', 1] }
      }}
    ]).toArray();
    
    res.json(stats[0] || {});
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// ================== ENDPOINT 3 ==================
// GET /api/vehicles/:id/maintenance - ТО для конкретного ТС ($lookup)

app.get('/api/vehicles/:id/maintenance', async (req, res) => {
  try {
    const vehicleId = new ObjectId(req.params.id);
    
    const result = await db.collection('vehicles').aggregate([
      { $match: { _id: vehicleId } },
      { $lookup: {
        from: 'maintenance',
        localField: '_id',
        foreignField: 'vehicleId',
        as: 'maintenanceHistory'
      }},
      { $project: {
        licensePlate: 1,
        model: 1,
        maintenanceHistory: {
          $map: {
            input: '$maintenanceHistory',
            as: 'm',
            in: {
              type: '$$m.type',
              date: '$$m.date',
              cost: '$$m.costRub',
              provider: '$$m.serviceProvider'
            }
          }
        }
      }}
    ]).toArray();
    
    if (!result.length) {
      return res.status(404).json({ error: 'Vehicle not found' });
    }
    
    res.json(result[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// ================== ENDPOINT 4 ==================
// GET /api/drivers/top - топ водителей по пробегу

app.get('/api/drivers/top', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 5;
    
    const topDrivers = await db.collection('trips').aggregate([
      { $match: { status: 'Завершена' } },
      { $group: {
        _id: { lastName: '$driver.lastName', firstName: '$driver.firstName' },
        trips: { $sum: 1 },
        totalKm: { $sum: '$actualDistanceKm' },
        totalFuel: { $sum: '$fuelConsumedLiters' }
      }},
      { $sort: { totalKm: -1 } },
      { $limit: limit },
      { $project: {
        _id: 0,
        driver: { $concat: ['$_id.lastName', ' ', '$_id.firstName'] },
        trips: 1,
        totalKm: { $round: ['$totalKm', 0] },
        totalFuel: { $round: ['$totalFuel', 1] }
      }}
    ]).toArray();
    
    res.json({ data: topDrivers });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// ================== ENDPOINT 5 ==================
// GET /api/vehicles/nearby - ближайшие ТС ($geoNear)
// Пример: /api/vehicles/nearby?lng=37.6&lat=55.75&maxDistance=10000

app.get('/api/vehicles/nearby', async (req, res) => {
  try {
    const lng = parseFloat(req.query.lng) || 37.6173;
    const lat = parseFloat(req.query.lat) || 55.7558;
    const maxDist = parseInt(req.query.maxDistance) || 50000; // метры
    
    const nearby = await db.collection('vehicles').aggregate([
      { $geoNear: {
        near: { type: 'Point', coordinates: [lng, lat] },
        distanceField: 'distance',
        maxDistance: maxDist,
        spherical: true,
        query: { isActive: true }
      }},
      { $limit: 10 },
      { $project: {
        licensePlate: 1,
        model: 1,
        'type.name': 1,
        distanceMeters: { $round: ['$distance', 0] },
        _id: 0
      }}
    ]).toArray();
    
    res.json({ 
      searchPoint: { lng, lat },
      maxDistanceMeters: maxDist,
      found: nearby.length,
      data: nearby 
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// Запуск сервера
const PORT = 4000;
connect().then(() => {
  app.listen(PORT, () => {
    console.log(`API running at http://localhost:${PORT}`);
  });
});