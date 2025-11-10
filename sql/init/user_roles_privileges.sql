+=============================================================================================+
--user roles and privileges control who can access or modify your database, schemas, & tables
+=============================================================================================+

--Create GIS/users
CREATE ROLE gis_user_1 WITH LOGIN PASSWORD 'securepassword';

--Database privileges
GRANT CONNECT ON DATABASE plantation_db to gis_user_1;

--Database privileges
GRANT USAGE ON SCHEMA schema_1, schema_2, schema_3 TO gis_user_1;
GRANT CREATE ON SCHEMA schema_1, schema_2, schema_3 TO gis_user_1;

--Table Privileges (read-only)
GRANT SELECT ON ALL TABLES IN SCHEMA schema_1, schema_2, schema_3 TO gis_user_1;
