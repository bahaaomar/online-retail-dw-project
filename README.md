# online-retail-dw-project

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

To maximize the value extracted from the data and increase revenue and sales performance, the dashboard should focus on answering the following analytical questions, which in turn reveal strategic goals and problems:

### A. Overall Sales Performance

- **Question:** What is the overall sales performance?
- **Key Metrics (KPI Cards):**
  - Total revenue
  - Total Customers
  - Total Orders
  - Average unit price
  - Total Quantity 
  - Average Order Value
- **Derived Goals/Problems:** Assessing the company's overall financial health, understanding the scale of business activity, and identifying key performance indicators that need improvement.

### B. Sales by Country

- **Question:** How are sales distributed by country?
- **Suggested Chart Type:** Donut Chart
- **Business Question:** Which countries generate the largest share of total sales?
- **Derived Goals/Problems:** Identifying the most profitable geographic markets, understanding the geographic concentration of sales, and guiding expansion strategies or strengthening presence in specific markets.

### C. Sales Trend Over Time

- **Question:** How have sales evolved over time?
- **Suggested Chart Type:** Stacked Column Chart
- **Business Question:** How did sales change on a monthly and yearly basis?
- **Derived Goals/Problems:** Identifying seasonal and cyclical trends in sales, forecasting future demand, and planning marketing campaigns and promotions at the right times.

### D. Top Customers

- **Question:** Who are the top customers?
- **Suggested Chart Type:** Horizontal Bar Chart
- **Business Question:** Who are the top 10 customers by sales value?
- **Derived Goals/Problems:** Identifying High-Value Customers for retention, developing personalized loyalty programs, and understanding these customers' characteristics to replicate success.

### E. Orders Over Time

- **Question:** How do orders change over time?
- **Suggested Chart Type:** Column Chart
- **Business Question:** Is the number of orders increasing or decreasing across months?
- **Derived Goals/Problems:** Understanding order dynamics, identifying peak and low periods in order volume, and improving logistics management and customer service.

### F. Top Selling Products

- **Question:** What are the top selling products?
- **Suggested Chart Type:** Horizontal Bar Chart
- **Business Question:** What are the top products by revenue?
- **Derived Goals/Problems:** Identifying trending products to ensure availability, improving pricing and promotion strategies, and guiding new product development efforts.

### G. Most Active Countries

- **Question:** What are the most active countries?
- **Suggested Chart Type:** Horizontal Bar Chart
- **Business Question:** Which countries have the largest number of customers or orders?
- **Derived Goals/Problems:** Identifying markets with the largest customer base, directing marketing campaigns to increase engagement in these countries, and understanding the geographic distribution of customers.

## 6. Derived Strategic Objectives for Achieving Growth

Based on the answers to the dashboard questions, the company can formulate the following strategic objectives:

1. **Smart Targeting:** Build marketing campaigns based on accurate data about the most profitable customers and markets.
2. **Operational Excellence:** Manage inventory and operations efficiently based on time-based and seasonal demand forecasts.
3. **Profitability Improvement:** Reassess products and pricing based on detailed financial performance analysis for each product.
4. **Sustainable Growth:** Build long-term relationships with the most valuable customers to ensure revenue stability and increase their loyalty.
5. **Market Share Expansion:** Identify promising geographic markets and allocate the necessary resources to expand into them...
