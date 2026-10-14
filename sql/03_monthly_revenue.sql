SELECT 
	DATE_TRUNC('month', invoice_date) AS month, --turns every date to first of month
	COUNT(DISTINCT invoice) AS orders, --counts rows in each bucket
	ROUND(SUM(line_total), 2) AS revenue --add revenue in each bucket (month)
FROM sales
GROUP BY DATE_TRUNC('month', invoice_date) --groups by date
ORDER BY month;