USE master;
GO

-- إغلاق أي الاتصالات مفتوحة على قاعدة البيانات ومسحها إن وجدت 
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'online_retail_II')
BEGIN
    ALTER DATABASE online_retail_II SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE online_retail_II;
END
GO
-- إنشاء قاعدة البيانات
CREATE DATABASE online_retail_II;
GO

USE online_retail_II;
GO
-- إنشاء الـ Schemas
CREATE SCHEMA BRONZE;
GO

CREATE SCHEMA SILVER;
GO
CREATE SCHEMA GOLD;
GO