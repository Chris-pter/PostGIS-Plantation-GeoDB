+==========================================+
  --CREATE THE MAIN PLANTATION DATABASE--
+==========================================+
--Window locale settings
--Adjust the database name and owner as needed

CREATE DATABASE plantation_db/estate_db
WITH
  OWNER = postgres    --change to your preferred DB user
  ENCODING = 'UTF8'
  LC_COLLATE = 'English_United_States.1252'
  LC_CTYPE = 'English_United_States.1252'
  LOCALE_PROVIDER = 'libc'
  TABLESPACE = pg_default
  CONNECTION LIMIT = -1
  IS_TEMPLATE = FALSE;
