//1. Статистика по данным

// Общее число узлов
MATCH (n) RETURN count(n) AS total_nodes;

// Общее число связей
MATCH ()-[r]->() RETURN count(r) AS total_relationships;

// Распределение по типам узлов
MATCH (n)
RETURN labels(n)[0] AS node_type, count(*) AS count
ORDER BY count DESC;



// 2. Активные транзакции и запросы
SHOW TRANSACTIONS
YIELD transactionId, username, currentQuery, currentQueryElapsedTime, status
RETURN transactionId, username, status, currentQueryElapsedTime AS queryTimeMs, currentQuery
ORDER BY queryTimeMs DESC;

//3. Только выполняющиеся (не простаивающие) запросы
SHOW TRANSACTIONS
YIELD transactionId, username, currentQuery, currentQueryElapsedTime, status
WHERE currentQuery <> '<IDLE>'
RETURN transactionId, username, status, currentQueryElapsedTime AS ms, currentQuery
ORDER BY ms DESC;


//5. Информация о версии и редакции
CALL dbms.components() YIELD name, versions, edition
WHERE name = 'Neo4j Kernel'
RETURN versions[0] AS version, edition;












UNWIND range(1, 10) AS i
CREATE (:TestNode {id: i, name: 'Test ' + i, createdAt: datetime()});


MATCH (n:TestNode)
DETACH DELETE n;



// Создаём 10 тестовых водителей
UNWIND range(1, 10) AS i
CREATE (:TestDriver {id: i, name: 'Водитель ' + i});

// Создаём 3 тестовых автомобиля
UNWIND ['Авто-1', 'Авто-2', 'Авто-3'] AS name
CREATE (:TestVehicle {name: name});

//все водители управляют одним авто:
MATCH (d:TestDriver), (v:TestVehicle {name: 'Авто-1'})
MERGE (d)-[:DRIVES {since: date('2024-01-01')}]->(v);

//удалить
MATCH (n:TestDriver) DETACH DELETE n;
MATCH (v:TestVehicle) DETACH DELETE v;

MATCH (n) RETURN count(n)