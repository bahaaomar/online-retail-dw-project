USE online_retail_II;
GO

ALTER DATABASE online_retail_II SET MULTI_USER;
GO

-- 1. مسح الجدول القديم
DROP TABLE IF EXISTS bronze.online_retail_II;
GO

-- 2. إنشاء الجدول بحقول نصية NVARCHAR(MAX) لضمان قبول البيانات الخام
CREATE TABLE bronze.online_retail_II (
    Invoice NVARCHAR(MAX),
    StockCode NVARCHAR(MAX),
    Description NVARCHAR(MAX),
    Quantity NVARCHAR(MAX),     -- تغيير النوع لنص لمنع إيرور الـ Bulk Load
    InvoiceDate NVARCHAR(MAX),
    Price NVARCHAR(MAX),        -- تغيير النوع لنص لمنع إيرور الـ Bulk Load
    [Customer ID] NVARCHAR(MAX),
    Country NVARCHAR(MAX)
);
GO

-- 3. رفع البيانات من الـ CSV
BULK INSERT bronze.online_retail_II
FROM 'C:\المشروع النهائي\data\online_retail_II.csv'
WITH (
    FIRSTROW = 2, 
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '0x0a'
);
GO

-- 4. التأكد من عدد الصفوف المرفوعة
SELECT COUNT(*) AS Bronze_Total_Rows FROM bronze.online_retail_II;
GO