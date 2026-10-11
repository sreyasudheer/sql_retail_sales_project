# 🛒 SQL Retail Sales Analysis

An end-to-end SQL project that takes a raw retail transactions dataset through **data cleaning**, **exploratory data analysis (EDA)**, and **business-question analysis** using PostgreSQL.

---

## 📌 Project Overview

| Item | Details |
|------|---------|
| **Database** | PostgreSQL |
| **Raw records** | 2,000 transactions |
| **Clean records** | 1,997 transactions |
| **Categories** | Clothing, Beauty, Electronics |
| **Period covered** | 2022 – 2023 |

**Goals**
- Build a clean, analysis-ready table from messy raw data
- Explore the dataset (sales, customers, categories)
- Answer practical business questions with SQL

---

## 📂 Repository Structure

```
├── sql_retail_sales_project.sql          # Full SQL script (create, clean, EDA, analysis)
├── SQL_-_Retail_Sales_Analysis_utf_.csv  # Raw dataset (2,000 rows)
├── Cleaned_retail_sales_data.csv         # Cleaned output (1,997 rows)
└── README.md
```

---

## 🗃️ Dataset Schema

| Column | Type | Description |
|--------|------|-------------|
| `transactions_id` | INT (PK) | Unique transaction ID |
| `sale_date` | DATE | Date of sale |
| `sale_time` | TIME | Time of sale |
| `customer_id` | INT | Customer identifier |
| `gender` | VARCHAR(15) | Customer gender |
| `age` | INT | Customer age |
| `category` | VARCHAR(15) | Product category |
| `quantiy` | INT | Units sold *(column name spelled as in the source data)* |
| `price_per_unit` | FLOAT | Price of one unit |
| `cogs` | FLOAT | Cost of goods sold |
| `total_sale` | FLOAT | Total sale amount |

---

## 🧹 Data Cleaning

The raw data contained **10 missing `age` values** and **3 rows with missing `quantiy`, `price_per_unit`, `cogs` and `total_sale`**. The cleaning steps were:

1. **Check row count** and scan every column for `NULL` values.
2. **Delete unusable rows** – transactions with no quantity, price and total sale (3 rows removed).
3. **Impute missing ages** with the rounded average age of all customers.
4. **Check for duplicates** using `GROUP BY ... HAVING COUNT(*) > 1` and `ROW_NUMBER()` – none found.
5. **Standardize text** – `TRIM` + `INITCAP` on `gender` and `category`.
6. **Standardize date/time** – dates formatted as `DD-MM-YYYY`, times as `HH24:MI:SS`.
7. **Detect outliers** using the 3-standard-deviation rule on `total_sale` – none found.
8. **Create the final table** `retail_sales_clean_v1` with all of the above applied in one `CREATE TABLE AS SELECT`.

---

## 🔍 Exploratory Data Analysis

- Total number of transactions
- Total number of unique customers
- List and count of product categories

---

## 💡 Business Questions Answered

| # | Question | SQL Techniques |
|---|----------|----------------|
| 1 | All sales made on `05-11-2022` | `WHERE` |
| 2 | Clothing transactions with quantity ≥ 4 in Nov 2022 | `WHERE`, `LIKE`, `AND` |
| 3 | Total sales and order count per category | `GROUP BY`, `SUM`, `COUNT` |
| 4 | Average age of customers buying Beauty products | `AVG` |
| 5 | Transactions where `total_sale` > 1000 | `WHERE` |
| 6 | Number of transactions by gender in each category | `GROUP BY` (multiple columns) |
| 7 | Best-selling month (by average sale) in each year | CTE, `TO_DATE`, `EXTRACT`, `RANK() OVER (PARTITION BY ...)` |
| 8 | Top 5 customers by total sales | `ORDER BY`, `LIMIT` |
| 9 | Unique customers per category | `COUNT(DISTINCT ...)` |
| 10 | Orders by shift (Morning / Afternoon / Evening) | `CASE WHEN` |

### Example – Best month in each year

```sql
WITH monthly_sales AS (
    SELECT
        EXTRACT(YEAR  FROM TO_DATE(formatted_sales_date, 'DD-MM-YYYY')) AS sales_year,
        EXTRACT(MONTH FROM TO_DATE(formatted_sales_date, 'DD-MM-YYYY')) AS sales_month,
        AVG(total_sale) AS avg_sale
    FROM retail_sales_clean_v1
    GROUP BY 1, 2
)
SELECT *
FROM (
    SELECT sales_year, sales_month, avg_sale,
           RANK() OVER (PARTITION BY sales_year ORDER BY avg_sale DESC) AS sales_rank
    FROM monthly_sales
) ranked_sales
WHERE sales_rank = 1;
```

### Example – Orders by shift

```sql
SELECT *,
    CASE
        WHEN formatted_sales_time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN formatted_sales_time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
FROM retail_sales_clean_v1;
```

---

## 🚀 How to Run

1. Install **PostgreSQL** and open **pgAdmin** or `psql`.
2. Create a database, e.g. `retail_db`.
3. Run the `CREATE TABLE` section of `sql_retail_sales_project.sql`.
4. Import `SQL_-_Retail_Sales_Analysis_utf_.csv` into the `retail_sales` table.
5. Run the rest of the script in order: cleaning → clean table → EDA → business questions.

---

## 🛠️ Skills Demonstrated

- Data cleaning & validation (NULL handling, deduplication, standardization, outlier detection)
- Aggregations and grouping
- Date/time functions (`TO_CHAR`, `TO_DATE`, `EXTRACT`)
- Subqueries and CTEs
- Window functions (`ROW_NUMBER`, `RANK`)
- Conditional logic with `CASE`

---

## 📝 Notes

- The column name `quantiy` is a typo carried over from the source dataset and is kept consistently throughout the project.
- `ROW_NUMBER() ... ORDER BY ctid` is PostgreSQL-specific.

---

## 👤 Author

**Sreya Sudheer**
- GitHub: https://github.com/sreyasudheer
- LinkedIn: https://www.linkedin.com/in/sreya-sudheer-2623b7353

⭐ If you found this project useful, feel free to star the repo!
