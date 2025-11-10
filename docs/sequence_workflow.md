## **Sequence of Operations**

### 1. Install PostgreSQL + PostGIS
  - Install PostgreSQL on your server/PC or workstation.
  - Install the PostGIS extension so that spatial types/functions are available.
  - Ensure you have a database superuser or equivalent rights.

### 2. Create the database
  - Create a new database (e.g., plantation_db).
  - Connect to that database.
  - Within that database, create the PostGIS extension:

    ```
    sql
    CREATE EXTENSION postgis;
    ```
  - At this point you have a spatially enabled database.

### 3. Create schema(s) and set up roles/users
  - Decide on a schema structure (e.g., public, infrastructure, plantation. etc).
  - Create roles/users who will load data or who will query the data.
  - Assign privileges to protect and control data access.

### 4. Define data model/create tables (schema creation)
  - Within your choosen schemas, create or load tables for the concepts you need (e.g., block, division, road, etc.).
  - Each geometry field is created with the correct type (Polygon/LineString/Point) and correct SRID.
  - Make sure to define non-spatial tables (attributes) and foreign key relationships as needed.

### 5. Prepare source data in QGIS
  - All raw layers first processed in QGIS.
  - Standardize the attribute fields (naming convention, data types, primary key column) inside the GeoPackage before loading).

### 6. Load data into PostgreSQL 
  - Once standardize, the .gpkg layers are exported into PostgreSQL using QGIS *"Export to PostgresQL"* tool.
  - Data is now centralized inside the database.

### 7. Connect to GIS
  - Connect QGIS to PostGIS, or any other downstream applications.
  - Spatial queries, analysis, and reporting are executed either from the downstream applications or from the central database. 

