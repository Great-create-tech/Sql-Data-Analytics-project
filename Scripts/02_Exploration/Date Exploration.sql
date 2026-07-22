/*
    Purpose:
    --------
    Explores date-related information within the Gold layer by identifying
    the sales period covered by the data and analyzing customer ages.
    The script also includes alternative methods for identifying the
    oldest and youngest customers.
*/

-- Determine the overall sales period covered by the fact table.
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS sales_years
FROM gold.fact_sales;

-- Determine the oldest and youngest birthdates and calculate their ages.
SELECT
    MIN(birthdate) AS oldest_customer_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_customer_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;

------------------------------------------------------------
-- Alternative Method 1:
-- Retrieve the names of the oldest and youngest customers.
------------------------------------------------------------

SELECT
    'Youngest' AS customer_type,
    first_name,
    last_name,
    birthdate
FROM gold.dim_customers
WHERE birthdate = (
    SELECT MAX(birthdate)
    FROM gold.dim_customers
)

UNION ALL

SELECT
    'Oldest' AS customer_type,
    first_name,
    last_name,
    birthdate
FROM gold.dim_customers
WHERE birthdate = (
    SELECT MIN(birthdate)
    FROM gold.dim_customers
);

------------------------------------------------------------
-- Alternative Method 2:
-- Use window functions to identify the oldest and youngest
-- customers efficiently.
------------------------------------------------------------

WITH RankedCustomers AS
(
    SELECT
        first_name,
        last_name,
        birthdate,
        ROW_NUMBER() OVER (ORDER BY birthdate ASC) AS oldest_rank,
        ROW_NUMBER() OVER (ORDER BY birthdate DESC) AS youngest_rank
    FROM gold.dim_customers
    WHERE birthdate IS NOT NULL
)

SELECT
    first_name,
    last_name,
    birthdate,
    CASE
        WHEN oldest_rank = 1 THEN 'Oldest'
        WHEN youngest_rank = 1 THEN 'Youngest'
    END AS customer_type
FROM RankedCustomers
WHERE oldest_rank = 1
   OR youngest_rank = 1;
