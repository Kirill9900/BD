#!/bin/bash
# gen_gps_batches.sh
# Batch GPS generation for transport.gps_tracking
# Настройки:
DB="transport_monitoring"
PSQL="psql -d $DB -q -v ON_ERROR_STOP=1"
BATCH_TRIPS=2000        # число поездок в одном батче (можно 2000..10000)
POINTS_PER_HOUR=6       # начальное предположение (точек в час)
MAX_POINTS_PER_TRIP=1000

# Определяем диапазон завершённых поездок
MIN_TRIP=$($PSQL -t -c "SELECT COALESCE(MIN(trip_id),0) FROM transport.trips WHERE trip_status='Завершена';" | tr -d ' ')
MAX_TRIP=$($PSQL -t -c "SELECT COALESCE(MAX(trip_id),0) FROM transport.trips WHERE trip_status='Завершена';" | tr -d ' ')

echo "План генерации GPS: trips $MIN_TRIP .. $MAX_TRIP (статус 'Завершена')"
if [ "$MIN_TRIP" -eq 0 ] || [ "$MAX_TRIP" -eq 0 ]; then
  echo "Нет завершённых поездок. Сгенерируй trips сначала."
  exit 1
fi

# Пробегаем батчами по trip_id
for START in $(seq $MIN_TRIP $BATCH_TRIPS $MAX_TRIP); do
  END=$((START + BATCH_TRIPS - 1))
  if [ $END -gt $MAX_TRIP ]; then END=$MAX_TRIP; fi
  echo "Обрабатываю поездки $START .. $END"

  $PSQL <<SQL
BEGIN;
INSERT INTO transport.gps_tracking (vehicle_id, trip_id, timestamp, latitude, longitude, speed_kmh)
SELECT t.vehicle_id, t.trip_id,
       t.start_time + ((gs.n - 1)::float / t.tot_pts) * (t.end_time - t.start_time) AS timestamp,
       t.start_lat + ((gs.n - 1)::float / t.tot_pts) * (t.target_lat - t.start_lat) + (random()-0.5)*0.001 AS latitude,
       t.start_lng + ((gs.n - 1)::float / t.tot_pts) * (t.target_lng - t.start_lng) + (random()-0.5)*0.002 AS longitude,
       CASE WHEN random() < 0.1 THEN 0
            WHEN random() < 0.3 THEN 20 + random() * 40
            ELSE 60 + random() * 50 END AS speed_kmh
FROM (
    SELECT trip_id, vehicle_id, start_time, end_time,
           GREATEST(1, LEAST( (EXTRACT(EPOCH FROM (end_time - start_time))/3600.0 * $POINTS_PER_HOUR)::int, $MAX_POINTS_PER_TRIP)) AS tot_pts,
           55.0 + random()*10.0 AS start_lat,
           37.0 + random()*50.0 AS start_lng,
           55.0 + random()*10.0 + (random()-0.5)*2.0 AS target_lat,
           37.0 + random()*50.0 + (random()-0.5)*4.0 AS target_lng
    FROM transport.trips
    WHERE trip_status = 'Завершена'
      AND trip_id BETWEEN $START AND $END
) t
CROSS JOIN generate_series(1, t.tot_pts) AS gs(n);
COMMIT;
SQL

  # краткая пауза для разгрузки
  sleep 0.2
done

echo "Генерация GPS по батчам завершена."
