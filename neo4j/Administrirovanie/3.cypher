-----LOAD CSV-----

LOAD CSV WITH HEADERS FROM 'file:///test_drivers_import.csv' AS row
MERGE (d:Driver {licenseNumber: row.licenseNumber})
ON CREATE SET
  d.firstName = row.firstName,
  d.lastName = row.lastName,
  d.phone = row.phone,
  d.experienceYears = toInteger(row.experienceYears),
  d.departmentName = row.departmentName



MATCH (d:Driver) RETURN count(d)






-------------------

docker run --rm \
  -e NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
  -v "$(pwd)/import:/import" \
  -v neo4j_test_import:/data \
  neo4j:enterprise \
  neo4j-admin database import full \
    --overwrite-destination=true \
    --nodes=/import/test_drivers_admin.csv \
    --to-database-location=/data/databases/neo4j