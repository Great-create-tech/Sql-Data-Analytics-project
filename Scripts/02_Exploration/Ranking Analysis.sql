/*
    Purpose:
    --------
    Performs ranking analysis on products and customers by identifying
    the highest and lowest performers based on revenue and order activity.
    The script demonstrates both the TOP clause and SQL window functions
    for ranking business entities.
*/

------------------------------------------------------------
-- Top 5 products by revenue
------------------------------------------------------------

SELECT TOP 5
    p.product_name,
    SUM(sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY revenue DESC;

------------------------------------------------------------
-- Alternative approach using ROW_NUMBER()
------------------------------------------------------------

SELECT *
FROM
(
    SELECT
        p.product_name,
        SUM(sales_amount) AS revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(sales_amount) DESC) AS rank
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.product_name
) RankedProducts
WHERE rank <= 5;

------------------------------------------------------------
-- Bottom 5 products by revenue
------------------------------------------------------------

SELECT TOP 5
    p.product_name,
    SUM(sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY revenue ASC;

------------------------------------------------------------
-- Top 10 customers by revenue
------------------------------------------------------------

SELECT *
FROM
(
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(sales_amount) AS revenue,
        RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS rank
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
) RankedCustomers
WHERE rank <= 10
ORDER BY rank;

------------------------------------------------------------
-- Three customers with the fewest orders
------------------------------------------------------------

SELECT *
FROM
(
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(order_number) AS nr_of_orders,
        ROW_NUMBER() OVER (ORDER BY COUNT(order_number)) AS rank_orders
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
) RankedOrderCounts
WHERE rank_orders <= 3;
