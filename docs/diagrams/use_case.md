# FCSMS — Use Case Diagrams

**Version:** 1.0  
**Project:** Forqani Computer Store Management System

Mermaid flowcharts provide UML-inspired use case views. Actual operation permissions follow the SRS.

| Actor | Responsibilities |
|---|---|
| Administrator | Users, authorization, configuration and auditing |
| Manager | Business operations, financial management and approvals |
| Sales Staff | Customers, sales, invoices and permitted payments |
| Inventory Staff | Products, purchasing and stock management |

Technicians are employee records; no separate technician login role is introduced.

## 1. Administrative use cases

```mermaid
flowchart LR
    A[Administrator]
    subgraph FCSMS
        U1([Login and logout])
        U2([Manage users])
        U3([Manage employees])
        U4([Configure permissions])
        U5([Manage currencies])
        U6([Review audit logs])
        U7([Manage system configuration])
    end
    A --> U1
    A --> U2
    A --> U3
    A --> U4
    A --> U5
    A --> U6
    A --> U7
```

## 2. Sales and purchasing use cases

```mermaid
flowchart LR
    S[Sales Staff]
    I[Inventory Staff]
    M[Manager]
    subgraph Sales
        S1([Manage customers])
        S2([Record sales])
        S3([Generate invoices])
        S4([Record permitted payments])
        S5([Verify warranty])
    end
    subgraph Purchasing
        P1([Manage suppliers])
        P2([Record purchases])
        P3([Manage products])
        P4([Monitor inventory])
    end
    S --> S1
    S --> S2
    S --> S3
    S --> S4
    S --> S5
    I --> P1
    I --> P2
    I --> P3
    I --> P4
    M --> S2
    M --> P2
    M --> P4
```

## 3. Financial management use cases

```mermaid
flowchart LR
    M[Manager]
    A[Administrator]
    subgraph Finance
        F1([Manage financial accounts])
        F2([Manage payments])
        F3([Manage receivables])
        F4([Manage payables])
        F5([Manage loans])
        F6([Record loan repayments])
        F7([Transfer funds])
        F8([Exchange currencies])
        F9([View ledger transactions])
        F10([Generate financial reports])
    end
    M --> F1
    M --> F2
    M --> F3
    M --> F4
    M --> F5
    M --> F6
    M --> F7
    M --> F8
    M --> F9
    M --> F10
    A --> F1
    A --> F9
    A --> F10
```

## 4. After-sales service use cases

```mermaid
flowchart LR
    M[Manager]
    S[Authorized Sales Staff]
    I[Authorized Inventory Staff]
    subgraph Services
        U1([Process customer returns])
        U2([Verify warranties])
        U3([Register repair cases])
        U4([Assign technicians])
        U5([Update repair history])
        U6([Manage defective stock])
        U7([Process supplier returns])
        U8([Approve repair settlements])
    end
    S --> U1
    S --> U2
    S --> U3
    I --> U5
    I --> U6
    I --> U7
    M --> U4
    M --> U7
    M --> U8
```
