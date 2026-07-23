use online_retail_II;
--ده بيحسب عدد الصفوف
SELECT COUNT(*) AS Total_Records
FROM bronze.online_retail_II;

--تشيك invoice المكرر

select [Invoice],count (*) 
from BRONZE.online_retail_II
group by [Invoice]
having count (*) >1

--  فى Descriptionتشيك القيم الفاضية أو النل
SELECT COUNT(*) AS Missing_Description
FROM bronze.online_retail_II
WHERE Description IS NULL OR LTRIM(RTRIM(Description)) = '';

--Quantity بقيم سالبة او صفر
SELECT Quantity
FROM bronze.online_retail_II
WHERE TRY_CAST(Quantity AS INT) <= 0;
--الكوانتيتي اللي فشل الكاستينج بتاعها
SELECT Quantity
FROM bronze.online_retail_II
WHERE TRY_CAST(Quantity AS INT) IS NULL 
  AND Quantity IS NOT NULL;
 --البرايس بقيم سالبة أو صفر
 SELECT Price
FROM BRONZE.online_retail_II
WHERE TRY_CAST(Price AS DECIMAL(10,2)) <= 0;
--تشيك الكستمر آي دي المكرر
use online_retail_II
go 
select [Customer ID],count (*) 
from BRONZE.online_retail_II
group by [Customer ID]
having count (*) >1

--القيم المختلفة للكنتري
 select distinct Country
 from BRONZE.online_retail_II
 --الكنتري اللي فيها مسافات زيادة
 SELECT DISTINCT Country
FROM bronze.online_retail_II
WHERE Country <> LTRIM(RTRIM(Country));




 


 --تشيك شامل للمسافات
select
    Invoice,
    StockCode,
    Description,
    Country,
    -- هل فيه مسافات اول واخر؟
    CASE WHEN Description <> LTRIM(RTRIM(Description)) THEN 'Yes' ELSE 'No' END AS Desc_LeadingTrailingSpace,
    CASE WHEN Country <> LTRIM(RTRIM(Country)) THEN 'Yes' ELSE 'No' END AS Country_LeadingTrailingSpace,
    -- هل فيه مسافتين ورا بعض؟
    CASE WHEN Description LIKE '%  %' THEN 'Yes' ELSE 'No' END AS Desc_DoubleSpace
FROM bronze.online_retail_II
WHERE 
    Description <> LTRIM(RTRIM(Description))
    OR Country <> LTRIM(RTRIM(Country))
    OR Description LIKE '%  %';


   



--سمّ الإنفاليد فاليوز

SELECT 
    SUM(CASE WHEN TRY_CAST(Quantity AS INT) <= 0 THEN 1 ELSE 0 END) AS Invalid_Quantity,
    SUM(CASE WHEN TRY_CAST(Price AS DECIMAL(10,2)) <= 0 THEN 1 ELSE 0 END) AS Invalid_Price
FROM bronze.online_retail_II;

--كاونت الباد داتا في كل الأعمدة
SELECT 
    COUNT(CASE WHEN TRY_CAST(Quantity AS INT) IS NULL AND Quantity IS NOT NULL THEN 1 END) AS Bad_Quantity,
    COUNT(CASE WHEN TRY_CAST(Price AS DECIMAL(10,2)) IS NULL AND Price IS NOT NULL THEN 1 END) AS Bad_Price,
    COUNT(CASE WHEN TRY_CAST(InvoiceDate AS DATETIME) IS NULL AND InvoiceDate IS NOT NULL THEN 1 END) AS Bad_InvoiceDate,
    COUNT(CASE WHEN TRY_CAST([Customer ID] AS INT) IS NULL AND [Customer ID] IS NOT NULL THEN 1 END) AS Bad_CustomerID
FROM bronze.online_retail_II;

