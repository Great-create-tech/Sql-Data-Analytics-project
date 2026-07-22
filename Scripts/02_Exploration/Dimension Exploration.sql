/*
    Purpose:
    --------
    Explores key business dimensions within the Gold layer by analyzing
    customer geographic distribution and the product hierarchy.
    The queries provide summary information that supports reporting,
    business analysis, and data exploration.
*/

-- Count customers by country to understand the geographic distribution
-- of the customer base.
SELECT
    country,
    COUNT(customer_id) AS number_of_customers
FROM gold.dim_customers
GROUP BY country;

-- Count the number of subcategories within each product category
-- to understand the product portfolio structure.
SELECT
    category,
    COUNT(subcategory) AS number_of_subcategories
FROM gold.dim_products
GROUP BY category;

-- Display the category-to-subcategory hierarchy.
SELECT DISTINCT
    category,
    subcategory
FROM gold.dim_products;

-- Display the complete product hierarchy by listing
-- categories, subcategories, and product names.
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
