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

### 3.Create schema(s) and set up roles
