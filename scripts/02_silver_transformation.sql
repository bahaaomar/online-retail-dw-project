use online_retail_II

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
    CustomerID    NVARCHAR(20),   -- تكست عشان تستحمل التحويل، بس دلوقتي بتفضل NULL حقيقية لو مش موجودة
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
-- تعديل: ضفنا DISTINCT هنا عشان نحل مشكلة الصفوف المكررة بالكامل
-- (تشيك A2 في سكريبت الـ Data Quality) - أي صف مطابق لصف تاني
-- في كل الأعمدة سوا سوا هيتجمع في نسخة واحدة بس بدل ما يتكرر
SELECT DISTINCT
    TRIM(Invoice) AS Invoice,
    TRIM(StockCode) AS StockCode,
    TRIM(Description) AS Description,
    TRY_CAST(Quantity AS INT) AS Quantity,
    TRY_CAST(InvoiceDate AS DATETIME) AS InvoiceDate,
    TRY_CAST(Price AS DECIMAL(10,2)) AS Price,
    -- بنعدي بـ FLOAT الأول قبل INT عشان نلحق أي كستمر آي دي جاي بصيغة "13085.0"
    -- وشيلنا الـ ISNULL(..., 'Unknown') عشان نسيب القيمة NULL حقيقية هنا
    -- والتحويل لـ 'Unknown' هيحصل بس جوه الجولد (نفس منطق الـ Product بالظبط)
    CAST(TRY_CAST(LTRIM(RTRIM([Customer ID])) AS FLOAT) AS INT) AS CustomerID,
    ISNULL(TRIM(Country), 'Unknown') AS Country
FROM bronze.online_retail_II
WHERE
    Invoice IS NOT NULL
    -- تعديل (اختيار ب): مبقيناش بنستبعد الإنفويسات الملغاة (اللي بتبدأ بـ C)
    -- ده بيسيبنا نتراكهم في الجولد بكولم IsCancelled بشكل صح
    -- الإنفويس الملغي لازم يبقى الكوانتيتي بتاعه سالب (ده منطقي: مرتجع)
    -- والإنفويس العادي لازم يبقى الكوانتيتي بتاعه موجب
    -- تعديل مهم: بنعمل TRIM(Invoice) هنا قبل المقارنة بـ C% مش على العمود الخام
    -- لأن لو فيه سبيس زيادة في الأول أو الآخر جوه البرونز، الشرط القديم
    -- كان بيفشل يتعرف على الإنفويس إنه ملغي، فالصف كان بيتستبعد بالكامل
    -- (مش بس بيطلع IsCancelled = 0، كان بيروح خالص من غير ما يدخل السيلفر)
    AND (
        (TRIM(Invoice) LIKE 'C%' AND TRY_CAST(Quantity AS INT) < 0)
        OR
        (TRIM(Invoice) NOT LIKE 'C%' AND TRY_CAST(Quantity AS INT) > 0)
    )
    -- استبعاد القيم الصفرية أو الغلط في السعر يفضل زي ما هو
    AND TRY_CAST(Price AS DECIMAL(10,2)) > 0;
GO

-- ==========================================
-- 2.5. إزالة أي صفوف مكررة بالكامل (لو لسه فيه بعد الـ DISTINCT)
-- ==========================================
-- الكود ده بيدور على أي صف مطابق تماماً لصف تاني في كل الأعمدة السبعة،
-- وبيسيب نسخة واحدة بس منه ويمسح الباقي.
-- ده Safety Net إضافي، حتى لو حصل خطأ أو الـ DISTINCT فوق ماشتغلش لأي سبب.
;WITH Duplicates AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country
            ORDER BY (SELECT NULL)
        ) AS rn
    FROM silver.online_retail_II
)
DELETE FROM Duplicates
WHERE rn > 1;
GO

-- تأكيد سريع: لازم يرجع صفر بعد التنفيذ
SELECT COUNT(*) AS Remaining_Duplicates
FROM (
    SELECT COUNT(*) AS cnt
    FROM silver.online_retail_II
    GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country
    HAVING COUNT(*) > 1
) x;
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


SELECT 
    Invoice, StockCode, Quantity, Price, InvoiceDate,
    COUNT(DISTINCT CustomerID) AS Distinct_CustomerIDs,
    COUNT(*) AS Row_Count
FROM silver.online_retail_II
GROUP BY Invoice, StockCode, Quantity, Price, InvoiceDate
HAVING COUNT(*) > 1;

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



SELECT DISTINCT
    Invoice, 
    StockCode, 
    Description, 
    Quantity, 
    InvoiceDate, 
    Price, 
  [Customer ID], 
    Country
FROM bronze.online_retail_II;
