# FCSMS — Software Requirements Specification & Database Requirements

**Project:** Forqani Computer Store Management System (FCSMS)  
**Document version:** 1.3  
**Database model:** 22 entities  

> This Markdown edition is converted from the corrected Word SRS. The editable DOCX remains the formatting master.

---

## 1. Introduction

### 1.1 Purpose

FCSMS is a web application for managing computer-store users, employees, products, category hierarchy, stock, inventory movements, suppliers, customers, purchases, sales, invoices, payments, returns, financial accounts, loans, ledger transactions, and reports.

### 1.2 Scope

- User authentication and permissions based on USERS role.
- Products, self-referencing categories, inventory and stock movement history, suppliers, customers, purchases, sales, and invoice management.
- Payments, returns/refunds, receivables, payables, loans, repayments, and financial ledger management.
- Financial/operational reports, report history, activity logging, and backup/recovery.
### 1.3 Technology Requirements

| Layer | Technology |
| --- | --- |
| Frontend | HTML + CSS |
| Backend | Python+ Flask |
| Database | Oracle Database |
| Database interface | python-oracledb (import oracledb) |
| Database language | Oracle SQL/ PL/SQL |
| Architecture | Web layered architecture: presentation, business logic, data access |

**Implementation approach: Flask renders Jinja2 HTML templates on the server. HTML forms submit requests to Flask routes; Python services handle validation and business logic, and python-oracledb executes parameterized Oracle SQL. Core operations do not require client-side JavaScript; pages may reload after submissions.**

## 2. System Objectives

- Reduce manual record keeping and maintain accurate product and financial records.
- Track current stock and an auditable movement history while preventing negative inventory.
- Automate purchase, sales, invoice, and payment calculations.
- Track customer receivables and supplier/other payables.
- Manage loans given by and received by the store.
- Maintain traceable financial transaction history.
- Generate invoices, account statements, and reports.
- Provide secure role-based access.
## 3. User Classes and Permissions

Roles are stored in user role; there is no ROLES table. The application shall validate allowed role values.

| Function | Admin | Manager | Sales Staff | Inventory Staff |
| --- | --- | --- | --- | --- |
| Login | Yes | Yes | Yes | Yes |
| Product/inventory management | Yes | Yes | No | Yes |
| Sales and invoices | Yes | Yes | Yes | No |
| Purchases | Yes | Yes | No | Yes |
| Customer accounts | Yes | Yes | Yes | Limited |
| Supplier accounts | Yes | Yes | No | Yes |
| Ledger | Yes | Yes | Limited | Limited |
| Loans | Yes | Yes | No | No |
| Debt collection/payment | Yes | Yes | Limited | No |
| Financial reports | Yes | Yes | Limited | Limited |
| User management | Yes | No | No | No |

## 4. Functional Requirements

### FR-01 User Authentication

- Provide login/logout and authenticate authorized accounts.
- Enforce permissions using USERS role.
- Allow authorized administrators to create, update, activate, and deactivate accounts.
- Store password hashes, never plain-text passwords.
- Restrict role to approved values such as Admin, Manager, Sales Staff, and Inventory Staff.
### FR-02 Product Management

- Allow authorized users to add, update, search, view, and deactivate products.
- Assign each product a unique SKU.
- Store brand name directly in PRODUCTS.
- Use CATEGORIES for categories and subcategories: each subcategory is a child row referencing its parent through parent_category_id.
- Store product_name, SKU, brand_name, model, description, purchase_price, sale_price, category_id, and status; reorder_level is stored in INVENTORY.
- Validate brand labels consistently.
### FR-03 Category

- Keep brand_name in PRODUCTS. Represent both categories and subcategories as rows in CATEGORIES; a root category has parent_category_id NULL and a child category references its parent category_id.
- Allow users to select an active parent category and then a valid active child category; save the selected category row as PRODUCTS.category_id, not a separate subcategory_id.
- Group reports by CATEGORIES.category_name and parent/child category relationships, with PRODUCTS.brand_name used for brand summaries.
- Do not introduce separate BRAND or SUBCATEGORY tables: CATEGORIES supplies the hierarchy, and PRODUCTS retains the brand as text.
### FR-04 Supplier Management

- Store supplier identity and contact information.
- Maintain supplier purchase history and outstanding amounts owed.
- Record supplier payments and remaining balances.
### FR-05 Customer Management

- Store customer information and sales history.
- Maintain customer account balances, outstanding credit, and payment history.
### FR-06 Inventory Management

