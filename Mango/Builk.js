db.vehicles.bulkWrite([
  // Операция 1: INSERT — добавляем новое ТС
  {
    insertOne: {
      document: {
        licensePlate: "Б001БК777",
        model: "МАЗ 6430",
        year: 2023,
        isActive: true,
        type: { name: "Грузовик большой", fuelType: "Дизель", avgFuelConsumption: 22 },
        department: { name: "Отдел логистики", head: "Иванов И.И." },
        currentLocation: { type: "Point", coordinates: [37.6, 55.7] },
        createdAt: new Date(),
        updatedAt: new Date()
      }
    }
  },
  
  // Операция 2: UPDATE — обновляем все электромобили
  {
    updateMany: {
      filter: { "type.fuelType": "Электричество" },
      update: { $set: { "type.avgFuelConsumption": 0, updatedAt: new Date() } }
    }
  },
  
  // Операция 3: UPDATE ONE — обновляем конкретное ТС
  {
    updateOne: {
      filter: { licensePlate: "Б001БК777" },
      update: { $set: { "department.head": "Петров П.П." } }
    }
  },
  
  // Операция 4: UPSERT — вставить или обновить
  {
    updateOne: {
      filter: { licensePlate: "Т123ТТ999" },
      update: {
        $set: {
          model: "Volvo FH16",
          year: 2024,
          isActive: true,
          type: { name: "Грузовик большой", fuelType: "Дизель" },
          department: { name: "Международные перевозки" },
          updatedAt: new Date()
        },
        $setOnInsert: { createdAt: new Date() }
      },
      upsert: true
    }
  },
  
  // Операция 5: DELETE — удаляем тестовые данные
  {
    deleteMany: {
      filter: { licensePlate: { $regex: /^ТЕСТ/ } }
    }
  }
], { ordered: true })


////
///
////
////
////


db.maintenance.bulkWrite([
  // Добавляем несколько записей ТО
  {
    insertOne: {
      document: {
        vehicleId: db.vehicles.findOne({ licensePlate: "Б001БК777" })._id,
        type: "ТО-1",
        date: new Date(),
        costRub: 12000,
        serviceProvider: "АвтоСервис Премиум",
        isCompleted: false,
        createdAt: new Date()
      }
    }
  },
  
  // Завершаем все незавершённые диагностики
  {
    updateMany: {
      filter: { type: "Диагностика", isCompleted: false },
      update: { $set: { isCompleted: true } }
    }
  },
  
  // Увеличиваем стоимость всех ТО-2 на 10%
  {
    updateMany: {
      filter: { type: "ТО-2" },
      update: [{ $set: { costRub: { $multiply: ["$costRub", 1.1] } } }]
    }
  }
])