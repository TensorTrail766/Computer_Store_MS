# FCSMS — Sequence Diagrams

**Version:** 1.0  
**Project:** Forqani Computer Store Management System

The sequences describe application interactions. Service names are logical design responsibilities. Financial and stock posting operations share one Oracle transaction; any failure rolls back all changes. Success responses follow commit.

## 1. Login

```mermaid
sequenceDiagram
    actor U as User
    participant V as Browser
    participant R as Flask Routes
    participant A as Auth Service
    participant D as Oracle
    U->>V: Enter username and password
    V->>R: Submit credentials
    R->>A: Authenticate user
    A->>D: Retrieve user record
    D-->>A: User information
    A->>A: Verify password hash and active status
    alt Valid credentials and active account
        A-->>R: Authentication successful
        R->>R: Create session
        R-->>V: Redirect to dashboard
    else Authentication failed
        A-->>R: Reject authentication
        R-->>V: Display error
    end
```

## 2. Sales

```mermaid
sequenceDiagram
    actor U as Sales Staff
    participant R as Flask
    participant S as Sales Service
    participant I as Inventory Service
    participant F as Ledger Service
    participant D as Oracle
    U->>R: Submit sale
    R->>S: Validate sale and permission
    S->>D: Begin transaction
    S->>I: Check and lock stock
    I->>D: Read inventory
    alt Sufficient stock and valid sale
        S->>D: Insert sale and items with rate and warranty snapshots
        S->>I: Deduct stock
        I->>D: Update stock and movements
        S->>F: Post financial movements and actual payments
        F->>D: Insert ledger and update balances
        S->>D: Record audit and commit
        S-->>R: Sale successful
        R-->>U: Display invoice
    else Validation or posting failure
        S->>D: Rollback
        S-->>R: Transaction rejected
        R-->>U: Display error
    end
```

## 3. Purchase

```mermaid
sequenceDiagram
    actor U as Inventory Staff
    participant R as Flask
    participant P as Purchase Service
    participant I as Inventory Service
    participant F as Ledger Service
    participant D as Oracle
    U->>R: Submit purchase
    R->>P: Validate purchase and permission
    P->>D: Begin transaction
    P->>D: Insert purchase and items
    P->>I: Process received quantities
    I->>D: Update sellable inventory
    I->>D: Register defective units
    I->>D: Record stock movements
    P->>F: Record payable and actual settlement
    F->>D: Post ledger movements
    alt All operations successful
        P->>D: Record audit and commit
        P-->>R: Purchase successful
        R-->>U: Display confirmation
    else Failure
        P->>D: Rollback
        P-->>R: Display error
        R-->>U: Purchase rejected
    end
```

## 4. Payment

```mermaid
sequenceDiagram
    actor U as Authorized Staff
    participant R as Flask
    participant P as Payment Service
    participant L as Ledger Service
    participant D as Oracle
    U->>R: Submit payment
    R->>P: Validate source and amount
    P->>D: Begin transaction
    P->>D: Lock relevant accounts and source
    alt Valid payment
        P->>D: Insert payment
        P->>L: Post account movements
        L->>D: Insert ledger entries
        L->>D: Update account balances
        P->>D: Update settlement status
        P->>D: Record audit and commit
        P-->>R: Payment confirmation
        R-->>U: Display confirmation
    else Invalid payment or posting failure
        P->>D: Rollback
        P-->>R: Payment rejected
        R-->>U: Display error
    end
```

## 5. Loan repayment

```mermaid
sequenceDiagram
    actor U as Manager
    participant R as Flask
    participant L as Loan Service
    participant F as Ledger Service
    participant D as Oracle
    U->>R: Submit loan repayment
    R->>L: Validate repayment
    L->>D: Begin transaction
    L->>D: Lock loan and accounts
    D-->>L: Loan and repayment records
    L->>L: Calculate outstanding amount
    alt Repayment within outstanding balance
        L->>D: Insert loan payment
        L->>F: Post financial movements
        F->>D: Update ledger and balances
        L->>L: Derive remaining loan amount
        L->>D: Update loan status
        L->>D: Record audit and commit
        L-->>R: Repayment successful
        R-->>U: Display confirmation
    else Invalid repayment or failure
        L->>D: Rollback
        L-->>R: Repayment rejected
        R-->>U: Display error
    end
```

