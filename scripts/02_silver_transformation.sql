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


USE online_retail_II;
GO

-- 1. إنشاء جدول Invoice
DROP TABLE IF EXISTS silver.online_retail_II_Invoice;
GO
CREATE TABLE silver.online_retail_II_Invoice (
    Invoice NVARCHAR(50)
);
GO
INSERT INTO silver.online_retail_II_Invoice (Invoice)
SELECT Invoice FROM silver.online_retail_II;
GO

-- 2. إنشاء جدول StockCode
DROP TABLE IF EXISTS silver.online_retail_II_StockCode;
GO
CREATE TABLE silver.online_retail_II_StockCode (
    StockCode NVARCHAR(50)
);
GO
INSERT INTO silver.online_retail_II_StockCode (StockCode)
SELECT StockCode FROM silver.online_retail_II;
GO

-- 3. إنشاء جدول Description
DROP TABLE IF EXISTS silver.online_retail_II_Description;
GO
CREATE TABLE silver.online_retail_II_Description (
    Description NVARCHAR(255)
);
GO
INSERT INTO silver.online_retail_II_Description (Description)
SELECT Description FROM silver.online_retail_II;
GO

-- 4. إنشاء جدول Quantity
DROP TABLE IF EXISTS silver.online_retail_II_Quantity;
GO
CREATE TABLE silver.online_retail_II_Quantity (
    Quantity INT
);
GO
INSERT INTO silver.online_retail_II_Quantity (Quantity)
SELECT Quantity FROM silver.online_retail_II;
GO

-- 5. إنشاء جدول InvoiceDate
DROP TABLE IF EXISTS silver.online_retail_II_InvoiceDate;
GO
CREATE TABLE silver.online_retail_II_InvoiceDate (
    InvoiceDate DATETIME
);
GO
INSERT INTO silver.online_retail_II_InvoiceDate (InvoiceDate)
SELECT InvoiceDate FROM silver.online_retail_II;
GO

-- 6. إنشاء جدول Price
DROP TABLE IF EXISTS silver.online_retail_II_Price;
GO
CREATE TABLE silver.online_retail_II_Price (
    Price DECIMAL(10,2)
);
GO
INSERT INTO silver.online_retail_II_Price (Price)
SELECT Price FROM silver.online_retail_II;
GO

-- 7. إنشاء جدول CustomerID
DROP TABLE IF EXISTS silver.online_retail_II_CustomerID;
GO
CREATE TABLE silver.online_retail_II_CustomerID (
   CustomerID NVARCHAR(20) NULL
);
GO
INSERT INTO silver.online_retail_II_CustomerID (CustomerID)
SELECT CustomerID FROM silver.online_retail_II;
GO

-- 8. إنشاء جدول Country
DROP TABLE IF EXISTS silver.online_retail_II_Country;
GO
CREATE TABLE silver.online_retail_II_Country (
    Country NVARCHAR(100)
);
GO
INSERT INTO silver.online_retail_II_Country (Country)
SELECT Country FROM silver.online_retail_II;
GO

SELECT * FROM silver.online_retail_II_Invoice
