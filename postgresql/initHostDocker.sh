#!/bin/bash
docker rm -f pgdb-1
docker run -d -p 5432:5432 --name pgdb-1 -e POSTGRES_PASSWORD=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx postgres

sleep 5

while read -r line; do
  echo "Running command with parameter: $line"
  docker exec  pgdb-1 psql -U postgres -c "$line"
done < postgresql/createDatabase.sql

while read -r line; do
  echo "Running command with parameter: $line"
  docker exec pgdb-1 psql -U postgres -d chatstore -c "$line" 
done < postgresql/createTables.sql