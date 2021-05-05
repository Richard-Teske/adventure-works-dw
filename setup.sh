#!/bin/bash

container_name=$1

if test -f "install.sql"; then
    echo "Found file [install.sql]"
else
    echo "File [install.sql] not found!\nExiting..."
    exit
fi

if [ -d "dataa" ]; then
    echo "Found folder [data]"
else
    echo "Folder [data] not found!\nExiting..."
    exit
fi

echo "Copy install.sql file to docker container $container_name..."
docker cp $(pwd)/install.sql $container_name:usr/src/install.sql

echo "Copy data folder to docker container $container_name..."
docker cp $(pwd)/data $container_name:usr/src/data

echo "Executing script to create schema & data..."
docker exec -i $container_name psql -U advworks_dw -d AdventureWorks -a -f "usr/src/install.sql"