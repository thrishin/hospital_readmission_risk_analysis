# Hospital Readmission Risk Analysis

## 📌 Project Overview

This project analyzes hospital encounter data to understand the factors associated with **30-day hospital readmissions**. Using **Microsoft SQL Server**, I performed data validation, data cleaning, missing-value analysis, readmission analysis, and exploratory analysis across patient and encounter characteristics.

The goal is to identify patterns in readmissions and generate business insights that can support better patient follow-up and care management.

---

## 🎯 Business Question

**Why are some patients readmitted within 30 days, and what patient or hospital factors are associated with higher 30-day readmission rates?**

---

## 🗂️ Dataset

The project uses the **Diabetes 130-US Hospitals for Years 1999–2008** dataset.

* **101,766 hospital encounters**
* **71,518 unique patients**
* Data collected from **130 US hospitals**
* Time period: **1999–2008**
* Encounter-level analysis

---

## 🛠️ Tools & Technologies

* **Microsoft SQL Server**
* **T-SQL**
* SQL Server Management Studio (SSMS)
* GitHub

### SQL Concepts Used

* `SELECT`
* `COUNT()`
* `SUM()`
* `CASE`
* `GROUP BY`
* `HAVING`
* `ORDER BY`
* `DISTINCT`
* `JOIN`
* `LEFT JOIN`
* `UPDATE`
* `ALTER TABLE`
* `NULLIF()`
* `TRY_CAST()`
* `LIKE`
* `BETWEEN`
* `ROUND()`
* Subqueries
* CTEs
* `RANK()` Window Function

---

## 🔄 Project Workflow

### 1. Data Validation

* Checked the total number of records.
* Inspected sample records.
* Reviewed table structure and column data types.
* Validated the mapping table.

### 2. Data Cleaning

* Identified missing-value placeholders represented by `?`.
* Converted `?` values into proper SQL `NULL` values.
* Modified column definitions to allow `NULL` values.

### 3. Missing Value Analysis

Calculated missing-value counts and percentages for important columns such as:

* Race
* Weight
* Payer Code
* Medical Specialty
* Diagnosis Codes

The `weight` column had a very high percentage of missing values, so it was excluded from further analysis.

### 4. Data Uniqueness Check

Checked:

* Total encounters
* Unique patients
* Unique encounters
* Duplicate `encounter_id` values

This confirmed that repeated patient records represented multiple encounters rather than duplicate encounter records.

### 5. 30-Day Readmission Analysis

Calculated:

* Total encounters
* Number of patients readmitted within 30 days
* 30-day readmission rate

The `readmitted` column contains three categories:

* `<30` → Readmitted within 30 days
* `30` → Readmitted after 30 days
* `>30` → Not readmitted within 30 days

### 6. Admission Type Analysis

Analyzed 30-day readmission rates across different admission types, including:

* Emergency
* Urgent
* Elective
* Newborn
* Trauma Center

A mapping table was created to convert admission type IDs into readable categories.

### 7. Age Analysis

Analyzed readmission patterns across different age groups.

The dataset stores age as ranges such as:

`[0-10)`, `[10-20)`, `[20-30)`, etc.

A `CASE` statement was used to maintain the correct age-group order.

### 8. Discharge Disposition Analysis

Compared 30-day readmission rates across different discharge disposition categories.

### 9. Previous Inpatient Utilization

Analyzed the relationship between the number of previous inpatient visits and 30-day readmission rates.

The analysis showed an increasing observed readmission rate as previous inpatient utilization increased, although groups with very few encounters require cautious interpretation.

### 10. Diagnosis Analysis

Primary diagnosis codes were grouped into broad categories using `CASE`, `LIKE`, `LEFT()`, `TRY_CAST()`, and numeric ranges.

Categories included:

* Diabetes
* Circulatory
* Respiratory
* Digestive
* Genitourinary
* Injury
* Other

The readmission rate was then calculated for each category.

---

## 🚀 Advanced SQL Analysis

### CTE

A **Common Table Expression (CTE)** was used to calculate diagnosis-level readmission metrics and compare each diagnosis category against the overall readmission rate.

### RANK() Window Function

The `RANK()` window function was used to rank diagnosis categories based on their observed 30-day readmission rate.

---

## 📊 Key Insights

* Previous inpatient utilization showed a clear association with higher observed 30-day readmission rates.
* Diabetes and injury categories showed relatively higher observed readmission rates among the diagnosis groups analyzed.
* Emergency and urgent admissions showed slightly higher observed readmission rates than elective admissions.
* Readmission rates varied across age groups and discharge disposition categories.
* Small groups with very few encounters can produce unstable percentages and should be interpreted carefully.

> **Note:** These findings describe associations in the dataset and do not establish that any factor directly causes readmission.

---

## 💡 Skills Demonstrated

This project demonstrates practical skills in:

* SQL Server
* T-SQL
* Data Cleaning
* Data Validation
* Missing Data Analysis
* Data Quality Checks
* Exploratory Data Analysis
* Healthcare Data Analysis
* KPI Calculation
* Aggregation
* Data Categorization
* CTEs
* Subqueries
* Window Functions
* Business Insight Generation

---

## 🔮 Future Enhancement

The next phase of the project is to build a **Power BI dashboard** using the SQL analysis to provide interactive views of:

* 30-Day Readmission Rate
* Readmission by Admission Type
* Readmission by Age Group
* Readmission by Diagnosis
* Previous Inpatient Visits
* Discharge Disposition
* Overall Readmission Distribution

---

## 👤 Author

**Thrishin R**

Data Analyst | SQL | Excel | Power BI | Data Quality | Business Intelligence
