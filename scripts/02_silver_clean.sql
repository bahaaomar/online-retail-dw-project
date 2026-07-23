-- ==========================================
-- 1. حذف الجدول القديم لو موجود، وإعادة إنشائه بالداتا تايبس الصح
-- ==========================================
DROP TABLE IF EXISTS silver.online_retail_II;

CREATE TABLE silver.online_retail_II (
    Invoice       NVARCHAR(20),
    StockCode     NVARCHAR(20),
    Description   NVARCHAR(200),
    Quantity      INT,
    InvoiceDate   DATETIME,
    Price         DECIMAL(10,2),
    CustomerID    NVARCHAR(20),   -- تكست عشان تستحمل "Unknown"
    Country       NVARCHAR(50)
);
GO

-- ==========================================
-- 2. عملية تنظيف والتحويل (Cleaning & Transformation)
-- ==========================================
INSERT INTO silver.online_retail_II (
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    CustomerID,
    Country
)
SELECT
    TRIM(Invoice) AS Invoice,
    TRIM(StockCode) AS StockCode,
    TRIM(Description) AS Description,
    TRY_CAST(Quantity AS INT) AS Quantity,
    TRY_CAST(InvoiceDate AS DATETIME) AS InvoiceDate,
    TRY_CAST(Price AS DECIMAL(10,2)) AS Price,
    ISNULL(CAST(TRY_CAST(LTRIM(RTRIM([Customer ID])) AS INT) AS NVARCHAR(20)), 'Unknown') AS CustomerID,
    ISNULL(TRIM(Country), 'Unknown') AS Country
FROM bronze.online_retail_II
WHERE
    -- استبعاد المرتجعات والفواتير الملغاة
    Invoice NOT LIKE 'C%'
    AND Invoice IS NOT NULL
    -- استبعاد القيم السالبة أو الصفرية غير المنطقية
    AND TRY_CAST(Quantity AS INT) > 0
    AND TRY_CAST(Price AS DECIMAL(10,2)) > 0;
GO

-- ==========================================
-- 3. مقارنة عدد الصفوف بين البرونز والسيلفر لمعرفة كم تم استبعاده
-- ==========================================
SELECT
    (SELECT COUNT(*) FROM bronze.online_retail_II) AS Bronze_Rows,
    (SELECT COUNT(*) FROM silver.online_retail_II) AS Silver_Clean_Rows;

-- ==========================================
-- 4. معاينة أول 50 صف من البيانات المنظفة
-- ==========================================
SELECT TOP 50 *
FROM silver.online_retail_II;