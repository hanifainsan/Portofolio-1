select *
from INFORMATION_SCHEMA.TABLES

select *
from INFORMATION_SCHEMA.COLUMNS

SELECT TOP 5 customer_key
FROM DataWarehouseAnalytics.dbo.[gold.dim_customers];

SELECT TOP 5 product_key
FROM DataWarehouseAnalytics.dbo.[gold.dim_products];

select DISTINCT
category
from DataWarehouseAnalytics.dbo.[gold.dim_products];

select DISTINCT
country
from DataWarehouseAnalytics.dbo.[gold.dim_customers];

select DISTINCT
category, subcategory, product_name
from DataWarehouseAnalytics.dbo.[gold.dim_products]
order by 1,2,3


 --Find first order date
select 
min(order_date) as first_order_date,
max(order_date) as last_order_date,
DATEDIFF(year, Min(order_date), max(order_date)) as order_range_years --how many years available
from DataWarehouseAnalytics.dbo.[gold.fact_sales];


--Find the youngest and oldest
select
min(birthdate) as oldest_birthdate,
datediff(year, min(birthdate), getdate()) as oldest_age,
max(birthdate) as youngest_brithdate,
DATEDIFF(year, max(birthdate), getdate()) as youngest_age
FROM DataWarehouseAnalytics.dbo.[gold.dim_customers];


--Find Total Sales
Select Sum(sales_amount) as total_sales
from DataWarehouseAnalytics.dbo.[gold.fact_sales];

--item sold
select Sum(quantity) as total_quantity
FROM DataWarehouseAnalytics.dbo.[gold.fact_sales];

--Average Sale price
select avg(price) as AVG_Price
from DataWarehouseAnalytics.dbo.[gold.fact_sales];

--Total orders
select count(order_number) as total_orders--(duplicate ke hitung semua)
from DataWarehouseAnalytics.dbo.[gold.fact_sales];
select count(distinct order_number) as total_orders --(distinct eliminasi duplicate order number)
from DataWarehouseAnalytics.dbo.[gold.fact_sales];

--total number of products
select count(product_name) as total_products
from DataWarehouseAnalytics.dbo.[gold.dim_products];
select count(distinct product_name) as total_product  --hasillnya sama tidak ada duplicate
from DataWarehouseAnalytics.dbo.[gold.dim_products];

--Total Numbers of Customers
select count(customer_key) as total_customers
FROM DataWarehouseAnalytics.dbo.[gold.dim_customers];

--Total Number of Customers that has placed an order
select count(distinct customer_key) as total_customers
FROM DataWarehouseAnalytics.dbo.[gold.fact_sales];


--Generate Report
select 'Total Sales' as measure_name, sum(sales_amount) as measure_values
from DataWarehouseAnalytics.dbo.[gold.fact_sales]
UNION ALL
select 'Total Quantiuty' as measure_name, sum(quantity) as measure_values
from DataWarehouseAnalytics.dbo.[gold.fact_sales]
Union All
select 'Average Price' as measure_name, avg(price) as measure_values
from DataWarehouseAnalytics.dbo.[gold.fact_sales]
Union All
select 'Total Nr.Orders' as measure_name, count(distinct order_number) as measure_values
from DataWarehouseAnalytics.dbo.[gold.fact_sales]
Union All
Select 'Total Nr.Products' as measure_name, count(product_name) as measure_values
from DataWarehouseAnalytics.dbo.[gold.dim_products]
Union All
Select 'Total Nr.Customers' as measure_name, count(customer_key) as measure_values
from DataWarehouseAnalytics.dbo.[gold.dim_customers];


--Total Customers by Countries
Select 
country,
count (customer_key) as Total_Customers
from DataWarehouseAnalytics.dbo.[gold.dim_customers]
Group By country
Order by Total_Customers Desc
-- Total Customers by Gender
Select
Gender,
count (Customer_key) as Total_Customers
from DataWarehouseAnalytics.dbo.[gold.dim_customers]
Group BY gender
Order by Total_Customers Desc
-- Total Products by Categories
Select
category,
count (Product_key) as Total_Products
from DataWarehouseAnalytics.dbo.[gold.dim_products]
Group By category
Order By Total_Products Desc
-- Average cost in each category
select 
category,
AVG(cost) as avg_cost
from DataWarehouseAnalytics.dbo.[gold.dim_products]
Group BY category
Order BY avg_cost Desc
-- Total revenue for each category
select 
p.category,
SUM(f.sales_amount) total_revenue
from DataWarehouseAnalytics.dbo.[gold.fact_sales] f
left join DataWarehouseAnalytics.dbo.[gold.dim_products] p
ON p.product_key = f.product_key
Group By p.category
Order By total_revenue Desc
-- Total revenue for each customer
select
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) as total_revenue
from DataWarehouseAnalytics.dbo.[gold.fact_sales] f
left join DataWarehouseAnalytics.dbo.[gold.dim_customers] c
on c.customer_key = f.customer_key
Group by
c.customer_key,
c.first_name,
c.last_name
Order BY total_revenue DESC
-- Sold item accros country
select
c.country,
SUM(f.quantity) as total_sold_items
from DataWarehouseAnalytics.dbo.[gold.fact_sales] f
left join DataWarehouseAnalytics.dbo.[gold.dim_customers] c
on c.customer_key = f.customer_key
Group BY
c.country
order by total_sold_items desc
-- 5 Products hihghest revenue
select top 5
p.product_name,
SUM(f.sales_amount) total_revenue
from DataWarehouseAnalytics.dbo.[gold.fact_sales] f
left join DataWarehouseAnalytics.dbo.[gold.dim_products] p
on p.product_key = f.product_key
group by
p.product_name
order by total_revenue desc
-- 5 worst performing products in terms of sales
select top 5
p.product_name,
sum(f.sales_amount) total_revenue
from DataWarehouseAnalytics.dbo.[gold.fact_sales] f
left join DataWarehouseAnalytics.dbo.[gold.dim_products] p
on p.product_key = f.product_key
group by
p.product_name
order by total_revenue


select *
from(
	select
	p.product_name,
	sum(f.sales_amount) total_revenue,
	row_number() Over (order by sum(f.sales_amount) desc) as rank_products
	from DataWarehouseAnalytics.dbo.[gold.fact_sales] f
	left join DataWarehouseAnalytics.dbo.[gold.dim_products] p
	on p.product_key = f.product_key
	group by
	p.product_name) t
where rank_products <= 5
--top 10 customers the highest revenue
select top 10
c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) as total_revenue
from DataWarehouseAnalytics.dbo.[gold.fact_sales] f
left join DataWarehouseAnalytics.dbo.[gold.dim_customers] c
on c.customer_key = f.customer_key
Group by
c.customer_key,
c.first_name,
c.last_name
Order BY total_revenue DESC
--3 customers fewest order placed
select top 3
c.customer_key,
c.first_name,
c.last_name,
count(distinct order_number) as total_orders
from DataWarehouseAnalytics.dbo.[gold.fact_sales] f
left join DataWarehouseAnalytics.dbo.[gold.dim_customers] c
on c.customer_key = f.customer_key
group by
c.customer_key,
c.first_name,
c.last_name
order by total_orders

