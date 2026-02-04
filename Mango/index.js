print("=== ДО ОПТИМИЗАЦИИ ===")
var start = new Date();
var result = db.trips.find({ vehicleId: ObjectId("692003c15a35ee4d24ce5f47") }).limit(10).toArray();
var end = new Date();
print("Время:", end - start, "ms");
print("Найдено документов:", result.length);

printjson(
  db.trips.find({ vehicleId: ObjectId("692003c15a35ee4d24ce5f47") }).explain("executionStats")
);

print("\n=== СОЗДАЮ ИНДЕКС ===")
db.trips.createIndex({ vehicleId: 1 });

print("\n=== ПОСЛЕ ОПТИМИЗАЦИИ ===")
var start2 = new Date();
var result2 = db.trips.find({ vehicleId: ObjectId("692003c15a35ee4d24ce5f47") }).limit(10).toArray();
var end2 = new Date();
print("Время:", end2 - start2, "ms");
print("Найдено документов:", result2.length);

printjson(
  db.trips.find({ vehicleId: ObjectId("692003c15a35ee4d24ce5f47") }).explain("executionStats")
);
