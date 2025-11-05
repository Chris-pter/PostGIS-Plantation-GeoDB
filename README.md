# Plantation-PostGIS-Geodatabase
<p align=justify>
This repository documents the development of an enterprise geodatabase for managing 12 oil palm estates (~50,000 ha total) located in Sarawak (Miri and Bintulu regions).
The project was built in PostgreSQL/PostGIS, following standardized naming conventions, schema design, and controlled access for collaborative GIS workflows.
</p>

As an aspiring Geodata Engineer, this project demonstrates my practical learning in spatial database modeling, ETL pipeline design, and implementing data governance within PostGIS.

## Project Structure Overview

The company manages **12 estates** each represented as a **separate schema** within central database called (`estate_db`).
Each estate schema contains four core spatial layers:
- `boundary` -overall estate boundary
- `division` -administrative division within estate
- `section` -subdivision under each division 
- `block` -smallest management unit (field/planting area)

* **Master Schema**: master-consolidate data from all estate schemas for regional analysis

Additional datasets (e.g., `palm_stand`, `road`, `building`) will be ingested progressively

## Tools & Technology Used
* **PostgreSQL 16.4 + PostGIS 3**- Spatial database engine
*  **QGIS 3.44.3** -visualization, data transformation and data ingestion
*  **pgAdmin 4** -Database management GUI
*  **Draw.io** -ERD design & schema sketching
*  **GitHub** -project documentation

## Geodatabase Design & Modeling

### Hierarchical Plantation Schema
<p align=center>
<img src='/docs/ERD Geodatabase.jpg' width=600>
</p>

**Description:** This model enforces a strictly hierarchical structure, following the plantation's administrative organization (Boundary, Division, Section, Block).
One-to-many (1:N) Foreign key constraints are used to link lower-level units to their unique parent, ensuring high data integrity (normalization) for core administrative layers.

#### Entity Relationships
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

**Description:** This model illustrates the consolidation model used for wide reporting. The central master schema aggregates data from all 12 operational estates schemas using read-only **SQL View***.
These views uses the **UNION ALL** operation to seamlessly combine identical tables, providing a single, unified dataset fast/wide analysis without duplicating the underlying operational data.

---

## Database Architecture & Schema Structure

The database is implemented using a multi-schema, two tier architecture to achieve strict separation between operational data integrity and centralized analytical reporting. The central database (`estate_db`) is
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

### Data Management Design
OLTP & OLAP Use:
* OLTP (Operational): These 12 schemas function as the **Online Transaction Processing** environment. They hold definitive, authoritative data for each estate, enabling local edits, updates, and version control.
* OLAP (Analytical): This central schema serves as the **Online Analytical Processing** environment. It contains no physical tables of its own, relying instead on read-only **SQL Views** that aggregate data from all
  12 operational schemas. This provides a single, secure source for multi-estate reporting and spatial analysis.

  e.g.,-Query the total planting area of the entire estates instantly and accurately, without opening 12 files.
  ```
  Reporting/Aggregation
          SELECT SUM(ST_AREA(geom)/10000) AS
          total_ha FROM
          master.sql_view_block_all;
    ```
---

## Data Ingestion Workflow

<p align=center>
<img src='/docs/Data Ingestion Workflow.jpg' width="900">
</p>

### ETL Workflow
This project applies a geospatial ETL pipeline to migrate raw estate mapping datasets into a unified PostGIS enterprise database structure.

**Extract**
* Raw data input from `.gpkg`, `.shp`, `.csv`, drone mapping outputs, and survey sources.

**Transform**
* Standardize field names (snake_case) and data types.
* Normalize SRID to **EPSG:32650/32649**.
* Validate geometry integrity and remove non-standard columns.

**Load**
* Ingest cleaned layers into the respective estate schemas via QGIS *Export to PostgreSQL*.
* Master schema then generates **SQL View** for cross-estate reporting.

This ETL framework ensures consistent structure, spatial integrity, and Single Source of Truth (SSOT) across all 12 estates.

---
### QGIS Ingestion 
<details>
<summary>Click to Expand: QGIS Pre-Ingestion Rules</summary>
Before importing data into PostGIS, the following standardization steps were applied:

1. **Field naming convention**  
   - Lowercase letters, underscores for separation (e.g., `section_no`, `area_ha`).  
   - Field names consistent across estates.

2. **Data type alignment**  
   - Ensured each field has the same type across all estates (text, numeric, integer).  
   - Removed extra or estate-specific columns.

3. **Coordinate reference system**  
   - All data projected to **EPSG:32650 (WGS 84 / UTM Zone 50N) / EPSG:32649 (WGS 84 / UTM Zone 49N)**.
</details>


### Naming Conventions
General Rules
* Use **snake_case** (lowercase, underscores).
* Avoid spaces, uppercase letters, or special characters.
* Keep names short, clear, and descriptive

## Problem Statement
### Why This Geodatabase Was Developed
Previously, spatial data for estate management has traditionally been handled using **GeoPackage (.gpkg)** files e.g.-division.gpkg, section.gpkg.
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

To modernize this workflow, this project introduces a **Postgres/PostGIS extension enabled enterprise geodatabase** - a centralized, scalable, and version-controlled system that ensures:

* One **authoritative data source** for all 12 estates.
* Standardized attribute schema and SRID across all layers.
* Role-based access control, separating editors from viewers.
* Integration-ready sturcture for advanced analysis and GIS connectivity.

-Shifting from manual, file-based data handling towards a modern, spatially enabled data management system. Designed for accuracy, collaboration, and long-term usability

## Lesson Learned

* Migrating from GeoPackage to PostGIS improved data integrity and collaboration.
* Consistent SRID, schema naming, and geometry type reduce integration errors.
* Multi-user QGIS + PostGIS workflows eliminate redundant files.
* Separating OLTP (operational) and OLAP (analytical) schemas supports scalable spatial analysis.
* Establishing a Single Source of Truth (SSOT) ensures reliable, unified geospatial data for decision-making.





