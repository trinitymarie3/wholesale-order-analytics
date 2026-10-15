--one row per customer w/o blank 
WITH per_customer AS (
	SELECT 
		customer_id,
		COUNT(DISTINCT invoice) AS orders,
		ROUND(SUM(line_total),2) AS revenue 
	FROM sales
	WHERE customer_id IS NOT NULL
	GROUP BY customer_id
),

--label by one time or repeat
labelled AS (
	SELECT 
		customer_id,
		orders,
		revenue,
		CASE 
			WHEN orders = 1 THEN 'one-time'
			ELSE 'repeat'
		END AS customer_type
	FROM per_customer
)

--group by customer type
SELECT 
	customer_type,
	COUNT(*) as customers,
	ROUND(100*COUNT(*)/SUM(COUNT(*)) OVER (), 2) as pct_of_customers, --groups count divided by total of all groups count
	ROUND(SUM(revenue), 2) as total_revenue,
	ROUND(100*SUM(revenue)/SUM(SUM(revenue)) OVER (), 2) as pct_of_revenue
FROM labelled
GROUP BY customer_type
LIMIT 10;

