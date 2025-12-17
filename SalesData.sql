-- Inspecting Data
select * from DataSales.dbo.sales_data_sample

--Unique Values
select distinct status from DataSales.dbo.sales_data_sample
select distinct year_id from DataSales.dbo.sales_data_sample
select distinct PRODUCTLINE from DataSales.dbo.sales_data_sample
select distinct country from DataSales.dbo.sales_data_sample
select distinct dealsize from DataSales.dbo.sales_data_sample
select distinct territory from DataSales.dbo.sales_data_sample

select distinct MONTH_ID
from DataSales.dbo.sales_data_sample
where year_id = 2003

--		ANALYSIS
--grouping sales by productline
Select productline, sum(sales) revenue
from DataSales.dbo.sales_data_sample
group by productline
order by 2 desc

Select Year_id, sum(sales) revenue
from DataSales.dbo.sales_data_sample
group by YEAR_ID
order by 2 desc

Select dealsize, sum(sales) revenue
from DataSales.dbo.sales_data_sample
group by DEALSIZE
order by 2 desc

-- Best month for sales and in spesific year, how much was earned
Select month_id, sum(sales) revenue, count(ordernumber) Frequency
from DataSales.dbo.sales_data_sample
where YEAR_ID = 2005
group by MONTH_ID
order by 2 desc

-- Product sale in November
select month_id, productline, sum(sales) Revenue, count(ordernumber)
from DataSales.dbo.sales_data_sample
where year_id = 2003 and month_id = 11
group by month_id, productline
order by 3 desc

-- Best Costummer(Using RFM)
DROP TABLE IF EXISTS #rfm
;with rfm as
(
	
	Select 
		CUSTOMERNAME,
		sum(sales) MonetaryValue,
		AVG(sales) AVGMonetaryValue,
		Count(ordernumber) Frequency,
		Max (orderdate) last_order_date,
		(select max(orderdate) from DataSales.dbo.sales_data_sample)max_order_date,
		DATEDIFF(DD, max(orderdate),(select max(orderdate) from DataSales.dbo.sales_data_sample)) Recency --Make Recency
	from DataSales.dbo.sales_data_sample
	group by CUSTOMERNAME
),
rfm_calc as
(
	select r.*,
		NTILE(4) OVER(Order by Recency desc) Rfm_Recency,
		NTILE(4) OVER(Order by Frequency ) Rfm_Frequency,
		NTILE(4) OVER(Order by MonetaryValue ) Rfm_Monetary
	from rfm r
)
select
	c.*, Rfm_Recency + Rfm_Frequency + Rfm_Monetary as Rfm_cell,
	cast (Rfm_Recency as nvarchar) + cast(Rfm_Frequency as nvarchar) + cast(Rfm_Monetary as nvarchar)rfm_cell_string
into #rfm
from rfm_calc c

Select CUSTOMERNAME, Rfm_Recency, Rfm_Frequency, Rfm_Monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from #rfm

--RFM use when send out marketing campaign or advertisement(wich customer you want to target fro wich program)--

-- What product are most often sold together
--which product see often sold together
-- Select * from DataSales.dbo.sales_data_sample where ordernumber = 10411(Orderhanyasekali tetapi beberapa product)

Select distinct Ordernumber, stuff(

	(Select ',' + PRODUCTCODE --("," append the products code for each other on one columns instead of rows
	from DataSales.DBO.sales_data_sample p
	where ordernumber in
		(
			Select ordernumber
			from (
				select ordernumber, count(*) rn
				from DataSales.dbo.sales_data_sample
				where STATUS ='Shipped'
				Group by ORDERNUMBER
			)m
			where rn = 3 --(only 2 items ordered)
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))--convert result to one line xml

		, 1, 1, '') ProductCodes--convert xml to string

from DataSales.dbo.sales_data_sample s
order by 2 desc