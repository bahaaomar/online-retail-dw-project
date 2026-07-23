USE online_retail_II;
GO

-- مسح أي نسخة قديمة (الفيو الأول عشان بيعتمد على التابلز)
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
INSERT INTO gold.dim_customer (CustomerID, Country)
SELECT CustomerID, MAX(Country)
FROM silver.online_retail_II
WHERE CustomerID IS NOT NULL      -- تعديل: مانسيبش الكستمر آي دي النل يدخل هنا، هنعمله صف تاني تحت
GROUP BY CustomerID;
GO

-- تعديل جديد: ضيف "Unknown Customer" عشان أي أوردر معندوش كستمر آي دي في السورس
-- ده بيمنع إننا نخسر صفوف من الفاكت تيبل لما نيجي نعمل جوين
SET IDENTITY_INSERT gold.dim_customer ON;
INSERT INTO gold.dim_customer (CustomerKey, CustomerID, Country)
VALUES (-1, 'Unknown', 'Unknown');
SET IDENTITY_INSERT gold.dim_customer OFF;
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
INSERT INTO gold.dim_product (StockCode, Description)
SELECT StockCode, MAX(Description)
FROM silver.online_retail_II
WHERE StockCode IS NOT NULL       -- تعديل: نفس فكرة الكستمر، بنستبعد النل هنا
GROUP BY StockCode;
GO

-- تعديل جديد: "Unknown Product" لنفس السبب لو فيه ستوك كود نل في السورس
SET IDENTITY_INSERT gold.dim_product ON;
INSERT INTO gold.dim_product (ProductKey, StockCode, Description)
VALUES (-1, 'Unknown', 'Unknown Product');
SET IDENTITY_INSERT gold.dim_product OFF;
GO

-- ==========================================
-- 4) FACT_SALES
-- سطر واحد = لاين آيتم واحد جوه إنفويس واحد
-- ==========================================
CREATE TABLE gold.fact_sales (
    SalesKey    INT IDENTITY(1,1) PRIMARY KEY,
    Invoice     NVARCHAR(20),
    ProductKey  INT,
    CustomerKey INT,
    DateKey     INT,
    Quantity    INT,
    Price       DECIMAL(10,2),
    TotalAmount DECIMAL(12,2),
    IsCancelled BIT              -- تعديل جديد: فلاج لأي إنفويس رقمه بيبدأ بحرف C (كانسل/ريتيرن)
);
GO

-- تعديل الأهم: استبدلنا INNER JOIN بـ LEFT JOIN + ISNULL
-- عشان لو الكستمر آي دي في السورس نل، الصف ميتشالش من الفاكت تيبل خالص
-- بدل ما يترمي بصمت زي ما كان بيحصل مع INNER JOIN
INSERT INTO gold.fact_sales (Invoice, ProductKey, CustomerKey, DateKey, Quantity, Price, TotalAmount, IsCancelled)
SELECT
    s.Invoice,
    ISNULL(p.ProductKey, -1),
    ISNULL(c.CustomerKey, -1),
    CAST(CONVERT(VARCHAR(8), s.InvoiceDate, 112) AS INT),
    s.Quantity, s.Price,
    CAST(s.Quantity * s.Price AS DECIMAL(12,2)),
    CASE WHEN s.Invoice LIKE 'C%' THEN 1 ELSE 0 END
FROM silver.online_retail_II s
LEFT JOIN gold.dim_product  p ON s.StockCode  = p.StockCode
LEFT JOIN gold.dim_customer c ON s.CustomerID = c.CustomerID
WHERE s.InvoiceDate IS NOT NULL;
GO

-- ==========================================
-- 5) VW_FACT_SALES  (فيو جاهز للـ Power BI)
-- ==========================================
CREATE VIEW gold.vw_fact_sales AS
SELECT
    f.SalesKey, f.Invoice, p.StockCode, p.Description,
    c.CustomerID, c.Country,
    d.InvoiceDate, d.YearNum, d.MonthName, d.QuarterNum, d.DayName, d.IsWeekend,
    f.Quantity, f.Price, f.TotalAmount, f.IsCancelled
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

-- تعديل جديد: تشيك مهم جداً - يتأكد إننا معملناش أي فقد في الصفوف
-- الرقمين دول لازم يبقوا متساويين تماماً
SELECT COUNT(*) AS Silver_Rows_WithDate FROM silver.online_retail_II WHERE InvoiceDate IS NOT NULL;

SELECT TOP 20 * FROM gold.vw_fact_sales;
GO
