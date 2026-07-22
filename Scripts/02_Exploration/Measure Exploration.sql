/*
    Purpose:
    --------
    Explores key business measures stored in the Gold layer by calculating
    sales, quantities, prices, orders, products, and customers. The script
    concludes by generating a consolidated KPI report for business reporting.
*/

-- Calculate the total revenue generated from all sales.
SELECT
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Calculate the total quantity of items sold.
SELECT
    SUM(quantity) AS items_sold
FROM gold.fact_sales;

-- Calculate the average selling price across all sales transactions.
SELECT
    AVG(price) AS average_selling_price
FROM gold.fact_sales;

-- Compare the total number of sales records with the number of unique orders.
SELECT
    COUNT(order_number) AS total_order_records,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Count all products available in the product dimension.
SELECT
    COUNT(product_key) AS total_products
FROM gold.dim_products;

-- Count the number of unique products that have been sold.
SELECT
    COUNT(DISTINCT product_key) AS products_sold
FROM gold.fact_sales;

-- Count all customers in the customer dimension.
SELECT
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.dim_customers;

-- Count the number of customers who have placed at least one order.
SELECT
    COUNT(DISTINCT customer_key) AS customers_with_orders
FROM gold.fact_sales;

-- Produce a consolidated KPI report.
SELECT 'Total Sales' AS measure_name,
       SUM(sales_amount) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Total Quantity',
       SUM(quantity)
FROM gold.fact_sales

UNION ALL

SELECT 'Average Price',
       AVG(price)
FROM gold.fact_sales

UNION ALL

SELECT 'Total Number of Orders',
       COUNT(DISTINCT order_number)
FROM gold.fact_sales

UNION ALL

SELECT 'Total Number of Products',
       COUNT(product_name)
FROM gold.dim_products

UNION ALL

SELECT 'Total Number of Customers',
       COUNT(customer_key)
FROM gold.dim_customers;
