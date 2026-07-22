/*
    Purpose:
    --------
    Creates the Gold-layer view `gold.report_customers`, which consolidates
    customer demographic information with purchasing behavior. The report
    calculates customer-level metrics, assigns business segments and age
    groups, and derives KPIs that support customer analytics and reporting.
*/

CREATE VIEW gold.report_customers AS

WITH base_query AS
(
    ------------------------------------------------------------
    -- Base dataset combining customer information with sales
    -- transactions. Only records with valid order dates are
    -- included.
    ------------------------------------------------------------
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity,

        c.customer_key,
        c.customer_number,

        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,

        -- Calculate the customer's current age.
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age

    FROM gold.fact_sales f

    LEFT JOIN gold.dim_customers c
        ON c.customer_key = f.customer_key

    WHERE f.order_date IS NOT NULL
),

customer_aggregation AS
(
    ------------------------------------------------------------
    -- Aggregate purchasing metrics at the customer level.
    ------------------------------------------------------------
    SELECT
        customer_key,
        customer_number,
        customer_name,
        age,

        COUNT(DISTINCT order_number) AS total_orders,

        SUM(sales_amount) AS total_sales,

        SUM(quantity) AS total_quantity,

        COUNT(DISTINCT product_key) AS total_products,

        MAX(order_date) AS last_order_date,

        DATEDIFF
        (
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan

    FROM base_query

    GROUP BY
        customer_key,
        customer_number,
        customer_name,
        age
)

------------------------------------------------------------
-- Produce the final customer report with business KPIs.
------------------------------------------------------------

SELECT

    customer_key,

    customer_number,

    customer_name,

    age,

    CASE
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_group,

    CASE
        WHEN lifespan >= 12
             AND total_sales > 5000
            THEN 'VIP'

        WHEN lifespan >= 12
             AND total_sales <= 5000
            THEN 'Regular'

        ELSE 'New'
    END AS customer_segment,

    last_order_date,

    -- Measure the number of months since the customer's last purchase.
    DATEDIFF
    (
        MONTH,
        last_order_date,
        GETDATE()
    ) AS recency,

    total_orders,

    total_sales,

    total_quantity,

    total_products,

    -- Average revenue generated per order.
    CASE
        WHEN total_orders = 0
            THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    -- Average spending during the customer's active purchasing period.
    CASE
        WHEN lifespan = 0
            THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_spend

FROM customer_aggregation;

------------------------------------------------------------
-- Customer Summary by Segment
------------------------------------------------------------

SELECT

    customer_segment,

    COUNT(customer_number) AS total_customers,

    SUM(total_sales) AS total_sales

FROM gold.report_customers

GROUP BY customer_segment;
