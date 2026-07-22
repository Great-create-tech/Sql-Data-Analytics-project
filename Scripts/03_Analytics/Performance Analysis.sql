/*
    Purpose:
    --------
    Performs performance analysis by evaluating product sales over time.
    The script compares each product's current sales against:
        1. Its historical average sales.
        2. Its previous period's sales.
    This helps identify products that are improving, declining,
    or performing consistently.
*/

------------------------------------------------------------
-- Yearly Product Performance Analysis
------------------------------------------------------------

-- Aggregate yearly sales for each product.
WITH yearly_product_sales AS
(
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_name
)

SELECT
    order_year,
    product_name,
    current_sales,

    -- Calculate each product's average yearly sales.
    AVG(current_sales) OVER
    (
        PARTITION BY product_name
    ) AS avg_sales,

    current_sales -
    AVG(current_sales) OVER
    (
        PARTITION BY product_name
    ) AS diff_avg,

    CASE
        WHEN current_sales -
             AVG(current_sales) OVER (PARTITION BY product_name) > 0
            THEN 'Above Avg'

        WHEN current_sales -
             AVG(current_sales) OVER (PARTITION BY product_name) < 0
            THEN 'Below Avg'

        ELSE 'Avg'
    END AS avg_change,

    -- Retrieve the previous year's sales for comparison.
    LAG(current_sales) OVER
    (
        PARTITION BY product_name
        ORDER BY order_year
    ) AS prev_year_sales,

    current_sales -
    LAG(current_sales) OVER
    (
        PARTITION BY product_name
        ORDER BY order_year
    ) AS diff_prev_year,

    CASE
        WHEN current_sales -
             LAG(current_sales) OVER
             (
                 PARTITION BY product_name
                 ORDER BY order_year
             ) > 0
            THEN 'Increase'

        WHEN current_sales -
             LAG(current_sales) OVER
             (
                 PARTITION BY product_name
                 ORDER BY order_year
             ) < 0
            THEN 'Decrease'

        ELSE 'No Change'
    END AS prev_year_change

FROM yearly_product_sales
ORDER BY product_name, order_year;

------------------------------------------------------------
-- Monthly Product Performance Analysis
------------------------------------------------------------

WITH monthly_product_sales AS
(
    SELECT
        DATETRUNC(month, s.order_date) AS order_month,
        p.product_name,
        SUM(s.sales_amount) AS current_sales,
        AVG(s.sales_amount) AS avg_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY
        DATETRUNC(month, s.order_date),
        p.product_name
)

SELECT
    order_month,
    product_name,
    current_sales,
    avg_sales,

    current_sales - avg_sales AS diff_avg,

    CASE
        WHEN current_sales - avg_sales > 0
            THEN 'Above Average'

        WHEN current_sales - avg_sales < 0
            THEN 'Below Average'

        ELSE 'Average'
    END AS avg_change,

    -- Compare each month's sales with the previous month.
    LAG(current_sales) OVER
    (
        ORDER BY order_month
    ) AS prev_month_sales,

    current_sales -
    LAG(current_sales) OVER
    (
        ORDER BY order_month
    ) AS diff_prev_month,

    CASE
        WHEN current_sales -
             LAG(current_sales) OVER (ORDER BY order_month) > 0
            THEN 'Increase'

        WHEN current_sales -
             LAG(current_sales) OVER (ORDER BY order_month) < 0
            THEN 'Decrease'

        ELSE 'No Change'
    END AS month_change

FROM monthly_product_sales;