- Maintain INVENTORY.quantity_in_stock with one inventory row per product (INVENTORY.product_id UNIQUE).
- After purchases, completed sales, accepted returns, or authorized adjustments, create INVENTORY_MOVEMENTS records and update current inventory in the same database transaction.
- Prevent negative inventory; provide low-stock/out-of-stock alerts using INVENTORY.reorder_level and quantity_in_stock.
### FR-07 Purchase Management

- Record supplier, responsible user, date, items, quantities, costs, and totals.
- Support paid and credit purchases.
- Credit purchases create or increase supplier payables.
### FR-08 Sales Management

- Allow authorized users to create sales.
- Calculate subtotal, discount, and total.
- Verify stock before completing a sale.
- Support full, partial, and credit payments.
### FR-09 Invoice Management

- Generate a unique invoice number for each sale.
- Include customer, responsible user, date, products, quantities, prices, payments, and balance.
- Support invoice printing.
### FR-10 Payment Management

- Record incoming and outgoing PAYMENTS with account_id, responsible user, and the applicable sale_id, purchase_id, or return_id when the payment belongs to that transaction.
- Support cash, card, bank transfer, mobile payment, and other configured methods.
- Record payment_date, amount, payment_direction, payment_method, status, user_id and applicable source foreign keys. A separate general payment-reference column is not shown in the current ERD.
### FR-11 Returns and Refunds

- Record each return against the original sale in RETURNS and the original sale line through RETURNS_ITEMS.sale_item_id.
- Store the reason, refund_amount and responsible user in RETURNS; returned quantity and condition_status belong in RETURNS_ITEMS.
- Restore sellable stock only after evaluating returned-item condition; record any stock adjustment in INVENTORY_MOVEMENTS.
## 5. Financial Ledger and Credit/Debts Requirements

### 5.1 Financial Management

Record and track amounts received, paid, owed to the store, owed by the store, lent to people, and repaid.

### 5.2 Accounts Receivable

Credit sales create an outstanding receivable associated with the sale and its customer. Partial payments reduce the unpaid sale balance without deleting the sale. Display the original amount, posted payments and remaining balance. The current 22-entity model does not contain a dedicated receivable record or due-date field; receivable due dates and statuses require a documented application rule or a future schema extension. Customer-specific financial-account statements require the account-mapping rule defined in Section 8.5.

### 5.3 Accounts Payable

Track supplier payables from credit PURCHASES and valid outgoing PAYMENTS, with the supplier identified through PURCHASES.supplier_id. FINANCIAL_ACCOUNT supports account activity and ledger reporting but does not contain a supplier_id foreign key. A supplier-to-financial-account mapping must be validated by the application as described in Section 8.5; until then, supplier statements should be derived from purchases and their associated payments.

### 5.4 Loans Given by the Store

Record the borrower in FINANCIAL_ACCOUNT and link LOANS.account_id to that account. Store principal_amount, loan_date, due_date, optional payment_schedule, loan_direction = given, status, notes and responsible user; calculate total_paid and remaining_amount from valid repayments.

### 5.5 Loans Received by the Store

Record the lender in FINANCIAL_ACCOUNT and link LOANS.account_id to that account. Use loan_direction = received; store principal_amount, loan_date, due_date, payment_schedule, status and responsible user, and derive the balance from LOAN_PAYMENTS.

### 5.6 Person Financial Account

FINANCIAL_ACCOUNT holds the name, account_type, holder_name, phone, opening_balance and status of a financial account. Use PAYMENTS, LOANS, LOAN_PAYMENTS, LEDGER_TRANSACTIONS and ACCOUNT_BALANCES for activity and statements. No separate loan-counterparty table is required.

### 5.7 Ledger Transactions

LEDGER_TRANSACTIONS records transaction_id, account_id, user_id, payment_id (nullable), loan_payment_id (nullable), transaction_date, transaction_type, transaction_direction, amount and description. transaction_direction indicates IN or OUT; amount is a positive monetary value. No debit_amount, credit_amount or balance_after columns are modeled. Source transactions are traced through the optional payment or loan-payment reference.

### 5.8 Financial Adjustments

Authorized corrections and adjustments require a reason, the responsible user and an immutable ledger/audit trail. Use a reversing or correcting ledger entry rather than deleting existing financial history.

## 6. Financial Rules

