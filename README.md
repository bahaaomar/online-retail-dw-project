## online-retail-dw-project

# Analytical Report: Boosting Revenue and Improving Sales Performance Through Data

## 1. Core Problem and Analytical Objectives

Companies face ongoing challenges in growing revenue and improving sales performance within a constantly changing competitive environment. The solution lies in a deep understanding of customers, products, timing, and markets. This report aims to provide an analytical framework that connects data quality to actionable insights in order to achieve sustainable sales growth.

## 2. Overview of the Retail Dataset (Online Retail II)

A comprehensive retail transactions dataset was analyzed, providing a solid foundation for deriving insights. This data includes:

- **Data Volume: More than 1,067,371 transaction records.
- **Time Period:** Covers business operations from December 2009 to December 2011.
- **Key Columns: Include Invoice Number, Stock Code, Description, Quantity, Invoice Date, Price, Customer ID, and Country.
- **Initial Indicators:** 53,628 unique invoices, 5,305 distinct products, 5,942 registered customers, and 43 countries involved in transactions were identified.
- **Top Revenue Countries:** The United Kingdom leads with estimated revenue of about 16.3 million, followed by Ireland, the Netherlands, Germany, and France.
- **Top Selling Products (by Quantity):** Products such as WORLD WAR 2 GLIDERS ASSTD DESIGNS and WHITE HANGING HEART T-LIGHT HOLDER.

## 3. Data Processing Methodology: Medallion Architecture

Medallion Architecture is a data organization approach aimed at improving data quality and structure as it moves through different layers, ensuring the transformation of raw data into valuable insights.

### A. Bronze Layer: Raw Data

- **Concept:** The first layer that receives data exactly as it comes from its original sources, without any modification or cleaning. The main goal is to keep an exact copy of the historical data as an "Immutable Log."
- **Role:** Provides a recovery point for the original data and ensures full transparency about the data source.
- **Usage:** Used primarily by data engineers to ensure all incoming data is ingested.

### B. Silver Layer: Refined Data

- **Concept:** In this layer, raw data from the Bronze layer is cleaned, standardized, has its types corrected, and missing or illogical values are handled. Business rules and quality checks are applied.
- **Role:** Transforms the data into a trusted "Source of Truth" for analytics, where the data is organized and consistent.
- **Usage:** Used by data analysts and data scientists to perform detailed analyses and build models.

### C. Gold Layer: Business-Ready Data

- **Concept:** The final layer containing pre-aggregated and pre-calculated data, specifically designed to answer specific business questions. This data is ready for direct consumption by dashboards, reports, and business applications.
- **Role:** Provides fast and accurate insights to support strategic and operational decision-making.
- **Usage:** Used by business managers, stakeholders, and interactive dashboards.

## 4. Connecting Medallion Architecture to Dashboard Questions

Medallion Architecture is the backbone that enables dashboards to deliver accurate, timely insights. Each layer serves a vital purpose in this process:

| Layer | Its Role in Answering Dashboard Questions |
|---|---|
| **Bronze** | Provides the raw foundation containing all the details we might need for verification or reprocessing. |
| **Silver** | Cleans and prepares the data, enabling the calculation of core metrics such as total sales, average order value, and identifying customers and products. |
| **Gold** | Provides the pre-aggregated, pre-calculated tables that feed dashboards directly, ensuring fast response times and accuracy when answering complex dashboard questions such as monthly sales trends or top customers. |

## 5. Dashboard Questions and Strategic Objectives

To maximize the value extracted from the data, the dashboard visualizations explicitly address nine key questions extracted directly from the reporting interface:

### A. Performance Overview

* **Visual Question:** How do sales change over time?
* **Key Metrics (KPI Cards):**
* Total Revenue: $19.96M
* Total Quantity: 11M
* Total Orders: 40K
* Total Customers: 6K
* Average Unit Price: 4.07
* Average Order Value: 504.85


* **Chart Visual:** Monthly Revenue Trend (Line Chart)

### B. Revenue Seasonality Analysis

