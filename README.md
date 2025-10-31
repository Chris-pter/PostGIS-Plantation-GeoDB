# Plantation-PostGIS-Geodatabase
This repository documents the development of an **enterprise geodatabase** for managing 12 oil palm estates (~50,000 ha total) located in Sarawak (Miri and Bintulu regions).
The project was built in **PostgresSQL/PostGIS**, following standardized naming conventions, schema design, andcontrolled access for collaborative GIS workflows.

## Overview

Each estate is stored as a separate schema inside a single database (`estate_db`), containing:
- `boundary`
- `division`
- `section`
- `block`

Additional datasets (e.g., `palm_stand`, `road`, `building`, `ramp`) will be ingested progressively