- Balances equal valid obligations/charges minus valid payments/credits.
- A loan or payable is paid only when its outstanding balance is zero.
- Customer balances must not become negative unless explicitly supported.
- Ordinary users cannot delete financial transactions; corrections use authorized reversals or adjustments.
- Every PAYMENTS row must reference a FINANCIAL_ACCOUNT and should reference the relevant sale, purchase or return when applicable. Loan repayments are recorded separately in LOAN_PAYMENTS.
- Prevent overpayment unless explicitly allowed.
- Use consistent currency and monetary precision.
## 7. Ledger and Financial Reports

- Daily/monthly ledger; customer receivables and supplier payables.
- People who owe the store and people/organizations the store owes.
- Active loans given/received, loan repayment history, and overdue accounts.
- Payments received/made; individual account statements; transaction history.
- Total receivables/payables; sales, purchase, inventory, low-stock, supplier, category, and brand summaries.
## 8. Database Requirements

### 8.1 Database Entities

The revised design contains 22 core entities, including INVENTORY_MOVEMENTS. Borrowers and lenders are recorded through FINANCIAL_ACCOUNT and LOANS.account_id; there is no LOAN_COUNTERPARTIES entity.

| # | Entity | Purpose |
| --- | --- | --- |
| 1 | USERS | Application user accounts, roles, authentication and audit attribution |
| 2 | EMPLOYEES | Employee details and optional one-to-one user login |
| 3 | CUSTOMERS | Customer identity and sales relationship |
| 4 | SUPPLIERS | Supplier identity and purchases relationship |
| 5 | FINANCIAL_ACCOUNT | Named financial accounts, including borrowers and lenders |
| 6 | PRODUCTS | Products, category link, brand and prices |
| 7 | INVENTORY | Current quantity and reorder level, one row per product |
| 8 | INVENTORY_MOVEMENTS | Stock receipt, issue, return and adjustment history |
| 9 | CATEGORIES | Parent/child category hierarchy in one table |
| 10 | PURCHASES | Supplier purchase headers |
| 11 | PURCHASE_ITEMS | Purchase lines linked to products |
| 12 | SALES | Sale headers and invoices |
| 13 | SALE_ITEMS | Sale lines linked to products |
| 14 | PAYMENTS | Sale, purchase and return payments against financial accounts |
| 15 | RETURNS | Return headers linked to original sale |
| 16 | RETURNS_ITEMS | Returned quantities linked to original sale items |
| 17 | LOANS | Loans given or received, using financial account as borrower/lender |
| 18 | LOAN_PAYMENTS | Loan repayments and receipt information |
| 19 | LEDGER_TRANSACTIONS | Financial journal history and optional payment references |
| 20 | ACCOUNT_BALANCES | Account balance snapshot or derived current balance |
| 21 | AUDIT_LOG | User action and affected-record trace |
| 22 | REPORT_HISTORY | Metadata for generated reports |

### 8.2 Core Table Attributes

#### USERS

user_id PK, username UNIQUE, password_hash, role, full_name, email, phone, is_active, created_at, last_login

#### EMPLOYEES

employee_id PK, first_name, last_name, phone, address, salary, hire_date, status, user_id FK UNIQUE NULL

#### CUSTOMERS

customer_id PK, name, phone, address, registration_date, status

#### SUPPLIERS

supplier_id PK, name, phone, address, status

#### FINANCIAL_ACCOUNT

account_id PK, account_name, account_type, holder_name, phone, opening_balance, status, created_at

#### PRODUCTS

product_id PK, SKU UNIQUE, product_name, category_id FK, brand_name, model, description, purchase_price, sale_price, status

#### INVENTORY

inventory_id PK, product_id FK UNIQUE, quantity_in_stock, reorder_level, last_updated

#### INVENTORY_MOVEMENTS

movement_id PK, inventory_id FK, movement_type, quantity_delta, occurred_at, recorded_by_user_id FK, source_reference

#### CATEGORIES

category_id PK, category_name, parent_category_id FK NULL (self-reference), description, is_active

#### PURCHASES

purchase_id PK, supplier_id FK, user_id FK, purchase_date, total_amount, payment_status

#### PURCHASE_ITEMS

purchase_item_id PK, purchase_id FK, product_id FK, quantity, unit_price, line_total

#### SALES

sale_id PK, customer_id FK NULL, user_id FK, invoice_no UNIQUE, sale_date, subtotal, discount, grand_total, payment_status

#### SALE_ITEMS

