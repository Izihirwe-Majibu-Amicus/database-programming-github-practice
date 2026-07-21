# Database Programming Assignments

Welcome to the official repository for Database Programming coursework at UNILAK.

## 📌 Repository Table of Contents

1. [Individual Assignment: CTEs & Window Functions](#individual-assignment-ctes--window-functions)

---

# Individual Assignment: CTEs & Window Functions

## Overview

This repository section contains an advanced database solution designed for an **E-Commerce / Retail Sales Management System**.

The project demonstrates complex SQL techniques using **Oracle Database (SQL*Plus terminal environment)**, specifically leveraging:

- **Common Table Expressions (CTEs)**
- **Recursive Queries**
- **SQL Window Functions**
- **Business Intelligence Analysis**

to solve real-world business data problems.

---

# Data Model & Schema

The relational structure consists of 3 core entities:

- **`Categories`**: Stores multi-level hierarchical catalog data (`category_id`, `category_name`, `parent_id`).
- **`Products`**: Stores inventory metadata and pricing (`product_id`, `product_name`, `category_id`, `price`).
- **`Sales`**: Captures granular sales transaction metrics (`sale_id`, `product_id`, `sale_date`, `quantity`, `amount`).

## Schema Creation

```sql
CREATE TABLE Categories (
    category_id NUMBER PRIMARY KEY,
    category_name VARCHAR2(50) NOT NULL,
    parent_id NUMBER,
    CONSTRAINT fk_parent_category 
    FOREIGN KEY (parent_id) REFERENCES Categories(category_id)
);

CREATE TABLE Products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100) NOT NULL,
    category_id NUMBER,
    price NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_product_category 
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Sales (
    sale_id NUMBER PRIMARY KEY,
    product_id NUMBER,
    sale_date DATE DEFAULT SYSDATE,
    quantity NUMBER NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_sales_product 
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
```

---

# Part A: Common Table Expressions (CTEs)

## 1. Simple CTE

**Business Value:**  
Filters high-value individual sales transactions ($1,000 or above) for rapid auditing.

```sql
WITH HighValueSales AS (
    SELECT 
        sale_id, 
        product_id, 
        amount
    FROM Sales
    WHERE amount >= 1000
)
SELECT * 
FROM HighValueSales;
```

---

## 2. Multiple CTEs

**Business Value:**  
Isolates performance of high-tier premium inventory to evaluate premium-segment revenue flow.

```sql
WITH PremiumProducts AS (
    SELECT 
        product_id,
        product_name,
        price
    FROM Products
    WHERE price >= 500
),

PremiumSales AS (
    SELECT 
        s.sale_id,
        p.product_name,
        s.amount
    FROM Sales s
    JOIN PremiumProducts p 
    ON s.product_id = p.product_id
)

SELECT *
FROM PremiumSales;
```

---

## 3. Recursive CTE

**Business Value:**  
Traverses variable-depth category hierarchies dynamically.

Example:

```
Electronics
      |
   Computers
      |
    Laptops
```

```sql
WITH CategoryHierarchy 
(category_id, category_name, parent_id, lvl) AS (

    SELECT 
        category_id,
        category_name,
        parent_id,
        1 AS lvl
    FROM Categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT
        c.category_id,
        c.category_name,
        c.parent_id,
        ch.lvl + 1
    FROM Categories c
    JOIN CategoryHierarchy ch
    ON c.parent_id = ch.category_id
)

SELECT 
    category_id,
    category_name,
    parent_id,
    lvl
FROM CategoryHierarchy;
```

---

## 4. CTE with Aggregation

**Business Value:**  
Consolidates total sales volume and order volume per product.

```sql
WITH ProductRevenue AS (

    SELECT
        product_id,
        SUM(amount) AS total_revenue,
        COUNT(sale_id) AS total_orders
    FROM Sales
    GROUP BY product_id
)

SELECT
    p.product_name,
    pr.total_revenue,
    pr.total_orders
FROM ProductRevenue pr
JOIN Products p
ON pr.product_id = p.product_id;
```

---

## 5. CTE Combined with JOIN Operations

**Business Value:**  
Rolls up individual transactions into broader category-level performance insights.

```sql
WITH CategorySales AS (

    SELECT
        p.category_id,
        SUM(s.amount) AS category_revenue
    FROM Sales s
    JOIN Products p
    ON s.product_id = p.product_id
    GROUP BY p.category_id
)

SELECT
    c.category_name,
    cs.category_revenue
FROM CategorySales cs
JOIN Categories c
ON cs.category_id = c.category_id;
```

---

# Part B: Advanced SQL Window Functions

## 1. Ranking Functions  
(ROW_NUMBER, RANK, DENSE_RANK, PERCENT_RANK)

**Business Value:**  
Ranks transactions to evaluate sales distribution and identify top performers.

```sql
SELECT 
    product_id,
    amount,

    ROW_NUMBER() OVER 
    (ORDER BY amount DESC) AS row_num,

    RANK() OVER 
    (ORDER BY amount DESC) AS rnk,

    DENSE_RANK() OVER 
    (ORDER BY amount DESC) AS dense_rnk,

    PERCENT_RANK() OVER 
    (ORDER BY amount DESC) AS pct_rnk

FROM Sales;
```

---

## 2. Aggregate Window Functions  
(SUM, AVG, MIN, MAX)

**Business Value:**  
Tracks cumulative revenue alongside benchmark metrics.

```sql
SELECT

    sale_id,
    amount,

    SUM(amount) OVER 
    (ORDER BY sale_id) AS running_total,

    AVG(amount) OVER () AS overall_avg_sale,

    MIN(amount) OVER () AS min_sale_amount,

    MAX(amount) OVER () AS max_sale_amount

FROM Sales;
```

---

## 3. Navigation Functions  
(LAG, LEAD)

**Business Value:**  
Performs period-over-period transaction comparison without complex self joins.

```sql
SELECT

    sale_id,
    sale_date,
    amount,

    LAG(amount,1,0) OVER 
    (ORDER BY sale_date) AS prev_sale_amount,

    LEAD(amount,1,0) OVER 
    (ORDER BY sale_date) AS next_sale_amount

FROM Sales;
```

---

## 4. Distribution Functions  
(NTILE, CUME_DIST)

**Business Value:**  
Groups sales into quartiles and determines relative transaction positioning.

```sql
SELECT

    sale_id,
    amount,

    NTILE(4) OVER 
    (ORDER BY amount DESC) AS sale_quartile,

    CUME_DIST() OVER 
    (ORDER BY amount) AS cumulative_distribution

FROM Sales;
```

---

# Business Analysis & Decision Insights

## 1. Descriptive Analysis

- Total revenue across all transactions reached **$13,175.00** across 7 recorded orders.

- The **Laptops category dominates sales revenue**, contributing **$12,500.00 (~95%)** of total sales, driven primarily by premium hardware purchases such as:
  - MacBook Pro
  - Dell XPS 15

- Low-cost accessories such as:
  - Logitech Mouse
  - Mechanical Keyboard

  account for **$675.00** in total revenue.

---

## 2. Diagnostic Analysis

### Product Mix Imbalance

Although accessory products generate higher order frequency, their revenue contribution remains significantly lower compared with premium laptop models.

### Transaction Fluctuation

Using **LAG and LEAD window functions** reveals significant revenue variation between transactions, ranging from:

- High-value transactions: **$6,000.00**
- Low-value transactions: **$125.00**

---

# 3. Prescriptive Analysis & Strategic Recommendations

## Bundle High-Margin Accessories

Attach low-cost accessories such as Logitech Mouse products to high-value laptop purchases through bundle offers to increase average customer spending.

---

## Category Diversification

Increase marketing investment in mid-tier categories to reduce dependency on laptop sales and create more balanced revenue growth.

---

# Conclusion

This database solution demonstrates how advanced SQL techniques can transform raw transactional data into meaningful business intelligence.

Through:

- CTEs
- Recursive Queries
- Window Functions
- Analytical Reporting

organizations can improve decision-making, identify trends, and develop effective business strategies.