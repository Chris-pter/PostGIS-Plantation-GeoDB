+=========================================================+
-Project: Estate Geodatabase (PostgresSQL/PostGIS)
-Purpose: Prepare estate schemas for Geopackage ingestion
+=========================================================+

/*
NOTE ON WORKFLOW
----------------------------------------------------------------------------
  * Each estate has its own dedicated schema.
  * The spatial tables-boundary, division, section, block- are not created manually here.
  * Instead, they are ingested/iploaded directly from standardized GeoPackage (.gpkg) files
    using QGIS → Database → Export to PostgreSQL/PostGIS.
*/
  
--Create schemas for each estate

--1. Create schema one-by-one (progressively)
CREATE SCHEMA IF NOT EXISTS estate_name_1;
CREATE SCHEMA IF NOT EXISTS estate_name_2;

--2. Create all schema using loops

DO $$
DECLARE
  estate TEXT;
  estates TEXT[]:= ARRAY[
    'estate_name_1', 'estate_name_2', 'estate_name_3'--Add more schema names here
    ];
BEGIN
  FOREACH estate IN ARRAY estates
  LOOP
      EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I;', estate);
  END LOOP;
END $$;
