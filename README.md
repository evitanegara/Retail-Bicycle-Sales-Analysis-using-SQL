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

Syntax :
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


### 2. Revenue by Country
- United States generated the highest revenue at over 9.16 million from 7,482 customers, indicating a strong and wide customer base.
- Australia nearly matches U.S. revenue at 9.06 million, but with less than half the customer count (3,591), highlighting higher average order values or premium product penetration.
- Mid-tier contributors include the United Kingdom (3.39M), Germany (2.89M), and France (2.64M), each showing decent customer engagement but lower sales volumes.
- Canada, despite having fewer than 1,600 customers, contributed nearly 2M in revenue, suggesting an opportunity for expansion if customer base grows.
  ![image](https://github.com/user-attachments/assets/67f9e4bc-24b5-42bb-8192-2667096b6d58)
  ![image](https://github.com/user-attachments/assets/42d19351-1a8d-4f9a-a946-c24d3494950e)

### 3. Year-over-Year Sales Trends
- Sales performance rose significantly from 2011 (7.1M) to 2013 (16.3M), indicating strong year-over-year growth.
- 2013 marked the peak in both revenue (16.3M) and customer volume (52.7K), highlighting it as the business’s best-performing year.
- In 2014, sales dropped sharply to just 45K, reflecting either data incompleteness or a major operational shift.
![image](https://github.com/user-attachments/assets/19bc5a9a-607a-4bda-84f6-e07c996c347e)
![image](https://github.com/user-attachments/assets/4417c7f6-ffd9-4881-96e5-f9652a4b6f15)

### 4. Category Revenue Contribution
- Bikes contribute the overwhelming majority of revenue, generating 96.46% of total sales.
- Accessories (2.39%) and Clothing (1.16%) have significantly lower revenue shares.
- The imbalance highlights a strategic opportunity to upsell accessories and apparel alongside bike purchases, boosting overall order value.
  ![image](https://github.com/user-attachments/assets/7e17b743-7d48-4ba4-af45-adcf462be9f8)
  ![image](https://github.com/user-attachments/assets/fe9c3c50-89ee-4eca-8fca-f1d066a05253)

### 5. Product Performance Over Time
- Mountain-200, Road-150, and Touring-1000 models peaked in 2013 before dropping in 2014. 
- Accessories and clothing items (gloves, jerseys, helmets) surged in 2013, then declined sharply in 2014.
- Products like All-Purpose Bike Stand and Classic Vests showed growth over 2 years, suggesting sustainable popularity.
-  2013 marked the peak sales year for most SKUs, with a significant drop-off in 2014 across categories.
 ![image](https://github.com/user-attachments/assets/97da7320-a67d-4621-84ef-6186c8d547c8)
![image](https://github.com/user-attachments/assets/dc7fd137-042a-47da-b958-e703dce3c576)

### 6. Gender-Based Revenue Segmentation
- Female customers contributed slightly more revenue (14.8M) than males (14.5M)
- Customer count is nearly equal across genders—9,128 females vs. 9,341 males
- Suggests purchasing power is balanced across gender, with similar average order values
  ![image](https://github.com/user-attachments/assets/ae17dda9-6a0e-4153-9be1-05c35fb8e3ea)
  ![image](https://github.com/user-attachments/assets/6eb4cf18-98aa-4acc-9738-19e0fe1c3503)

### 7. Customer Segmentation by Value
-The majority of customers (14,631) fall into the New segment  
- Regular customers account for 2,198 individuals  
- VIP customers, though smallest in number (1,655), likely contribute the most revenue  
- Targeted efforts to retain and convert New users into Regular or VIP could significantly boost profitability
  ![image](https://github.com/user-attachments/assets/c4cf9b51-45bd-4cf9-a0ea-7f248b28b4a0)
![image](https://github.com/user-attachments/assets/84b88731-0d6a-4366-9640-ab122ac8007f)


### 8. Top-Spending Customers
- All top 10 highest-spending customers are located in France  
- Kaitlyn Henderson and Nichole Nara are tied as the top spenders, each contributing 13,294 in total revenue  
- Each of the top 10 has contributed over 13K, highlighting a concentrated group of high-value buyers  
- These customers present an opportunity for premium loyalty programs and tailored offers  
  ![image](https://github.com/user-attachments/assets/b0633d73-d6e9-4e3f-a1f3-63cf2a88cdf6)
  ![image](https://github.com/user-attachments/assets/ca9cdd21-c62c-444d-8d1f-e23993c36b5a)

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
