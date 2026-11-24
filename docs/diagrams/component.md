# FCSMS — Component Diagram

**Version:** 1.0  
**Project:** Forqani Computer Store Management System

The modular layered architecture separates presentation, controllers, domain services and Oracle data access. These are logical components rather than confirmed source-code modules.

## 1. Application components

```mermaid
flowchart TB
    U[System Users]
    subgraph Presentation
        UI[HTML and CSS]
        J[Jinja2 Templates]
    end
    subgraph Controller
        R[Flask Routes]
        A[Authentication and Authorization]
    end
    subgraph Business_Logic
        C[Catalog Service]
        I[Inventory Service]
        P[Purchase Service]
        S[Sales Service]
        F[Financial Services]
        W[Warranty Service]
        RP[Repair Service]
        RT[Return Services]
        CR[Currency Service]
        RE[Reporting Service]
    end
    subgraph Data_Access
        REP[Repositories]
        CON[Oracle Connection]
    end
    DB[(Oracle Database)]
    U --> UI
    UI --> J
    J <--> R
    R --> A
    R --> C
    R --> I
    R --> P
    R --> S
    R --> F
    R --> W
    R --> RP
    R --> RT
    R --> CR
    R --> RE
    C --> REP
    I --> REP
    P --> REP
    S --> REP
    F --> REP
    W --> REP
    RP --> REP
    RT --> REP
    CR --> REP
    RE --> REP
    REP --> CON
    CON <--> DB
```
