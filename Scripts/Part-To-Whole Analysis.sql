/*
    Purpose:
    --------
    Performs part-to-whole analysis to determine how individual categories
    and products contribute to overall business sales. The script calculates
    percentage contributions using SQL window functions, making it easy to
    identify the most significant revenue contributors.
*/

------------------------------------------------------------
-- Category Contribution to Total Sales
------------------------------------------------------------

-- Calculate each product category's share of total company sales.
SELECT
    *,
    SUM(sales) OVER () AS total_sales,

    CONCAT
    (
        CAST
        (
            100.0 * sales /
            SUM(sales) OVER ()
            AS DECIMAL(10,2)
        ),
        '%'
    ) AS percentage_contribution

FROM
(
    SELECT
        p.category,
        SUM(s.sales_amount) AS sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.category
) CategorySales;

------------------------------------------------------------
-- Product Contribution Within Its Category
------------------------------------------------------------

-- Calculate each product's contribution to its own category.
SELECT
    *,
    SUM(sales) OVER (PARTITION BY category) AS category_sales,

    CAST
    (
        100.0 * sales /
        SUM(sales) OVER (PARTITION BY category)
        AS DECIMAL(10,2)
    ) AS percentage_contribution

FROM
(
    SELECT
        p.category,
        p.product_name,
        SUM(s.sales_amount) AS sales
    FROM gold.fact_sales s
    INNER JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY
        p.category,
        p.product_name
) ProductSales;

------------------------------------------------------------
-- Product Contribution to Overall Company Sales
------------------------------------------------------------

SELECT
    *,

    SUM(sales) OVER () AS total_sales,

    SUM(sales) OVER
    (
        PARTITION BY category
    ) AS category_sales,

    CAST
    (
        100.0 * sales /
        SUM(sales) OVER ()
        AS DECIMAL(10,2)
    ) AS percentage_contribution

FROM
(
    SELECT
        p.category,
        p.product_name,
        SUM(s.sales_amount) AS sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY
        p.category,
        p.product_name
) ProductSales;

------------------------------------------------------------
-- Identify the Data Type Returned by SUM()
------------------------------------------------------------

SELECT
    SQL_VARIANT_PROPERTY
    (
        SUM(sales_amount),
        'BaseType'
    ) AS data_type
FROM gold.fact_sales;
