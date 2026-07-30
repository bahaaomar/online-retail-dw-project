# Technical Report – Online Retail Data Warehouse Project

## 1. Introduction

This project is a complete Data Warehouse for the sales data of an online retail company (Online Retail II), built on SQL Server and connected to Power BI to create an analytical dashboard. The architecture used is the Medallion Architecture, meaning the data passes through three layers: the Bronze Layer, the Silver Layer, and the Gold Layer, until it reaches a clean, analysis-ready state in Star Schema format.

This report documents three core aspects of the project:
- The system's High Level Architecture.
- The Data Flow / Data Lineage, i.e., how data moves from its source to the final consumption point.
- The Data Model in Star Schema format in the Gold Layer.

---

## 2. High Level Architecture

### 2.1 Sources

| Item | Details |
|---|---|
| Object Type | CSV File |
| Interface | File Path |
| Load Method | Bulk Insert |
| File Name | online_retail_II.csv |

The original data comes from a single CSV file named `online_retail_II.csv`, loaded using the Bulk Insert method via its file path.

### 2.2 Bronze Layer

The purpose of the Bronze Layer is to keep an exact copy of the raw data as-is, without any modification or cleaning.

| Item | Details |
|---|---|
| Table Name | bronze.online_retail_II |
| Object Type | Table |
| Load | Bulk Insert (Full Load) + Truncate & Insert |
| Transformations | None |
| Data Model | None (as-is) |
| Data Type | All columns NVARCHAR(MAX) |

- Loading is done through a Stored Procedure that performs Truncate & Insert on the table before every new load.
- Several Data Quality Checks are performed at the Bronze level, including:
  - Duplicate Invoice Check
  - Null / Missing Values
  - Invalid Quantity & Price
  - Cancelled Invoices marked with a C% prefix
  - Extra Spaces / Trimming

### 2.3 Silver Layer

In the Silver Layer, cleaning and standardization operations are performed on the data coming from the Bronze layer.

| Item | Details |
|---|---|
| Table Name | silver.online_retail_II |
| Object Type | Table |
| Load | Full Load (Insert) |
| Data Model | None (as-is) |

The transformations applied in this layer:
- Data Cleansing using TRIM
- Type Casting using TRY_CAST
- Deduplication using DISTINCT
- Cancelled Invoice Logic
- Handling NULLs for the Customer ID column

Loading here is also performed through a separate Stored Procedure.

### 2.4 Gold Layer

The Gold Layer is the final, business-ready layer, where the data is transformed into Star Schema format.

| Item | Details |
|---|---|
| Objects | dim_date, dim_customer, dim_product, fact_sales, vw_fact_sales |
| Object Type | Tables & View |
| Load | Full Load (for the fact and dimension tables) + No Load (for the view) |
| Data Model | Star Schema |

Transformations in the Gold Layer:
- Data Integration via Joins
- Surrogate Keys (SK)
- Business Logic such as IsCancelled and TotalAmount
- Unknown Members with a value of -1

The load and views (Views & Stored Procedure) here cover both the tables and the reporting view (vw_fact_sales).

### 2.5 Consume Layer

| Tool | Usage |
|---|---|
| Power BI | BI & Reporting |
| SSMS | Ad-Hoc SQL Queries |

The data in the Gold Layer is consumed in two ways: through Power BI to build dashboards and reports, and through SSMS to run Ad-Hoc Queries when needed.

---

## 3. Data Flow / Data Lineage

Data Lineage shows how each piece of data moves from its source to its final consumption point, which helps trace the origin of any figure in the final report.

The data path flows as follows:

1. **online_retail_II.csv** (CSV file) ⟶
2. **bronze.online_retail_II** (Bronze Layer – loaded raw, as-is) ⟶
3. **silver.online_retail_II** (Silver Layer – cleaned and standardized) ⟶
4. Gold Layer, where the data is split into 4 main objects:
   - **fact_sales**
   - **dim_customer**
   - **dim_product**
   - **dim_date**

In other words, every record starts from the CSV file, passes through Bronze without any modification, gets cleaned in Silver, and finally gets split in Gold into fact and dimension tables ready for analysis.

---

## 4. Data Model (Star Schema)

The Star Schema in the Gold Layer consists of one Fact Table and three Dimension Tables connected to it.

### 4.1 gold.fact_sales (Fact Table)

| Type | Column Name |
|---|---|
| PK | sk_sales |
| — | Invoice |
| FK1 | sk_product |
| FK2 | sk_customer |
| FK3 | sk_date |
| — | Quantity |
| — | Price |
| — | TotalAmount |
| — | IsCancelled |

This fact table is connected to the three dimensions via three Foreign Keys: sk_product, sk_customer, and sk_date.

### 4.2 gold.dim_customer

| Type | Column Name |
|---|---|
| PK | sk_customer |
| — | CustomerID |
| — | Country |

### 4.3 gold.dim_product

| Type | Column Name |
|---|---|
| PK | sk_product |
| — | StockCode |
| — | Description |

### 4.4 gold.dim_date

| Type | Column Name |
|---|---|
| PK | sk_date |
| — | InvoiceDate |
| — | DayNum |
| — | MonthNum |
| — | MonthName |
| — | QuarterNum |
| — | YearNum |
| — | DayName |
| — | WeekOfYear |
| — | IsWeekend |

### 4.5 Business Logic Notes

Several business logic rules were applied at the Gold Layer level:

- **Sales Calculation**: `TotalAmount = Quantity * Price`
- **IsCancelled**:
  - 1 = Cancelled Invoice, when the Invoice starts with the letter C
  - 0 = Normal Sale
- **IsWeekend**:
  - 1 = Weekend, meaning Saturday or Sunday
  - 0 = regular Weekday

---

## 5. Conclusion

The project fully implements the Medallion Architecture, starting from a raw CSV file, passing through the Bronze layer for as-is storage, the Silver layer for cleaning and standardization, and reaching the Gold layer in Star Schema format, ready for consumption via Power BI or SSMS. This design provides full Data Lineage traceability and facilitates future Maintenance and Scalability.
