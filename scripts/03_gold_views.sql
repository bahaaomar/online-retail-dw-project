USE online_retail_II;
GO

-- مسح أي نسخة قديمة (فيو الأول عشان بيعتمد على التابلز)
DROP VIEW  IF EXISTS gold.vw_fact_sales;
DROP TABLE IF EXISTS gold.fact_sales;
DROP TABLE IF EXISTS gold.dim_date;
DROP TABLE IF EXISTS gold.dim_customer;
DROP TABLE IF EXISTS gold.dim_product;
GO

-- ==========================================
-- 1) DIM_DATE  (DateKey = سمارت سوروجيت كي بصيغة YYYYMMDD)
-- ==========================================
CREATE TABLE gold.dim_date (
    DateKey     INT PRIMARY KEY,
    InvoiceDate DATE,
    DayNum      INT,
    MonthNum    INT,
    MonthName   NVARCHAR(20),
    QuarterNum  INT,
    YearNum     INT,
    DayName     NVARCHAR(20),
    WeekOfYear  INT,
    IsWeekend   BIT
);
GO
-- Populate Date Dimension Table (gold.dim_date)
INSERT INTO gold.dim_date
SELECT DISTINCT
    CAST(CONVERT(VARCHAR(8), InvoiceDate, 112) AS INT),
    CAST(InvoiceDate AS DATE),
    DATEPART(DAY, InvoiceDate),
    DATEPART(MONTH, InvoiceDate),
    DATENAME(MONTH, InvoiceDate),
    DATEPART(QUARTER, InvoiceDate),
    DATEPART(YEAR, InvoiceDate),
    DATENAME(WEEKDAY, InvoiceDate),
    DATEPART(WEEK, InvoiceDate),
    CASE WHEN DATEPART(WEEKDAY, InvoiceDate) IN (1,7) THEN 1 ELSE 0 END
FROM silver.online_retail_II
WHERE InvoiceDate IS NOT NULL;
GO

-- ==========================================
-- 2) DIM_CUSTOMER  (CustomerKey = سوروجيت كي)
-- ==========================================
CREATE TABLE gold.dim_customer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  NVARCHAR(20),
    Country     NVARCHAR(50)
);
GO
-- Populate Customer Dimension Table (gold.dim_customer)
INSERT INTO gold.dim_customer (CustomerID, Country)
SELECT CustomerID, MAX(Country)
FROM silver.online_retail_II
GROUP BY CustomerID;
GO

-- ==========================================
-- 3) DIM_PRODUCT  (ProductKey = سوروجيت كي)
-- ==========================================
CREATE TABLE gold.dim_product (
    ProductKey  INT IDENTITY(1,1) PRIMARY KEY,
    StockCode   NVARCHAR(20),
    Description NVARCHAR(200)
);
GO
-- Populate Product Dimension Table (gold.dim_product)
INSERT INTO gold.dim_product (StockCode, Description)
SELECT StockCode, MAX(Description)
FROM silver.online_retail_II
GROUP BY StockCode;
GO

-- ==========================================
-- 4) FACT_SALES
-- الجرين: سطر واحد = لاين آيتم واحد جوه إنفويس واحد
-- SalesKey = سوروجيت كي الفاكت، والباقي فورين سوروجيت كيز (من غير كونسترينت)
-- ==========================================
CREATE TABLE gold.fact_sales (
    SalesKey    INT IDENTITY(1,1) PRIMARY KEY,
    Invoice     NVARCHAR(20),
    ProductKey  INT,
    CustomerKey INT,
    DateKey     INT,
    Quantity    INT,
    Price       DECIMAL(10,2),
    TotalAmount DECIMAL(12,2)
);
GO
-- Load data into Gold Fact Table (gold.fact_sales)
INSERT INTO gold.fact_sales (Invoice, ProductKey, CustomerKey, DateKey, Quantity, Price, TotalAmount)
SELECT
    s.Invoice, p.ProductKey, c.CustomerKey,
    CAST(CONVERT(VARCHAR(8), s.InvoiceDate, 112) AS INT),
    s.Quantity, s.Price,
    CAST(s.Quantity * s.Price AS DECIMAL(12,2))
FROM silver.online_retail_II s
JOIN gold.dim_product  p ON s.StockCode  = p.StockCode
JOIN gold.dim_customer c ON s.CustomerID = c.CustomerID
WHERE s.InvoiceDate IS NOT NULL;
GO

-- ==========================================
-- 5) VW_FACT_SALES  (فيو جاهز لل Power BI)
-- ==========================================
CREATE VIEW gold.vw_fact_sales AS
SELECT
    f.SalesKey, f.Invoice, p.StockCode, p.Description,
    c.CustomerID, c.Country,
    d.InvoiceDate, d.YearNum, d.MonthName, d.QuarterNum, d.DayName, d.IsWeekend,
    f.Quantity, f.Price, f.TotalAmount
FROM gold.fact_sales f
JOIN gold.dim_product  p ON f.ProductKey  = p.ProductKey
JOIN gold.dim_customer c ON f.CustomerKey = c.CustomerKey
JOIN gold.dim_date     d ON f.DateKey     = d.DateKey;
GO

-- ==========================================
-- 6) تشيك سريع
-- ==========================================
SELECT COUNT(*) AS DimDate_Rows     FROM gold.dim_date;
SELECT COUNT(*) AS DimCustomer_Rows FROM gold.dim_customer;
SELECT COUNT(*) AS DimProduct_Rows  FROM gold.dim_product;
SELECT COUNT(*) AS FactSales_Rows   FROM gold.fact_sales;
SELECT TOP 20 * FROM gold.vw_fact_sales;
GO
