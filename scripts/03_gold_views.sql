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
-- 1) DIM_DATE  (sk_date = سمارت سوروجيت كي بصيغة YYYYMMDD)
-- ==========================================
CREATE TABLE gold.dim_date (
    sk_date     INT PRIMARY KEY,
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
-- 2) DIM_CUSTOMER  (sk_customer = سوروجيت كي)
-- ==========================================
CREATE TABLE gold.dim_customer (
    sk_customer INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  NVARCHAR(20),
    Country     NVARCHAR(50)
);
GO
-- تعديل: دلوقتي WHERE CustomerID IS NOT NULL بقى ليها معنى حقيقي
-- لأن السيلفر بقى بيرجع NULL حقيقية بدل ما كان بيحول كل حاجة لـ 'Unknown'
INSERT INTO gold.dim_customer (CustomerID, Country)
SELECT CustomerID, MAX(Country)
FROM silver.online_retail_II
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;
GO

-- "Unknown Customer" لأي أوردر معندوش كستمر آي دي في السورس
-- ده بيمنع إننا نخسر صفوف من الفاكت تيبل لما نيجي نعمل جوين
-- ودلوقتي مضمون إنه صف واحد بس (مفيش تكرار زي الأول)
SET IDENTITY_INSERT gold.dim_customer ON;
INSERT INTO gold.dim_customer (sk_customer, CustomerID, Country)
VALUES (-1, 'Unknown', 'Unknown');
SET IDENTITY_INSERT gold.dim_customer OFF;
GO

-- ==========================================
-- 3) DIM_PRODUCT  (sk_product = سوروجيت كي)
-- ==========================================
CREATE TABLE gold.dim_product (
    sk_product  INT IDENTITY(1,1) PRIMARY KEY,
    StockCode   NVARCHAR(20),
    Description NVARCHAR(200)
);
GO
INSERT INTO gold.dim_product (StockCode, Description)
SELECT StockCode, MAX(Description)
FROM silver.online_retail_II
WHERE StockCode IS NOT NULL
GROUP BY StockCode;
GO

-- "Unknown Product" لنفس السبب لو فيه ستوك كود نل في السورس
SET IDENTITY_INSERT gold.dim_product ON;
INSERT INTO gold.dim_product (sk_product, StockCode, Description)
VALUES (-1, 'Unknown', 'Unknown Product');
SET IDENTITY_INSERT gold.dim_product OFF;
GO

-- ==========================================
-- 4) FACT_SALES
-- سطر واحد = لاين آيتم واحد جوه إنفويس واحد
-- تعديل (اختيار ب): رجّعنا كولم IsCancelled، ودلوقتي شغال صح فعلاً
-- لأن السيلفر بقى بيسيب الإنفويسات الملغاة (اللي بتبدأ بـ C) جوه الداتا
-- بالكوانتيتي بتاعها سالب (يعني TotalAmount هيبقى سالب برضه، وده منطقي)
-- ==========================================
CREATE TABLE gold.fact_sales (
    sk_sales    INT IDENTITY(1,1) PRIMARY KEY,
    Invoice     NVARCHAR(20),
    sk_product  INT,
    sk_customer INT,
    sk_date     INT,
    Quantity    INT,
    Price       DECIMAL(10,2),
    TotalAmount DECIMAL(12,2),
    IsCancelled BIT
);
GO

-- LEFT JOIN + ISNULL عشان لو الكستمر آي دي في السورس نل، الصف ميتشالش من الفاكت تيبل خالص
-- بدل ما يترمي بصمت زي ما كان بيحصل مع INNER JOIN
INSERT INTO gold.fact_sales (Invoice, sk_product, sk_customer, sk_date, Quantity, Price, TotalAmount, IsCancelled)
SELECT
    s.Invoice,
    ISNULL(p.sk_product, -1),
    ISNULL(c.sk_customer, -1),
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
    f.sk_sales, f.Invoice, p.StockCode, p.Description,
    c.CustomerID, c.Country,
    d.InvoiceDate, d.YearNum, d.MonthName, d.QuarterNum, d.DayName, d.IsWeekend,
    f.Quantity, f.Price, f.TotalAmount, f.IsCancelled
FROM gold.fact_sales f
JOIN gold.dim_product  p ON f.sk_product  = p.sk_product
JOIN gold.dim_customer c ON f.sk_customer = c.sk_customer
JOIN gold.dim_date     d ON f.sk_date     = d.sk_date;
GO

-- ==========================================
-- 6) تشيك سريع
-- ==========================================
SELECT COUNT(*) AS DimDate_Rows     FROM gold.dim_date;
SELECT COUNT(*) AS DimCustomer_Rows FROM gold.dim_customer;
SELECT COUNT(*) AS DimProduct_Rows  FROM gold.dim_product;
SELECT COUNT(*) AS FactSales_Rows   FROM gold.fact_sales;

-- تشيك مهم جداً - يتأكد إننا معملناش أي فقد في الصفوف
-- الرقمين دول لازم يبقوا متساويين تماماً
SELECT COUNT(*) AS Silver_Rows_WithDate FROM silver.online_retail_II WHERE InvoiceDate IS NOT NULL;

-- تشيك إضافي جديد: يتأكد إن مفيش دبليكيشن حصل بسبب الجوين مع dim_customer
-- الرقمين دول برضه المفروض يبقوا متساويين
SELECT COUNT(*) AS FactSales_Rows_Check FROM gold.fact_sales;

SELECT TOP 20 * FROM gold.vw_fact_sales;
GO



-- تتأكد إن IsCancelled شغال
SELECT TOP 20 * FROM gold.vw_fact_sales WHERE IsCancelled = 1;

-- تتأكد إن IsWeekend شغال
SELECT TOP 20 * FROM gold.vw_fact_sales WHERE IsWeekend = 1;

-- تشوف كل الكوارترز موجودة
SELECT DISTINCT QuarterNum FROM gold.vw_fact_sales ORDER BY QuarterNum;



SELECT TOP 20 * FROM gold.vw_fact_sales WHERE IsCancelled = 1;
