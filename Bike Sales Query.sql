-- Top 10 products by total revenue
SELECT TOP 10
    p.product_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;

--Sales Distribution by Country
SELECT 
    c.country,
    COUNT(DISTINCT f.customer_key) AS total_customers,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.country != 'n/a'
GROUP BY c.country
ORDER BY total_revenue DESC;

-- Year-over-Year Sales Overview
SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(customer_key) AS total_customer,
SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

--- Revenue Contribution by Product Category
WITH category_sales AS (
SELECT
p.category,
sum(f.sales_amount) AS total_sales
-- buat windows function
from gold.fact_sales f
LEFT JOIN gold.dim_products p
on f.product_key = p.product_key
GROUP BY category)

SELECT
category,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT (ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC

--- Year-over-Year Product Performance
WITH yearly_product_sales AS (
SELECT
YEAR(f.order_date) AS order_year,
p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
GROUP BY 
YEAR(f.order_date),
p.product_name
)

SELECT
order_year,
product_name,
current_sales,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year)< 0 THEN 'Decrease'
	 WHEN current_sales - LAG (current_sales) OVER (PARTITION BY product_name ORDER BY order_year)> 0 THEN 'Increase'
	ELSE 'No Change'
END py_change
FROM yearly_product_sales
order by product_name, order_year

--- Revenue Segmentation by Gender
SELECT 
    c.gender,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.customer_key) AS customer_count
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.gender IS NOT NULL
  AND c.gender != 'n/a'
GROUP BY c.gender;

--- Most Valuable Customers by Spend
   SELECT TOP 10
    c.customer_number,
    c.first_name + ' ' + c.last_name AS customer_name,
    c.country,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name, c.country
ORDER BY total_revenue DESC;

--	Customer Segmentation: VIP, Regular, and New
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT 
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM (
    SELECT 
        customer_key,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;