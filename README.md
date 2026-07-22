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
- [Part B – SQL Window Functions](#-part-b--advanced-sql-window-functions)
- [Business Analysis](#-business-analysis--decision-insights)
- [Conclusion](#-conclusion)
- [References](#-references)
- [Academic Integrity](#-academic-integrity-statement)

---

# 📂 Group Assignment I – CTEs & SQL Window Functions

**Course:** C11665 – DPR400210 Database Programming

**Instructor:** Eric Maniraguha

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

![ER Diagram](diagrams/ER_diagram.svg)

### Relationships

- Categories → Categories *(Self Reference)*
- Categories → Products *(One-to-Many)*
- Products → Sales *(One-to-Many)*

---

# 📘 Part A – Common Table Expressions

## 1. Simple CTE

### Business Value

Filters high-value sales transactions ($1,000 or above).

```sql
WITH HighValueSales AS (
    SELECT sale_id,
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

### Business Value

Analyzes premium products and associated sales.

```sql
WITH PremiumProducts AS (

    SELECT product_id,
           product_name,
           price
    FROM Products
    WHERE price >= 500

),

PremiumSales AS (

    SELECT s.sale_id,
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

### Business Value

Traverses hierarchical product categories dynamically.

Example

```
Electronics
    └── Computers
          └── Laptops
```

```sql
WITH CategoryHierarchy
(category_id,
 category_name,
 parent_id,
 lvl)

AS (

SELECT category_id,
       category_name,
       parent_id,
       1

FROM Categories

WHERE parent_id IS NULL

UNION ALL

SELECT c.category_id,
       c.category_name,
       c.parent_id,
       ch.lvl + 1

FROM Categories c
JOIN CategoryHierarchy ch

ON c.parent_id = ch.category_id

)

SELECT *
FROM CategoryHierarchy;
```

---

## 4. CTE with Aggregation

### Business Value

Calculates total revenue and order count per product.

```sql
-- Your SQL here
```

---

## 5. CTE with JOIN Operations

### Business Value

Summarizes revenue by category.

```sql
-- Your SQL here
```

---

# 📈 Part B – Advanced SQL Window Functions

## Ranking Functions

- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- PERCENT_RANK()

```sql
-- SQL Query
```

---

## Aggregate Window Functions

- SUM()
- AVG()
- MIN()
- MAX()

```sql
-- SQL Query
```

---

## Navigation Functions

- LAG()
- LEAD()

```sql
-- SQL Query
```

---

## Distribution Functions

- NTILE()
- CUME_DIST()

```sql
-- SQL Query
```

---

# 📊 Business Analysis & Decision Insights

## Descriptive Analysis

- Total Revenue: **$13,175**
- Total Orders: **7**
- Laptop sales generated approximately **95%** of revenue.
- Accessories generated approximately **$675**.

---

## Diagnostic Analysis

### Product Mix

Premium laptops contribute significantly more revenue than accessories.

### Sales Variation

Window functions reveal transaction values ranging from:

- **Highest:** $6,000
- **Lowest:** $125

---

## Prescriptive Recommendations

- Bundle accessories with premium laptops.
- Diversify marketing toward mid-range products.
- Reduce dependency on a single product category.

---

# 🎯 Conclusion

This project demonstrates how advanced SQL techniques transform transactional data into meaningful business intelligence.

Key concepts demonstrated include:

- Common Table Expressions
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
