WITH all_lines AS (
	SELECT country, line_total FROM sales
	UNION ALL --stacks next query rows
	SELECT country, line_total FROM cancellations
),
--next step: by_country holds one row per country
by_country AS (
	SELECT country,
	SUM(line_total) AS net_revenue --cancellations get subtracted
	FROM all_lines
	GROUP BY country
)
--final query: each city's share
SELECT 
	country,
	ROUND(net_revenue, 2) AS net_revenue,
	ROUND(100*net_revenue/ SUM(net_revenue) OVER (), 2) AS pct_of_revenue
FROM by_country
ORDER BY net_revenue DESC
	

