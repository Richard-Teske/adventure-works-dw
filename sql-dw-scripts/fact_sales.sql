-- Creating schema 
create schema if not exists dw;

-- Creating table
drop table if exists dw.fact_sales;

create table dw.fact_sales (
	sales_id int not null primary key,
	date_id text not null ,
	location_id int not null ,
	product_id int not null ,
	customer_id int not null ,
	order_quantity int not null,
	unit_price float not null,
	unit_price_discount float not null,
	tax_amount float not null,
	freight float not null,
	total_due float not null,
	ship_base float not null, 
	ship_rate float not null,
	sales_person_bonus float not null,
	sales_person_comission_pct float not null,
	sub_total float not null,
	
	constraint fk_date foreign key (date_id) references dw.dim_date (date_id),
	constraint fk_location foreign key (location_id) references dw.dim_location (location_id),
	constraint fk_product foreign key (product_id) references dw.dim_product (product_id),
	constraint fk_customer foreign key (customer_id) references dw.dim_customer (customer_id)
);

with sum_sub_total as (
	select 	salesorderid,
			sum(orderqty * unitprice) as total 
	from	sales.salesorderdetail
	group by salesorderid
)

-- Insert rows from AdventureWorks Database
insert into dw.fact_sales
SELECT 		sod.salesorderdetailid as sales_id,
			TO_CHAR(soh.orderdate, 'yyyymmdd') as date_id,
			coalesce(adr.addressid, soh.shiptoaddressid) as location_id,
			sod.productid as product_id,
			soh.customerid as customer_id,
			sum(sod.orderqty) as order_quantity, 
			sum(sod.unitprice) as unit_price, 
			sum(sod.unitpricediscount) as unit_price_discount, 
			sum((sod.orderqty * sod.unitprice / sst.total ) * soh.taxamt) as tax_amount,
			sum((sod.orderqty * sod.unitprice / sst.total ) * soh.freight) as freight,
			sum(((sod.orderqty * sod.unitprice / sst.total ) * soh.taxamt) + 
			((sod.orderqty * sod.unitprice / sst.total ) * soh.freight) + 
			(sod.orderqty * sod.unitprice)) as totaldue,
			sum((sod.orderqty * sod.unitprice / sst.total ) * sme.shipbase) as ship_base,
			sum((sod.orderqty * sod.unitprice / sst.total ) * sme.shiprate) as ship_rate,
			coalesce (sum((sod.orderqty * sod.unitprice / sst.total ) * spe.bonus), 0) as sales_person_bonus,
			coalesce (sum((sod.orderqty * sod.unitprice / sst.total ) * spe.commissionpct), 0) as sales_person_comission_pct,
			sum(sod.orderqty * sod.unitprice) as sub_total
from 		sales.salesorderdetail sod 
join 		sales.salesorderheader soh on soh.salesorderid = sod.salesorderid
join 		sum_sub_total sst on sst.salesorderid = sod.salesorderid
join 		sales.specialofferproduct sop on sop.specialofferid = sod.specialofferid 
									  and sop.productid = sod.productid 
join 		sales.specialoffer sof on sof.specialofferid = sop.specialofferid 
join  		purchasing.shipmethod sme on sme.shipmethodid = soh.shipmethodid 
left join 	sales.salesperson spe on spe.businessentityid = soh.salespersonid 
join 		sales.customer cus on cus.customerid = soh.customerid 
join 		person.person per on per.businessentityid = cus.personid 
left join lateral (
	select		adr.addressid 
	from 		person.businessentityaddress bad 
	join		person.address adr on adr.addressid = bad.addressid 
	where 		per.businessentityid = bad.businessentityid 
	order by 	bad.addressid 
	fetch first 1 row only
) adr on true
group by 	TO_CHAR(soh.orderdate, 'yyyymmdd'),
			sod.productid,
			adr.addressid,
			sod.salesorderdetailid,
			soh.customerid,
			soh.shiptoaddressid
