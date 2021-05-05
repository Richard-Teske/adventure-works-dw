# Adventure Works DW Project

## Introduction

This project is intended to create a data warehouse architecture from Adventure Works data. The database is 3º normal form and we will transform it to a snow flake schema

## Objective

Our goals is creating some architecture that could easily queried and understandable by business people. With that in mind, we want to awnser a few questions about the data:

* Which city has more sales between first quarter of the year
* Product already sell with more taxes 

Here's a Entity Relationship Diagram from Adventure Works:

![adv-works-diagram](images/adv-works-diagram.png)

## Configurations

To run a docker container for postgres locally:<br>
`docker run --name postgres-dw -p 5432:5432 -e POSTGRES_PASSWORD=advworks_dw_123 -e POSTGRES_USER=advworks_dw -e POSTGRES_DB=AdventureWorks -d postgres`

To create schema and populate tables in postgres just run:<br>
`sh setup.sh postgres-dw`

And then check if data is there<br>
`docker exec -it postgres-dw psql -U advworks_dw -d AdventureWorks -c "SELECT * FROM sales.store LIMIT 5"`

<br>

Big thanks to @NorfolkDataSci for share he's repository with the data and install.sql file to work on postgres<br>
You can check the repo here: https://github.com/NorfolkDataSci/adventure-works-postgres