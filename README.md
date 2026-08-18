# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---

## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:

- SQL Development
- Data Architect
- Data Engineering
- ETL Pipeline Developer
- Data Modeling
- Data Analytics

    
## Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective

Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.
#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analyties teams.

  ---
### BI: Analytics & Reporting (Data Analytics)
# Objective
Develop SQL-based analytics to deliver detailed insights into:
- **Customer Behavior**
- **Product Performance**
- **Sales Trends**
These insights empower stakeholders with key business metrics, enabling strategic decision-making.

### 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture Bronze, Silver, and Gold layers:
##### Sources → Data Warehouse (SQL Server) → Consume

<img width="745" height="426" alt="Screenshot 2026-08-18 at 1 53 03 PM" src="https://github.com/user-attachments/assets/c14a1095-29e3-4bcb-8920-849621e7aaf4" />

##### Bronze Layer: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
##### Silver Layer: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
##### Gold Layer: Houses business-ready data modeled into a star schema required for reporting and analytics.
- - -

## License
This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.
## * About Me
Hi there! I am **Krish Kumar** also known as **Krish Rdx**. I'm an student from NIT Allahabad and Amazed how these data works end to end, starting from data enginnering process building any model for business and LLMs etc.
