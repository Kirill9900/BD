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

