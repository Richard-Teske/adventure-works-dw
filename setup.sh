#!/bin/bash

container_name=$1

if test -f "install.sql"; then
    echo "Found file [install.sql]"
else
    echo "File [install.sql] not found!\nExiting..."
    exit
fi

if [ -d "data" ]; then
    echo "Found folder [data]"
else
    echo "Folder [data] not found!\nExiting..."
    exit
fi

if [ -d "sql-dw-scripts" ]; then
    echo "Found folder [sql-dw-scripts]"
else
    echo "Folder [sql-dw-scripts] not found!\nExiting..."
    exit
fi

echo "Copy install.sql file to docker container $container_name..."
docker cp $(pwd)/install.sql $container_name:usr/src/install.sql

echo "Copy data folder to docker container $container_name..."
docker cp $(pwd)/data $container_name:usr/src/data

echo "Executing script to create schema & data..."
docker exec -i $container_name psql -U advworks_dw -d AdventureWorks -a -f "usr/src/install.sql"

echo "Insert data to dimensional tables"

echo "Customer dimension table"
cat $(pwd)/sql-dw-scripts/dim_customer.sql | docker exec -i $container_name psql -U advworks_dw -d AdventureWorks
echo "Date dimension table"
cat $(pwd)/sql-dw-scripts/dim_date.sql | docker exec -i $container_name psql -U advworks_dw -d AdventureWorks
echo "Location dimension table"
cat $(pwd)/sql-dw-scripts/dim_location.sql | docker exec -i $container_name psql -U advworks_dw -d AdventureWorks
echo "Product dimension table"
cat $(pwd)/sql-dw-scripts/dim_product.sql | docker exec -i $container_name psql -U advworks_dw -d AdventureWorks
echo "Sales fact table"
cat $(pwd)/sql-dw-scripts/fact_sales.sql | docker exec -i $container_name psql -U advworks_dw -d AdventureWorks

echo "DONE!"