sale_item_id PK, sale_id FK, product_id FK, quantity, unit_price, line_total

#### PAYMENTS

payment_id PK, sale_id FK NULL, purchase_id FK NULL, return_id FK NULL, account_id FK, user_id FK, payment_date, amount, payment_direction, payment_method, status

#### RETURNS

return_id PK, sale_id FK, user_id FK, return_date, reason, refund_amount, status

#### RETURNS_ITEMS

return_item_id PK, return_id FK, sale_item_id FK, quantity, condition_status

#### LOANS

loan_id PK, account_id FK (borrower/lender), loan_direction, principal_amount, loan_date, due_date, payment_schedule NULL, total_paid (stored derived), remaining_amount (stored derived), status, notes, created_by_user_id FK

#### LOAN_PAYMENTS

loan_payment_id PK, loan_id FK, account_id FK, payment_date, amount_paid, payment_method, receipt_no, payment_reference, status, notes, recorded_by_user_id FK

#### LEDGER_TRANSACTIONS

transaction_id PK, account_id FK, user_id FK, payment_id FK NULL, loan_payment_id FK NULL, transaction_date, transaction_type, transaction_direction, amount, description.

#### ACCOUNT_BALANCES

balance_id PK, account_id FK UNIQUE, current_balance (stored derived), as_of_date, last_updated

#### AUDIT_LOG

audit_id PK, user_id FK, action_type, table_name, record_id, action_date, description

#### REPORT_HISTORY

report_history_id PK, user_id FK, report_type, report_name, generated_at, start_date, end_date, export_format, status, total_records, file_path NULL

### 8.3 Financial and Loan Data

- FINANCIAL_ACCOUNT identifies each account holder and account type, including the borrower or lender of a loan. LOANS.account_id references this table directly.
- LEDGER_TRANSACTIONS records the responsible user, financial account, transaction_direction (IN/OUT), positive amount, and an optional payment_id or loan_payment_id source reference. transaction_type classifies the transaction independently of its direction.
- LOANS uses loan_direction to distinguish store-given from store-received loans. total_paid and remaining_amount are stored derived values: total_paid equals the sum of valid posted repayments, and remaining_amount equals principal_amount minus total_paid (for interest-free loans). Update both atomically with each posted, reversed or corrected repayment.
- LOAN_PAYMENTS stores loan_id, account_id, payment_date, amount_paid, payment_method, receipt/reference, status and recording user. Posted repayments update the stored derived loan totals in the same Oracle transaction; cancelled or reversed payments must not count toward total_paid.
### 8.4 Key Relationships and Cardinalities

- USERS 1 : 0..1 EMPLOYEES through EMPLOYEES.user_id (nullable, UNIQUE); USERS 1: N AUDIT_LOG. Employee actions are identified indirectly through USERS, not through an AUDIT_LOG.employee_id field.
- USERS 1 : N SALES, PURCHASES, RETURNS, PAYMENTS, LOANS, LOAN_PAYMENTS, LEDGER_TRANSACTIONS, REPORT_HISTORY and INVENTORY_MOVEMENTS (each using the relevant user foreign key).
- CATEGORIES 1 : N CATEGORIES for parent/child groups (parent_category_id, nullable); CATEGORIES 1 : N PRODUCTS through PRODUCTS.category_id.
- PRODUCTS 1 : 0..1 INVENTORY; INVENTORY 1 : N INVENTORY_MOVEMENTS; PRODUCTS 1 : N PURCHASE_ITEMS and SALE_ITEMS.
- SUPPLIERS 1 : N PURCHASES; PURCHASES 1 : N PURCHASE_ITEMS and may have multiple PAYMENTS.
- CUSTOMERS 1 : N SALES (customer_id on sale is optional); SALES 1 : N SALE_ITEMS, RETURNS and PAYMENTS.
- RETURNS 1 : N RETURNS_ITEMS and may have multiple refund PAYMENTS; SALE_ITEMS 1 : N RETURNS_ITEMS, allowing partial or repeated returns up to the sold quantity.
- FINANCIAL_ACCOUNT 1 : 0..1 ACCOUNT_BALANCES and 1 : N PAYMENTS, LOANS, LOAN_PAYMENTS and LEDGER_TRANSACTIONS.
- LOANS 1 : N LOAN_PAYMENTS. Each PAYMENTS or LOAN_PAYMENTS row may be referenced by zero or one LEDGER_TRANSACTIONS row under the one-posting-per-source rule (1 : 0..1); the journal source foreign keys are nullable. Additional financial postings, if needed, require an explicitly revised rule and corresponding ERD update.
### 8.5 Model Boundaries

