-- Creating schema 
create schema if not exists dw;

-- Creating table
drop table if exists dw.dim_product;

create table dw.dim_product (
	product_id int not null primary key,
	product_name text not null,
	product_model text null,
	product_color text null, 
	product_size text null, 
	product_weight float null, 
	days_to_manufacture int null, 
	product_class text null, 
	product_style text null, 
	product_subcategory text null, 
	product_category text null, 
	inventory_quantity int null, 
	inventory_bin int null, 
	product_rating_mean float null
);

with cte_product_review as (
	select 		productid ,
				avg(pre.rating) as product_rating_mean 
	from 		production.productreview pre
	group by 	pre.productid 
),
cte_product_inventory as (
	select 		pin.productid ,
				sum(pin.quantity) as inventory_quantity,
				sum(pin.bin) as inventory_bin
	from 		production.productinventory pin
	group by 	pin.productid
)

-- Insert rows from AdventureWorks Database
insert into dw.dim_product
select 		pro.productid as product_id,
			pro."name" as product_name,
			pro."name" as product_model,
			pro.color as product_color,
			pro."size" as product_size,
			pro.weight as product_weight,
			pro.daystomanufacture as days_to_manufacture,
			pro."class" as product_class,
			pro."style" as product_style,
			psu."name" as product_subcategory,
			pca."name" as product_category,
			cpi.inventory_quantity,
			cpi.inventory_bin,
			pre.product_rating_mean
from 		production.product pro
left join	production.productmodel pmo on pmo.productmodelid = pro.productmodelid 
left join 	production.productsubcategory psu on psu.productsubcategoryid = pro.productsubcategoryid 
left join 	production.productcategory pca on pca.productcategoryid = psu .productcategoryid 
left join 	cte_product_inventory cpi on cpi.productid = pro.productid 
left join	cte_product_review pre on pre.productid = pro.productid 
