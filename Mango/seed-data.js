// ============================================
// SEED-СКРИПТ ДЛЯ MongoDB
// Запуск: mongosh -u root -p rootpass < seed-data.js
// Или вставить в mongosh после подключения
// ============================================

use transport_monitoring

// Очистка перед загрузкой
db.vehicles.drop()
db.trips.drop()
db.maintenance.drop()

// --------------------------------------------
// СПРАВОЧНЫЕ ДАННЫЕ
// --------------------------------------------
const vehicleTypes = [
  { name: "Легковой автомобиль", maxLoadCapacity: 0.5, fuelType: "Бензин", avgFuelConsumption: 8.5 },
  { name: "Грузовик малый", maxLoadCapacity: 3.5, fuelType: "Дизель", avgFuelConsumption: 12.0 },
  { name: "Грузовик средний", maxLoadCapacity: 10.0, fuelType: "Дизель", avgFuelConsumption: 15.5 },
  { name: "Грузовик большой", maxLoadCapacity: 20.0, fuelType: "Дизель", avgFuelConsumption: 22.0 },
  { name: "Автобус", maxLoadCapacity: 25.0, fuelType: "Дизель", avgFuelConsumption: 18.0 },
  { name: "Электромобиль", maxLoadCapacity: 0.6, fuelType: "Электричество", avgFuelConsumption: 0 }
]

const departments = [
  { name: "Отдел логистики", head: "Иванов И.И.", phone: "+7-495-123-45-67" },
  { name: "Служба доставки", head: "Петров П.П.", phone: "+7-495-234-56-78" },
  { name: "Пассажирские перевозки", head: "Сидоров С.С.", phone: "+7-495-345-67-89" },
  { name: "Международные перевозки", head: "Козлов К.К.", phone: "+7-495-456-78-90" }
]

const cities = [
  { name: "Москва", lat: 55.7558, lng: 37.6173 },
  { name: "Санкт-Петербург", lat: 59.9343, lng: 30.3351 },
  { name: "Казань", lat: 55.8304, lng: 49.0661 },
  { name: "Нижний Новгород", lat: 56.2965, lng: 43.9361 },
  { name: "Екатеринбург", lat: 56.8389, lng: 60.6057 },
  { name: "Новосибирск", lat: 55.0084, lng: 82.9357 },
  { name: "Тверь", lat: 56.8587, lng: 35.9176 },
  { name: "Владимир", lat: 56.1290, lng: 40.4066 }
]

const models = ["КамАЗ 5490", "МАЗ 5440", "Volvo FH", "Scania R450", "MAN TGX", "ГАЗель NEXT", "Ford Transit", "Mercedes Sprinter", "ПАЗ 3205", "ЛиАЗ 5292"]
const firstNames = ["Алексей", "Дмитрий", "Сергей", "Андрей", "Михаил", "Иван", "Николай", "Владимир", "Павел", "Артём"]
const lastNames = ["Смирнов", "Иванов", "Кузнецов", "Попов", "Соколов", "Лебедев", "Козлов", "Новиков", "Морозов", "Петров"]
const middleNames = ["Петрович", "Иванович", "Сергеевич", "Александрович", "Михайлович", "Николаевич", "Владимирович", "Андреевич"]
const maintenanceTypes = ["ТО-1", "ТО-2", "Ремонт", "Диагностика", "Замена масла", "Заправка"]
const serviceProviders = ["АвтоСервис Премиум", "ТехЦентр Профи", "Официальный дилер", "СТО Мастер", "АвтоДок"]
const fuelStations = ["Лукойл", "Газпромнефть", "Роснефть", "Shell", "BP"]
const tripStatuses = ["Запланирована", "В пути", "Завершена", "Отменена"]

// Хелперы
const rand = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min
const randEl = arr => arr[rand(0, arr.length - 1)]
const randDate = (start, end) => new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()))
const genPlate = () => {
  const letters = "АВЕКМНОРСТУХ"
  return randEl(letters.split('')) + rand(100,999) + randEl(letters.split('')) + randEl(letters.split('')) + rand(10,199)
}
const genVin = () => {
  const chars = "ABCDEFGHJKLMNPRSTUVWXYZ0123456789"
  return Array(17).fill().map(() => randEl(chars.split(''))).join('')
}
const genLicense = () => rand(10,99) + randEl("АВ".split('')) + randEl("АВ".split('')) + rand(100000,999999)

// --------------------------------------------
// 1. ГЕНЕРАЦИЯ VEHICLES (50 документов)
// --------------------------------------------
print("Генерация vehicles...")
const vehicleDocs = []
for (let i = 0; i < 50; i++) {
  const type = randEl(vehicleTypes)
  const dept = randEl(departments)
  const city = randEl(cities)
  
  vehicleDocs.push({
    licensePlate: genPlate(),
    model: randEl(models),
    year: rand(2015, 2024),
    vinNumber: genVin(),
    engineNumber: "ENG" + rand(100000, 999999),
    insurancePolicy: "ХХХ" + rand(1000000000, 9999999999),
    registrationDate: randDate(new Date(2015,0,1), new Date(2024,0,1)),
    isActive: Math.random() > 0.1,
    type: type,
    department: dept,
    currentLocation: {
      type: "Point",
      coordinates: [city.lng + (Math.random()-0.5)*0.1, city.lat + (Math.random()-0.5)*0.1]
    },
    createdAt: new Date(),
    updatedAt: new Date()
  })
}
db.vehicles.insertMany(vehicleDocs)
print(`Вставлено vehicles: ${db.vehicles.countDocuments()}`)

// Получаем ID для связей
const vehicleIds = db.vehicles.find({}, {_id:1}).toArray().map(v => v._id)

