#!/bin/bash

while read -r line; do
  echo "Running command with parameter: $line"
  psql -U postgres -c "$line"
done < postgresql/createDatabase.sql

while read -r line; do
  echo "Running command with parameter: $line"
  psql -U postgres -d chatstore -c "$line" 
done < postgresql/createTables.sql