---- KPI 1 : Total Revenue ----

SELECT ROUND(SUM(amount),2) as total_revenue
FROM amazon_sales
where status not ilike '%Cancelled%';


---- KPI 2 : Total order ----

SELECT COUNT(order_id) AS total_orders
FROM amazon_sales
WHERE status NOT ILIKE '%Cancelled%';

---- KPI 3: Average Order Value ----

with aov as 
(
select SUM(amount) as total_revenue,
COUNT(distinct order_id) as total_orders 
from amazon_sales
where status not ilike '%Cancelled%' 
) 
select ROUND((total_revenue / total_orders),2) as Average_order_value
from aov;

---- KPI 4: Revenue by State ----

SELECT ship_state,
       ROUND(SUM(amount)) AS revenue
FROM amazon_sales
WHERE status NOT ILIKE '%Cancelled%'
GROUP BY ship_state
ORDER BY revenue DESC
LIMIT 5;

---- KPI 5: Revenue by City ----

SELECT ship_city,
       ROUND(SUM(amount)) AS revenue
FROM amazon_sales
WHERE status NOT ILIKE '%Cancelled%'
GROUP BY ship_city
ORDER BY revenue DESC
LIMIT 10;

--- KPI 6: Best Selling Categories ----

SELECT category,
       SUM(qty) AS quantity
FROM amazon_sales
WHERE status NOT ILIKE '%Cancelled%'
GROUP BY category
ORDER BY quantity DESC;

---- KPI 7: Highest Revenue Categories ----

SELECT category,
       ROUND(SUM(amount)) AS revenue
FROM amazon_sales
WHERE status NOT ILIKE '%Cancelled%'
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

---- KPI 8: Monthly Revenue Trend ----

select Date_trunc('month', to_date(order_date , 'MM-DD-YY')) as month,
SUM(amount) as total_revenue
from amazon_sales
where status not ilike '%Cancelled%'
and trim(order_date) <> ''
Group  by month
Order by month;

---- KPI 9: Monthly Growth % ----

with monthly_sales AS
(
 select DATE_TRUNC('month' , TO_DATE(order_date, 'MM-DD-YY')) as month,
 SUM(amount) as total_revenue
 from amazon_sales
 where status not ilike '%Cancelled%'
 and trim(order_date) <> ''
 Group by month
),
pre_month AS
(
select month, total_revenue , lAG(total_revenue) over (ORDER BY month) as previous_month
from monthly_sales
)
select month , total_revenue , ROUND(((total_revenue - previous_month) / previous_month) * 100,2) as growth_percente
from pre_month
WHERE previous_month IS NOT NULL;

---- KPI 10: Order Status Analysis ----

with status AS
(
select status , count(*) as total_orders , SUM(COUNT(*)) OVER () as total
from amazon_sales
Group by status
)
select status , total_orders , total , ROUND( ((total_orders*100.0)/total) , 2) as order_percentage
from status;


---- KPI 11: Cancellation Rate ----

with cancle_orders AS
(
select count(*) as Cancelled_orders , 
  (
  select
  COUNT(order_id) as total_orders
  from amazon_sales
  )
from amazon_sales
where status = 'Cancelled'
)

select total_orders , cancelled_orders ,
ROUND((cancelled_orders * 100.0) / total_orders ,2)as Cancellation_rate
from cancle_orders;


---- KPI 12: Fulfilment Analysis ----

with fulfilment_cte AS
(
SELECT fulfilment , COUNT(*) orders , (
 select COUNT(*) as total_orders from amazon_sales 
)
FROM amazon_sales
GROUP BY fulfilment
)

select fulfilment , orders , ROUND(orders * 100.0/ total_orders , 2) as fulfilment_analysis
from fulfilment_cte;

---- KPI 13: B2B vs B2C Revenue ----

with b2b_cte AS
(
select  b2b , SUM(amount) as b2b_revenue , 
(select
 SUM(amount)
 from amazon_sales
) as total_revenue
from amazon_sales
GROUP BY b2b
)

select b2b , b2b_revenue , ROUND((b2b_revenue *100.0) / total_revenue ,2 ) as b2b_percentage
from b2b_cte;


---- KPI 14: Top 10 Products ----

select sku ,SUM(COALESCE(amount,0)) as revenue
from amazon_sales
GROUP BY sku
ORDER BY revenue desc
limit 10;

----KPI 15: Top States by Revenue Ranking ---

select ship_state , SUM(COALESCE(amount,0)) as revenue,
RANK() over (
order by  SUM(COALESCE(amount,0)) desc
) as state_rank
from amazon_sales
GROUP by ship_state
ORDER by revenue desc
limit 10;

