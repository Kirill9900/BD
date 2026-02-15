CALL dbms.listConfig() 
YIELD name, value 
WHERE name CONTAINS 'memory' 
RETURN name, value;



PROFILE 
MATCH (d:Driver)-[:DRIVES]->(v:Vehicle) 
WHERE d.experienceYears > 5 
RETURN d.firstName, v.model;


PROFILE MATCH (d:Driver {firstName: 'Сергей'}) RETURN d; //выполняет и покаызвает че получилось
EXPLAIN MATCH (d:Driver {firstName: 'Сергей'}) RETURN d; //Просто показывает план запроса используется ли индекс и тд