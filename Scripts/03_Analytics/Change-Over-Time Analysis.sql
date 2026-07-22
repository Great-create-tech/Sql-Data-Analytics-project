/*
    Purpose:
    --------
    Performs change-over-time analysis by summarizing sales performance
    across different time periods. The queries measure revenue, customer
    activity, and sales volume at the daily, yearly, monthly, and
    year-month levels to identify business trends.
*/

------------------------------------------------------------
-- Daily Sales Trend
------------------------------------------------------------

-- Summarize sales by individual order date.
SELECT
    order_date,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date;

------------------------------------------------------------
-- Yearly Sales Trend
------------------------------------------------------------

-- Aggregate sales by calendar year.
SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Include additional yearly business metrics.
SELECT
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

------------------------------------------------------------
-- Monthly Analysis
------------------------------------------------------------

-- Compare performance across calendar months regardless of year.
SELECT
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- Analyze each month within each year.
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

------------------------------------------------------------
-- Monthly Trend Using DATETRUNC
------------------------------------------------------------

-- Group all dates into the first day of each month.
SELECT
    DATETRUNC(month, order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

------------------------------------------------------------
-- Monthly Trend Using FORMAT
------------------------------------------------------------

-- Present month-year values in a reporting-friendly format.
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_period,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
