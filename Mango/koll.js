db.createCollection("vehicles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["licensePlate", "model", "year", "type", "department", "isActive"],
      properties: {
        licensePlate: { bsonType: "string", description: "Гос. номер" },
        model: { bsonType: "string" },
        year: { bsonType: "int", minimum: 1990 },
        type: {
          bsonType: "object",
          required: ["name", "fuelType"],
          properties: {
            name: { bsonType: "string" },
            maxLoadCapacity: { bsonType: "double" },
            fuelType: { enum: ["Бензин", "Дизель", "Электричество", "Гибрид"] },
            avgFuelConsumption: { bsonType: "double" }
          }
        },
        department: {
          bsonType: "object",
          required: ["name"],
          properties: {
            name: { bsonType: "string" },
            head: { bsonType: "string" },
            phone: { bsonType: "string" }
          }
        },
        vinNumber: { bsonType: "string" },
        isActive: { bsonType: "bool" },
        currentLocation: {
          bsonType: "object",
          properties: {
            type: { enum: ["Point"] },
            coordinates: { bsonType: "array" }
          }
        }
      }
    }
  }
})

db.createCollection("trips", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["vehicleId", "driver", "status", "startTime"],
      properties: {
        vehicleId: { bsonType: "objectId" },
        driver: {
          bsonType: "object",
          required: ["firstName", "lastName", "licenseNumber"],
          properties: {
            firstName: { bsonType: "string" },
            lastName: { bsonType: "string" },
            phone: { bsonType: "string" },
            licenseNumber: { bsonType: "string" }
          }
        },
        route: {
          bsonType: "object",
          properties: {
            name: { bsonType: "string" },
            startPoint: { bsonType: "string" },
            endPoint: { bsonType: "string" },
            distanceKm: { bsonType: "double" },
            waypoints: { bsonType: "array" }
          }
        },
        status: { enum: ["Запланирована", "В пути", "Завершена", "Отменена"] },
        startTime: { bsonType: "date" },
        endTime: { bsonType: "date" },
        actualDistanceKm: { bsonType: "double" },
        fuelConsumedLiters: { bsonType: "double" },
        gpsTrack: { bsonType: "array" }
      }
    }
  }
})

db.createCollection("maintenance", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["vehicleId", "type", "date", "serviceProvider"],
      properties: {
        vehicleId: { bsonType: "objectId" },
        type: { enum: ["ТО-1", "ТО-2", "Ремонт", "Диагностика", "Замена масла", "Заправка", "Прочее"] },
        date: { bsonType: "date" },
        description: { bsonType: "string" },
        costRub: { bsonType: "double" },
        serviceProvider: { bsonType: "string" },
        odometerReading: { bsonType: "int" },
        isCompleted: { bsonType: "bool" },
        fuelData: {
          bsonType: "object",
          properties: {
            liters: { bsonType: "double" },
            pricePerLiter: { bsonType: "double" },
            station: { bsonType: "string" }
          }
        }
      }
    }
  }
})
