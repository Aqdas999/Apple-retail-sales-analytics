# Apple-retail-sales-analytics
Business Analytics project using PostgreSQL to analyze Apple retail sales, product performance, warranty trends, and strategic business insights.
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql)

![SQL](https://img.shields.io/badge/SQL-Advanced-green)

![Business Analytics](https://img.shields.io/badge/Business-Analytics-orange)

![Status](https://img.shields.io/badge/Project-Completed-success)

## 📖 Project Overview

This project simulates the work of a Business Analyst within Apple's retail business by analyzing transactional sales data using PostgreSQL.

The objective is not only to write SQL queries, but also to answer practical business questions related to sales performance, product strategy, store operations, warranty analysis, market expansion, and executive decision-making.

The project contains **40 progressively structured SQL queries**, beginning with basic business reporting and gradually moving towards advanced analytical and strategic business insights using PostgreSQL.

## ✨ Project Highlights

- 📊 40 real-world business-focused SQL queries
- 🏪 Analysis across stores, products, categories, cities and countries
- 📈 Sales trend and performance analysis
- 🛠 Warranty and product reliability analysis
- 🌍 Market expansion and geographical insights
- 📦 Product portfolio evaluation
- 📉 Growth, benchmarking and performance tracking
- 📋 Executive-level business reporting

 ## 🎯 Business Problem

Retail businesses generate large volumes of transactional data every day, but raw data alone does not support business decisions.

Business leaders require meaningful insights to answer questions such as:

- Which products generate the highest business value?
- Which stores consistently outperform others?
- Which product categories contribute the most revenue?
- Are warranty claims impacting product reliability?
- Which markets have the greatest expansion potential?
- Which products should receive additional marketing investment?
- How has sales performance changed over time?

This project demonstrates how SQL can be used to transform raw transactional data into actionable business insights that support strategic decision-making.

## 🎯 Project Objectives

The primary objectives of this project are to:

- Analyze sales performance across products, stores, cities, and countries.
- Evaluate revenue contribution at multiple business levels.
- Measure product reliability using warranty claim data.
- Identify high-performing and underperforming products.
- Compare store performance using business benchmarks.
- Detect sales trends and seasonal demand patterns.
- Evaluate market expansion opportunities.
- Generate executive-level insights using SQL.
- Demonstrate practical PostgreSQL skills through real-world business scenarios.

## 🛠 Tech Stack

| Tool | Purpose |
|------|----------|
| PostgreSQL | Database Management System |
| pgAdmin 4 | Query Development & Execution |
| SQL | Data Analysis & Business Insights |
| Git | Version Control |
| GitHub | Project Documentation & Portfolio |

## 📂 Dataset Overview

The project uses a relational database consisting of five interconnected tables representing Apple's retail business.

| Table | Description |
|--------|-------------|
| **sales** | Stores every sales transaction including product sold, quantity, store, and sale date. |
| **products** | Contains product information such as product name, category, launch date, and price. |
| **stores** | Contains store location details including city and country. |
| **category** | Stores product category information. |
| **warranty** | Records warranty claims and repair status for sold products. |

Together, these tables simulate a realistic retail business environment suitable for business analytics.

## 🗄 Database Schema

The database consists of five relational tables connected through primary and foreign key relationships.

> **ER Diagram will be added here after the database schema is finalized.**

## 📁 Project Structure

```text
Apple-retail-sales-analytics
│
├── assets/              # Images, diagrams and project visuals
├── data/                # Raw dataset files
├── docs/                # Project documentation
├── presentation/        # Executive presentation
├── queries/             # SQL query files
├── schema/              # Database creation scripts
├── screenshots/         # Query outputs and visuals
│
├── README.md
├── LICENSE
```

## 📊 Business Questions Covered

The project answers business questions across multiple analytical domains.

### Business Snapshot

- Overall business performance
- Revenue by country
- Revenue by product
- Revenue by store
- Revenue by category

### Market Analysis

- Monthly sales trends
- Product pricing insights
- Product mix analysis
- High-value transactions
- Product launch performance
- Market opportunity analysis

### Product & Store Analytics

- Product performance
- Product reliability
- Distribution efficiency
- Store performance benchmarking
- Market dependency
- Portfolio analysis

### Performance Analytics

- Month-over-month growth
- Product consistency
- Sales momentum
- Revenue contribution
- Performance benchmarking
- Market balance

### Strategic Business Insights

- Marketing prioritization
- Operational improvements
- Expansion opportunities
- Revenue diversification
- Inventory planning
- Executive reporting

## 💻 SQL Concepts Demonstrated

| Category | Concepts |
|----------|----------|
| Joins | INNER JOIN, LEFT JOIN |
| Aggregation | SUM, AVG, COUNT, MIN, MAX |
| Grouping | GROUP BY, HAVING |
| Common Table Expressions | WITH Clause |
| Window Functions | LAG(), DENSE_RANK(), RANK() |
| Conditional Logic | CASE, COALESCE, NULLIF |
| Date Functions | DATE_TRUNC(), INTERVAL |
| Analytical Functions | Running totals, rankings, benchmarking |
| Subqueries | Correlated and non-correlated subqueries |

## 🔄 Project Workflow

```text
Raw CSV Files
        │
        ▼
Database Design
        │
        ▼
PostgreSQL Database
        │
        ▼
Business-focused SQL Queries
        │
        ▼
Business Insights
        │
        ▼
Recommendations
```

## ⭐ Why This Project?

Unlike traditional SQL practice projects that focus primarily on query writing, this project emphasizes solving real business problems using SQL.

Rather than simply retrieving data, the queries are designed to answer strategic business questions related to sales performance, operational efficiency, product reliability, market expansion, and executive decision-making.

The project demonstrates how SQL can be used as a decision-support tool in a retail business environment.
