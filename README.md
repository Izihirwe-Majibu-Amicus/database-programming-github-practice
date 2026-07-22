# 📚 Database Programming Assignments

![Oracle](https://img.shields.io/badge/Database-Oracle-red)
![SQL](https://img.shields.io/badge/Language-SQL-blue)
![PL/SQL](https://img.shields.io/badge/PL%2FSQL-Oracle-orange)
![UNILAK](https://img.shields.io/badge/University-UNILAK-green)

Official repository for **Database Programming** coursework at **UNILAK**.

This repository contains assignments demonstrating advanced SQL programming concepts using **Oracle Database** and **SQL*Plus**.

---

# 📑 Table of Contents

- [Group Assignment I – CTEs & SQL Window Functions](#-group-assignment-i--ctes--sql-window-functions)
- [Project Overview](#-project-overview)
- [Database Schema](#-database-schema)
- [ER Diagram](#-er-diagram)
- [Part A – Common Table Expressions](#-part-a--common-table-expressions)
- [Part B – Advanced SQL Window Functions](#-part-b--advanced-sql-window-functions)
- [Business Analysis & Decision Insights](#-business-analysis--decision-insights)
- [Conclusion](#-conclusion)
- [References](#-references)
- [Academic Integrity Statement](#-academic-integrity-statement)

---

# 📂 Group Assignment I – CTEs & SQL Window Functions

**Course:** C11665 – DPR400210 Database Programming

**Instructor:** Eric Maniraguha
### 👥 Group Members
1. **Izihirwe Majibu Amicus** – Registration No: `30848/2025` (GitHub: `@Izihirwe-Majibu-Amicus`)
2. **Duhimbaze Seth** – Registration No: `32481/2025` (GitHub: `@duhimbaze-seth`)
3. **Uwiduhaye Frank Raymond** – Registration No: `32122/2025` (GitHub: `@raymondfrankuwiduhaye-eng`)
---

# 📖 Project Overview

This project presents an **E-Commerce / Retail Sales Management System** implemented using **Oracle SQL**.

It demonstrates advanced SQL techniques including:

- Common Table Expressions (CTEs)
- Recursive Queries
- SQL Window Functions
- Business Intelligence Analysis

These techniques are applied to solve real-world business reporting and analytical problems.

---

# 🗄 Database Schema

The database consists of three core tables.

| Table | Description |
|--------|-------------|
| **Categories** | Stores hierarchical product categories |
| **Products** | Stores product information and pricing |
| **Sales** | Stores sales transaction records |

## Tables

### Categories

- category_id
- category_name
- parent_id

### Products

- product_id
- product_name
- category_id
- price

### Sales

- sale_id
- product_id
- sale_date
- quantity
- amount

---

## Schema Creation

```sql
CREATE TABLE Categories (
    category_id NUMBER PRIMARY KEY,
    category_name VARCHAR2(50) NOT NULL,
    parent_id NUMBER,
    CONSTRAINT fk_parent_category
        FOREIGN KEY (parent_id)
        REFERENCES Categories(category_id)
);

CREATE TABLE Products (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100) NOT NULL,
    category_id NUMBER,
    price NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES Categories(category_id)
);

CREATE TABLE Sales (
    sale_id NUMBER PRIMARY KEY,
    product_id NUMBER,
    sale_date DATE DEFAULT SYSDATE,
    quantity NUMBER NOT NULL,
    amount NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id)
        REFERENCES Products(product_id)
);
```

---

# 📊 ER Diagram

<img width="1408" height="768" alt="E-Commerce" src="https://github.com/user-attachments/assets/77b80873-fea7-4715-bc9d-2319b255127b" />


The diagram shows the three entities and their relationships:

- **Categories → Categories** (Self Reference)
- **Categories → Products** (One-to-Many)
- **Products → Sales** (One-to-Many)

---

# 📘 Part A – Common Table Expressions

## 1. Simple CTE

### Business Value

Filters high-value sales transactions ($1,000 or above) for auditing and revenue tracking.

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

### 🖼️ Query Execution Proof

> <img width="477" height="174" alt="cte_simple" src="https://github.com/user-attachments/assets/19c13682-e966-4900-9ebb-6a2748d711ba" />


---

## 2. Multiple CTEs

### Business Value

Separates product performance into price tiers to analyze revenue split among premium catalog items.

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

### 🖼️ Query Execution Proof

> <img width="567" height="177" alt="cte_multiple" src="https://github.com/user-attachments/assets/f34a497a-cb83-4f90-9f14-086c667d3a23" />

> ---

## 3. Recursive CTE

### Business Value

Traverses hierarchical product categories dynamically (e.g., Electronics → Computers → Laptops).

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

### 🖼️ Query Execution Proof

> <img width="1025" height="176" alt="cte_recursive" src="https://github.com/user-attachments/assets/c0db4c59-f8e9-477b-8b84-bb69dd04d062" />


---

## 4. CTE with Aggregation

### Business Value

Aggregates product revenue to identify top-performing inventory items and total volume per product.

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

### 🖼️ Query Execution Proof

> <img width="582" height="161" alt="cte_aggregation" src="https://github.com/user-attachments/assets/10be554c-1784-40db-ae46-ac041a119dc4" />


---

## 5. CTE with JOIN Operations

### Business Value

Joins sales metrics with category metadata to provide high-level category revenue insights.

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

### 🖼️ Query Execution Proof

> <img width="825" height="129" alt="cte_joins" src="https://github.com/user-attachments/assets/635e59b7-1d09-4c20-95e4-257139d37e97" />


---

# 📈 Part B – Advanced SQL Window Functions

## 1. Ranking Functions

### Business Value

Ranks products by sales amount to identify market leaders, ties, and relative percentile standings.

```sql
SELECT
    product_id,
    amount,

    ROW_NUMBER() OVER (
        ORDER BY amount DESC
    ) AS row_num,

    RANK() OVER (
        ORDER BY amount DESC
    ) AS rnk,

    DENSE_RANK() OVER (
        ORDER BY amount DESC
    ) AS dense_rnk,

    PERCENT_RANK() OVER (
        ORDER BY amount DESC
    ) AS pct_rnk

FROM Sales;
```

### 🖼️ Query Execution Proof

> <img width="800" height="262" alt="image" src="https://github.com/user-attachments/assets/0f6022f2-d933-459f-8660-078eae59e9d7" />


---

## 2. Aggregate Window Functions

### Business Value

Computes running sales totals and comparative metrics against global sales benchmarks without collapsing rows.

```sql
SELECT
    sale_id,
    amount,

    SUM(amount) OVER (
        ORDER BY sale_id
    ) AS running_total,

    AVG(amount) OVER () AS overall_avg_sale,

    MIN(amount) OVER () AS min_sale_amount,

    MAX(amount) OVER () AS max_sale_amount

FROM Sales;
```

### 🖼️ Query Execution Proof

> <img width="1050" height="237" alt="window_aggregate" src="https://github.com/user-attachments/assets/6995fc48-9d39-4ebf-8123-1fde904715c1" />

---

## 3. Navigation Functions (LAG & LEAD)

### Business Value

Evaluates transaction-to-transaction sales trends and revenue variance over chronological order dates.

```sql
SELECT
    sale_id,
    sale_date,
    amount,

    LAG(amount, 1, 0) OVER (
        ORDER BY sale_date
    ) AS prev_sale_amount,

    LEAD(amount, 1, 0) OVER (
        ORDER BY sale_date
    ) AS next_sale_amount

FROM Sales;
```

### 🖼️ Query Execution Proof

> <img width="811" height="230" alt="image" src="https://github.com/user-attachments/assets/61659349-95d4-45b0-93a7-61965c8ae280" />


---

## 4. Distribution Functions (NTILE & CUME_DIST)

### Business Value

Segments transactions into financial quartiles and calculates exact cumulative distribution percentages.

```sql
SELECT
    sale_id,
    amount,

    NTILE(4) OVER (
        ORDER BY amount DESC
    ) AS sale_quartile,

    CUME_DIST() OVER (
        ORDER BY amount DESC
    ) AS cumulative_distribution

FROM Sales;
```

### 🖼️ Query Execution Proof

> <img width="731" height="225" alt="image" src="https://github.com/user-attachments/assets/8c7f7fc2-49a4-484a-9d02-4e1bf1b97168" />


---

# 📊 Business Analysis & Decision Insights

## Descriptive Analysis

- Total Revenue: **$13,175**
- Total Orders: **7**
- Laptop sales generated approximately **95%** of the overall revenue.
- Accessories generated approximately **$675** in revenue.

---

## Diagnostic Analysis

### Product Mix

Premium laptops contribute significantly more revenue than accessories.

### Sales Variation

Window functions reveal transaction values ranging from:

- **Highest:** **$6,000**
- **Lowest:** **$125**

---

## Prescriptive Recommendations

- Bundle accessories with premium laptops to increase average transaction value.
- Diversify marketing toward mid-range products.
- Reduce financial dependency on a single product category.

---

# 🎯 Conclusion

This project demonstrates how advanced SQL techniques transform raw transactional data into meaningful business intelligence.

Key concepts demonstrated include:

- Common Table Expressions (CTEs)
- Recursive Queries
- SQL Window Functions
- Analytical Reporting

These techniques support better reporting, trend identification, and data-driven decision-making.

---

# 📚 References

- Oracle Database SQL Language Reference
- Oracle PL/SQL Documentation
- UNILAK Database Programming Course Materials
- Instructor: Eric Maniraguha

---

# 🎓 Academic Integrity Statement

This project was completed independently by the group members in accordance with **UNILAK Academic Integrity Policy**.

All SQL queries, schema design, business analysis, and documentation represent original work unless otherwise cited.
