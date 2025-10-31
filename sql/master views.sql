+=====================================================================================================+
--Purpose: Create master view combining all estate block layers

--Decsription:
  --This script demonstrates how to consolidate multiple estate polygon layers (blocks) from different
  --schemas into a single master view for analysis in GIS-environment

  --Each estate is represented as its own schema in the database, and each schema contains standardized
  --tables (boundary, division, section, block)
+=====================================================================================================+
  
/*
Adding ROW_NUMBER() OVER()
-----------------------------------------------------
-- Each estate's GeoPackage was created independently, meaning the fid or block_id(PK) values often restart at 1.
-- When combining them into a single view, duplicate primary keys would cause confusion or break QGIS layer linking.
-- ROW_NUMBER() OVER() creates a unique running ID for each feature in the combined dataset.
-- This makes view GIS-friendly, every feature has its own unique identifier, even if block IDs overlap.
*/

--Create master schema
CREATE SCHEMA IF NOT EXISTS master;

--Create unified block view
CREATE OR REPLACE VIEW master.unified_block AS
SELECT
    ROW_NUMBER() OVER () AS qgis_fid, -- Generate a unique IDs for QGIS use.
    t.estate_label,                   
    t.estate_name,
    t.section_number,
    t.area_ha,
    t.geom
FROM (
    -- Estate 1
    SELECT
        'Estate_1'::text AS estate_label,
        f.estate_name,
        f.section_number,
        f.area_ha,
        f.geom::geometry(MultiPolygon, 32650) AS geom
    FROM estate_1.block AS f

    UNION ALL

    -- Estate 2
    SELECT
        'Estate_2'::text AS estate_label,
        f.estate_name,
        f.section_number,
        f.area_ha,
        f.geom::geometry(MultiPolygon, 32650) AS geom
    FROM estate_2.block AS f
  
      -- 🟢 Add more estates below as needed:
    -- UNION ALL
    -- SELECT
    --     'Baram_Estate'::text AS estate_label,
    --     f.estate_name,
    --     f.section_number,
    --     f.area_ha,
    --     f.geom::geometry(MultiPolygon, 32650) AS geom
    -- FROM baram_estate.block AS f
) AS t;
