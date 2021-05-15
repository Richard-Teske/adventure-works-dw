-- Creating schema 
create schema if not exists dw;

-- Creating table
drop table if exists dw.dim_location;

create table dw.dim_location (
	location_id int not null primary key,
	city text not null,
	state_province_code text null,
	state_province_name text null, 
	country_region_code text null, 
	country_region_name text null, 
	territory_name text null, 
	region_group text null, 
	state_province_tax_name text null, 
	state_province_tax_rate float null
);

-- Insert rows from AdventureWorks Database
insert into dw.dim_location
select 		adr.addressid as location_id,
			adr.city as city,
			stp.stateprovincecode as state_province_code,
			stp."name" as state_province_name,
			stp.countryregioncode as country_region_code,
			cor."name" as country_region_name,
			sat."name" as territory_name,
			sat."group" as region_group,
			str.state_province_tax_name,
			str.state_province_tax_rate
from 		person.address adr
join 		person.stateprovince stp on stp.stateprovinceid = adr.stateprovinceid 
join		person.countryregion cor on cor.countryregioncode = stp.countryregioncode
join 		sales.salesterritory sat on sat.territoryid = stp.territoryid 
left join lateral (
		select 	tax."name" as state_province_tax_name,
				tax.taxrate as state_province_tax_rate
		from 	sales.salestaxrate tax
		where 	tax.stateprovinceid = stp.stateprovinceid
		fetch first 1 row only
	) str on true 

