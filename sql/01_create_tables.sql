DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
	invoice TEXT,
	stock_code TEXT,
	description TEXT,
	quantity INTEGER,
	invoice_date TIMESTAMP,
	price NUMERIC,
	customer_id INTEGER,
	country TEXT,
	line_total NUMERIC
);

DROP TABLE IF EXISTS cancellations;
CREATE TABLE cancellations (
	invoice TEXT,
	stock_code TEXT,
	description TEXT,
	quantity INTEGER,
	invoice_date TIMESTAMP,
	price NUMERIC,
	customer_id INTEGER,
	country TEXT,
	line_total NUMERIC
);