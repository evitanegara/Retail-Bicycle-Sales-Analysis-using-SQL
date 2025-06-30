# Retail Bicycle Sales Analysis using SQL

## Project Background
This SQL-based project focuses on analyzing retail sales data related to bicycles, accessories, and cycling apparel. The dataset follows a star schema structure, with a central fact table capturing sales transactions and supporting dimension tables describing products and customers. This project aims to help stakeholders leverage SQL to uncover actionable insights across product categories, customer demographics, and sales channels. By using advanced querying techniques, the analysis helps identify high-performing products, evaluate customer segments, and track revenue trends over time. The insights derived from this analysis are valuable for marketing, sales, and operations teams, enabling data-driven decisions in areas such as product strategy, inventory management, targeted promotions, and customer retention.

## Dataset Overview

The dataset follows a star schema structure, consisting of one fact table and two dimension tables:

| Table Name     | Columns |
|----------------|---------|
| fact_sales     | order_number, product_key, customer_key, order_date, shipping_date, due_date, sales_amount, quantity, price |
| dim_products   | product_key, product_id, product_number, product_name, category_id, category, subcategory, maintenance, cost, product_line, start_date |
| dim_customers  | customer_key, customer_id, customer_number, first_name, last_name, country, marital_status, gender, birthdate, create_date |

## Executive Summary

This SQL-based analysis explores retail sales data from 2010 to 2014, uncovering key trends across products, customers, and countries. Bikes dominate sales, contributing over 96% of total revenue. The Mountain-200 and Road-150 models are top performers, with individual products generating over 1.3 million in sales.Revenue is nearly evenly split by gender, with a slightly higher spend from female customers. The United States and Australia lead in revenue, while France has the highest-spending individual customers. Sales peaked in 2013 with over 16 million in revenue, followed by a sharp decline in 2014. Most customers are new, highlighting an opportunity for retention and loyalty programs. To drive growth, the business should focus on expanding bike offerings, targeting high-performing countries, and converting new customers into repeat buyers.

## Insights Deep-Dive

### 1. Top 10 Products by Revenue
- Total revenue among the top 10 products exceeds 12 million, with Mountain-200 and Road-150 models dominating the list.
- Mountain 200 Black 46 leads as the highest grossing product, generating over 1.37 million in sales.
- All top-performing products fall into two families: Mountain-200 and Road-150, reflecting strong brand loyalty and product-market fit.
- Size and color variations (example : Black 46, Silver 38, Red 62) consistently appear across the top ranks, indicating that both product specification and aesthetic options influence customer purchasing decisions.
- The Mountain-200 series alone accounts for 7 out of 10 top spots, highlighting its market dominance across multiple sizes and finishes.

To identify top-selling products, I aggregated sales revenue and ranked the highest-grossing items:

