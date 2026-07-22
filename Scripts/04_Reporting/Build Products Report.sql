/*
    Purpose:
    --------
    Creates the Gold-layer view `gold.report_products`, which provides a
    consolidated product performance report. The view combines product
    master data with sales transactions, aggregates product-level metrics,
    classifies products into revenue segments, and calculates key business
    KPIs for reporting and analytics.
*/

CREATE VIEW gold.report_products AS

WITH base_query AS
(
    ------------------------------------------------------------
    -- Base dataset combining sales transactions with product
    -- attributes. Only completed sales with valid order dates
    -- are included.
    ------------------------------------------------------------
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_aggregations AS
(
    ------------------------------------------------------------
    -- Aggregate sales metrics at the product level.
    ------------------------------------------------------------
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,

        DATEDIFF
        (
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan,

        MAX(order_date) AS last_sale_date,

        COUNT(DISTINCT order_number) AS total_orders,

        COUNT(DISTINCT customer_key) AS total_customers,

        SUM(sales_amount) AS total_sales,

        SUM(quantity) AS total_quantity,

        -- Calculate the average selling price per unit sold.
        ROUND
        (
            AVG
            (
                CAST(sales_amount AS FLOAT) /
                NULLIF(quantity, 0)
            ),
            1
        ) AS avg_selling_price

    FROM base_query

    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

------------------------------------------------------------
-- Produce the final product report with KPIs and segments.
------------------------------------------------------------

SELECT

    product_key,

    product_name,

    category,

    subcategory,

    cost,

    last_sale_date,

    -- Measure how long it has been since the product was last sold.
    DATEDIFF
    (
        MONTH,
        last_sale_date,
        GETDATE()
    ) AS recency_in_months,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,

    total_orders,

    total_sales,

    total_quantity,

    total_customers,

    avg_selling_price,

    -- Average revenue generated per order.
    CASE
        WHEN total_orders = 0
            THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average revenue generated per active month.
    CASE
        WHEN lifespan = 0
            THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
