db.runCommand({
  collMod: "vehicles",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["licensePlate", "model", "year", "isActive", "type"],
      properties: {
        
        // Правило 1: Гос.номер обязателен и должен быть строкой
        licensePlate: {
          bsonType: "string",
          minLength: 6,
          maxLength: 15,
          description: "Гос.номер обязателен, 6-15 символов"
        },
        
        // Правило 2: Год выпуска от 1990 до 2025
        year: {
          bsonType: "int",
          minimum: 1990,
          maximum: 2025,
          description: "Год выпуска должен быть от 1990 до 2025"
        },
        
        // Правило 3: Тип топлива только из списка
        type: {
          bsonType: "object",
          required: ["name", "fuelType"],
          properties: {
            name: { bsonType: "string" },
            fuelType: {
              enum: ["Бензин", "Дизель", "Электричество", "Гибрид"],
              description: "Тип топлива: Бензин, Дизель, Электричество или Гибрид"
            },
            avgFuelConsumption: {
              bsonType: "double",
              minimum: 0,
              description: "Расход топлива >= 0"
            }
          }
        },
        
        isActive: { bsonType: "bool" }
      }
    }
  },
  validationLevel: "moderate",
  validationAction: "error"
})


// Это должно сработать
db.vehicles.insertOne({
  licensePlate: "В555ВВ787",
  model: "Scania R500",
  year: NumberInt(1980),
  isActive: true,
  type: {
    name: "Грузовик большой",
    fuelType: "Дизель",
    avgFuelConsumption: 25.1
  },
  department: { name: "Отдел логистики" },
  createdAt: new Date()
})

print("некорректно!")