* **Visual Question:** What are the top months by sales?
* **Chart Visual:** Top 5 Revenue Months (Horizontal Bar Chart)

### C. Revenue Drivers by Product

* **Visual Question:** What are the top 10 products by revenue?
* **Chart Visual:** Top 10 Products by Revenue (Horizontal Bar Chart)

### D. Volume Drivers by Product

* **Visual Question:** What are the top 10 products by quantity sold?
* **Chart Visual:** Top 10 Products by Quantity (Horizontal Bar Chart)

### E. Geographic Revenue Volume

* **Visual Question:** What are the top countries by total revenue?
* **Chart Visual:** Total Revenue by Country (Column Chart)

### F. Geographic Order Value Distribution

* **Visual Question:** What are the top countries by Average Order Value?
* **Chart Visual:** Average Order Value by Country (Horizontal Bar Chart)

### G. Customer Revenue Performance

* **Visual Question:** Who are the top customers by revenue?
* **Chart Visual:** Top 10 Customers by Revenue (Summary Data Table)

### H. Customer Retention & Repeat Purchase Rate

* **Visual Question:** Do customers return to buy again?
* **Chart Visual:** Repeat Customers vs. One-Time Customers (Donut Chart)

### I. Sales Concentration & Dependence Risk

* **Visual Question:** Do sales depend on a limited number of customers or products?
* **Chart Visuals:** Customer Revenue Concentration & Product Revenue Concentration (Donut Charts)

---

## 6. Analytical Insights and Strategic Recommendations

### Key Insights derived from Dashboard Analytics:

* **Revenue Seasonality & Slicing:** Sales demonstrate severe seasonal spikes during Q4 of each year, hitting peak revenue months in November 2011 ($1.50M) and November 2010 ($1.46M). Mid-year months experience noticeable dips (e.g., $0.52M in February 2011).
* **Product Performance Disparity:** `REGENCY CAKESTAND 3 TIER` generates the highest revenue ($325K), while `WORLD WAR 2 GLIDERS ASSTD DESIGNS` commands the largest volume sold (105K units). Products like `WHITE HANGING HEART T-LIGHT HOLDER` and `RED RETROSPOT JUMBO BAG` act as core anchors, performing strongly in both sales revenue and overall volume.
* **Geographic Market Dynamics:** The United Kingdom accounts for the massive majority of aggregate revenue ($16.9M). However, international markets lead significantly in transaction size per order, with the Netherlands ($2,410) and Singapore ($2,302) recording the highest Average Order Values (AOV).
* **Retention vs. Acquisition:** Customer retention is strong, with repeat customers accounting for 72.03% (4K) of the customer base compared to 27.97% (2K) one-time buyers.
* **Low Concentration Risk:** Business risk is well diversified. The Top 10 Customers generate 13.51% ($2.7M) of overall revenue, while the Top 10 Products represent 9.97% ($1.99M) of total revenue, indicating strong reliance on a broader long-tail market.

### Strategic Recommendations :-

1. **Supply Chain & Inventory Alignment for Q4:** Prepare supply chain operations, inventory buffer levels, and warehouse staffing starting in late Q3 to handle the 2x–3x demand surge demonstrated every year during October and November.
2. **Targeted B2B Wholesale Expansion:** Leverage high Average Order Values in international regions (Netherlands, Singapore, Australia) by launching tailored B2B/wholesale catalogs and dedicated key account managers for these countries.
3. **VIP Loyalty & Retention Programs:** Implement dedicated loyalty management workflows and VIP account benefits for top accounts (e.g., Customer IDs 18102, 14646, 14156) to ensure consistent re-ordering patterns.
4. **Re-engagement Campaigns for One-Time Buyers:** Build automated post-purchase email series and targeted incentives to convert the 27.97% one-time buyers into repeat buyers.
5. **Product Bundling Strategy:** Bundle high-volume/lower-price drivers (e.g., WWII Gliders, Cake Cases) with top-revenue drivers (e.g., Regency Cakestand) to elevate basket sizes across retail segments.
