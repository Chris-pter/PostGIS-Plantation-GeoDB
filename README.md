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
Master Schema: master-consolidate data from all estate schemas for regional analysis

Additional datasets (e.g., `palm_stand`, `road`, `building`, `ramp`) will be ingested progressively

##Database architecture
```
estate_db (PostgreSQL Database)
│
├── samarakan (Schema)
│   ├── boundary
│   ├── division
│   ├── section
│   └── block
│
├── beluru (Schema)
│   ├── boundary
│   ├── division
│   ├── section
│   └── block
│
├── drian (Schema)
│   ├── boundary
│   ├── division
│   ├── section
│   └── block
│
├── ... (Other 9 estate schemas)
│
└── master (Schema)
    ├── vw_block_all         ← OLAP-style combined block view  
    ├── vw_section_all       ← Combined section view  
    ├── vw_flightplan        ← Combined flight area view  
    └── other analytical views



    
