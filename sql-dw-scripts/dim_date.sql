-- Creating schema 
create schema if not exists dw;

-- Creating table
drop table if exists dw.dim_date;

create table dw.dim_date (
	date_id text not null primary key,
	yyyy_mm_dd text not null,
	dd_mm_yyyy text not null,
	day_suffix text not null, 
	day_name text not null, 
	day_of_week int not null, 
	day_of_month int not null, 
	day_of_quarter int not null, 
	day_of_year int not null, 
	week_of_month int not null, 
	week_of_year int not null, 
	month int not null, 
	month_name text not null, 
	month_name_abbreviated text not null, 
	quarter int not null, 
	quarter_name text not null, 
	year int not null, 
	first_day_of_week date not null, 
	last_day_of_week date not null, 
	first_day_of_month date not null, 
	last_day_of_month date not null, 
	first_day_of_quarter date not null, 
	last_day_of_quarter date not null, 
	first_day_of_year date not null, 
	last_day_of_year date not null, 
	is_weekend bool not null
);

-- Insert rows from AdventureWorks Database
insert into dw.dim_date
SELECT 		distinct 
			TO_CHAR(soh.orderdate, 'yyyymmdd') AS date_id,
		   	TO_CHAR(soh.orderdate, 'yyyy-mm-dd') as yyyy_mm_dd,
		   	TO_CHAR(soh.orderdate, 'dd-mm-yyyy') as dd_mm_yyyy,
	       	TO_CHAR(soh.orderdate, 'fmDDth') AS day_suffix,
	       	TO_CHAR(soh.orderdate, 'Day') AS day_name,
	       	EXTRACT(ISODOW FROM soh.orderdate) AS day_of_week,
	       	EXTRACT(DAY FROM soh.orderdate) AS day_of_month,
	       	cast(soh.orderdate as date) - DATE_TRUNC('quarter', soh.orderdate)::DATE + 1 AS day_of_quarter,
	       	EXTRACT(DOY FROM soh.orderdate) AS day_of_year,
	       	TO_CHAR(soh.orderdate, 'W')::INT AS week_of_month,
	       	EXTRACT(WEEK FROM soh.orderdate) AS week_of_year,
	       	EXTRACT(MONTH FROM soh.orderdate) AS month,
	       	TO_CHAR(soh.orderdate, 'Month') AS month_name,
	       	TO_CHAR(soh.orderdate, 'Mon') AS month_name_abbreviated,
	       	EXTRACT(QUARTER FROM soh.orderdate) AS quarter,
	       	CASE
	           WHEN EXTRACT(QUARTER FROM soh.orderdate) = 1 THEN 'First'
	           WHEN EXTRACT(QUARTER FROM soh.orderdate) = 2 THEN 'Second'
	           WHEN EXTRACT(QUARTER FROM soh.orderdate) = 3 THEN 'Third'
	           WHEN EXTRACT(QUARTER FROM soh.orderdate) = 4 THEN 'Fourth'
	           END AS quarter_name,
	       	EXTRACT(ISOYEAR FROM soh.orderdate) AS year,
	       	cast(soh.orderdate as date) + (1 - EXTRACT(ISODOW FROM soh.orderdate))::INT AS first_day_of_week,
	       	cast(soh.orderdate as date) + (7 - EXTRACT(ISODOW FROM soh.orderdate))::INT AS last_day_of_week,
	       	cast(soh.orderdate as date) + (1 - EXTRACT(DAY FROM soh.orderdate))::INT AS first_day_of_month,
	       	(DATE_TRUNC('MONTH', soh.orderdate) + INTERVAL '1 MONTH - 1 day')::DATE AS last_day_of_month,
	       	DATE_TRUNC('quarter', soh.orderdate)::DATE AS first_day_of_quarter,
	       	(DATE_TRUNC('quarter', soh.orderdate) + INTERVAL '3 MONTH - 1 day')::DATE AS last_day_of_quarter,
	       	TO_DATE(EXTRACT(YEAR FROM soh.orderdate) || '-01-01', 'YYYY-MM-DD') AS first_day_of_year,
	       	TO_DATE(EXTRACT(YEAR FROM soh.orderdate) || '-12-31', 'YYYY-MM-DD') AS last_day_of_year,
	       	CASE
	           WHEN EXTRACT(ISODOW FROM soh.orderdate) IN (6, 7) THEN TRUE
	           ELSE FALSE
	        END AS is_weekend
FROM 		sales.salesorderheader soh
order by 	1 