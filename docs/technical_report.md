# تقرير تكنيكال – Online Retail Data Warehouse Project

## 1. مقدمة

المشروع ده عبارة عن داتا ويرهاوس (Data Warehouse) متكامل لبيانات مبيعات شركة أونلاين ريتيل (Online Retail II)، اتبنى على إس كيو إل سيرفر (SQL Server) وبيتصل بـ باور بي آي (Power BI) لعمل داشبورد تحليلي. الأركيتيكتشر (Architecture) المستخدمة هي الميداليون أركيتيكتشر (Medallion Architecture)، يعني الداتا بتعدي على تلات ليرز: البرونز ليير (Bronze Layer)، السيلفر ليير (Silver Layer)، والجولد ليير (Gold Layer)، لحد ما توصل لصورة نضيفة وجاهزة للتحليل بصيغة ستار سكيما (Star Schema).

التقرير ده بيوثّق تلات حاجات أساسية في المشروع:
- الـ هاي ليفل أركيتيكتشر (High Level Architecture) بتاعة النظام.
- الداتا فلو / الداتا لينيج (Data Flow / Data Lineage) يعني إزاي الداتا بتتحرك من مصدرها لحد آخر نقطة.
- الداتا موديل (Data Model) بصيغة ستار سكيما في الجولد ليير.

---

## 2. الـ هاي ليفل أركيتيكتشر (High Level Architecture)

### 2.1 السورسز (Sources)

| البند | التفاصيل |
|---|---|
| Object Type | CSV File |
| Interface | File Path |
| Load Method | Bulk Insert |
| اسم الملف | online_retail_II.csv |

الداتا الأصلية بتيجي من ملف سي إس في (CSV File) واحد اسمه `online_retail_II.csv`، وبيتحمّل بطريقة البالك إنسيرت (Bulk Insert) عن طريق الفايل باث (File Path) بتاعه.

### 2.2 البرونز ليير (Bronze Layer)

الهدف من البرونز ليير إنه يحتفظ بنسخة طبق الأصل من الداتا الخام (Raw Data) زي ما هي، من غير أي تعديل أو تنظيف.

| البند | التفاصيل |
|---|---|
| اسم الجدول | bronze.online_retail_II |
| Object Type | Table |
| Load | Bulk Insert (Full Load) + Truncate & Insert |
| Transformations | لا يوجد – No Transformations |
| Data Model | None (as-is) |
| Data Type | كل الأعمدة NVARCHAR(MAX) |

- اللود بيتم عن طريق ستورد بروسيجر (Stored Procedure) بيعمل تروانكيت اند إنسيرت (Truncate & Insert) على الجدول قبل كل تحميل جديد.
- بيتعمل شوية داتا كواليتي تشيكس (Data Quality Checks) على مستوى البرونز، منها:
  - دوبليكيت إنفويس تشيك (Duplicate Invoice Check)
  - نُل / ميسينج فاليوز (Null / Missing Values)
  - إنفاليد كوانتيتي اند برايس (Invalid Quantity & Price)
  - كانسلد إنفويسز (Cancelled Invoices) بنسبة C%
  - إكسترا سبيسز / تريمينج (Extra Spaces / Trimming)

### 2.3 السيلفر ليير (Silver Layer)

في السيلفر ليير بتتعمل عمليات التنضيف والتوحيد (Cleaning & Standardization) على الداتا الجاية من البرونز.

| البند | التفاصيل |
|---|---|
| اسم الجدول | silver.online_retail_II |
| Object Type | Table |
| Load | Full Load (Insert) |
| Data Model | None (as-is) |

الترانسفورميشنز (Transformations) اللي بتتعمل في الليير ده:
- داتا كلينزينج (Data Cleansing) باستخدام TRIM
- تايب كاستينج (Type Casting) باستخدام TRY_CAST
- ديدوبليكيشن (Deduplication) باستخدام DISTINCT
- كانسلد إنفويس لوجيك (Cancelled Invoice Logic)
- هاندلينج نُلز (Handling NULLs) لعمود الـ Customer ID

اللود هنا كمان بيتم عن طريق ستورد بروسيجر مستقل.

### 2.4 الجولد ليير (Gold Layer)

الجولد ليير هو الليير النهائي الجاهز للاستهلاك (Business-Ready Data)، وفيه الداتا بتتحول لصيغة ستار سكيما.

| البند | التفاصيل |
|---|---|
| الأوبجيكتس (Objects) | dim_date, dim_customer, dim_product, fact_sales, vw_fact_sales |
| Object Type | Tables & View |
| Load | Full Load (للفاكت والديمنشنز) + No Load (للفيو) |
| Data Model | Star Schema |

