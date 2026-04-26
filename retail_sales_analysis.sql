-- SQL Project: Retail Sales Analysis
-- Author: Pragyan Bhuyan
-- Description: Analysis of customer behavior and sales trends using SQL
-- Tools: PostgreSQL

-- =========================
-- BASIC AGGREGATION
-- =========================

-- Q1: Total spending per customer
SELECT c.customer_id, SUM(o.amount) AS total_sales
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id ASC;

-- Q2: Total spending per customer (with name)
SELECT c.customer_id, c.name, SUM(o.amount) AS total_sales
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY c.name ASC;

-- Q3: Top 2 customers by spending
SELECT c.customer_id, c.name, SUM(o.amount) AS total_sales
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_sales DESC
LIMIT 2;

-- Q4: Total sales per city
SELECT c.city, SUM(o.amount) AS total_sales
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY c.city ASC;

-- Q5: Average order amount per customer
SELECT c.customer_id, ROUND(AVG(o.amount), 2) AS average_order_value
FROM orders AS o
JOIN customers AS c
ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id ASC;

-- =========================
-- SALES ANALYSIS
-- =========================

-- Q1: Total sales
SELECT SUM(amount) AS total_sales
FROM sales;

-- Q2: Total sales per customer
SELECT customer_id, customer_name, SUM(amount) AS total_sales
FROM sales
GROUP BY customer_id, customer_name
ORDER BY customer_id;

-- Q3: Top 3 customers by spending
SELECT customer_id, customer_name, SUM(amount) AS total_sales
FROM sales
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC
LIMIT 3;

-- Q4: Total sales per city
SELECT city, SUM(amount) AS total_sales
FROM sales
GROUP BY city
ORDER BY total_sales DESC;

-- =========================
-- ADVANCED ANALYSIS: (WINDOW FUNCTIONS)
-- =========================

-- Q1: Rank customers by total spending
SELECT customer_name, total_spending,
RANK() OVER (ORDER BY total_spending DESC) AS spending_rank
FROM (
  SELECT customer_name, SUM(amount) AS total_spending
  FROM sales
  GROUP BY customer_name
) AS t;

-- Q2: Dense rank customers by total spending
SELECT customer_name, total_spending,
DENSE_RANK() OVER (ORDER BY total_spending DESC) AS spending_dense_rank
FROM (
  SELECT customer_name, SUM(amount) AS total_spending
  FROM sales
  GROUP BY customer_name
) AS t;

-- Q3: Running total of sales by date
SELECT order_date, amount,
SUM(amount) OVER (ORDER BY order_date) AS running_total
FROM sales;

-- Q4: Previous order amount (LAG)
SELECT order_date, amount,
LAG(amount) OVER (ORDER BY order_date) AS previous_order_amount
FROM sales;

-- Q5: Difference between current and previous order
SELECT order_date, amount, previous_amount,
amount - previous_amount AS amount_difference
FROM (
  SELECT order_date, amount,
  COALESCE(LAG(amount) OVER (ORDER BY order_date), 0) AS previous_amount
  FROM sales
) AS t;

-- =========================
-- CTE + BUSINESS ANALYSIS:
-- =========================

-- Q1: Top 3 customers by total spending using CTE
WITH customer_spending AS (
    SELECT customer_id, customer_name, SUM(amount) AS total_spending
    FROM sales
    GROUP BY customer_id, customer_name
)
SELECT customer_id, customer_name, total_spending
FROM customer_spending
ORDER BY total_spending DESC
LIMIT 3;


-- Q2: Customers spending above average
WITH customer_spending AS (
    SELECT customer_id, customer_name, SUM(amount) AS total_spending
    FROM sales
    GROUP BY customer_id, customer_name
),
avg_spending AS (
    SELECT AVG(total_spending) AS avg_amount
    FROM customer_spending
)
SELECT cs.customer_id, cs.customer_name, cs.total_spending
FROM customer_spending cs
JOIN avg_spending a
ON cs.total_spending > a.avg_amount;


-- Q3: Daily sales and running total
WITH daily_sales AS (
    SELECT order_date, SUM(amount) AS total_sales
    FROM sales
    GROUP BY order_date
)
SELECT order_date, total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total
FROM daily_sales;


-- Q4: Highest spending city
WITH city_sales AS (
    SELECT city, SUM(amount) AS total_sales
    FROM sales
    GROUP BY city
)
SELECT city, total_sales
FROM city_sales
ORDER BY total_sales DESC
LIMIT 1;


-- Q5: Customer contribution percentage to total sales (Window Function)
WITH customer_spending AS (
    SELECT customer_id, customer_name, SUM(amount) AS total_spending
    FROM sales
    GROUP BY customer_id, customer_name
)
SELECT customer_id, customer_name, total_spending,
ROUND(total_spending * 100.0 / SUM(total_spending) OVER (), 2) AS contribution_pct
FROM customer_spending;


-- Q6: Top Customer per city
WITH customer_sales AS (
    SELECT city, customer_name, SUM(amount) AS total_sales
    FROM sales
    GROUP BY city, customer_name
)
SELECT city, customer_name, total_sales
FROM (
    SELECT city, customer_name, total_sales,
    RANK() OVER (PARTITION BY city ORDER BY total_sales DESC) AS rnk
    FROM customer_sales
) t
WHERE rnk = 1;