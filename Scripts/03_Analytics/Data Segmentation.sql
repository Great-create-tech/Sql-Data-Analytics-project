/*
    Purpose:
    --------
    Performs data segmentation by grouping products and customers into
    meaningful business categories based on cost and spending behavior.
    The script demonstrates how CASE expressions can be used to create
    business segments for reporting and decision-making.
*/

------------------------------------------------------------
-- Product Cost Segmentation
------------------------------------------------------------

-- Assign each product to a predefined cost range.
WITH product_segments AS
(
    SELECT
        product_key,
        product_name,
        cost,

        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range

    FROM gold.dim_products
)

SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

------------------------------------------------------------
-- Product Segmentation by Total Cost (Option 1)
------------------------------------------------------------

SELECT
    cost_range,
    COUNT(*) AS no_of_products
FROM
(
    SELECT
        product_name,
        SUM(cost) AS cost,

        CASE
            WHEN SUM(cost) < 500 THEN 'Very Low'
            WHEN SUM(cost) < 1000 THEN 'Low'
            WHEN SUM(cost) < 1500 THEN 'Medium'
            WHEN SUM(cost) < 2000 THEN 'High'
            ELSE 'Very High'
        END AS cost_range

    FROM gold.dim_products
    GROUP BY product_name
) ProductCosts

GROUP BY cost_range;

------------------------------------------------------------
-- Product Segmentation by Total Cost (Option 2)
------------------------------------------------------------

-- Return one row containing the count of products in each segment.
SELECT

    COUNT(CASE WHEN cost_range = 'Very Low' THEN 1 END) AS very_low,

    COUNT(CASE WHEN cost_range = 'Low' THEN 1 END) AS low,

    COUNT(CASE WHEN cost_range = 'Medium' THEN 1 END) AS medium,

    COUNT(CASE WHEN cost_range = 'High' THEN 1 END) AS high,

    COUNT(CASE WHEN cost_range = 'Very High' THEN 1 END) AS very_high

FROM
(
    SELECT
        product_name,
        SUM(cost) AS cost,

        CASE
            WHEN SUM(cost) < 500 THEN 'Very Low'
            WHEN SUM(cost) < 1000 THEN 'Low'
            WHEN SUM(cost) < 1500 THEN 'Medium'
            WHEN SUM(cost) < 2000 THEN 'High'
            ELSE 'Very High'
        END AS cost_range

    FROM gold.dim_products
    GROUP BY product_name
) ProductCosts;

------------------------------------------------------------
-- Customer Segmentation
------------------------------------------------------------

/*
Business Rules

VIP
    • Customer history >= 12 months
    • Total spending > 5,000

Regular
    • Customer history >= 12 months
    • Total spending <= 5,000

New
    • Customer history < 12 months
*/

WITH customer_segments AS
(
    SELECT
        customer_key,

        MIN(order_date) AS first_order,

        MAX(order_date) AS last_order,

        DATEDIFF
        (
            month,
            MIN(order_date),
            MAX(order_date)
        ) AS history,

        SUM(sales_amount) AS total_spending

    FROM gold.fact_sales
    GROUP BY customer_key
)

SELECT

    CASE

        WHEN history >= 12
             AND total_spending > 5000
            THEN 'VIP'

        WHEN history >= 12
             AND total_spending <= 5000
            THEN 'Regular'

        ELSE 'New'

    END AS customer_segment,

    COUNT(*) AS total_customers

FROM customer_segments

GROUP BY

CASE

    WHEN history >= 12
         AND total_spending > 5000
        THEN 'VIP'

    WHEN history >= 12
         AND total_spending <= 5000
        THEN 'Regular'

    ELSE 'New'

END;

------------------------------------------------------------
-- Alternative Customer Segmentation (Subquery)
------------------------------------------------------------

/*
SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM
(
    SELECT
        customer_key,

        CASE
            WHEN lifespan >= 12
                 AND total_spending > 5000
                THEN 'VIP'

            WHEN lifespan >= 12
                 AND total_spending <= 5000
                THEN 'Regular'

            ELSE 'New'
        END AS customer_segment

    FROM customer_segments
) CustomerGroups

GROUP BY customer_segment
ORDER BY total_customers DESC;
*/