## 6. Exchange-rate update

```mermaid
sequenceDiagram
    actor U as Authorized Manager
    participant R as Flask
    participant C as Currency Service
    participant D as Oracle
    U->>R: Submit new exchange rate
    R->>C: Validate permission and rate
    C->>D: Begin transaction
    C->>D: Lock currency record
    D-->>C: Current exchange rate
    alt Valid new rate
        C->>D: Insert exchange rate history
        C->>D: Update current currency rate
        C->>D: Record audit and commit
        C-->>R: Exchange rate updated
        R-->>U: Display confirmation
    else Invalid rate or failure
        C->>D: Rollback
        C-->>R: Update rejected
        R-->>U: Display error
    end
    Note over C,D: Posted historical transaction values remain unchanged
```

## 7. Internal account transfer

```mermaid
sequenceDiagram
    actor U as Manager
    participant R as Flask
    participant T as Transfer Service
    participant L as Ledger Service
    participant D as Oracle
    U->>R: Submit account transfer
    R->>T: Validate transfer
    T->>D: Begin transaction
    T->>D: Lock both accounts
    D-->>T: Account balances and currencies
    alt Valid transfer and sufficient funds
        T->>D: Insert account transfer
        T->>L: Post source OUT movement
        L->>D: Decrease source balance
        T->>L: Post destination IN movement
        L->>D: Increase destination balance
        T->>D: Record audit and commit
        T-->>R: Transfer successful
        R-->>U: Display confirmation
    else Failure
        T->>D: Rollback
        T-->>R: Transfer rejected
        R-->>U: Display error
    end
```

## 8. Repair history

```mermaid
sequenceDiagram
    actor U as Authorized Staff
    participant R as Flask
    participant S as Repair Service
    participant H as Repair History Service
    participant D as Oracle
    U->>R: Submit repair status change
    R->>S: Validate permission and status
    S->>D: Begin transaction
    S->>D: Lock repair record
    D-->>S: Current repair status
    alt Valid status transition
        S->>D: Update repair status
        S->>H: Record previous and new status
        H->>D: Insert repair history
        S->>D: Record audit and commit
        S-->>R: Repair updated
        R-->>U: Display confirmation
    else Invalid transition or failure
        S->>D: Rollback
        S-->>R: Update rejected
        R-->>U: Display error
    end
```

## 9. Supplier return dispatch

```mermaid
sequenceDiagram
    actor U as Authorized Staff
    participant R as Flask
    participant S as Supplier Return Service
    participant I as Inventory Service
    participant D as Oracle
    U->>R: Submit supplier return dispatch
    R->>S: Validate original purchase
    S->>D: Begin transaction
    S->>D: Lock source quantities
    alt Valid return quantity and source
        S->>D: Insert supplier return and items
        S->>I: Process stock dispatch
        I->>D: Update appropriate stock records
        S->>D: Record audit and commit
        S-->>R: Return dispatched
        R-->>U: Display confirmation
    else Invalid quantity or source or failure
        S->>D: Rollback
        S-->>R: Return rejected
        R-->>U: Display error
    end
    Note over U,D: Supplier resolution is processed in a later transaction
```

## 10. Report generation

```mermaid
sequenceDiagram
    actor U as Authorized Staff
    participant R as Flask
    participant S as Report Service
    participant D as Oracle
    U->>R: Select report and filters
    R->>S: Validate access and filters
    S->>D: Execute reporting queries
    D-->>S: Report records
    S->>S: Calculate and format results
    S->>D: Insert report history
    S-->>R: Generated report
    R-->>U: Display or export report
```
