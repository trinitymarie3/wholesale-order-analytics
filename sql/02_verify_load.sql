SELECT COUNT(*) AS sales_rows
FROM sales; 

SELECT COUNT(*) AS cancellations_rows
FROM cancellations;

SELECT COUNT(*) AS missing_customer_id
FROM sales
WHERE customer_id IS NULL;