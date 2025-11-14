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
