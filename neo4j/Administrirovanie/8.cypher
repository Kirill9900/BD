CREATE (n:TestNode {timestamp: datetime(), data: randomUUID()}) RETURN n.timestamp;

docker kill neo4j

docker-compose up -d

MATCH (n:TestNode) RETURN count(n), max(n.timestamp);




MATCH (n:TestNode) DELETE n;