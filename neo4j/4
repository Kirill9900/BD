// ШАГ 4: Цепочки связей и переменная длина пути [:REL*2..4]

// ЗАПРОС 1: Найти водителей, связанных через общий транспорт (косвенная связь через Vehicle)
// Цепочка: Driver -[:DRIVES]-> Vehicle <-[:DRIVES]- Driver
MATCH (d1:Driver)-[:DRIVES]->(v:Vehicle)<-[:DRIVES]-(d2:Driver)
WHERE d1 <> d2
RETURN d1.firstName + ' ' + d1.lastName as Driver1, 
       d2.firstName + ' ' + d2.lastName as Driver2,
       v.licensePlate, v.model
ORDER BY v.licensePlate
LIMIT 20;

// ЗАПРОС 2: Найти маршруты, связанные через 2 поездки (косвенная связь)
// Цепочка: Route <-[:FOLLOWS]- Trip -[:USES_VEHICLE]-> Vehicle <-[:USES_VEHICLE]- Trip -[:FOLLOWS]-> Route
MATCH path = (r1:Route)<-[:FOLLOWS]-(t1:Trip)-[:USES_VEHICLE]->(v:Vehicle)<-[:USES_VEHICLE]-(t2:Trip)-[:FOLLOWS]->(r2:Route)
WHERE r1 <> r2 AND t1 <> t2
RETURN r1.name as Route1, r2.name as Route2, v.licensePlate, 
       length(path) as PathLength
LIMIT 15;

// ЗАПРОС 3: Найти связи между водителями через поездки (переменная длина 2-3)
// Водители, связанные косвенно через поездки и транспорт (длина пути 2..4)
MATCH path = (d1:Driver)<-[:PERFORMED_BY*1..2]-(t:Trip)-[:USES_VEHICLE*1..2]->(v:Vehicle)<-[:USES_VEHICLE*1..2]-(t2:Trip)-[:PERFORMED_BY*1..2]->(d2:Driver)
WHERE d1 <> d2
RETURN d1.firstName + ' ' + d1.lastName as Driver1,
       d2.firstName + ' ' + d2.lastName as Driver2,
       length(path) as ConnectionSteps,
       [node in nodes(path) | labels(node)[0]] as NodeTypes
LIMIT 10;


// ЗАПРОС 5: Найти цепочку: Водитель -> Поездка -> Маршрут (длина 2)
MATCH path = (d:Driver)-[*2..4]-(r:Route)
RETURN d.firstName + ' ' + d.lastName as Driver,
       r.name as Route,
       r.distanceKm,
       length(path) as PathLength
LIMIT 25;

//6
MATCH path = (v1:Vehicle)-[*3..4]-(v2:Vehicle)
WHERE v1 <> v2
RETURN v1.licensePlate as Vehicle1,
       v2.licensePlate as Vehicle2,
       length(path) as PathLength,
       [rel in relationships(path) | type(rel)] as RelationshipTypes
LIMIT 15;

































// Водитель -> Поездка -> Транспорт -> Maintenance -> ServiceCenter <- Maintenance <- Vehicle <- Поездка <- Водитель
MATCH path = (d1:Driver)-[:PERFORMED_BY*1..2]-(t1:Trip)-[:USES_VEHICLE*1..2]->(v:Vehicle)
             -[:SERVICED*1..2]->(m:Maintenance)-[:PERFORMED_AT]->(sc:ServiceCenter)
             <-[:PERFORMED_AT]-(:Maintenance)<-[:SERVICED*1..2]-(v2:Vehicle)<-[:USES_VEHICLE*1..2]-(t2:Trip)
             <-[:PERFORMED_BY*1..2]-(d2:Driver)
WHERE d1 <> d2
RETURN d1.firstName + ' ' + d1.lastName as Driver1,
       d2.firstName + ' ' + d2.lastName as Driver2,
       length(path) as Steps,
       [node in nodes(path) | labels(node)[0]] as NodeTypes
LIMIT 10;





// Vehicle -> Trip -> Route <- Trip <- Vehicle
MATCH path = (v1:Vehicle)-[:USES_VEHICLE*1..2]-(t1:Trip)-[:FOLLOWS*1..2]->(r:Route)
             <-[:FOLLOWS*1..2]-(t2:Trip)-[:USES_VEHICLE*1..2]-(v2:Vehicle)
WHERE v1 <> v2
RETURN v1.licensePlate as Vehicle1,
       v2.licensePlate as Vehicle2,
       r.name as CommonRoute,
       length(path) as Steps,
       [rel in relationships(path) | type(rel)] as RelationshipTypes
LIMIT 15;