الترانسفورميشنز في الجولد ليير:
- داتا إنتيجريشن (Data Integration) عن طريق الجوينز (Joins)
- سوروجيت كيز (Surrogate Keys – SK)
- بيزنس لوجيك (Business Logic) زي IsCancelled و TotalAmount
- أننون ممبرز (Unknown Members) بقيمة -1

اللود والـ فيوز (Views & Stored Procedure) هنا بيغطوا كل من التابلز والفيو الخاص بالتقارير (vw_fact_sales).

### 2.5 الكونسيوم ليير (Consume)

| الأداة | الاستخدام |
|---|---|
| باور بي آي (Power BI) | BI & Reporting |
| إس إس إم إس (SSMS) | Ad-Hoc SQL Queries |

الداتا في الجولد ليير بتتستهلك من ناحيتين: عن طريق باور بي آي لعمل الداشبوردز والتقارير، وعن طريق إس إس إم إس لعمل استعلامات مباشرة (Ad-Hoc Queries) وقت الحاجة.

---

## 3. الداتا فلو / الداتا لينيج (Data Flow / Data Lineage)

الداتا لينيج (Data Lineage) بيوضّح إزاي كل عنصر داتا بيتحرك من مصدره لحد آخر نقطة استهلاك، وده بيساعد في تتبع مصدر أي رقم في التقرير النهائي.

مسار الداتا بيمشي بالشكل ده:

1. **online_retail_II.csv** (سي إس في فايل) ⟶
2. **bronze.online_retail_II** (البرونز ليير – تحميل خام زي ما هو) ⟶
3. **silver.online_retail_II** (السيلفر ليير – تنضيف وتوحيد) ⟶
4. الجولد ليير، وفيه الداتا بتتقسم على 4 أوبجيكتس رئيسية:
   - **fact_sales**
   - **dim_customer**
   - **dim_product**
   - **dim_date**

يعني كل ريكورد بيبدأ من ملف السي إس في، يعدي على البرونز من غير أي تعديل، بعدين يتنضف في السيلفر، وفي الآخر يتقسم في الجولد لفاكت وديمنشنز جاهزين للتحليل.

---

## 4. الداتا موديل (Data Model – Star Schema)

الستار سكيما (Star Schema) في الجولد ليير بتتكون من جدول فاكت واحد (Fact Table) وتلات ديمنشن تابلز (Dimension Tables) متصلين بيه.

### 4.1 gold.fact_sales (الفاكت تيبل)

| النوع | اسم العمود |
|---|---|
| PK | sk_sales |
| — | Invoice |
| FK1 | sk_product |
| FK2 | sk_customer |
| FK3 | sk_date |
| — | Quantity |
| — | Price |
| — | TotalAmount |
| — | IsCancelled |

الفاكت تيبل ده متصل بالتلات ديمنشنز عن طريق تلات فورين كيز (Foreign Keys): sk_product و sk_customer و sk_date.

### 4.2 gold.dim_customer

| النوع | اسم العمود |
|---|---|
| PK | sk_customer |
| — | CustomerID |
| — | Country |

### 4.3 gold.dim_product

| النوع | اسم العمود |
|---|---|
| PK | sk_product |
| — | StockCode |
| — | Description |

### 4.4 gold.dim_date

| النوع | اسم العمود |
|---|---|
| PK | sk_date |
| — | InvoiceDate |
| — | DayNum |
| — | MonthNum |
| — | MonthName |
| — | QuarterNum |
| — | YearNum |
| — | DayName |
| — | WeekOfYear |
| — | IsWeekend |

### 4.5 البيزنس لوجيك (Business Logic Notes)

في شوية قواعد بيزنس لوجيك (Business Logic) اتطبقت على مستوى الجولد ليير:

- **Sales Calculation**: `TotalAmount = Quantity * Price`
- **IsCancelled**:
  - 1 = فاتورة ملغية (Cancelled Invoice) لما الـ Invoice يبدأ بحرف C
  - 0 = عملية بيع عادية (Normal Sale)
- **IsWeekend**:
  - 1 = ويكند (Weekend) يعني يوم سبت أو حد
  - 0 = يوم شغل عادي (Weekday)

---

## 5. الخلاصة (Conclusion)

المشروع بيطبّق الميداليون أركيتيكتشر (Medallion Architecture) بشكل كامل، بادئ من ملف سي إس في خام، عدي على برونز ليير للحفظ زي ما هو، سيلفر ليير للتنضيف والتوحيد، وصولاً لجولد ليير بصيغة ستار سكيما جاهزة للاستهلاك عن طريق باور بي آي أو إس إس إم إس. الديزاين ده بيوفّر تتبع كامل للداتا لينيج (Data Lineage)، وبيسهّل عملية الصيانة (Maintenance) والتوسع (Scalability) في المستقبل.
