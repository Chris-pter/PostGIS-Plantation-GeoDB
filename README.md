# PostGIS-Plantation GeoDB
<p align=justify>
This repository documents the development of an enterprise geodatabase for managing 12 oil palm estates (~52,000 ha total) located in Sarawak (Miri and Bintulu regions).
The project was built in PostgreSQL/PostGIS, following standardized naming conventions, schema design, and controlled access for collaborative GIS workflows.
</p>

As an aspiring Geodata Engineer, this project demonstrates my practical learning in spatial database development/modeling, ETL pipeline design, and implementing data governance within PostGIS.

## 📌 Project Structure Overview

The company manages **12 estates** each represented as a **separate schema** within central database called (`estate_db`).
Oil palm plantation contain multiple hierarchical spatial layer (boundary → division → section → block). Traditionally these layers are stored as separate GeoPackage (.gpkg) files, standalone folders in a shared server files.

This repository demonstrates how these core plantation layers can be structured into a unified relational geodatabase using PostGIS. This enables:

- controlled foreign key relationship.
- consistent spatial reference.
- cross-estate integration.
- easier reporting & analysis.

Additional datasets (e.g., `palm_stand`, `road`, `building`) will be ingested progressively.

## 🛠️ Tools & Technology Used
* **[PostgreSQL 16.4 + PostGIS 3](https://www.postgresql.org/)** - Spatial database engine
*  **[QGIS 3.44.3](https://qgis.org/download/)** - visualization, data transformation and data ingestion
*  **[pgAdmin 4](https://www.postgresql.org/)** - Database management GUI
*  **[Draw.io](https://www.drawio.com/)** - ERD design & schema sketching
*  **GitHub** - project documentation

## 🧩 Database Initialization
To prepare the PostGIS database, you must run the scripts located in the `sql/init/` directory in the following sequence:
1. [Create Database](sql/init/00_create_db.sql): Sets up the initial database environment.
2. [Enable PostGIS Extension](sql/init/01_enable_postgis.sql): Enables the PostGIS extension.
3. [Create Schemas](sql/init/02_create_schema.sql): Defines the logical structure and namespace for your tables and objects.
4. [Create Roles](sql/init/03_user_roles_privileges.sql): Establishes user roles and assigns neccessary access permission.

## 🔗 Sequence Workflow
This project follows a simple PostGIS setup flow: create database → enable PostGIS → create schemas → create spatial tables → load data → connect to GIS tools.

To keep this README short, the full detailed explanation is moved to a separate page.
Refer to: [sequence workflow](docs/sequence_workflow.md)
 for full breakdown of each step.

## ⚙️ Geodatabase Design & Modeling

### Hierarchical Plantation Schema
<p align=center>
<img src='/docs/erd_geodatabase.jpg' width=600>
</p>

**Description:** This model enforces a strictly hierarchical structure, following the plantation's administrative organization (Boundary, Division, Section, Block).
One-to-many (1:N) Foreign key constraints are used to link lower-level units to their unique parent, ensuring high data integrity (normalization) for core administrative layers.

### Entity Relationships
```
boundary (1) ──< division (many)
division (1) ──< section (many)
section  (1) ──< block   (many)
block    (1) ──< palm_stand (many) [planned]
```

##

### Cross-Estate Master View Architecture
<p align=center>
<img src='/docs/cross estate_master schema ERD.jpg' width="900">
</p>

**Description:** This model illustrates the consolidation model used for wide reporting. The central master schema aggregates data from all 12 operational estates schemas using read-only **SQL Views**.
These views use the **UNION ALL** operation to seamlessly combine identical tables, providing a single, unified dataset fast/wide analysis without duplicating the underlying operational data.

### Master Views
The defined views, which are essential for the application's reporting and data access layer, are located here:
* [Master Views SQL](sql/views/estate_summary.sql)

---

## 🏗️ Database Architecture & Schema Structure

The database is implemented using a multi-schema, two-tier architecture to achieve strict separation between operational data integrity and centralized analytical reporting. The central database (`estate_db`) is
logically divided into 13 schemas: 12 individual estate schemas for daily operations and one dedicated master schema for wide analysis/fast map production.


```
estate_db
│
├── estate_1 (Schema)
│   ├── boundary
│   ├── division
│   ├── section
│   └── block
│
├── ... (Other 11 estate schemas)
│
└── master (Schema)
    ├── sql_view_block_all  
    └── other analytical views
```

### Schema Design Summary Table
The table below provides a structured overview of the core spatial layers within each schema. Each layer represents a hierarchical administrative level in the plantation, with clearly defined geometry types, primary keys, and foreign key relationships to enforce data integrity across the estate hierarchy. Spatial reference systems are standardized to **EPSG: 32650** or **EPSG: 32649**, depending on the estate's regional location, ensuring spatial consistency and seamless integration across all estates through master schema views.
| Table Name | Geometry Type | Primary Key | Foreign Key | SRID | Description |
|-------------|----------------|--------------|--------------|-------|--------------|
| `boundary` | Polygon | `estate_id` | — | 32650/32649 | Overall estate boundary |
| `division` | Polygon | `division_id` | `estate_id` | 32650/32649 | Administrative division |
| `section` | Polygon | `section_id` | `division_id` | 32650/32649 | Subdivision under a division |
| `block` | Polygon | `block_id` | `section_id` | 32650/32649 | Smallest management unit |

➡️ See [Layer Hierarchy and Design Rationale](docs/layer_hierarchy_and_design_rationale.md) for a detailed explanation of how boundary, division, section and block layers are structured and how they support data integrity and ETL workflows.

### Data Management Design
OLTP & OLAP Use:
* OLTP (Operational): These 12 schemas function as the **Online Transaction Processing** environment. They hold definitive, authoritative data for each estate, enabling local edits, updates, and version control.
* OLAP (Analytical): This central schema serves as the **Online Analytical Processing** environment. It contains no physical tables of its own, relying instead on read-only **SQL Views** that aggregate data from all
  12 operational schemas. This provides a single, secure source for multi-estate reporting and spatial analysis.

  e.g., Query the total planting area of the entire estates instantly and accurately, without opening 12 files.
  ```
  Reporting/Aggregation
          SELECT SUM(ST_AREA(geom)/10000) AS
          total_ha FROM
          master.sql_view_block_all;
    ```
---

## 🔧 Data Ingestion Workflow

<p align=center>
<img src='/docs/data_ingestion_workflow.jpg' width="900">
</p>

### ETL Workflow
This project applies a geospatial ETL pipeline to migrate raw estate mapping datasets into a unified PostGIS enterprise database structure.

**Extract**
* Raw data input from `.gpkg`, `.shp`, `.csv`, drone mapping outputs, and survey sources.

**Transform**
* Standardize field names (snake_case) and data types.
* Normalize SRID to **EPSG:32650/32649**.
* Validate geometry integrity and remove non-standard columns.
* Attribute standardization via QGIS Field Calculator: Use QGIS to enforce relational integrity, such as assigning parent IDs (section_id in the block layer) based on spatial relationships. For instance, calculate "section_id" using conditional logic to match blocks     to their parent sections:
  ```
  CASE
      WHEN "section_id" = 1 THEN 1
      WHEN "section_id" = 2 THEN 2
     --Additional condition as needed-- 
    ELSE NULL
  END
  ```
  - This ensures hierarchical links are correctly set before ingestion, preventing orphaned records and maintaining the 1:N relationships in the schema.
  - Please consult the dedicated documentation: **[QGIS Attribute Standardization](docs/attribute_standardization.md)**

**Load**
* Ingest cleaned layers into the respective estate schemas via QGIS *Export to PostgreSQL*.
* Master schema then generates **SQL Views** for cross-estate reporting.

This ETL framework ensures consistent structure, spatial integrity, and Single Source of Truth (SSOT) across all 12 estates.

---
## ⚠️ Problem Statement
### Why This Geodatabase Was Developed
Previously, spatial data for estate management has traditionally been handled using **GeoPackage (.gpkg)** files e.g., division.gpkg, section.gpkg.
Each .gpkg file contained consolidated spatial layers for every estate, a convenient "plug-and-play" solution that we could copy and use in QGIS.

While this approach worked for quick map production, it introduced several issues over time:

1. **🧩Lack of attribute standardization**:

   The attribute tables were edited ad-hoc depending on mapping or reporting needs. Columns differed between estates, and there was no consistent field naming convention or data type control.
   
2. **🗃️No centralized control**:

   Because files were "drag-and-drop" and edited individually, it became difficult to track the most recent or authoritative version of a dataset.
   
3. **💾Inefficient storage and duplications**:

   Large, redundant GeoPackage files were duplicated across user machines, wasting storage and complicating backup processes.

4. **🚫 No Access or version control**:

   Everyone could edit any dataset, which  increased the risk of accidental data loss or overwrite.

To modernize this workflow, this project introduces a **PostgreSQL/PostGIS extension enabled enterprise geodatabase** - a centralized, scalable, and version-controlled system that ensures:

* One **authoritative data source** for all 12 estates.
* Standardized attribute schema and SRID across all layers.
* Role-based access control, separating editors from viewers.
* Integration-ready structure for advanced analysis and GIS connectivity.

Shifting from manual, file-based data handling towards a modern, spatially enabled data management system designed for accuracy, collaboration, and long-term usability

## ✅ Lessons Learned

* Migrating from GeoPackage to PostGIS improved data integrity and collaboration.
* Consistent SRID, schema naming, and geometry type reduce integration errors.
* Multi-user QGIS + PostGIS workflows eliminate redundant files.
* Separating OLTP (operational) and OLAP (analytical) schemas supports scalable spatial analysis.
* Establishing a Single Source of Truth (SSOT) ensures reliable, unified geospatial data for decision-making.

## Related Project: Drone Flight Plan Database [gis_flightplan_db]
To further streamline operations and leverage the new database architecture, a related project was initiated to manage drone flight planning assets efficiently. This project directly addresses the manual, repetative process of generating buffered vector data for drone pilots.

**Project Goal:** Establish a centralized repository for standardized flight planning resources, allowing drone pilots and GIS team to retrieve current and historical buffered flight sections instanly without manual processing. This eliminates duplicated effort and ensures all flight data is based in the single, authoritative geometry (SSOT).

**Result:** Drone pilots can instantly pull the correct .gpkg, easily convert it to **KML/KMZ** fortmat, and upload it for immediate mission execution on DJI drone remotes.



