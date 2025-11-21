select * from df_orders

--Top 10 Highest Revenue Product
select Top 10 product_id,sum(quantity*sale_price)as revenue from df_orders
group by product_id
order by revenue desc 

--Top 5 Highest selling product by each region
with cte as(
select region, product_id,sum(quantity*sale_price)as revenue
from df_orders
group by region,product_id)
select * from(
select *,
ROW_NUMBER() over(partition by region order by revenue)as rn
from cte)A
where rn<=5

-- find month over month growth comparison for 2022 and 2023 sales
with cte as(
select year(order_date) as order_year,MONTH(order_date) as order_month,
SUM(sale_price)as sales
from df_orders
group by year(order_date),MONTH(order_date))
select order_month
,sum(case when order_year = 2022 then sales else 0 end) as sales_2022
,sum(case when order_year = 2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month

--for each category which month had highest sale
with cte as(
select category,format(order_date,'yyyy-MM')as order_year_month,SUM(sale_price) as sales
from df_orders
group by category,format(order_date,'yyyy-MM')
)
select * from(
select *,
ROW_NUMBER() over(partition by category order by sales DESC) as rn
from cte) a
where rn = 1

--which sub caegory had highest growth by profit in 2023 compare to 2022
with cte as(
	select sub_category, year(order_date)as order_year,SUM(sale_price) as sales
	from df_orders
	group by sub_category, year(order_date)
),
cte2 as(
select sub_category
	,sum(case when order_year = 2022 then sales else 0 end)as sales_2022
	,sum(case when order_year = 2023 then sales else 0 end)as sales_2023
	from cte
	group by sub_category
)
select top 1*,
	(sales_2023-sales_2022)*100/nullif(sales_2022,0) as percentage
	from cte2
	order by percentage desc

