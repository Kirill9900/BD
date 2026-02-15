docker run --rm \
  -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  -v neo4j_neo4j_data:/data \
  -v $(pwd)/backups:/backups \
  neo4j:enterprise \
  neo4j-admin database dump neo4j --to-path=/backups

docker run --rm \
  -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  -v neo4j_neo4j_data:/data \
  -v $(pwd)/backups:/backups \
  neo4j:enterprise \
  neo4j-admin database load neo4j --from-path=/backups --overwrite-destination=true

  