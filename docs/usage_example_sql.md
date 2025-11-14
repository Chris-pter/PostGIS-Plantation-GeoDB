# Geodatabase Usage Examples: Plantation Block Layer Settings
This document provides a simple and practical SQL queries for retrieving and reporting essential information from the centralized PostGIS geodatabase, specifically focusing on the *'block'* layer.

### Raw Sample Data
For a direct, downloadable sample of the non-spatial attribute data used this example, please refer to the included .csv file: **[example_block](/docs)**

## Practical Data Retrieving

### Basic Data Retrieval
These are simple operation queries used for validation and quick map production.

**Select ALL Data** | Retrieve all columns and all rows for the block layer in a specific estate schema |
```sql
SELECT * FROM estate_name.estate_block;
```
or 

### Selective Query by Attribute
Pull data for a specific plantation vintage

**Selective Data Retrieval** | Select all blocks planted in 2015 from a specific estate schema, retrieving only key columns |
```sql
SELECT
 block_id,
 block_number,
 area_ha,
 planted_year
FROM
 estate_name.estate_block
WHERE
 planted_year = 2015;
```

**Numerical Attribute Filtering** | Uses the WHERE clause with the condition area_ha that are greater or equal than 5 hactare to filter the dataset numerically |
```sql
SELECT
 block_id,
 block_number,
 area_ha,
 planted_year
FROM
 estate_name.estate_block
WHERE
 area_ha >= 5
ORDER BY block_number ASC/DESC
```
---

### Simple Aggregation

**Basic Summation** | The SUM() function is used to calculate the grand total of all values in the area_ha column across the entire table |
```sql
SELECT
 SUM(area_ha) AS total_area
FROM
 estate_name.estate_block;
```

**Grouping & Summation** | This function calculates the total count of palm stands, and the GROUP BY planted year clause breaks this into separate totals for each planting vintage. This output is essential for creating the estate's crucial age profile report |
```sql
SELECT
    planted_year,
    SUM(palm_stand) AS total_palm_stand_count
FROM
    estate_name.estate_block
WHERE
    planted_year IS NOT NULL
GROUP BY
    planted_year
ORDER BY
    planted_year DESC;
```

**Filtering Aggregated Data** | Uses the HAVING clause to filter the results after the data has been grouped. The condition "HAVING SUM(palm_stand) > 35000 ensures that only those administrative sections that contain a significant high number of palms are included in the final report, allowing management to focus analysis on the largest operational areas |
```sql
SELECT
    section_id,
    SUM(palm_stand) AS total_palm_stand_count
FROM
    estate_name.estate_block
WHERE
    palm_stand IS NOT NULL 
GROUP BY
    section_id
HAVING
    SUM(palm_stand) > 35000
ORDER BY
    total_palm_stand_count DESC;
```

---

## OLAP & Master View Examples
These queries utilize the centralized master schema views to perform essential cross-estate reporting and analysis.

1. Basic Master View Selection
- Simplest wat to check that data from all estates is successfully aggregated and view the unified schema.

**Unified Data Structure** | This query performs a simple SELECT to confirm that the master view schema successfully combines data from all underlying estate schemas into one table. The LIMIT 10 clause is used to quickly inspect the structure without fetching the entire massive dataset.
```sql
SELECT
 estate_name,
 section_id,
 block_number,
 area_ha
FROM
 master.schema_name
LIMIT 10;
```

2. Basic Cross-Estate Count
- This is a simple audit query to quickly verify the total number of records across the entire geodatabase.

**Total Record Audit** | Uses COUNT() aggregate function on the master View to provide the definitive, total number of records in the geodatabase. Crucial, high-level metric used for data quality checks and reporting inventory size |
```sql
SELECT
 COUNT(block_id) AS total_blocks_in_company
FROM
 master.schema_name;
```

3. Estate Area Snapshot Query
- This is a simple audit report to quickly verify the total area and block count contributed by each esate in the company.
**Area Audit** | This query groups total area by the estate_name and used to track the area of each estates's total reported area over time.
```sql
SELECT
    estate_name,
    SUM(area_ha) AS total_area_contribution_ha,
    COUNT(block_id) AS total_blocks_in_estate
FROM
    master.schema_name
WHERE
    area_ha > 0
GROUP BY
    estate_name
ORDER BY
    total_area_contribution_ha DESC;
```


