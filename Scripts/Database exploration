/*
    Purpose:
    --------
    Explores the metadata of the data warehouse by retrieving information
    about database tables and their columns. The script also inspects the
    structure of specific analytical tables used in the Gold layer.
*/

-- Retrieve all user tables available in the current database.
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- Retrieve metadata for every column in every table.
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;

-- ==========================================================
-- Explore Gold Layer Tables
-- ==========================================================

-- Display the column definitions for the customer dimension.
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- Display the column definitions for the product dimension.
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products';

-- Display the column definitions for the sales fact table.
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';