- No LOAN_COUNTERPARTIES table or counterparty_id foreign key is used. The FINANCIAL_ACCOUNT attached to each LOAN represents its borrower or lender according to loan_direction.
- Serial-number history, warranty claims and a dedicated receivable/payable obligation table are not represented as separate entities in this 22-table ERD; these features require future schema extensions if needed.
- FINANCIAL_ACCOUNT has no customer_id or supplier_id foreign key. For the current 22-entity implementation, customer/supplier receivables and payables are identified through SALES.customer_id or PURCHASES.supplier_id and their related PAYMENTS. Do not assume FINANCIAL_ACCOUNT can be joined reliably to CUSTOMERS or SUPPLIERS by name or phone. If a separate account is required per customer or supplier, implement and document an explicit, validated identifier-mapping convention in application logic before enabling account-based statements; a proper foreign-key mapping is recommended for a future schema revision.
- Physical data types, allowed values, dates, amount precision, indexing, source-reference validation and transaction logic must be finalized during Oracle implementation.
## 9. Database Integrity Requirements

- Every core entity has a primary key and valid foreign keys.
- SKU, invoice number, username are unique where applicable.
- User role is restricted to approved values.
- PRODUCTS.category_id must reference an existing CATEGORIES.category_id; application validation must ensure that the selected child category belongs to the chosen active parent. Brand names are stored as text.
- Invalid negative amounts are rejected except where transaction rules explicitly permit them.
- Quantity and inventory must not be negative; purchase, sale and return item quantities and loan payments must be positive. INVENTORY_MOVEMENTS.quantity_delta may be positive or negative as required by the action.
- Required identifiers, dates, and amounts cannot be null.
- Referential integrity is maintained when related records are created, updated or deactivated. CATEGORIES.parent_category_id is a nullable self-reference, and PRODUCTS.category_id must be a valid category row; the application prevents cycles and invalid category selections.
**Financial validation: LEDGER_TRANSACTIONS.amount and PAYMENTS.amount must be positive; transaction_direction must use the approved IN/OUT values. Reversals must preserve the original transaction history and prevent duplicate postings.**

**Ledger source integrity: each posted payment or loan repayment must create at most one journal entry for that source. Enforce UNIQUE(payment_id) and UNIQUE(loan_payment_id) for non-null values, or an equivalent idempotency guarantee; when a source-linked posting is required, exactly one of the two source references must be non-null. Standalone authorized adjustment entries may have neither source reference.**

## 10. Transaction and Consistency Requirements

- Each committed sale and its stock decrease, payment/ledger records and INVENTORY_MOVEMENTS entry form one atomic Oracle transaction.
- Purchases, purchase items, payment/ledger records, inventory increases and inventory movements remain consistent within the transaction.
- Loans and repayments reference FINANCIAL_ACCOUNT and update the ledger consistently; repayment-derived totals and balances must match recorded loan payments.
- Stored derived balances: for cash-type accounts, ACCOUNT_BALANCES.current_balance = FINANCIAL_ACCOUNT.opening_balance + total valid posted IN ledger amounts - total valid posted OUT ledger amounts. Define separate balance semantics for receivable/payable accounts; update stored balances, loan totals, and their source ledger records atomically, including reversal handling.
- Failed multi-step financial operations roll back.
- Financial history remains traceable to the originating transaction.
## 11. Security Requirements

- Authentication is required for protected functions.
- Passwords are stored as hashes.
- Authorization is based on user role and enforced in application logic.
- Only authorized users may create, modify, reverse, or adjust financial transactions.
- Restrict database access to authorized application accounts.
- Validate inputs and use parameterized SQL/bind variables.
- Financial changes are auditable.
## 12. Non-Functional Requirements

- Provide acceptable response times under expected store workload.
- Separate interface, business logic, and data access into maintainable modules.
- Show clear errors without exposing sensitive database details.
- Preserve financial accuracy and consistency.
- Make the UI understandable to non-technical employees.
- Support backup/recovery and future expansion.
## 13. Interface Requirements

