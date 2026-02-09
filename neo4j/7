/*
=====================================================================
ЗАПРОС 1: Найти водителей с общими транспортными средствами
Паттерн: два водителя управляют одним и тем же транспортом
=====================================================================
*/
MATCH (d1:Driver)-[:DRIVES]->(v:Vehicle)<-[:DRIVES]-(d2:Driver)
WHERE id(d1) < id(d2)
WITH d1, d2, collect(v) as commonVehicles
RETURN d1.firstName + ' ' + d1.lastName as Driver1,
       d2.firstName + ' ' + d2.lastName as Driver2,
       size(commonVehicles) as CommonVehicleCount,
       [v in commonVehicles | v.licensePlate] as SharedVehicles
ORDER BY CommonVehicleCount DESC, Driver1
LIMIT 15;


/*
=====================================================================
ЗАПРОС 2: Найти транспортные средства, обслуживаемые в общих сервисных центрах
Паттерн: два ТС проходят обслуживание в одних и тех же центрах
=====================================================================
*/
MATCH (v1:Vehicle)-[:SERVICED]->(:Maintenance)-[:PERFORMED_AT]->(sc:ServiceCenter)
      <-[:PERFORMED_AT]-(:Maintenance)<-[:SERVICED]-(v2:Vehicle)
WHERE id(v1) < id(v2)
WITH v1, v2, collect(DISTINCT sc) as commonServiceCenters
WHERE size(commonServiceCenters) > 0
RETURN v1.licensePlate as Vehicle1,
       v1.model as Model1,
       v2.licensePlate as Vehicle2,
       v2.model as Model2,
       size(commonServiceCenters) as CommonServiceCenters,
       [sc in commonServiceCenters | sc.name] as ServiceCenterNames
ORDER BY CommonServiceCenters DESC
LIMIT 20;


/*
=====================================================================
ЗАПРОС 3: Найти маршруты с общими транспортными средствами
Паттерн: два маршрута используются одним транспортом
=====================================================================
*/
MATCH (r1:Route)<-[:FOLLOWS]-(:Trip)-[:USES_VEHICLE]->(v:Vehicle)
      <-[:USES_VEHICLE]-(:Trip)-[:FOLLOWS]->(r2:Route)
WHERE id(r1) < id(r2)
WITH r1, r2, collect(DISTINCT v) as commonVehicles
WHERE size(commonVehicles) > 0
RETURN r1.name as Route1,
       r2.name as Route2,
       size(commonVehicles) as CommonVehicles,
       [v in commonVehicles | v.licensePlate] as VehiclePlates
ORDER BY CommonVehicles DESC
LIMIT 15;


/*
=====================================================================
ЗАПРОС 4: Найти водителей, которые ездили по общим маршрутам
Более сложный паттерн через поездки
=====================================================================
*/
MATCH (d1:Driver)<-[:PERFORMED_BY]-(:Trip)-[:FOLLOWS]->(r:Route)
      <-[:FOLLOWS]-(:Trip)-[:PERFORMED_BY]->(d2:Driver)
WHERE id(d1) < id(d2)
WITH d1, d2, collect(DISTINCT r) as commonRoutes
WHERE size(commonRoutes) > 0
RETURN d1.firstName + ' ' + d1.lastName as Driver1,
       d2.firstName + ' ' + d2.lastName as Driver2,
       size(commonRoutes) as CommonRouteCount,
       [r in commonRoutes | r.name] as RouteNames
ORDER BY CommonRouteCount DESC, Driver1
LIMIT 20;


/*
//  ЗАПРОС 5Найти транспорт, обслуживаемый в нескольких центрах
MATCH (v:Vehicle)-[:SERVICED]->(:Maintenance)-[:PERFORMED_AT]->(sc:ServiceCenter)
WITH v, collect(DISTINCT sc.name) as centers
WHERE size(centers) > 1
RETURN v.licensePlate as Vehicle,
       v.model,
       centers as ServiceCenters,
       size(centers) as CenterCount
ORDER BY CenterCount DESC
LIMIT 10;

/*
// ЗАПРОС 6 Найти водителей из одного отдела с общим транспортом
MATCH (d1:Driver)-[:DRIVES]->(v:Vehicle)<-[:DRIVES]-(d2:Driver)
WHERE id(d1) < id(d2)
RETURN d1.firstName + ' ' + d1.lastName as Driver1,
       d2.firstName + ' ' + d2.lastName as Driver2,
       v.licensePlate as SharedVehicle,
       v.model,
       d1.departmentName as Department
ORDER BY v.licensePlate
LIMIT 15;


/*