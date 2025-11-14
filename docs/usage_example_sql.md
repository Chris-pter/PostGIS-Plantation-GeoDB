# Geodatabase Usage Examples: Plantation Block Layer Settings
This document provides a simple and practical SQL queries for retrieving and reporting essential information from the centralized PostGIS geodatabase, specifically focusing on the *'block'* layer.

### Raw Sample Data
For a direct, downloadable sample of the non-spatial attribute data used this example, please refer to the included .csv file: **[example_block](/docs)**

## Practical Data Retrieving

### Basic Data Retrieval
These are simple operation queries used for validation and quick map production.

**Select ALL Data** | Retrieve all columns and all rows for the block layer in a specific estate schema |

SELECT 
  * 
FROM
  estate_name.estate_block;