```sql
SELECT TOP 10
  p.product_name,
  SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
  ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;
```
![image](https://github.com/user-attachments/assets/43a8afed-9567-425b-b9df-9cbe21ab91dc)


### 2. Revenue by Country
- United States generated the highest revenue at over 9.16 million from 7,482 customers, indicating a strong and wide customer base.
- Australia nearly matches U.S. revenue at 9.06 million, but with less than half the customer count (3,591), highlighting higher average order values or premium product penetration.
- Mid-tier contributors include the United Kingdom (3.39M), Germany (2.89M), and France (2.64M), each showing decent customer engagement but lower sales volumes.
- Canada, despite having fewer than 1,600 customers, contributed nearly 2M in revenue, suggesting an opportunity for expansion if customer base grows.
  
```sql
Sales Distribution by Country
SELECT 
    c.country,
    COUNT(DISTINCT f.customer_key) AS total_customers,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.country != 'n/a'
GROUP BY c.country
ORDER BY total_revenue DESC;
![image](https://github.com/user-attachments/assets/a7214187-8e0b-4849-bc70-7c9c0ae37631)

```

### 3. Year-over-Year Sales Trends
- Sales performance rose significantly from 2011 (7.1M) to 2013 (16.3M), indicating strong year-over-year growth.
- 2013 marked the peak in both revenue (16.3M) and customer volume (52.7K), highlighting it as the business’s best-performing year.
- In 2014, sales dropped sharply to just 45K, reflecting either data incompleteness or a major operational shift.
```sql
-- Year-over-Year Sales Overview
SELECT
  YEAR(order_date) AS order_year,
  SUM(sales_amount) AS total_sales,
  COUNT(customer_key) AS total_customer,
  SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);
```

![image](https://github.com/user-attachments/assets/88c4621a-8a6a-4115-a828-1d60cf9eb830)


### 4. Category Revenue Contribution
- Bikes contribute the overwhelming majority of revenue, generating 96.46% of total sales.
- Accessories (2.39%) and Clothing (1.16%) have significantly lower revenue shares.
- The imbalance highlights a strategic opportunity to upsell accessories and apparel alongside bike purchases, boosting overall order value.
```sql
Revenue Contribution by Product Category
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
```
![image](https://github.com/user-attachments/assets/9c9a69e0-f8e2-4fbb-ad57-510eff90847b)


### 5. Product Performance Over Time
- Mountain-200, Road-150, and Touring-1000 models peaked in 2013 before dropping in 2014. 
- Accessories and clothing items (gloves, jerseys, helmets) surged in 2013, then declined sharply in 2014.
- Products like All-Purpose Bike Stand and Classic Vests showed growth over 2 years, suggesting sustainable popularity.
-  2013 marked the peak sales year for most SKUs, with a significant drop-off in 2014 across categories.

```sql
Year-over-Year Product Performance
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
  CASE 
    WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
    WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
    ELSE 'No Change'
  END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
```
![image](https://github.com/user-attachments/assets/616704ad-aa38-4d49-ab91-49a6d5ad0182)


### 6. Gender-Based Revenue Segmentation
- Female customers contributed slightly more revenue (14.8M) than males (14.5M)
- Customer count is nearly equal across genders—9,128 females vs. 9,341 males
- Suggests purchasing power is balanced across gender, with similar average order values
  
```sql
 Revenue Segmentation by Gender
SELECT 
    c.gender,
    SUM(f.sales_amount) AS total_sales,
    COUNT(DISTINCT f.customer_key) AS customer_count
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
WHERE c.gender IS NOT NULL
  AND c.gender != 'n/a'
GROUP BY c.gender;
```
![image](https://github.com/user-attachments/assets/cadab18b-4456-4c51-8603-1daebc75991f)


### 7. Customer Segmentation by Value
-The majority of customers (14,631) fall into the New segment  
- Regular customers account for 2,198 individuals  
- VIP customers, though smallest in number (1,655), likely contribute the most revenue  
- Targeted efforts to retain and convert New users into Regular or VIP could significantly boost profitability

 ```sql
-- Customer Segmentation: VIP, Regular, and New
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
```
![image](https://github.com/user-attachments/assets/f2587f35-c477-4065-9279-6129db39c5e3)

---
  
### 8. Top-Spending Customers
- All top 10 highest-spending customers are located in France  
- Kaitlyn Henderson and Nichole Nara are tied as the top spenders, each contributing 13,294 in total revenue  
- Each of the top 10 has contributed over 13K, highlighting a concentrated group of high-value buyers  
- These customers present an opportunity for premium loyalty programs and tailored offers

```sql
 Most Valuable Customers by Spend
SELECT TOP 10
  c.customer_number,
  c.first_name + ' ' + c.last_name AS customer_name,
  c.country,
  SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name, c.country
ORDER BY total_revenue DESC;
```
![image](https://github.com/user-attachments/assets/0ebf0374-a856-4083-bdf9-19da4e7aeb2c)

---

## Recommendations

### Product Strategy
- Prioritize inventory allocation and targeted promotions for the Mountain-200 and Road-150 product lines, which dominate top sales.
- Bundle high-performing bikes with accessories or apparel to increase average order value and address low revenue share in non-bike categories.
- Monitor products that showed consistent year-over-year growth (e.g., Classic Vests, All-Purpose Bike Stand) for potential seasonal restocking or promotion.

### Market Strategy
- Double down on high-revenue countries with lower customer bases like Australia and Canada by expanding marketing and localized offerings.
- Re-engage mid-tier markets such as Germany, France, and the United Kingdom through region-specific campaigns and product visibility initiatives.
- Investigate the sharp decline in 2014 sales to address potential data gaps or operational bottlenecks.

### Customer Strategy
- Create tiered loyalty programs tailored to VIPs and Regular customers to increase retention and repeat purchases.
- Deploy onboarding sequences or personalized email flows to guide New customers toward higher-value tiers.
- Analyze purchasing behavior of high-spending individuals in France to replicate success in other geographies.

### Gender-Based Marketing
- Maintain balanced targeting as both genders show nearly equal purchasing power and engagement.
- Test messaging variations or product highlights tailored to each gender to optimize campaign performance.
- Encourage community engagement and reviews from both male and female customers to reinforce social proof across demographics.


## Contact

For questions or collaboration:  
📧 **evitanegara@gmail.com**
