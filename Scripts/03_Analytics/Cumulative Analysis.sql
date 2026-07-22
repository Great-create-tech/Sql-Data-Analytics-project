/*
    Purpose:
    --------
    Performs cumulative analysis to measure business performance over time.
    The script calculates monthly sales, running totals, moving averages,
    and period-over-period changes (Month-over-Month and Year-over-Year)
    using SQL window functions.
*/

------------------------------------------------------------
-- Monthly Sales Summary
------------------------------------------------------------

-- Aggregate sales by calendar month (months from different years are combined).
SELECT
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

------------------------------------------------------------
-- Monthly Sales Timeline
------------------------------------------------------------

-- Preserve chronological order by truncating each date to the first day of its month.
SELECT
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

------------------------------------------------------------
-- Running Total of Sales (Subquery)
------------------------------------------------------------

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total
FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) MonthlySales;

------------------------------------------------------------
-- Alternative Using a CTE
------------------------------------------------------------

/*
WITH MonthlySales AS
(
    SELECT
        MONTH(order_date) AS order_month,
        SUM(sales_amount) AS sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY MONTH(order_date)
)
SELECT
    order_month,
    sales,
    SUM(sales) OVER (ORDER BY order_month) AS running_total
FROM MonthlySales
ORDER BY order_month;
*/

------------------------------------------------------------
-- Running Total Reset Each Year
------------------------------------------------------------

SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER
    (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
    ) AS running_total
FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) MonthlySales;

------------------------------------------------------------
-- Cumulative Moving Average
------------------------------------------------------------

SELECT
    order_date,
    total_sales,

    SUM(total_sales) OVER
    (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
    ) AS running_total,

    avg_sales,

    AVG(avg_sales) OVER
    (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
    ) AS moving_average_sales,

    avg_price,

    AVG(avg_price) OVER
    (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
    ) AS moving_average_price

FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date,
        AVG(sales_amount) AS avg_sales,
        AVG(price) AS avg_price,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) MonthlySales;

------------------------------------------------------------
-- Four-Month Moving Average
------------------------------------------------------------

SELECT
    order_date,
    total_sales,

    SUM(total_sales) OVER
    (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
    ) AS running_total,

    avg_sales,

    AVG(avg_sales) OVER
    (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS moving_average_sales,

    avg_price,

    AVG(avg_price) OVER
    (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS moving_average_price

FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date,
        AVG(sales_amount) AS avg_sales,
        AVG(price) AS avg_price,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) MonthlySales;

------------------------------------------------------------
-- Month-over-Month (MoM) Change
------------------------------------------------------------

SELECT
    order_date,
    total_sales,

    SUM(total_sales) OVER
    (
        PARTITION BY YEAR(order_date)
        ORDER BY order_date
    ) AS running_total,

    total_sales -
    LAG(total_sales) OVER (ORDER BY order_date) AS monthly_change

FROM
(
    SELECT
        DATETRUNC(month, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) MonthlySales;

------------------------------------------------------------
-- Year-over-Year (YoY) Change
------------------------------------------------------------

SELECT
    order_date,
    total_sales,

    SUM(total_sales) OVER
    (
        ORDER BY order_date
    ) AS running_total,

    total_sales -
    LAG(total_sales) OVER (ORDER BY order_date) AS yearly_change

FROM
(
    SELECT
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) YearlySales;