// --------------------------------------------
// 2. ГЕНЕРАЦИЯ TRIPS (300 документов)
// --------------------------------------------
print("Генерация trips...")
const tripDocs = []
for (let i = 0; i < 300; i++) {
  const startCity = randEl(cities)
  const endCity = randEl(cities.filter(c => c.name !== startCity.name))
  const status = randEl(tripStatuses)
  const startTime = randDate(new Date(2024,0,1), new Date(2024,11,31))
  const distanceKm = rand(50, 1500)
  
  // GPS трек (5-15 точек на поездку)
  const gpsTrack = []
  const trackPoints = rand(5, 15)
  for (let j = 0; j < trackPoints; j++) {
    const progress = j / (trackPoints - 1)
    gpsTrack.push({
      timestamp: new Date(startTime.getTime() + progress * rand(2,12) * 3600000),
      location: {
        type: "Point",
        coordinates: [
          startCity.lng + (endCity.lng - startCity.lng) * progress + (Math.random()-0.5)*0.05,
          startCity.lat + (endCity.lat - startCity.lat) * progress + (Math.random()-0.5)*0.05
        ]
      },
      speedKmh: rand(0, 110),
      directionDegrees: rand(0, 359)
    })
  }
  
  const dept = randEl(departments)
  const doc = {
    vehicleId: randEl(vehicleIds),
    driver: {
      firstName: randEl(firstNames),
      lastName: randEl(lastNames),
      middleName: randEl(middleNames),
      phone: "+7-9" + rand(10,99) + "-" + rand(100,999) + "-" + rand(10,99) + "-" + rand(10,99),
      licenseNumber: genLicense(),
      departmentName: dept.name
    },
    route: {
      name: `${startCity.name} - ${endCity.name}`,
      startPoint: `${startCity.name}, ул. Складская ${rand(1,100)}`,
      endPoint: `${endCity.name}, ул. Промышленная ${rand(1,100)}`,
      distanceKm: distanceKm,
      estimatedTimeMinutes: Math.round(distanceKm / 60 * 60),
      waypoints: [
        { seq: 1, name: startCity.name, lat: startCity.lat, lng: startCity.lng },
        { seq: 2, name: endCity.name, lat: endCity.lat, lng: endCity.lng }
      ]
    },
    status: status,
    startTime: startTime,
    gpsTrack: gpsTrack,
    lastSensorData: {
      engineTemperature: rand(70, 95),
      oilPressure: (rand(30, 50) / 10),
      tirePressure: { fl: 2.2 + Math.random()*0.3, fr: 2.2 + Math.random()*0.3, rl: 2.3 + Math.random()*0.3, rr: 2.3 + Math.random()*0.3 },
      batteryVoltage: 12.5 + Math.random()*1.5
    },
    createdAt: new Date(),
    updatedAt: new Date()
  }
  
  if (status === "Завершена") {
    doc.endTime = new Date(startTime.getTime() + rand(2,12) * 3600000)
    doc.actualDistanceKm = distanceKm + rand(-20, 50)
    doc.fuelConsumedLiters = doc.actualDistanceKm * rand(8, 25) / 100
  }
  
  tripDocs.push(doc)
}
db.trips.insertMany(tripDocs)
print(`Вставлено trips: ${db.trips.countDocuments()}`)

// Получаем trip IDs
const tripIds = db.trips.find({}, {_id:1}).toArray().map(t => t._id)

// --------------------------------------------
// 3. ГЕНЕРАЦИЯ MAINTENANCE (200 документов)
// --------------------------------------------
print("Генерация maintenance...")
const maintenanceDocs = []
for (let i = 0; i < 200; i++) {
  const mType = randEl(maintenanceTypes)
  const date = randDate(new Date(2024,0,1), new Date(2024,11,31))
  
  const doc = {
    vehicleId: randEl(vehicleIds),
    tripId: Math.random() > 0.5 ? randEl(tripIds) : null,
    type: mType,
    date: date,
    serviceProvider: mType === "Заправка" ? randEl(fuelStations) + " АЗС №" + rand(1,500) : randEl(serviceProviders),
    odometerReading: rand(10000, 300000),
    isCompleted: Math.random() > 0.15,
    createdAt: new Date()
  }
  
  if (mType === "Заправка") {
    const liters = rand(20, 80)
    const price = rand(50, 65)
    doc.fuelData = {
      liters: liters,
      pricePerLiter: price,
      totalCost: liters * price,
      station: doc.serviceProvider,
      receiptNumber: randEl(["ЛК","ГП","РН","SH","BP"]) + "-2024-" + rand(10000,99999)
    }
    doc.costRub = doc.fuelData.totalCost
  } else {
    doc.description = `${mType} - плановое обслуживание`
    doc.costRub = rand(1000, 50000)
    if (Math.random() > 0.3) {
      doc.nextMaintenanceDate = new Date(date.getTime() + rand(30,180) * 24*3600000)
    }
  }
  
  maintenanceDocs.push(doc)
}
db.maintenance.insertMany(maintenanceDocs)
print(`Вставлено maintenance: ${db.maintenance.countDocuments()}`)

// --------------------------------------------
// ИТОГ
// --------------------------------------------
print("\n========== ИТОГО ==========")
print(`vehicles:    ${db.vehicles.countDocuments()}`)
print(`trips:       ${db.trips.countDocuments()}`)
print(`maintenance: ${db.maintenance.countDocuments()}`)
print(`ВСЕГО:       ${db.vehicles.countDocuments() + db.trips.countDocuments() + db.maintenance.countDocuments()}`)
print("============================")