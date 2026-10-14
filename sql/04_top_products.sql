SELECT
	stock_code,
	description, --include for readability
	SUM(quantity) AS units_sold, --sums quantity of each product (groupby)
	ROUND(SUM(line_total), 2) AS revenue
FROM sales
GROUP BY stock_code, description --every plain column must be listed here
ORDER BY revenue DESC --descending order
LIMIT 10; --top 10 products

--investigate #23843
SELECT
	invoice,
	invoice_date,
	stock_code,
	quantity,
	customer_id,
	line_total
FROM sales
WHERE stock_code = '23843'
ORDER BY quantity DESC
LIMIT 5;

SELECT
	invoice,
	invoice_date,
	stock_code,
	quantity,
	customer_id,
	line_total
FROM cancellations
WHERE stock_code = '23843'
ORDER BY quantity ASC
LIMIT 5;

--investigate #23166
SELECT
	invoice,
	invoice_date,
	stock_code,
	quantity,
	customer_id,
	line_total
FROM sales
WHERE stock_code = '23166'
ORDER BY quantity DESC
LIMIT 5;

SELECT
	invoice,
	invoice_date,
	stock_code,
	quantity,
	customer_id,
	line_total
FROM cancellations
WHERE stock_code = '23166'
ORDER BY quantity ASC
LIMIT 5;

--net sales
SELECT
	stock_code,
	description,
	SUM(quantity) AS net_units, 
	ROUND(SUM(line_total), 2) AS net_revenue
FROM ( 
	SELECT stock_code, description, quantity, line_total FROM sales
	UNION ALL --combined list
	SELECT stock_code, description, quantity, line_total FROM cancellations
) AS all_lines
GROUP BY stock_code, description
ORDER BY net_revenue DESC
LIMIT 10;