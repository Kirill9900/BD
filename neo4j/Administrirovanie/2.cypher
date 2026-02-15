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


