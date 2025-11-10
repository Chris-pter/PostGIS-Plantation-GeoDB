+============================================+
--Enable PostGIS extensions in the database
+============================================+

--Main PostGIS extension
CREATE EXTENSION IF NOT EXISTS postgis;

--Verify installed extension (optional)
SELECT * FROM pg_extension;
