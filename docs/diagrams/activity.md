# FCSMS — Activity Diagrams

**Version:** 1.0  
**Project:** Forqani Computer Store Management System

These models describe business workflows. Each posting event must validate permissions and commit all relevant stock, financial and audit records atomically.

## 1. User authentication

```mermaid
flowchart TD
    A([Start]) --> B[Enter credentials]
    B --> C[Validate input]
    C --> D{Credentials valid?}
    D -->|No| E[Display error]
    E --> B
    D -->|Yes| F{Account active?}
    F -->|No| G[Reject access]
    F -->|Yes| H[Create session]
    H --> I[Load role permissions]
    I --> J[Open dashboard]
    J --> K([End])
    G --> K
```

## 2. Sales processing

```mermaid
flowchart TD
    A([Start]) --> B[Select customer and products]
    B --> C[Enter quantities]
    C --> D{Stock available?}
    D -->|No| E[Display stock error]
    E --> C
    D -->|Yes| F[Calculate invoice total]
    F --> G[Capture currency and rate]
    G --> H[Calculate warranty dates]
    H --> I[Select payment arrangement]
    I --> J{Outstanding amount?}
    J -->|Yes| K[Validate customer and due date]
    J -->|No| L[Validate settlement]
    K --> M[Post sale]
    L --> M
    M --> N[Update inventory]
    N --> O[Record stock movements]
    O --> P[Record financial movements]
    P --> Q{Transaction successful?}
    Q -->|No| R[Rollback]
    Q -->|Yes| S[Commit transaction]
    S --> T[Generate invoice]
    T --> U([End])
    R --> U
```

## 3. Purchase processing

```mermaid
flowchart TD
    A([Start]) --> B[Select supplier]
    B --> C[Enter purchased products]
    C --> D[Inspect and classify received quantities]
    D --> J[Calculate purchase amount]
    J --> K[Capture exchange rate]
    K --> L[Validate payment or payable]
    L --> V[Begin posting transaction]
    V --> H[Update sellable inventory]
    H --> I[Register defective stock if applicable]
    I --> M[Post ledger movements and actual payments]
    M --> N{All operations successful?}
    N -->|Yes| O[Commit transaction]
    N -->|No| P[Rollback]
    O --> Q([End])
    P --> Q
```

## 4. Customer return processing

```mermaid
flowchart TD
    A([Start]) --> B[Find original sale]
    B --> C[Select returned items]
    C --> D{Return valid?}
    D -->|No| E[Reject return]
    D -->|Yes| F[Inspect product condition]
    F --> G{Sellable?}
    G -->|Yes| H[Restore inventory]
    G -->|No| I[Register defective stock]
    H --> J[Calculate authorized return value]
    I --> J
    J --> K[Determine credit or refund]
    K --> L[Post financial adjustments]
    L --> M{Transaction successful?}
    M -->|Yes| N[Commit]
    M -->|No| O[Rollback]
    E --> P([End])
    N --> P
    O --> P
```

## 5. Supplier return processing

```mermaid
flowchart TD
    A([Start]) --> B[Find original purchase]
    B --> C[Select supplier return items]
    C --> D{Quantity and source valid?}
    D -->|No| E[Reject return]
    D -->|Yes| F{Stock source}
    F -->|Sellable| G[Reduce sellable inventory]
    F -->|Defective| H[Update defective custody]
    G --> I[Post dispatch and commit]
    H --> I
    I --> J[Record supplier resolution in separate transaction]
    J --> K{Resolution type}
    K -->|Refund| L[Record actual refund]
    K -->|Credit| M[Adjust supplier payable]
    K -->|Replacement| N[Inspect received products]
    K -->|Repair| N
    N --> O[Classify received stock]
    L --> P[Finalize resolution and commit]
    M --> P
    O --> P
    P --> Q([End])
    E --> Q
```

## 6. Repair processing

```mermaid
flowchart TD
    A([Start]) --> B[Register repair case]
    B --> C[Record reception history]
    C --> D[Inspect device]
    D --> E[Verify warranty]
    E --> F[Record diagnosis]
    F --> G{Repair possible?}
    G -->|No| H[Mark unrepairable]
    G -->|Yes| I[Obtain required approval]
    I --> J{Approved?}
    J -->|No| K[Cancel repair]
    J -->|Yes| L[Perform repair]
    L --> M[Test device]
    M --> N{Test successful?}
    N -->|No| L
    N -->|Yes| O[Mark repaired]
    O --> P{Ownership type}
    P -->|Store| Q[Approve stock restoration]
    P -->|Customer| R[Settle or record applicable charges]
    R --> S[Deliver device]
    Q --> T[Record final history]
    S --> T
    H --> T
    K --> T
    T --> U([End])
```

## 7. Account transfer processing

```mermaid
flowchart TD
    A([Start]) --> B[Select source and destination accounts]
    B --> C[Enter transfer amount]
    C --> D{Accounts valid and distinct?}
    D -->|No| E[Reject transfer]
    D -->|Yes| F{Sufficient source balance?}
    F -->|No| E
    F -->|Yes| G{Same currency?}
    G -->|Yes| H[Use rate of one]
    G -->|No| I[Enter executed exchange rate]
    H --> J[Calculate destination amount]
    I --> J
    J --> K[Record account transfer]
    K --> L[Post source OUT movement]
    L --> M[Post destination IN movement]
    M --> N[Update both balances]
    N --> O{Successful?}
    O -->|Yes| P[Commit]
    O -->|No| Q[Rollback]
    E --> R([End])
    P --> R
    Q --> R
```

**Repair history:** Each activity and status transition is recorded as it occurs; status and corresponding history updates are atomic.

**Supplier returns:** Dispatch and resolution are independent posting events. A failed event rolls back its own changes.