- Login and dashboard.
- Product form with parent category, filtered child category and brand; save the selected child CATEGORIES.category_id in PRODUCTS.category_id.
- Customer and supplier screens.
- Inventory screen, low-stock alerts and inventory movement history.
- Sales/POS, invoice, purchase, and payment screens.
- Returns screen.
- Financial accounts, ledger, loans, and loan-payment screens.
- Receivables/payables and reports screens.
- Report history view.
- Admin user-management screen with role selection.
## 14. Financial Dashboard Requirements

- Sales and purchases for selected periods.
- Payments received/made; total receivables/payables.
- Active loans given/received and overdue accounts.
- Recent financial transactions.
- Inventory value, low-stock products and category/child-category/brand summaries derived from INVENTORY, PRODUCTS and CATEGORIES.
## 15. Use Cases — Financial Management

### UC-F01 Record Customer Credit Sale

Sales Staff/Manager records the sale and amount paid; the system creates a receivable for the unpaid amount, records the ledger entry, and displays the balance.

### UC-F02 Receive Payment

Authorized user selects the account, records payment, reduces the balance, records the ledger entry, and views the updated balance.

### UC-F03 Record Store Liability

Manager/Admin identifies a person or organization, records amount and reason, creates a payable, and records the ledger entry.

### UC-F04 Pay Person or Supplier

Manager/Admin selects a payable, records full/partial payment, reduces the payable, and updates payment history and ledger.

### UC-F05 Give Loan

Manager/Admin selects borrower account, records terms, creates the loan, and records the financial transaction.

### UC-F06 Receive Loan Repayment

Manager/Admin records repayment, reduces loan balance, and updates ledger/history.

### UC-F07 Borrow Money for Store

Manager/Admin selects lender account, records terms, creates store liability, and records ledger entry.

### UC-F08 Repay Store Loan

Manager/Admin records repayment and updates liability, ledger, and remaining balance.

### UC-F09 View Account Statement

Authorized user selects an account and views chronological transactions, obligations, payments, and balance.

## 16. Reports and Statements

- Customer, supplier, and person/organization statements.
- Loan and repayment statements.
- Receivables/payables aging, daily/monthly ledger, transaction history, outstanding balance, and payment history reports.
- Sales, purchase, inventory, low-stock, supplier, category, and brand reports.
- REPORT_HISTORY may store report type/name, user, generated date/time, date range, export format, status, record count, and file path. Actual report data is queried from operational tables.
## 17. Acceptance Criteria

- Users log in securely and permissions match user role.
- Products, customers, suppliers, sales, purchases, and inventory can be managed.
- PRODUCTS stores category_id and brand_name; selected subcategory is a CATEGORIES child row referencing its parent category.
- Sales, purchases and accepted returns change inventory correctly and produce corresponding INVENTORY_MOVEMENTS entries.
- Credit sales create receivables; payments reduce balances correctly.
- Credit purchases create payables; payments reduce them correctly.
- The store can track amounts owed to and by people/organizations.
- Loans given/received and repayments are tracked through LOANS.account_id and LOAN_PAYMENTS without a separate borrower/lender entity.
- Ledger history and account balances remain consistent.
- Authorized users generate reports/statements and financial changes are auditable.
- A return line references the original SALE_ITEMS.sale_item_id, and total returned quantity cannot exceed the sold quantity.
- The database records stock movement history and preserves users responsible for financial, stock and audit operations.
- Oracle enforces required relationships and integrity constraints.
## 18. Recommended End-to-End Business Flow

Login → Users/Employees → CATEGORIES (parent/child) → PRODUCTS → Supplier Purchase → PURCHASE_ITEMS → INVENTORY and INVENTORY_MOVEMENTS → Customer Sale and SALE_ITEMS → Full/Partial/Credit Payments → Financial Account and Ledger → Invoice → LOANS and LOAN_PAYMENTS → RETURNS and RETURNS_ITEMS → Reports and Statements → AUDIT_LOG.

**Appendix A. Database Design Notes**

- User role should use an Oracle check constraint or application validation for permitted role values.
- PRODUCTS.brand_name remains a text attribute; normalize spelling and handle renames consistently.
- CATEGORIES(category_id, category_name, parent_category_id) represents category hierarchy through parent_category_id FK NULL. PRODUCTS.category_id references the selected CATEGORIES row.
- REPORT_HISTORY records report-generation metadata only, and AUDIT_LOG records the acting USERS.user_id; employee identity is resolved through EMPLOYEES.user_id when available.
- Oracle implementation must finalize data types, lengths, monetary precision, nullability, foreign-key actions, check constraints, indexes, atomic stock and payment operations and derived balances.
