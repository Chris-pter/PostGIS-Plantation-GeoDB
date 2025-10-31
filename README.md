# Plantation-PostGIS-Geodatabase
This repository documents the development of an **enterprise geodatabase** for managing 12 oil palm estates (~50,000 ha total) located in Sarawak (Miri and Bintulu regions).
The project was built in **PostgresSQL/PostGIS**, following standardized naming conventions, schema design, and controlled access for collaborative GIS workflows.

## Project Structure Overview

The company manages **12 estates** each represented as a **separate schema** within central database called (`estate_db`).
Each estate schema contains four core spatial layers:
- `boundary` -overall estate boundary
- `division` -administrative division within estate
- `section` -subdivision under each division 
- `block` -smallest management unit (field/planting area)

* **Master Schema**: master-consolidate data from all estate schemas for regional analysis

Additional datasets (e.g., `palm_stand`, `road`, `building`) will be ingested progressively

## Database Architecture
```
estate_db (PostgreSQL Database)
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
    ├── vw_block_all         ← OLAP-style combined block view  
    └── other analytical views
```
### Data Management Design
OLTP & OLAP Use:
* OLTP (Operational): Used at the estate schema level for updates, edits and version control.
* OLAP (Analytical): Implemented in the master schema via SQL views for multi-estate/stakeholder overview.

## Geodatabase ERD Design
<img src=''>

## Data Ingestion Workflow
1. **Source Data**: Geopackage (.gpkg) from field mapping/drone data/surveys.
2. **Standardization** : Unified column names, data types, and SRID.
3. **Validation**: Check geometry types, validity, and spatial integrity.
4. **Ingestion**: Imported via **QGIS**-"Export to PostgresSQL" tool.
5. **Storage**: Each estate → its own schema; SRID EPSG:32650 (UTM Zone 50N) / EPSG:32649 (UTM Zone 49N).

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

## Foreign Key Constraints and Relationships
Each schema follows a top-down hierarchical model, where each layer is linked through unique IDs and foreign key constraints to ensure referential integrity.

### Entity Relationships
```
boundary (1) ──< division (many)
division (1) ──< section (many)
section  (1) ──< block   (many)
block    (1) ──< palm_stand (many) [planned]
```

## Problem Statement: Why This Geodatabase Was developed
Previously, spatial data for estate management has traditionally been handled using **GeoPackage (.gpkg)** files e.g.-division.gpkg, section.gpkg.
Each .gpkg file contained consolidated spatial layers for every estate, a convienient "plug-and-play" solution that we could copy and use in QGIS.

While this approach worked for quick map production, it introduced several isues over time:

1. **🧩Lack of attribute standardization**:

   The attribute tables were edited ad-hoc depending on mapping or reporting needs. Columns differed between estates, and there was no consistent field naming convention or data type control.
   
2. **🗃️No centralized control**:

   Because files were "drag-and-drop" and edited individually, it became difficult to track the most recent or authoritative version of a dataset.
   
3. **💾Inefficient storage and duplications**:

   Large, redundant GeoPackage files were duplicated across user machines, wasting storage and complicating backup processes.

4. **🚫 No Access or version control**:

   Everyone could edit any dataset, which  increased the risk of accidental data loss or overwrite.

To modernize this workflow, this project introduces a **Postgres/PostGIS Extension enabled enterprise geodatabase** - a centralized, scalable, and version-controlled system that ensures:

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





