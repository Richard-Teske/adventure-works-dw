-- Creating schema 
create schema if not exists dw;

-- Creating table
drop table if exists dw.dim_customer;

create table dw.dim_customer (
	customer_id int not null primary key,
	first_name text null,
	middle_name text null,
	last_name text null, 
	suffix text null, 
	person_type text null, 
	address text null, 
	address_type text null, 
	postal_code text null, 
	spartial_location text null, 
	contact_type text null, 
	email_address text null, 
	phone_number text null, 
	phone_number_type text null
);

-- Insert rows from AdventureWorks Database
insert into dw.dim_customer
select		cus.customerid as customer_id,
			per.firstname as first_name,
			per.middlename as middle_name,
			per.lastname as last_name,
			per.suffix as suffix,
			per.persontype as person_type,
			adr.address,
			adr.address_type,
			adr.postal_code,
			adr.spartial_location,
			ctt."name" as contact_type,
			eml.emailaddress as email_address,
			pho.phonenumber as phone_number,
			pty."name" as phone_number_type
from		sales.customer cus
left join 	person.person per on cus.personid = per.businessentityid 
left join   person.businessentity ben on ben.businessentityid = per.businessentityid 
left join 	person.businessentitycontact bco on bco.personid = per.businessentityid 
left join 	person.contacttype ctt on ctt.contacttypeid = bco.contacttypeid 
left join   person.emailaddress eml on eml.businessentityid = ben.businessentityid 
left join 	person.personphone pho on pho.businessentityid = ben.businessentityid 
left join 	person.phonenumbertype pty on pty.phonenumbertypeid = pho.phonenumbertypeid
left join lateral (
	select		adr.addressline1 as address,
				adr.postalcode as postal_code,
				adr.spatiallocation as spartial_location,
				adt."name" as address_type
	from 		person.businessentityaddress bad 
	join		person.address adr on adr.addressid = bad.addressid 
	join 		person.addresstype adt on adt.addresstypeid = bad.addresstypeid 
	where 		ben.businessentityid = bad.businessentityid 
	order by 	bad.addressid 
	fetch first 1 row only
) adr on true