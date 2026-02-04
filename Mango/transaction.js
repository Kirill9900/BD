// Начинаем сессию
var session = db.getMongo().startSession()

// Начинаем транзакцию
session.startTransaction()

try {
  var tripsCol = session.getDatabase("transport_monitoring").trips
  var maintCol = session.getDatabase("transport_monitoring").maintenance
  
  // Находим активную поездку
  var activeTrip = tripsCol.findOne({ status: "В пути" })
  
  if (!activeTrip) {
    throw new Error("Нет активных поездок")
  }
  
  print("Завершаем поездку: " + activeTrip._id)
  
  // ШАГ 1: Обновляем статус поездки
  tripsCol.updateOne(
    { _id: activeTrip._id },
    { $set: {
      status: "Завершена",
      endTime: new Date(),
      actualDistanceKm: 450.5,
      fuelConsumedLiters: 65.3,
      updatedAt: new Date()
    }}
  )
  print("Поездка обновлена")
  
  // ШАГ 2: Добавляем запись о заправке
  maintCol.insertOne({
    vehicleId: activeTrip.vehicleId,
    tripId: activeTrip._id,
    type: "Заправка",
    date: new Date(),
    serviceProvider: "Лукойл АЗС №123",
    costRub: 3500,
    fuelData: {
      liters: 65.3,
      pricePerLiter: 53.60,
      station: "Лукойл АЗС №123"
    },
    isCompleted: true,
    createdAt: new Date()
  })
  print("Заправка добавлена")
  
  // Всё ок — коммитим
  session.commitTransaction()
  print("=== ТРАНЗАКЦИЯ УСПЕШНО ЗАВЕРШЕНА ===")
  
} catch (error) {
  // Ошибка — откатываем
  session.abortTransaction()
  print("=== ТРАНЗАКЦИЯ ОТМЕНЕНА ===")
  print("Ошибка: " + error.message)
  
} finally {
  session.endSession()
}