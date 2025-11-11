## 🌳Attribute Standardization Deep Dive
This document details the mandatory attribute standardization applied to the four core hierarchical spatial layers: `boundary`, `division`, `section`, `block`, during the ETL process.
These standards ensures data integrity, query consistency, and aligmnent with established enterprise conventions.

### The core principles applied were:
1. **Naming Convention:** All column names are converted to *snake_case*.
2. **Data Type Consistency:** Field types are enforced (e.g., ID's are integers, areas are numeric).
3. **Spatial Reference:** All geometries are reprojected to the designated SRID for the specific estate (EPSG: 32650 or EPSG: 32649).

## Standardization by Layer
- Each layer follows a consistent attribute schema and maintains referential integrity through primary and foreign key relationships.

## 1. Boundary Layer

| Name| Data Type | Notes |
|-------------|----------------|--------------|
| `estate_id` | INT | Primary Key. Numeric ID for the estate. |
| `estate_name` | VARCHAR(50) | Full legal name of the estate. | 
| `area_ha` | NUMERIC(12,2) | Calculated: `round($area/10000,2)`.| 
| `geom` | Polygon | Standardized SRID (EPSG: 32650/32649). |

## 2. Division Layer

| Name| Data Type | Notes |
|-------------|----------------|--------------|
| `division_id` | INT | Primary Key. Numeric ID for division. |
| `estate_id` | INT | Foreign Key referencing boundary.estate_id. | 
| `division_number` | VARCHAR(50) | Unique code number for each division. | 
| `area_ha` | NUMERIC(12,2) | Calculated: `round($area/10000,2)`.| 
| `geom` | Polygon | Standardized SRID (EPSG: 32650/32649). |

## 3. Section Layer
| Name| Data Type | Notes |
|-------------|----------------|--------------|
| `section_id` | INT | Primary Key. Numeric ID for section layer. |
| `division_id` | INT | Foreign Key referencing boundary.division_id. | 
| `section_number` | VARCHAR(50) | Unique code number for each section. | 
| `area_ha` | NUMERIC(12,2) | Calculated: `round($area/10000,2)`.| 
| `geom` | Polygon | Standardized SRID (EPSG: 32650/32649). |

## 4. Block Layer
| Name| Data Type | Notes |
|-------------|----------------|--------------|
| `block_id` | INT | Primary Key. Numeric ID for block layer. |
| `section_id` | INT | Foreign Key referencing boundary.section_id. | 
| `block_number` | VARCHAR(50) | Unique code number for each block. | 
| `planted_year` | INT | Planted year for each block. | 
| `area_ha` | NUMERIC(12,2) | Calculated: `round($area/10000,2)`.| 
| `geom` | Polygon | Standardized SRID (EPSG: 32650/32649). |

## Summary
This standardization framework enforces consistent naming, spatial reference, and data types across all hierarchical layers, ensuring integrity and interoperability within the enterprise geodatabase.

