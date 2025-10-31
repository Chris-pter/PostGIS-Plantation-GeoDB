# Plantation-PostGIS-Geodatabase
A centralized PostGIS geodatabase designed for plantation spatial data storage and OLTP workflows, supporting efficient management of planted areas, infrastructure, and natural resources

## Overview

Each estate is stored as a separate schema inside a single database (`estate_db`), containing:
- `boundary`
- `division`
- `section`
- `block`

Additional datasets (e.g., `palm_stand`, `road`, `building`, `ramp`) will be ingested progressively
