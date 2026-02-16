// Создаём пользователя reader
CREATE USER reader SET PASSWORD 'reader123' CHANGE NOT REQUIRED;

// Назначаем роль reader (только чтение)
GRANT ROLE reader TO reader;

// Даём доступ к базе данных neo4j
GRANT ACCESS ON DATABASE neo4j TO reader;

// Даём право читать данные
GRANT MATCH {*} ON GRAPH neo4j TO reader;


// Создаём пользователя publisher
CREATE USER publisher SET PASSWORD 'publisher123' CHANGE NOT REQUIRED;

// Назначаем роль publisher (чтение + запись)
GRANT ROLE publisher TO publisher;

// Даём полный доступ к базе
GRANT ACCESS ON DATABASE neo4j TO publisher;

// Даём права на чтение и запись
GRANT MATCH {*} ON GRAPH neo4j TO publisher;
GRANT CREATE ON GRAPH neo4j TO publisher;
GRANT DELETE ON GRAPH neo4j TO publisher;
GRANT SET LABEL ON GRAPH neo4j TO publisher;



// Просмотр всех пользователей
SHOW USERS;

// Просмотр ролей пользователя reader
SHOW USER reader PRIVILEGES;

// Просмотр ролей пользователя publisher
SHOW USER publisher PRIVILEGES;

заппись ридер: CREATE (n:TestNode {name: 'Test'}) RETURN n;
MATCH (n) RETURN n LIMIT 10;

publisher: 

читать: MATCH (n) RETURN n LIMIT 10; 


