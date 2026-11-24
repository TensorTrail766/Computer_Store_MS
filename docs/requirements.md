# Forqani Computer Store Management System (FCSMS)

**Software Requirements Specification (SRS) — Version 1.0**

| Document control | Value |
| --- | --- |
| Document ID | FCSMS-SRS-01 |
| Version | 1.0 |
| Date | 24 November 2026 |
| Authors | FCSMS Project Team |
| Project | Forqani Computer Store Management System |
| Target database | 30 core entities |
| Delivery class | Academic, single-store system; modular expansion roadmap |
| Related controlled documents | 02_System_Architecture.md, 03_Database_Design.md, 04_System_Modeling.md |
| Reference systems | ERPNext, Dolibarr, Odoo (functional benchmarks, not dependencies) |

Requirements conventions. SHALL/MUST designates a mandatory functional or technical requirement; SHOULD indicates a recommended quality or usability requirement; MAY identifies an optional capability.

---

## 1. Introduction

### 1.1 Purpose

FCSMS is a browser-based business application for a computer store: products, category hierarchy, customers, suppliers, employees, inventory, stock movements, purchases, sales and invoices, sale returns and refunds, invoice-line warranties, repairs and repair history, defective stock, supplier returns, payments, named financial accounts, receivables/payables, loans given/received, ledger movements, ,multi-currency handling, operational reports, audit records and report history. It aims to reduce manual records while protecting stock and monetary consistency.

### 1.2 In-scope outcomes

- Authenticate authorized staff; apply Admin, Manager, Sales Staff and Inventory Staff permissions.
- Keep searchable products (unique SKU, text brand and model) under self-referencing categories and maintain nonnegative stock with an auditable stock movement trail.
- Record credit or paid supplier purchases; customer sales, partial payments, invoices, accepted returns and refunds; preserve source documents.
- Track customer and supplier accounts by verified party identifiers, account-specific statements, invoice/payment histories, outstanding balances, due dates, and native-currency ageing reports.
- Support interest-free store loans given to persons and loans received from persons; retain principal, due date, repayment history and available cash impact.
- Track cash/bank/other settlement accounts separately from party receivable/payable accounts; maintain operational IN/OUT ledger movements with source traceability; do not claim double-entry financial accounting.
- Keep AFN as reporting currency; support AFN, USD and PKR denominations with immutable posting-time AFN equivalents, an append-only exchange-rate history, and a separate current-rate valuation.
- Support auditable internal transfers between store cash/bank/mobile-money accounts, including approved currency-exchange transfers, with two linked ledger movements and no effect on sales revenue.
- Generate usable invoices, account statements, ageing and store reports; support authorized correction/reversal, audit history and recoverable backups.
- Maintain product-specific warranty dates on invoices, customer/store repairs and chronological repair history, separate defective stock and supplier returns with traceable financial and inventory consequences.

### 1.3 Technical constraints

| Layer | Requirement |
| --- | --- |
| Presentation | HTML, CSS, Flask/Jinja2 templates |
| Backend | Python + Flask, modular services, repository/data-access layer |
| Database | Oracle Database, Oracle SQL/PLSQL as appropriate, python-oracledb |
| Persistence | Parameterized bind variables; Oracle as the authoritative source |
| Atomic operations | Service-owned commit/rollback and Oracle constraints/row locks |
| Installation | Single-store deployment, approved team environment. |

## 2. Actors and authorization

| Actor | Core access | Restrictions |
| --- | --- | --- |
| Admin | Full approved functions, user management, rate maintenance/history, transfer authorization, reversal approval, audit review | Cannot silently rewrite posted history or override currency integrity |
| Manager | Catalog, purchases, sales, customer/supplier account reports, loans, transfers, repair and supplier-return approvals, reports; delegated reversals/rate changes | Cannot arbitrarily manage users |
| Sales Staff | Sales, invoices, customers, repair intake and permitted collections | Cannot create/repay store loans or change rates |
| Inventory Staff | Products, category assignment, stock movements, purchases, defective-stock handling and authorized repair activities | No loan authority; restricted financial reports |

FR-01 Authentication and authorization. Users SHALL log in/out; passwords SHALL use a modern salted password hash; USERS.username is unique and USERS.role restricted to four supported roles. User activation/deactivation and permission checks SHALL be enforced server-side for every protected endpoint, not merely hidden in the UI. EMPLOYEES.user_id stays nullable/unique. Failed logins SHALL be rate-limited and relevant administrative actions audited. CSRF defenses, safe sessions and secure credential storage SHALL be used.

## 3. Functional requirements

| ID | Function | Acceptance summary |
| --- | --- | --- |
| FR-01 | Authentication, roles and users | Unauthorized action denied; password hashes and unique username |
| FR-02 | Products and pricing | Unique SKU; valid child category; archived referenced product preserved |
| FR-03 | Categories and brand grouping | Parent/child self-FK, no cycles; brand remains product text |
| FR-04 | Suppliers and procurement accounts | Supplier history, due dates, outstanding and payments match |
| FR-05 | Customers and account statements | Customer history/credit, account identity and balances reconcile |
| FR-06 | Inventory and movement provenance | No oversell; every stock mutation has one traceable movement |
| FR-07 | Purchases, receiving and supplier credit | Draft/posted purchase and stock/payable impact deterministic |
| FR-08 | Sales and POS | Safe stock check; posted sale; full/partial/credit handling |
| FR-09 | Invoice numbers and printing | Unique invoice; totals, dates, payments and balance displayed |
| FR-10 | Receipts, disbursements and payment allocation | Cash/party effects, currency matches, valid status and no overpayment |
| FR-11 | Sale returns and refunds | Return references original line; no excessive returns or false restocking |
| FR-12 | Currency accounts and FX snapshots | AFN base, USD/PKR rates, immutable snapshots and native balances |
| FR-13 | Explicit party/account mapping | No name/phone joins; account owner and account type verifiable |
| FR-14 | Receivables/payables, due dates and ageing | Exact amount due and overdue classification from persisted due dates |
| FR-15 | Loan origination/repayment/cash traceability | Counterparty and settlement accounts posted once; totals reconcile |
| FR-16 | Document lifecycle, reversals and idempotency | Draft no posting; posted immutable; reversal restores impacts safely |
| FR-17 | Financial ledger and balance reconciliation | Multiple traceable movements per source; account balances match ledger |
| FR-18 | Reporting, statements and financial dashboard | Filters, native and AFN fields, ageing, inventory, loans and history |
| FR-19 | Audit, backup and operational recovery | Financial edits audited; restore test; no silent delete |
| FR-20 | Usability, search and workflow feedback | Form errors, status display, pagination, accessible labels, safe print |
| FR-21 | Internal account transfers and currency exchange | Each posted transfer produces one source OUT and one destination IN; no duplication or revenue effect |
| FR-22 | Exchange-rate change history | Append-only rate events with user/time, AFN base rate 1, and current-rate consistency |
| FR-23 | Customer/supplier account-based reporting | Per-party and per-account statements, ageing, reconciliation and currency separation |
| FR-24 | Product warranty management | Invoice-line dates frozen at posting; eligibility separately evaluated |
| FR-25 | Repair management | Customer custody separated from store stock; approved charges and costs traceable |
| FR-26 | Supplier return management | Original purchase provenance, stock custody and supplier refund/credit reconcile |
| FR-27 | Defective stock management | Non-sellable quantities and dispositions traceable; no duplicate stock effects |
| FR-28 | Repair history and reporting | Append-only chronological events, actor and technician attribution |

### 3.1 FR-02 and FR-03 — Products, brands and categories

1. Authorized staff SHALL create, edit, search, filter, view and deactivate PRODUCTS without deleting records referenced by purchase/sale history.
2. Every active product SHALL have a unique, stable SKU, product name, category reference, brand_name stored as text, optional model/description, reference purchase price, reference selling price and status.
3. Both catalog reference prices SHALL use AFN; posted purchase/sale line amounts SHALL use their respective document currencies. A converted document price SHALL be captured in the document line and never retrospectively changed by later rate edits.
4. CATEGORIES.parent_category_id SHALL reference the same table; root rows have NULL parent; the application SHALL reject cycles, inactive parent selection and invalid parent/child combinations.
5. The selected child category ID SHALL be stored in PRODUCTS.category_id, not a separate subcategory field. Brand values reside in PRODUCTS.brand_name; the category hierarchy resides in CATEGORIES.
6. Reports SHALL group by category/parent category and consistently normalized brand text. Price and category edits SHALL not rewrite posted sale/purchase line facts.
7. SKU, name, brand, model, category and stock status SHOULD be searchable.

### 3.2 FR-04 and FR-05 — Suppliers and customers

1. Supplier and customer master records SHALL store identity/contact/status and be referenced by PURCHASES.supplier_id or SALES.customer_id respectively.
2. A person/business can be both a supplier and customer; if represented by two records, the UI SHALL make that distinction explicit and SHALL NOT merge them by matching names/phone numbers.
3. Outstanding supplier payables SHALL derive from posted purchases and valid posted payments/returns/adjustments; customer receivables SHALL derive from posted credit sales and valid posted settlements/returns.
4. Statements SHALL show originating document, due date, currency, original charge, payments/adjustments, remaining due, and ageing as of the selected date. See FR-13/14 for mandatory party-account links.
5. A credit or partial-payment sale MUST have a registered customer. Anonymous/walk-in sales MAY be completed only with immediate full settlement; they SHALL NOT create anonymous credit debt.

### 3.3 FR-06 — Inventory and stock movement controls

1. INVENTORY.product_id SHALL be unique: one aggregate stock row per product in the first-release single location.
2. Every posted purchase records received stock in the correct sellable or defective category and every posted sale reduces sellable stock exactly once. Approved sellable returns increase stock; defective returns do not. Approved stock correction records a signed quantity_delta and an audit reason.
3. INVENTORY.quantity_in_stock SHALL not go below zero. Concurrency control SHALL lock or conditionally update affected inventory rows before committing sales; two concurrent sales must not oversell.
4. INVENTORY_MOVEMENTS SHALL record movement type, signed delta, timestamp, user and typed/validated originating document line, not an unchecked free-text reference alone; see §8.
5. Repeated POST requests/retries SHALL NOT create duplicate stock movements. Draft and rejected documents SHALL NOT change stock.
6. Low/out-of-stock alerts SHALL compare quantity_in_stock with reorder_level.

### 3.4 FR-07 — Purchasing

1. Authorized staff SHALL create purchases with supplier, user, date, one or more positive-quantity item lines, purchase currency and totals.
2. A DRAFT purchase SHALL not increase stock or create payable postings. A POSTED purchase SHALL atomically record sellable and defective receipts as applicable, create eligible stock movement records and create the supplier payable charge.
3. Full/partial payment SHALL be recorded through distinct valid PAYMENTS rows; the purchase remains outstanding until payments and authorized credits cover the posted obligation.
4. PURCHASES.due_date SHALL support credit ageing. A purchase cannot be marked PAID merely by selecting an arbitrary status; payment status is calculated from posted settlement amounts.

### 3.5 FR-08 and FR-09 — Sales, POS, invoices

1. Users SHALL create a sales header and positive-quantity item lines, associate a registered customer where relevant, calculate subtotal/discount/grand total server-side and preserve currency + posting-rate snapshot.
2. A sale has a document status (DRAFT, POSTED, REVERSED) and an independent payment status (UNPAID, PARTIAL, PAID). Posted totals SHALL NOT be modified in place.
3. Draft sales do not reduce stock or generate financial charges. Posting atomically checks stock, reduces quantities, creates stock movements, and, for registered customers, posts receivable effects.
4. Walk-in sales without customer_id SHALL be paid in full at posting; a credit or partially paid sale SHALL have a registered customer and a valid same-currency receivable account.
5. Every posted sale SHALL have a unique stable invoice_no, responsible user, date, line details, discounts, currency, payment status, amount paid and remaining balance, with printable output. SALES.due_date SHALL be set for credit sales; due date is optional for fully settled sales.
6. A failed or double-submitted sale SHALL leave no partial stock or financial changes. Front-end JS is optional; the backend is authoritative.

### 3.6 FR-10 — Payments, collections and refunds

1. PAYMENTS SHALL reference exactly one of sale, purchase, return, supplier return or repair when it is a document-settlement payment; authorized standalone account adjustments use LEDGER_TRANSACTIONS adjustment mechanism rather than a fabricated invoice.
2. PAYMENTS.account_id SHALL identify the cash, bank or other settlement account, not ambiguously a party receivable; require PAYMENTS.counterparty_account_id to explicitly identify the applicable receivable/payable account for credit settlements (nullable only where no party balance exists).
3. Payments SHALL record amount > 0, payment date, user, incoming/outgoing direction, payment method, status, currency, rate snapshot and AFN equivalent.
4. Only POSTED payments SHALL affect account balances or ledger. DRAFT and REVERSED rows SHALL not count as active settlement. Store payment status transitions and authorized reversal history.
5. Payments SHALL NOT exceed the remaining amount due except through an approved. Return refunds SHALL not exceed the legally/operationally authorized refundable value.
6. For invoice, purchase, return, supplier return, repair and loan settlements, the payment, cash/bank account, counterparty account (when any) and source document SHALL share one currency. Only the internal transfer workflow (FR-21) may move funds between eligible accounts in different currencies; it is not an invoice-payment conversion.
7. One payment may cause multiple account movements (e.g., cash IN and customer receivable OUT); idempotency is enforced per (source, account, posting_role) instead of the obsolete unique LEDGER_TRANSACTIONS.payment_id constraint.

### 3.7 FR-11 — Sales returns/refunds

1. Every return SHALL reference the original sale and each returned line SHALL reference an original SALE_ITEMS.sale_item_id belonging to that sale.
2. The sum of all accepted posted return quantities for a sold line SHALL never exceed the original quantity, including concurrent requests and previous partial returns.
3. Returned item condition (SELLABLE/DEFECTIVE/etc.) SHALL determine whether quantity is added back to inventory. Refund and store credit decisions SHALL be explicit and consistent with the original paid/unpaid balance.
4. Return posting SHALL reverse/reduce the appropriate receivable charge, create outgoing refund payment only for actual cash refunded, and create eligible stock movement. Avoid paying a refund for an outstanding credit portion.
5. RETURNS SHALL have document status and a posting-time historical AFN refund-equivalent snapshot, while inheriting the original sale denomination. Reversal SHALL be approved and traceable.
6. Basic warranty eligibility, supplier returns and defective-stock handling follow FR-24–FR-28.

### 3.8 FR-12 — Currency denomination and AFN equivalents

1. CURRENCIES(cur_id PK, cur_name, cur_code UNIQUE, cur_exchange_rate, rate_updated_at) SHALL be maintained in the core data model; allowed codes initially AFN/USD/PKR. cur_exchange_rate means AFN per 1 unit; AFN is fixed at exactly 1; others must be positive and manually maintained by authorized staff.
2. Every FINANCIAL_ACCOUNT SHALL reference exactly one currency; cash, customer/supplier party and person-loan accounts may exist separately per currency. No account with posted activity may change cur_id by editing a field.
3. A posted sale, purchase, payment, loan, repayment, repair bill, supplier return, ledger row and customer return (inherited denomination) SHALL preserve native amount, exchange_rate_to_afn and corresponding historical AFN equivalent. Posting-time snapshots are immutable.
4. Each accepted rate update SHALL append one immutable EXCHANGE_RATE_HISTORY record and update the current CURRENCIES.cur_exchange_rate and rate_updated_at values in the same Oracle transaction, with audit attribution. Historical postings SHALL NOT change when current FX rates change.
5. Reports SHALL distinguish historical posted AFN equivalents from any current-rate valuation of outstanding account balances. Do not sum mixed native currencies without conversion.
6. Sale, purchase, return, repair, supplier return, loan and customer/supplier settlement payments SHALL use the denomination of the related account and source document. Internal ACCOUNT_TRANSFERS is the sole first-release exception: transfers may cross currencies only between eligible store-owned settlement accounts, using a separate executed rate and source/destination FX snapshots. Cross-currency invoice settlement, automatic FX gains/losses and revaluation postings are outside v1.0.
7. Financial amounts use Oracle decimal types (NUMBER(18,2)); rates NUMBER(18,6); round posted equivalents to two decimal places using an agreed Oracle/Python rounding rule. Example rates in documentation are hypothetical, not current exchange rates.

### 3.9 FR-13 — Financial-party account relationships

1. FINANCIAL_ACCOUNT SHALL distinguish settlement accounts (CASH, BANK, MOBILE_MONEY) from party balances (CUSTOMER_RECEIVABLE, SUPPLIER_PAYABLE, PERSON_RECEIVABLE, PERSON_PAYABLE) through controlled account types.
2. Add nullable FINANCIAL_ACCOUNT.customer_id FK and supplier_id FK; at most one may be populated, and the populated value must agree with account_type. Loan person accounts use holder_name and other identifying details in the FCSMS v1.0 30-entity model; no separate borrower/lender table is introduced.
3. A customer or supplier MAY have multiple party accounts in distinct currencies, but no duplicate active account for the same (party ID, account_type, cur_id) without an approved exception. The combination of customer/supplier identifier, account type and currency SHALL be available for report filtering and joins.
4. Link receivable/payable entries and payments through these explicit IDs, never by name or phone comparison. If an existing person account is intended for both borrower and lender roles, create separate receivable and payable accounts to avoid contradictory sign semantics.
5. Every party account requires a balance record; ACCOUNT_BALANCES.account_id stays unique. Deactivate rather than delete referenced accounts.

### 3.10 FR-14 — Receivables, payables and ageing

1. Use nullable SALES.due_date and PURCHASES.due_date; posted credit documents MUST specify a due date. The system SHALL not infer an obligation due date from invoice date without a documented payment-term rule.
2. Remaining receivable = posted sale or repair charge − posted allocated payments − permitted posted credits/returns; remaining payable = posted purchase total − posted allocated payments − permitted credits/adjustments including supplier returns, calculated in source currency.
3. Overdue status uses remaining_due > 0 AND due_date < as_of_date; day buckets for 0–30, 31–60, 61–90, >90 overdue days (or another documented, consistently tested configuration). Show not-yet-due separately. Account-based reports SHALL reconcile these invoice-level obligations to their mapped customer/supplier accounts.
4. Amounts paid, remaining and statuses SHALL be recomputed from posted source records, not trusted solely from editable payment_status text.
5. A single counterparty with AFN and USD obligations SHALL have per-currency balances and AFN-reporting totals; native totals SHALL not be added across currencies.
6. No dedicated RECEIVABLE or PAYABLE table is required for the 30-entity FCSMS v1.0 design: sales, purchases and chargeable repairs plus linked posted payments and approved returns represent obligations.

### 3.11 FR-15 — Loan origination and repayment

1. LOANS.account_id refers to the person’s receivable or payable account; require LOANS.funds_account_id FK for the actual cash/bank account disbursed from or received into. Both must use LOANS.cur_id.
2. LOAN_PAYMENTS.account_id refers to the same loan party account and require LOAN_PAYMENTS.funds_account_id FK for the settlement account; both shall match loan denomination.
3. A given loan posts party receivable IN and cash OUT. A received loan posts party payable IN and cash IN. Repayment of a given loan posts party receivable OUT and cash IN; repayment of a received loan posts party payable OUT and cash OUT. See §7.1.
4. Origination and repayments SHALL create separate but grouped ledger lines, source-linked to the loan or loan payment, not just a single ambiguous cash posting.
5. total_paid = sum of valid posted repayments; remaining_amount = principal − total_paid for interest-free loans. Prevent overpayment and negative remaining balances; reverse adjustments atomically.
6. Store principal, origination/due dates, optional payment schedule note, direction GIVEN/RECEIVED, actor, native currency and AFN snapshot. Distinguish due-date overdue display from manually set status.

### 3.12 FR-16 — Document statuses, safe posting and correction

1. SALES, PURCHASES, RETURNS, SUPPLIER_RETURNS and financial billing on REPAIRS SHALL have document_status independent of payment status. At minimum: DRAFT, POSTED, REVERSED; approved corrections after posting create reversal evidence, not destructive mutation.
2. Only DRAFT documents can edit key commercial details. POSTED rows are immutable except safe administrative metadata; corrections use controlled reversal + replacement or explicit adjustment, each tied to the original and an audit reason.
3. Business services SHALL own the transaction; database operations are all-or-nothing with rollback on validation/constraint exceptions.
4. Posting APIs/form handlers SHALL be idempotent. A repeated request must not double-count stock, receivable/payable, ledger or loan balances.
5. Status transitions SHALL be authorized and validated; no unsupported transition (e.g., DRAFT → PAID without posting) is permitted.

### 3.13 FR-17 — Ledger, typed references and reconciliation

1. LEDGER_TRANSACTIONS is an operational account-movement ledger, rather than a double-entry general ledger. Every row has one FINANCIAL_ACCOUNT.account_id, positive amount, direction IN/OUT indicating that this account’s balance increases/decreases, user, date, currency snapshot, source reference and posting role.
2. Add nullable, explicitly typed source FKs sale_id, purchase_id, return_id, loan_id, transfer_id, supplier_return_id, repair_id, along with payment_id and loan_payment_id. Each source-linked row SHALL reference exactly one of these; authorized standalone adjustments use a controlled adjustment reference/reason and no source FK.
3. Include posting_group_id and controlled posting_role; multiple distinct ledger lines may belong to the same source transaction (for example CASH_RECEIPT and CUSTOMER_AR_SETTLEMENT). Unique (source type, source ID, posting_role, account_id) semantics SHALL prevent duplicate posting; SQL may use virtual columns/function-based indexes or service checks with locked source rows to enforce idempotency. Each source may legitimately generate multiple ledger movements distinguished by account and posting role.
4. ACCOUNT_BALANCES.current_balance = FINANCIAL_ACCOUNT.opening_balance + SUM(active IN) − SUM(active OUT) in the account’s native currency; account class semantics must be labeled in UI. A payment’s two different accounts each maintain separate native balances; balance totals are not a substitute for double-entry financial statements.
5. Include typed source FKs in INVENTORY_MOVEMENTS (nullable purchase_item_id, sale_item_id, return_item_id, supplier_return_item_id, repair_id, defective_stock_id plus controlled adjustment reference). Exactly one originating line or authorized adjustment SHALL apply; ensure the line’s product equals the inventory product.
6. Reconciliation reports SHALL identify missing source rows, duplicate ledger/movement effects, transfer-leg imbalance or omission, balance differences, currency mismatches, and orphaned or unposted adjustments; blocking discrepancies SHALL prevent release.

### 3.14 FR-18 — Financial, stock and management reporting

1. Report sales and purchases by date, customer/supplier, product, category, subcategory, brand and native currency; show optional historical AFN equivalents.
2. Generate stock availability, low/out-of-stock lists, stock movement history and quantity reports; do not claim FIFO/weighted-average stock valuation or reliable COGS before implementing a costing policy.
3. Generate customer/supplier receivables/payables and ageing, cash received/paid, outstanding loans, repayments, overdue loans, operational ledger history, and per-account statements. Each registered customer or supplier SHALL have an identifiable summary with accounts grouped by currency; users SHALL drill into one account to view opening balance, dated invoices/credits/payments, ledger movements, running balance, and closing balance.
4. For finance reports clearly label native currency, historical posted AFN, or current-rate AFN valuation and include report-as-of dates. Avoid mixing different conversion bases in one unlabeled subtotal.
5. Keep report-generation metadata in REPORT_HISTORY (not redundant copies of all data); permit print and, where feasible, CSV export; PDF/XLSX export is optional unless separately approved.
6. Dashboard shows recent sales, purchases, financial movements, aged receivables/payables, active loans and low stock. Reports SHALL include internal transfer registers, exchange-rate change logs, and customer/supplier account reports without counting internal transfer legs as external income, revenue, expense or loan activity.

### 3.15 FR-19 and FR-20 — Audit, recovery and usability

1. Every authorized rate update, internal transfer posting/reversal, reversal, loan origination/repayment, warranty override, repair financial posting, supplier dispatch/resolution, defective-stock disposition, financial adjustment and stock adjustment SHALL record acting user, affected record, date/time and reason in AUDIT_LOG; sensitive passwords or secrets SHALL NOT enter log descriptions.
2. Posted source data shall be protected from hard deletion. Audit data must be readable only to authorized roles. Report history shall record when and by whom reports were run.
3. Team SHALL define backup ownership, backup frequency, retention, storage location and a restore-test procedure. Before v1.0 acceptance, perform and document one restoration into a test database; a file export alone does not prove recovery.
4. Server-rendered screens SHALL show clear validation errors, native currency and historical AFN labels, available stock, due/paid statuses and reversal indication; permission or database error messages SHALL not expose SQL credentials.
5. Search, filtering, pagination and print-friendly invoices SHOULD be provided; keyboard labels and readable tables SHOULD work without client JavaScript.

### 3.16 FR-21 — Internal account transfers and foreign-currency exchange

1. Authorized Admin and Manager users SHALL create, review, post, search and reverse internal transfers only between store-owned settlement accounts of type CASH, BANK or MOBILE_MONEY. Party receivable/payable accounts SHALL NOT be transfer endpoints.
2. Every transfer SHALL identify a distinct from_account_id and to_account_id, positive source_amount and destination_amount, actor, date/time, unique reference_no, notes/reason, and document status DRAFT, POSTED or REVERSED. Transfer currencies SHALL be inherited from the two accounts and shown explicitly.
3. For SAME_CURRENCY transfers, source and destination account currencies SHALL match and destination_amount = source_amount; the transfer conversion rate is 1. For CURRENCY_EXCHANGE transfers, a positive immutable executed_rate_to_destination SHALL express destination currency units per one source currency unit and destination_amount = ROUND(source_amount × executed_rate_to_destination, 2) under an approved rounding rule. Executed rates may differ from reference rates.
4. On posting, an eligible transfer SHALL create exactly two grouped operational ledger movements: TRANSFER_OUT (source account OUT) and TRANSFER_IN (destination account IN). Both movements, transfer status, account balances and audit attribution SHALL commit atomically or roll back together. A repeated post request SHALL never create additional legs.
5. Every transfer SHALL preserve each leg’s native currency, its independent posting-time AFN reference-rate snapshot, and the historical AFN equivalent. Cross-currency transfers SHALL not be treated as customer/supplier invoice settlement and SHALL not automatically create FX gain/loss journal entries.
6. Transfers SHALL not modify sales totals, purchase totals, loans, customer/supplier receivables or payables. Operational cash movement reports SHALL identify transfer legs and exclude them from external receipts, disbursements, revenue and expense totals, while account statements SHALL show the movements.
7. The system SHALL validate sufficient source funds under the store’s nonnegative-settlement-balance policy, distinct accounts, approved currencies, correct account ownership, valid rates and permission to post. Initial release SHALL not support transfer fees, split transfer legs, third-party exchanges or automatic gain/loss accounting.
8. Posted transfers SHALL retain immutable source/destination amounts and rates. Authorized reversal SHALL generate two opposite ledger movements in a linked posting group, restore balances and retain the original record and audit history.

### 3.17 FR-22 — Exchange-rate history and controls

1. The system SHALL maintain append-only EXCHANGE_RATE_HISTORY records for manual AFN/USD/PKR reference-rate settings, storing rate_history_id, cur_id, rate_to_afn, effective_at, recorded_at, recorded_by_user_id, and a nonempty reason. Each new rate event has an unambiguous currency and effective time. Current rates SHALL be initialized through auditable history records, including the initial USD/PKR values.
2. AFN SHALL have rate exactly 1. Non-AFN rates SHALL be positive; invalid currency codes, zero/negative rates, duplicate effective timestamps per currency, unauthorized edits, and ambiguous effective ordering SHALL be rejected. Backdated rate insertion is outside initial-release scope.
3. The current CURRENCIES.cur_exchange_rate SHALL equal the most recent applicable history record, and rate_updated_at SHALL reflect its recording time. Adding the history row, updating the current rate and creating the audit event SHALL be atomic.
4. Posted rate-history records SHALL never be overwritten or deleted. Corrections use a later, attributable event; source-document and transfer FX snapshots SHALL remain unchanged. Transfer executed rates are distinct from the reference-rate history.
5. Authorized staff SHALL view and filter exchange-rate history by currency, effective date, recorded date and responsible user, including old/new rate, reason and change sequence. The report SHALL clearly identify reference rates; actual executed transfer rates SHALL be displayed separately in the transfer register (REP-16).

### 3.18 FR-23 — Customer and supplier account-based reports

1. Authorized users SHALL retrieve a Customer Account Summary by CUSTOMERS.customer_id, listing only linked FINANCIAL_ACCOUNT rows with account_type = CUSTOMER_RECEIVABLE, separated by currency and showing opening balance, posted changes, current outstanding balance, overdue amount and last activity.
2. Authorized users SHALL retrieve a Supplier Account Summary by SUPPLIERS.supplier_id, listing only linked FINANCIAL_ACCOUNT rows with account_type = SUPPLIER_PAYABLE, with the same per-currency and overdue information.
3. A user SHALL select a specific account_id to obtain a chronological account statement with source document number/type, date, transaction direction, native amount, running balance, optional historical AFN amount, actor and reference; opening and closing balances must reconcile to posted ledger movements for the requested period.
4. Each account report SHALL reconcile invoice/purchase and approved repair obligations, permitted customer and supplier returns/credits, valid allocated payments and ending receivable/payable balances. Aging buckets SHALL use each document’s due date and the selected report-as-of date; not-yet-due and overdue amounts SHALL be separate.
5. The system SHALL provide filters by customer/supplier, account, currency, document status, payment status, date interval and as-of date, with printing and CSV export where supported. AFN valuation totals SHALL identify the valuation rate/time and SHALL not be mixed with historical posting equivalents.
6. Reports SHALL exclude draft, voided or unapplied rows and shall reflect compensating reversal entries without silently removing historic activity. A report shall never join customer/supplier accounts by names or telephone numbers; it SHALL use the explicit party foreign keys.
7. Manager/Admin SHALL access all authorized party reports; Sales Staff may access permitted customer statements only; Inventory Staff SHALL not access sensitive financial histories without an explicit authorization rule.

---

### 3.19 FR-24 — Product warranty management

1. Authorized users SHALL configure PRODUCTS.warranty_period_months as a nonnegative integer; zero means no warranty. A sale item SHALL preserve its applicable warranty commencement and expiry dates when posted; both dates are null for no warranty. Warranty commencement defaults to the sale date; any authorized override is recorded before posting.
2. Calculate the expiry date using calendar months (Oracle ADD_MONTHS or equivalent documented rule); coverage applies from start date through the stated end date inclusive. Derived status is NO_WARRANTY, NOT_STARTED, ACTIVE or EXPIRED as of the evaluation date. A date range SHALL NOT be inverted.
3. Invoices SHALL display product-specific warranty dates/duration, including no-warranty indication. Changes to catalog defaults SHALL NOT alter posted invoice dates. Purchase lines MAY record supplier warranty start/end dates, both nullable together, independently of customer warranty.
4. Staff SHALL verify original invoice/item, identity where available, defect and policy conditions; warranty validity alone does not authorize a refund. Return eligibility and warranty coverage are independent. Return policy terms (including permitted days, inspection and authorization rules) SHALL be documented by management and enforced; no automatic refund of unpaid amounts.

### 3.20 FR-25 — Repair management

1. Register a unique repair case for CUSTOMER or STORE ownership. Customer repairs require a customer; original sale item is optional for external devices, and mandatory for store-issued warranty verification. Product may be null for an external device not in the catalog; record device description/model and serial number where available. Store repairs require a defective-stock record and matching product. Customer-owned devices never enter sellable or defective store stock solely because received for service.
2. Record problem, diagnosis, responsible user, optional assigned employee, received/completion/delivery timestamps, warranty decision and notes. Require valid dates and record changes in REPAIR_HISTORY. Verify original customer/product identity and warranty dates; authorized manager confirms coverage, quote and customer acceptance for chargeable work.
3. Workflow statuses: RECEIVED, UNDER_INSPECTION, AWAITING_APPROVAL, UNDER_REPAIR, TESTING, REPAIRED, DELIVERED, UNREPAIRABLE, CANCELLED. Permit only documented transitions; completion follows successful testing; delivery records custody handover. Store repair completion does not itself restore stock until approved inspection and disposition.
4. Distinguish actual repair costs from customer charges. Repair billing uses separate DRAFT/POSTED/REVERSED document status, currency, due date for credit, historical rate and AFN charge/cost snapshots. Store repairs have zero customer charge; covered work has zero customer charge unless separately approved non-covered work is agreed. Financial values are frozen at posting. Paid/partial/credit repairs use the customer’s same-currency receivable account and linked incoming PAYMENTS. Actual store-paid repair costs use outgoing PAYMENTS linked to the case; do not confuse an estimate with cash spent. No repair-parts consumption subsystem or repair supplier payable is included; actual costs are recorded when incurred and paid, with authorization and supporting reference.
5. Each repair charge posts the applicable receivable once; collections reduce it and increase settlement funds. Costs affect only actual settlement funds on payment, with a distinct controlled payment purpose (REPAIR_COST versus REPAIR_COLLECTION; ordinary payments use DOCUMENT_SETTLEMENT). Prevent overcollection or overpayment of approved cost. Refund/reversal requires an authorized compensating posting, preserving source evidence; no financial posting from draft cases. Customer account reports include posted repair bills and their settlements/ageing.
6. Search/filter by case, customer, product, serial, technician, dates, warranty decision and status. Provide printable repair intake and completion/billing references, showing amounts paid/due separately from cost (cost restricted to authorized staff).

### 3.21 FR-26 — Supplier return management

1. Record a uniquely referenced supplier return against one original posted purchase; each line references an original purchase item belonging to that purchase. Customer-originated items also retain the original customer return line and verified purchase provenance; do not guess source purchase from product name or SKU. Where origin cannot be verified, hold defective stock pending investigation, not a fabricated supplier return.
2. Record quantities, condition, reason, original purchase denomination, approved unit return value and resolution (REFUND, CREDIT, REPLACEMENT, REPAIR). One document uses one resolution type; split distinct resolutions into separate documents. Cumulative non-reversed returned quantities must not exceed purchased quantity or available eligible stock. Lock source lines and stock records during posting.
3. Record dispatch and resolution independently of DRAFT/POSTED/REVERSED status. Dispatch deducts sellable stock exactly once, or marks the corresponding defective quantity as sent to supplier without deducting sellable stock again. A pending supplier return represents goods in supplier custody; rejected/returned goods re-enter the appropriate stock only after actual receipt and inspection. Record resolution date, received quantities, receipt events with unique posting references and evidence; prevent duplicate receipts.
4. Refund/credit financial effects occur only for an approved monetary resolution. Credit reduces the open payable on the original purchase; actual refunds generate incoming PAYMENTS linked to supplier_return_id. For a return exceeding outstanding payable, recognize a temporary supplier credit (negative payable) for the paid portion, cleared by actual cash refund. No cash refund is assumed before receipt; outstanding supplier refund credits are separately labeled. Approved partial refund or credit may be lower than original value; no refund for unpaid amounts. Do not exceed the approved value or actual paid portion after other returns. Replacement/repair alone causes no refund or payable reduction; approved monetary differences require a separate attributable resolution.
5. Replacement or repaired units are received against the supplier return line only after inspection. Sellable units restore inventory; defective units enter defective stock. Post dispatch, resolution and receipts with distinct movement roles, auditable idempotency and physical-custody checks. Reverse only with matching compensating stock and finance effects; reject reversal if downstream effects cannot safely be unwound.
6. Preserve historical currency snapshots, approved values and all prior documents; report supplier returns by supplier, purchase, product, date, resolution, pending receipt/refund and status. Print return references and line details.

### 3.22 FR-27 — Defective stock management

1. Maintain store-owned defective units separately from INVENTORY.quantity_in_stock (sellable only). Record product, quantity, origin purchase item or customer return item where known, detection date, condition, reason, optional serial, actor and disposition. A defective record represents a homogeneous quantity with one disposition; split records with parent reference before partial disposition, conserving quantity. Serialized records have quantity one; no claim of complete serial lifecycle tracking.
2. On detection in sellable inventory, deduct available stock once using a typed movement and create defective record atomically. Purchase lines record defective_quantity between zero and purchased quantity. Defective purchase receipts and accepted defective customer returns create defective records directly without increasing sellable stock. Preserve source line references and enforce cumulative quantities; customer property undergoing repair is excluded.
3. Statuses include AWAITING_INSPECTION, AWAITING_REPAIR, UNDER_REPAIR, AWAITING_SUPPLIER_RETURN, RETURNED_TO_SUPPLIER, RESTORED_TO_INVENTORY, WRITTEN_OFF and SPLIT. Returned-to-supplier status denotes dispatched custody, not in-store stock; report supplier custody separately. Active in-store totals exclude terminal/split records. A split parent is closed, and children sum to parent quantity; no double counting.
4. Store repair and supplier return lines reference the defective record; block concurrent incompatible dispositions. Restore to sellable inventory only after successful inspection, create one positive movement and close the defective record atomically. Record authorized write-offs with quantity, reason, date and actor; no second deduction from sellable inventory. Do not claim a monetary loss calculation without costing policy.
5. All changes SHALL be attributable through typed stock movements where sellable stock changes and AUDIT_LOG for defective custody/disposition, including before/after quantity/status and source IDs. Reject negative quantities, duplicate effects and inconsistent origin/product. Report by product, condition, origin, current custody, disposition and date.

### 3.23 FR-28 — Repair history and reporting

1. Every repair case SHALL have chronological, append-only REPAIR_HISTORY records including initial reception; each event references the case, responsible user, optional technician, action type, timestamp, prior/new status, description and notes.
2. Record reception, inspection, diagnosis, assignment, warranty verification, approval, repair, component replacement narrative, testing, completion, delivery, cancellation and financial/disposition events as applicable. Non-status events may retain the same status; corrections use additional attributable events rather than overwriting history.
3. Each status change and its history event SHALL commit atomically; enforce ordered events and valid transitions, including concurrent updates. Current REPAIRS status must reconcile to latest status event. Preserve separate repair cases for repeat visits and filter by serial where available.
4. Authorized staff SHALL view chronology and filter repair reports by customer, product, serial, technician, date, warranty and status. Financial reports distinguish actual costs, charges, collected and outstanding amounts and apply currency separation and role-based restrictions. No silent deletion of repair history.

## 4. Core data model — 30 entities

The following 30 entities define the logical data model for FCSMS Version 1.0. Field lists specify the required conceptual attributes and key relationships; detailed Oracle data types, indexes and cross-table constraints are defined during physical database design.

| # | Entity | Core attributes and keys (not exhaustive) |
| --- | --- | --- |
| 1 | USERS | user_id PK, username UNIQUE, password_hash, role, full_name, email, phone, is_active, created_at, last_login |
| 2 | EMPLOYEES | employee_id PK, first_name, last_name, phone, address, salary, hire_date, status, user_id FK UNIQUE NULL |
| 3 | CUSTOMERS | customer_id PK, name, phone, address, registration_date, status; mapped via FINANCIAL_ACCOUNT.customer_id |
| 4 | SUPPLIERS | supplier_id PK, name, phone, address, status; mapped via FINANCIAL_ACCOUNT.supplier_id |
| 5 | FINANCIAL_ACCOUNT | account_id PK, account_name, controlled account_type, holder_name, phone, opening_balance, status, created_at, cur_id FK NOT NULL, customer_id FK NULL, supplier_id FK NULL |
| 6 | PRODUCTS | product_id PK, SKU UNIQUE, product_name, category_id FK, brand_name, model, description, purchase_price, sale_price, status, warranty_period_months (reference prices AFN) |
| 7 | INVENTORY | inventory_id PK, product_id FK UNIQUE, quantity_in_stock, reorder_level, last_updated |
| 8 | INVENTORY_MOVEMENTS | movement_id PK, inventory_id FK, movement_type, quantity_delta, occurred_at, recorded_by_user_id FK, source_reference (display only), purchase_item_id FK NULL, sale_item_id FK NULL, return_item_id FK NULL, supplier_return_item_id FK NULL, repair_id FK NULL, defective_stock_id FK NULL, movement_role, movement_reference UNIQUE, adjustment_reference NULL |
| 9 | CATEGORIES | category_id PK, category_name, parent_category_id FK NULL, description, is_active |
| 10 | PURCHASES | purchase_id PK, supplier_id FK, user_id FK, purchase_date, total_amount, payment_status, due_date NULL, document_status, cur_id FK, exchange_rate_to_afn, total_amount_afn |
| 11 | PURCHASE_ITEMS | purchase_item_id PK, purchase_id FK, product_id FK, quantity, unit_price, line_total, defective_quantity, supplier_warranty_start_date NULL, supplier_warranty_end_date NULL |
| 12 | SALES | sale_id PK, customer_id FK NULL, user_id FK, invoice_no UNIQUE, sale_date, subtotal, discount, grand_total, payment_status, due_date NULL, document_status, cur_id FK, exchange_rate_to_afn, grand_total_afn |
| 13 | SALE_ITEMS | sale_item_id PK, sale_id FK, product_id FK, quantity, unit_price, line_total, warranty_start_date NULL, warranty_end_date NULL, warranty_status derived |
| 14 | PAYMENTS | payment_id PK, sale_id FK NULL, purchase_id FK NULL, return_id FK NULL, supplier_return_id FK NULL, repair_id FK NULL, payment_purpose, account_id FK (settlement), counterparty_account_id FK NULL, user_id FK, payment_date, amount, payment_direction, payment_method, status, cur_id FK, exchange_rate_to_afn, amount_afn |
| 15 | RETURNS | return_id PK, sale_id FK, user_id FK, return_date, reason, refund_amount, status, document_status, exchange_rate_to_afn, refund_amount_afn; currency inherited from sale |
| 16 | RETURNS_ITEMS | return_item_id PK, return_id FK, sale_item_id FK, quantity, condition_status |
| 17 | LOANS | loan_id PK, account_id FK (person balance), funds_account_id FK, loan_direction, principal_amount, loan_date, due_date, payment_schedule NULL, total_paid derived, remaining_amount derived, status, notes, created_by_user_id FK, cur_id FK, exchange_rate_to_afn, principal_amount_afn |
| 18 | LOAN_PAYMENTS | loan_payment_id PK, loan_id FK, account_id FK (person balance), funds_account_id FK, payment_date, amount_paid, payment_method, receipt_no, payment_reference, status, notes, recorded_by_user_id FK, cur_id FK, exchange_rate_to_afn, amount_paid_afn |
| 19 | LEDGER_TRANSACTIONS | transaction_id PK, account_id FK, user_id FK, sale_id FK NULL, purchase_id FK NULL, return_id FK NULL, loan_id FK NULL, transfer_id FK NULL, supplier_return_id FK NULL, repair_id FK NULL, payment_id FK NULL, loan_payment_id FK NULL, posting_group_id, posting_role, adjustment_reference NULL, is_reversal, transaction_date, transaction_type, transaction_direction IN/OUT, amount, description, cur_id FK, exchange_rate_to_afn, amount_afn |
| 20 | ACCOUNT_BALANCES | balance_id PK, account_id FK UNIQUE, current_balance stored derived, as_of_date, last_updated (native currency inherited from account) |
| 21 | AUDIT_LOG | audit_id PK, user_id FK, action_type, table_name, record_id, action_date, description; reasons and before/after context SHALL be recorded in a sanitized, readable audit format |
| 22 | REPORT_HISTORY | report_history_id PK, user_id FK, report_type, report_name, generated_at, start_date, end_date, export_format, status, total_records, file_path NULL |
| 23 | CURRENCIES | cur_id PK, cur_name, cur_code UNIQUE, cur_exchange_rate > 0, rate_updated_at, AFN fixed at 1 |
| 24 | ACCOUNT_TRANSFERS | transfer_id PK, from_account_id FK, to_account_id FK, source_amount, destination_amount, executed_rate_to_destination, source_rate_to_afn, destination_rate_to_afn, source_amount_afn, destination_amount_afn, transfer_type, transfer_date, reference_no UNIQUE, document_status, notes, created_by_user_id FK, posted_at, reversal_of_transfer_id FK NULL |
| 25 | EXCHANGE_RATE_HISTORY | rate_history_id PK, cur_id FK, rate_to_afn > 0, effective_at, recorded_at, recorded_by_user_id FK, reason, supersedes_rate_history_id FK NULL; unique (cur_id, effective_at) |
| 26 | REPAIRS | repair_id PK, repair_reference UNIQUE, customer_id FK NULL, product_id FK NULL, sale_item_id FK NULL, defective_stock_id FK NULL, employee_id FK NULL, user_id FK, repair_type, device_description, serial_number NULL, problem_description, diagnosis NULL, received_date, completion_date NULL, delivery_date NULL, is_warranty_covered, repair_cost, repair_charge, cur_id FK, exchange_rate_to_afn, repair_cost_afn, repair_charge_afn, due_date NULL, document_status, status, notes |
| 27 | SUPPLIER_RETURNS | supplier_return_id PK, purchase_id FK, user_id FK, return_reference UNIQUE, return_date, reason, total_amount, resolution_type, document_status, resolution_status, resolution_date NULL, exchange_rate_to_afn, total_amount_afn, notes |
| 28 | SUPPLIER_RETURN_ITEMS | supplier_return_item_id PK, supplier_return_id FK, purchase_item_id FK, return_item_id FK NULL, defective_stock_id FK NULL, quantity, unit_price, line_total derived, condition_status, source_stock_type, received_sellable_quantity, received_defective_quantity, reason |
| 29 | DEFECTIVE_STOCK | defective_stock_id PK, product_id FK, purchase_item_id FK NULL, return_item_id FK NULL, supplier_return_item_id FK NULL, parent_defective_stock_id FK NULL, user_id FK, quantity, serial_number NULL, condition_status, detected_date, status, reason |
| 30 | REPAIR_HISTORY | repair_history_id PK, repair_id FK, employee_id FK NULL, user_id FK, action_type, previous_status NULL, new_status NULL, action_date, description, notes |

The FCSMS v1.0 data model consists of these 30 entities. Extension entities appear separately in the system evolution roadmap. The return-line entity name is RETURNS_ITEMS.

## 5. Relationship and integrity model

| Relationship | Required cardinality/invariant |
| --- | --- |
| CATEGORIES → CATEGORIES | Self-reference for parent/child hierarchy; no cycles |
| CATEGORIES → PRODUCTS | One category may have many products; each product selects one category |
| PRODUCTS → INVENTORY | At most one stock row per product; unique product FK |
| INVENTORY → INVENTORY_MOVEMENTS | Many immutable positive/negative stock changes with typed origin |
| SUPPLIERS → PURCHASES → PURCHASE_ITEMS | One supplier many purchases; a posted purchase has ≥1 line |
| CUSTOMERS → SALES → SALE_ITEMS | Optional customer only for fully paid walk-ins; posted sale has ≥1 line |
| SALES → RETURNS → RETURNS_ITEMS | Return tied to original sale and each return line tied to original sale item |
| SALES/PURCHASES/RETURNS/REPAIRS/SUPPLIER_RETURNS → PAYMENTS | One document may have many posted settlements; each payment references one source |
| CUSTOMERS/SUPPLIERS → FINANCIAL_ACCOUNT | Explicit nullable party FKs, conditional by type; multiple currencies possible |
| CURRENCIES → financial source/account tables | One currency per account/doc where directly referenced; returns inherit original document currency; historical transaction rate stored on posting |
| FINANCIAL_ACCOUNT → ACCOUNT_BALANCES | Account has 0..1 snapshot row; create at first posting or on account activation |
| FINANCIAL_ACCOUNT → ACCOUNT_TRANSFERS (source) | One settlement account may fund many transfers; from_account_id is mandatory |
| FINANCIAL_ACCOUNT → ACCOUNT_TRANSFERS (destination) | One settlement account may receive many transfers; to_account_id is mandatory; distinct from source |
| ACCOUNT_TRANSFERS → LEDGER_TRANSACTIONS | One posted transfer produces exactly two active legs with transfer_id FK and distinct TRANSFER_OUT / TRANSFER_IN roles; reversal adds compensating movements |
| CURRENCIES → EXCHANGE_RATE_HISTORY | One currency has many historical reference-rate events; ordered by effective/recorded time |
| USERS → ACCOUNT_TRANSFERS / EXCHANGE_RATE_HISTORY | Every posted transfer and every stored rate update identifies the responsible user |
| FINANCIAL_ACCOUNT → LOANS | LOANS.account_id is person’s loan receivable/payable account |
| FINANCIAL_ACCOUNT → LOANS | LOANS.funds_account_id is actual settlement/cash/bank account |
| LOANS → LOAN_PAYMENTS | A loan has many valid repayments; repayment links same party account and funds account |
| FINANCIAL_ACCOUNT → LEDGER_TRANSACTIONS | Each ledger row changes exactly one named account’s native balance |
| Source docs → LEDGER_TRANSACTIONS | One-to-many, not one-to-one; role/group/idempotency controls duplicate rows |
| USERS → mutation/audit tables | Every money or stock posting identifies the responsible user |
| PURCHASES → SUPPLIER_RETURNS → SUPPLIER_RETURN_ITEMS | Each return references one purchase; one or more lines when posted |
| PURCHASE_ITEMS → SUPPLIER_RETURN_ITEMS | Each return line references one original purchase line; cumulative cap |
| RETURNS_ITEMS → SUPPLIER_RETURN_ITEMS | Optional customer-origin reference, one to many |
| PRODUCTS → DEFECTIVE_STOCK | Each defective record references one product |
| PURCHASE_ITEMS / RETURNS_ITEMS / SUPPLIER_RETURN_ITEMS → DEFECTIVE_STOCK | Optional origin references; provenance validated, one to many |
| DEFECTIVE_STOCK → DEFECTIVE_STOCK | Optional parent split; children conserve parent quantity |
| DEFECTIVE_STOCK → SUPPLIER_RETURN_ITEMS / REPAIRS | Optional source for supplier dispatch or store repair; multiple historical cases, no incompatible active disposition |
| CUSTOMERS / PRODUCTS / SALE_ITEMS / EMPLOYEES → REPAIRS | Optional FKs conditional on ownership, device catalog and warranty; one to many |
| CURRENCIES → REPAIRS | One repair billing currency |
| REPAIRS → REPAIR_HISTORY | Each event references exactly one repair; one or more events per registered case |
| EMPLOYEES / USERS → REPAIR_HISTORY | Optional technician; mandatory recording user |
| USERS → REPAIRS / SUPPLIER_RETURNS / DEFECTIVE_STOCK | Mandatory responsible user |
| REPAIRS / SUPPLIER_RETURNS → PAYMENTS / LEDGER_TRANSACTIONS | One to many, typed source and controlled purposes |
| REPAIRS / SUPPLIER_RETURN_ITEMS / DEFECTIVE_STOCK → INVENTORY_MOVEMENTS | Typed source where sellable stock changes; one to many, distinct movement roles |

### 5.1 Additional mandatory checks

- Oracle PK/FK/UNIQUE/CHECK/NOT NULL rules SHALL cover valid identifiers, approved roles, statuses, quantities > 0, monetary transaction amounts > 0, nonnegative repair costs/charges and decimal rate > 0. Approval rules beyond simple row checks SHALL be enforced in an atomic, tested Python service and, where appropriate, Oracle triggers or deferred validation.
- FINANCIAL_ACCOUNT.customer_id and .supplier_id cannot both be non-null; customer/supplier party account types require their corresponding foreign key. Settlement accounts require neither.
- For sale/purchase/return/repair/supplier-return/loan/payment settlement, all involved accounts and source documents have matching cur_id (including inherited currency). Internal ACCOUNT_TRANSFERS is the only cross-currency account-movement exception; both endpoint currencies must match the selected settlement accounts.
- A product cannot be deactivated and replaced by an unrelated ID to hide a prior invoice; referenced financial and inventory master records are not hard-deleted.
- A posting with the same stable (source kind, source ID, posting_role, account ID) SHALL be recognized as already applied, not inserted again. Oracle strategy must account for NULL source FKs.
- Stock source line reference shall match the corresponding product and posted source document. Each posted source line’s expected stock movement may be applied only once per distinct authorized movement role; incremental supplier receipts use a locked cumulative quantity and stable event identity.
- Prevent customer/supplier/loan balance underflow except an approved temporary return credit awaiting actual refund or a separately approved audited credit/advance use case. Identify such credits separately.
- ACCOUNT_TRANSFERS.from_account_id and .to_account_id must be distinct eligible settlement accounts; positive amounts, document state, transfer type, source funds, executed conversion rate, immutable FX snapshots and two unique ledger roles are mandatory at posting.
- EXCHANGE_RATE_HISTORY must be unique by currency/effective timestamp, append-only after recording, attributable to a user, and consistent with the CURRENCIES current rate. There is no inferred FX gain/loss ledger posting.
- Warranty dates must be paired, ordered and immutable on posted sale lines. Store repairs require defective stock; customer repairs require customer identity and cannot reference store stock. Approved repair bills, costs and receipts must reconcile in the same currency; zero charge/cost allowed where appropriate.
- Supplier return lines must match original purchase/product and available stock, with verified provenance, separate dispatch/receipt roles and bounded cumulative quantities and refunds. Defective records must conserve quantities across splits and disposition. All custody events and repair history must be attributable; no concurrent incompatible actions.

## 6. Document lifecycles and posting eligibility

| Domain | DRAFT behavior | POSTED behavior | REVERSED behavior |
| --- | --- | --- | --- |
| Sale | Editable; no stock or monetary impact | Freeze lines/totals; reduce stock; post receivable/settlements | Original preserved; compensating stock and monetary movements; link reason and actor |
| Purchase | Editable; no stock or monetary impact | Freeze lines/totals; receive stock; establish payable and payments | Compensating movements subject to physical goods check |
| Sale return | Editable; no stock/refund impact | Validate cumulative quantity, condition, credit/refund and movement | Compensate earlier effects; never silently delete |
| Payment | Entered but no balance impact | Cash and party-account movements; allocated against source | Reverse account effects with compensating movements |
| Loan repayment | Entered but does not reduce balance | Counterparty and funds movements; update derived loan totals | Restore principal outstanding with reversals and audit |
| Supplier return | Editable; no stock or finance impact | Dispatch and approved resolution tracked separately; actual receipts/refunds posted once | Compensate physical and financial effects with traceable authorization |
| Repair billing | Editable quote; no financial impact | Freeze authorized charge/cost; post obligation and actual payments independently | Reverse approved financial effects; preserve repair activity history |
| Account transfer | Editable; no account or monetary impact | Source OUT and destination IN; atomic posting, immutable values and two linked ledger legs | Preserve original and compensate both legs atomically with approval |

Posting preconditions: valid actor; posted source where required; at least one item line for line-based documents; valid currency and rate; enough stock; correct party/account linkage; nonnegative remaining obligations except approved temporary refund credits; no existing posting identity; and all required approvals. Posted documents must keep their original amounts even after a rate or catalog price change.

## 7. Payment, account and ledger semantics

Account balance direction rule: In the operational ledger IN means increase this account’s displayed balance, and OUT means decrease this account’s displayed balance. For cash this coincides with physical cash movement; for a receivable/payable account it means increasing/decreasing the obligation. It is not an accounting debit/credit representation.

Party-account classification: CUSTOMER_RECEIVABLE, SUPPLIER_PAYABLE, PERSON_RECEIVABLE, PERSON_PAYABLE track positive outstanding balances; CASH, BANK, MOBILE_MONEY track available funds. A single entry is not sufficient to represent payment settlement when two distinct accounts change. Never sum all account types as though they were profit or a unified cash balance.

Reversal rule: Do not delete the original posted ledger movement. Create an equal and opposite compensating movement, linked by a group/adjustment reference, then make reporting include original and valid compensating movements. Source-specific derived totals (e.g., valid repayments) exclude reversed source payments so totals still reconcile.

### 7.1 Required account-movement scenarios (illustrative, no tax/interest)

| Event | Movement 1 | Movement 2 | Extra effect |
| --- | --- | --- | --- |
| Registered-customer credit sale 100 USD | Customer USD receivable IN 100 | — | Stock sale movement; receivable remains 100 until payment |
| Collection of 40 USD against that sale | USD cash IN 40 | Customer USD receivable OUT 40 | Posted payment; outstanding 60 |
| Supplier credit purchase 500 AFN | Supplier AFN payable IN 500 | — | Receipt increases inventory |
| Supplier settlement 200 AFN | AFN cash OUT 200 | Supplier AFN payable OUT 200 | Remaining payable 300 |
| Store gives person a loan 1,000 AFN | Person receivable IN 1,000 | AFN cash OUT 1,000 | Loan outstanding 1,000 |
| Person repays 250 AFN on given loan | Person receivable OUT 250 | AFN cash IN 250 | Loan remaining 750 |
| Store borrows 1,000 AFN | Person payable IN 1,000 | AFN cash IN 1,000 | Store liability 1,000 |
| Store repays 250 AFN on received loan | Person payable OUT 250 | AFN cash OUT 250 | Liability remaining 750 |
| Registered-customer sale return, 20 USD credited | Customer receivable OUT 20 | — | If previously fully paid, creates 20 credit owed until refund |
| Cash refund of 20 USD for previously paid return | USD cash OUT 20 | Customer receivable IN 20 | Clears the temporary credit created by return |
| Fully-paid anonymous sale | AFN cash IN sale amount | — | No anonymous customer receivable account |
| Cash refund of previously paid anonymous sale | AFN cash OUT refund amount | — | Requires original sale/payment and valid return reference |
| Store moves 5,000 AFN from cash to bank | AFN cash OUT 5,000 | AFN bank IN 5,000 | Same-currency transfer; not revenue or external payment |
| Store exchanges 100 USD into 7,000 AFN at executed 70 AFN/USD | USD cash OUT 100 | AFN cash IN 7,000 | Cross-currency internal transfer; executed rate distinct from reference rates; no automatic FX profit posting |

Illustrative example (not a quoted market rate). For a 100 USD sale posted at 70 AFN/USD, the historical equivalent remains 7,000 AFN even if current rate later changes. A later 40 USD receipt may have its own posting-rate snapshot under the same-currency settlement policy. Those historical AFN equivalents need not arithmetically cancel across different posting dates; the difference is not labeled realized FX profit without a future accounting design.

### 7.2 After-sales posting rules

| Event | Native account movement | Stock/custody effect |
| --- | --- | --- |
| Approved monetary supplier return | Supplier payable OUT for approved credit amount | Dispatch eligible stock; no second deduction for defective stock |
| Actual supplier refund | Settlement IN; supplier payable IN to clear temporary refund credit | No stock effect |
| Supplier replacement or repair receipt | No monetary effect unless separately approved | Actual inspected receipt restores sellable or defective stock |
| Posted chargeable customer repair | Customer receivable IN for approved charge | Customer device remains outside inventory |
| Repair collection | Settlement IN; customer receivable OUT | None |
| Actual store-paid repair cost | Settlement OUT, linked to repair cost payment | None; no inventory costing claim |
| Warranty repair with zero charge | No customer receivable or collection | Record service history; store cost paid separately if incurred |

For a 25,000 AFN purchase with 15,000 paid and 10,000 outstanding, a full approved monetary return reduces payable by 25,000, creating a temporary 15,000 supplier refund credit; actual receipt of 15,000 clears that credit. A fully unpaid purchase generates no cash refund. Reports distinguish outstanding refund credits from positive obligations. Repair billing and supplier return credits are included in account statements and due-date ageing where applicable, not product sales revenue. Payment purpose distinguishes repair collection from repair cost; exactly one source FK per payment and ledger movement. Reversal identities distinguish compensating roles from original roles.

## 8. Inventory movement provenance

| Movement source | Required FK | Direction | Additional validation |
| --- | --- | --- | --- |
| Posted purchase line | INVENTORY_MOVEMENTS.purchase_item_id | Positive | Item belongs to posted purchase; product matches inventory; sellable receipt quantity only |
| Posted sale line | INVENTORY_MOVEMENTS.sale_item_id | Negative | Item belongs to posted sale; cannot drive balance below zero |
| Posted accepted sellable return line | INVENTORY_MOVEMENTS.return_item_id | Positive | Return links to original sale item; condition permits resale |
| Supplier return dispatch/receipt | supplier_return_item_id | Negative dispatch from sellable; positive inspected sellable receipt | Distinct roles; defective dispatch changes custody only |
| Store repair restoration | repair_id | Positive | Successful inspection; close defective record atomically |
| Defect detected in sellable stock | defective_stock_id | Negative | Move quantity into defective stock exactly once |
| Authorized stock adjustment | adjustment_reference plus AUDIT_LOG record | ± | Nonempty reason, actor and approved adjustment; only one source selector |

A movement may not attach to two different source line types. Defective items returned but not restocked remain documented through RETURNS_ITEMS, DEFECTIVE_STOCK and an audit record, not a misleading positive sellable stock change.

## 9. Currency conversion and financial reporting rules

- AFN is base/reporting currency with exchange rate 1. USD and PKR are allowed. A rate is AFN per one unit, not its inverse.
- historical_amount_afn = ROUND(native_amount * frozen_rate_to_afn, 2); per posting, not a current-rate recomputation.
- current_value_afn = native_outstanding_balance * current_rate is a valuation, not a historical posted total; show rate timestamp and valuation date.
- Transactions may be grouped/summed only if currency and valuation basis are compatible. Mixed currency totals require explicitly labeled AFN conversion.
- The source sale/purchase/loan posting and cash collection/repayment can occur on different dates at different rates; preserve each snapshot. Rate history is selected by effective timestamp only for reference; a transfer records its independently agreed executed rate.
- CURRENCIES stores the current rate and EXCHANGE_RATE_HISTORY stores an append-only sequence of reference rates. Posted source documents and transfer legs retain independent immutable posting-time rate snapshots. Internal same-currency and cross-currency transfers are recorded in ACCOUNT_TRANSFERS; cross-currency invoice settlement and automated FX gain/loss accounting are outside v1.0.

## 10. User interface requirements

| Screen | Required contents |
| --- | --- |
| Login | Safe credentials, logout, validation messages |
| Dashboard | Native/AFN summary labels, sales, purchases, collections, outstanding debts, loans and low stock |
| Products/categories | SKU, brand, model, selected child-category, AFN catalog prices, stock/reorder level |
| Inventory history | Signed quantity, source document/line, actor and date; authorized adjustment reason |
| Sales/POS | Registered or fully paid walk-in choice, items, stock, due date, currency, full/partial/credit payments, DRAFT/POSTED status |
| Invoice print | Stable invoice number; customer, user, items, discounts, native total, paid and due, due date, line-level warranty dates |
| Purchases | Supplier, received lines, posting status, currency, due date and payments |
| Returns | Original invoice/line, condition, quantities, accepted credit, actual refund |
| Customer/supplier accounts | Party ID, linked account list by currency, statement drill-down, document/payment history, ageing, opening/closing and running balance |
| Cash/bank accounts | Native opening/current balances and financial movement history |
| Loans/repayments | GIVEN/RECEIVED, person account, funds account, principal, due date, repayments, outstanding |
| Currency management | AFN fixed; authorized USD/PKR rate entry; history listing, effective timestamps, actor, reason and old/new reference-rate display |
| Account transfers | Select source/destination store settlement accounts, amounts, currencies, executed FX rate when applicable, transaction status, printable transfer reference and ledger details |
| Customer account report | Customer summary by currency, account-level statement, invoices, returns, receipts, ageing, running/closing balances and filters |
| Supplier account report | Supplier summary by currency, account-level statement, purchases, payments, credits, ageing, running/closing balances and filters |
| Reports and audit | As-of filters, currency basis, posting and reversal status, user/time/source |
| Repairs | Intake, ownership, device, original invoice, warranty, technician, status, diagnosis, quote, billing and chronological history |
| Supplier returns | Original purchase/line, source stock, dispatch, resolution, actual receipts/refunds and status |
| Defective stock | Origin, quantity, condition, custody, split, disposition and linked repair/return |
| Repair history | Chronological events, actor, technician, status changes and filters |

## 11. Reporting specifications

| Report ID | Report | Inputs | Expected result |
| --- | --- | --- | --- |
| REP-01 | Sales summary | period, product/category/brand, currency | Posted sales and returned amounts, clearly denominated |
| REP-02 | Purchase summary | period, supplier, currency | Posted purchases and outstanding supplier amounts |
| REP-03 | Inventory/low stock | as-of/available scope, product/category | Stock on hand, reorder level, signed movement trace |
| REP-04 | Customer receivables | as-of date, customer, currency | Open invoices, due dates, amounts unpaid, overdue ageing |
| REP-05 | Supplier payables | as-of date, supplier, currency | Open purchases, due dates, amounts unpaid, ageing |
| REP-06 | Loan balances | as-of date, GIVEN/RECEIVED, currency | Principal, valid repayments, outstanding, overdue flag |
| REP-07 | Account statement | account, period | Opening, chronological IN/OUT, running balance, closing native total |
| REP-08 | Cashflow operational | period, settlement account | Cash/bank IN/OUT; exclude party-account movements from cash totals |
| REP-09 | FX historical register | period, source, currency | Native amount, frozen rate, historical AFN equivalent |
| REP-10 | Current valuation | as-of date/rate time, account | Native outstanding × current AFN rate, separately labeled |
| REP-11 | Audit/report history | user, source, period | Reversals, adjustments, rate changes, reports generated |
| REP-12 | Integrity exceptions | as-of / admin | Duplicate/missing posting, negative or mismatched balances, orphan movements and incomplete transfer legs |
| REP-13 | Customer account detail | customer, account, currency, date interval/as-of | Linked customer accounts and their invoice/return/payment movement statements, opening/closing balance and ageing |
| REP-14 | Supplier account detail | supplier, account, currency, date interval/as-of | Linked supplier accounts and purchase/payment movement statements, opening/closing balance and ageing |
| REP-15 | Party-account overview | party type, currency, as-of | Customer/supplier balance summaries, per-account native balances and separately labeled AFN valuation |
| REP-16 | Account transfer register | transfer reference, account, currency, date/status | Both native transfer legs, executed FX rates, original/compensating posting links; internal transfers excluded from external cashflow totals |
| REP-17 | Exchange-rate history | currency, effective/recorded dates, actor | Append-only reference rate chronology, old/new rate, reason and attribution |
| REP-18 | Warranty register | invoice, product, date, status | Per-item coverage dates and derived eligibility |
| REP-19 | Repair cases and history | customer, product, serial, technician, date, status | Case chronology, warranty decision and resolution |
| REP-20 | Repair financial report | date, case, currency | Approved charges, actual costs, collected and outstanding; native and AFN basis |
| REP-21 | Supplier return register | supplier, purchase, product, date, resolution | Dispatched/received quantities, approved credits, actual refunds and pending resolution |
| REP-22 | Defective stock report | product, origin, condition, custody, date | In-store defective quantities, supplier custody and terminal dispositions, no double count |

## 12. Security and non-functional requirements

| ID | Requirement / acceptance evidence |
| --- | --- |
| NFR-01 | Strong password hashing; session control; RBAC on every protected route; CSRF checks; no secrets in source code |
| NFR-02 | Oracle SQL uses bound parameters; no concatenated user SQL; user errors never expose credentials/SQL traces |
| NFR-03 | Atomic Oracle transactions and rollback; concurrency tests for stock, document posting, account balances and repayments |
| NFR-04 | Precision: no binary floating point for monetary amounts; agreed Oracle NUMBER(18,2) for native money and NUMBER(18,6) for exchange rates; one consistent rounding policy |
| NFR-05 | Referential integrity: PK/FK/UNIQUE/CHECK for required relations; additional service validation for cross-table currency/source invariants |
| NFR-06 | Maintainable separation of routes, domain services, repositories and templates; optional JS only enhances forms |
| NFR-07 | Response targets and capacity numbers SHALL be set from a team-agreed representative dataset and test machine before acceptance; no invented response-time SLA |
| NFR-08 | Routine backup, protected backup storage, retention and documented successful restore into isolated test Oracle DB |
| NFR-09 | Finance and stock history audit trail persists original events and compensating reversals |
| NFR-10 | UI displays actionable messages, labels, currency symbols/codes, input errors; invoices print reliably without optional JS |
| NFR-11 | Support common date/time and approved timezone consistently; timestamps in DB and UI SHALL be documented |
| NFR-12 | No legal or tax compliance claim without separately verified applicable legislation and acceptance tests |
| NFR-13 | Concurrency and idempotency: account transfer source/destination balances lock in consistent order; repeated posting cannot duplicate either transfer leg; rate updates are serialized per currency |
| NFR-14 | Financial reports must reconcile by party identifier, account, currency and as-of time; prevent cross-currency native sums and distinguish transfer/internal movement from external cashflow |

## 13. First-release acceptance test matrix

| Test ID | Related FR | Test and expected result |
| --- | --- | --- |
| AT-01 | 01 | Invalid role cannot access loans, user admin or rate changes; password stored hashed |
| AT-02 | 02/03 | Duplicate SKU fails; category cycle fails; referenced item can be deactivated without deleting history |
| AT-03 | 06/07 | Post supplier purchase; exactly one stock increment and traceable origin; repeated submit no duplicate |
| AT-04 | 06/08 | Two concurrent sales for last unit: only one posts and stock never negative |
| AT-05 | 08/09/16 | Draft does not change stock/finances; posted sale freezes totals and generates unique printable invoice |
| AT-06 | 05/13 | Registered credit sale requires valid customer receivable account; invalid name-only mapping blocked |
| AT-07 | 10/14/17 | Partial credit payment updates one cash balance and the correct receivable; aged outstanding matches invoices |
| AT-08 | 04/07/14 | Supplier credit purchase/partial settlement updates supplier payable and cash with correct due-date bucket |
| AT-09 | 11 | Multiple partial returns cannot exceed sold quantity; damaged return does not increase sellable stock |
| AT-10 | 11/17 | Return of already-paid credit sale creates temporary customer credit then refund clears it without negative false balances |
| AT-11 | 15/17 | GIVEN loan origination: person receivable IN, cash OUT; repayment: opposite; loan balance reconciles |
| AT-12 | 15/17 | RECEIVED loan origination: person payable IN, cash IN; repayment: both OUT; loan balance reconciles |
| AT-13 | 12 | AFN base rate immutable; nonpositive rate rejected; USD/PKR postings preserve native amount and frozen AFN equivalent |
| AT-14 | 12/14 | Mismatched payment/account/document currency fails; later rate change does not alter historical values |
| AT-15 | 16/17 | Duplicate posting request makes no second financial/movement impact; original preserved when reversed |
| AT-16 | 17 | Three account types independently reconcile to opening + posted IN − posted OUT, including reversals |
| AT-17 | 18 | Reports do not mix native currencies; historical and current-rate AFN clearly labeled; overdue as-of matches due dates |
| AT-18 | 19 | Audit rows identify actor/reason; backup can be restored and representative totals verified |
| AT-19 | 20 | Browser forms work without JS; errors are comprehensible; invoice prints correctly |
| AT-20 | DB | Invalid FK, negative amounts, invalid status, excessive return and source duplication fail by tested defenses |
| AT-21 | 21/17 | Same-currency AFN cash→bank transfer posts exactly one OUT/one IN, correct balances, no sale/purchase/receivable change |
| AT-22 | 21/12 | Cross-currency USD→AFN transfer preserves both native amounts, executed rate and each leg’s posting-time AFN snapshot; original unchanged after new reference rate |
| AT-23 | 21/16/17 | Duplicate/concurrent transfer posting is idempotent; insufficient funds rejects both legs; authorized reversal compensates both ledger legs |
| AT-24 | 22/12 | Rate update writes immutable history + current rate + audit in one commit; AFN change or invalid/duplicate effective time rejected |
| AT-25 | 23/05/13/14 | Customer account report shows correct customer-only accounts, movement sequence, invoice/payment/return totals, ageing and opening/closing balances |
| AT-26 | 23/04/13/14 | Supplier account report matches supplier ID, payable documents, partial payments, native currency and posted balance; no name-based joins |
| AT-27 | 18/21/23 | Internal transfer legs appear on account statements but are excluded from external receipts/expenses; separate currency totals and valuation bases labeled |
| AT-28 | 24/09 | Warranty dates printed per item; no-warranty null dates; later catalog changes leave posted dates unchanged |
| AT-29 | 24/25 | Warranty lookup verifies original customer/item and dates; active warranty alone does not trigger refund |
| AT-30 | 25/27 | Customer repair does not change store stock; store repair requires matching defective record and inspection before restoration |
| AT-31 | 25/10/17 | Paid/credit repair charge and collections reconcile; actual cost payment separately recorded; warranty zero charge valid; overcollection rejected |
| AT-32 | 26/06/27 | Supplier return dispatch from sellable or defective stock affects correct quantity once; duplicate/concurrent return rejected |
| AT-33 | 26/10/14/17 | Full/partial/unpaid purchase return creates correct supplier credit and actual refund; no fictitious cash posting |
| AT-34 | 26/27 | Replacement/repair receipt counted once after inspection; rejected return custody handled; unsafe reversal rejected |
| AT-35 | 27/06 | Defect detection and split conserve quantities; write-off does not deduct sellable stock twice; restore only after approval |
| AT-36 | 28/25 | Status change and history event atomic; concurrent invalid transitions rejected; history append-only and current status reconciles |
| AT-37 | 23/25/26/27/28 | Authorized account and after-sales reports reconcile native amounts, custody, credits and repair history; restricted costs protected |

## 14. Verification strategy

All mandatory first-release requirements SHALL be verified against the acceptance criteria. Recommended and optional capabilities shall be verified when selected for delivery. Delivery scheduling is maintained separately in the development plan.

## 15. Design boundaries and operating assumptions

- The FCSMS v1.0 core model uses the 30 entities in Section 4, including the currency master, internal transfer records and immutable exchange-rate history.
- LEDGER_TRANSACTIONS records operational account movements and source references.
- INVENTORY maintains one aggregate sellable quantity per product; DEFECTIVE_STOCK tracks non-sellable store-owned units and their custody separately.
- The currency master maintains current AFN conversion rates; immutable rate-history events preserve earlier reference rates; transaction-level snapshots preserve historical posting values.
- Receivables and payables are derived from sales, purchases, approved repair bills and returns, with identifiable party-account links; interest-free loan balances derive from principal and posted repayments.
- When a person has different account roles (for example, borrower and lender), the system may maintain distinct typed financial accounts linked to that person’s business identity.
- Local statutory accounting or tax compliance, hosting capacity and exact recovery targets require environment-specific verification and are not presumed from general ERP features.

## 16. System evolution principles

1. Retain stable document IDs, line IDs and audit history when extending data models or workflows.
2. Implement database evolution with reversible versioned migration scripts, documented data backfill and integrity checks.
3. Assign each new module a requirement identifier, business rules, permissions, traceability design and acceptance tests.
4. Keep all stock and money mutations in domain posting services, with atomic Oracle transactions.
5. Preserve party-account identifiers and account histories when introducing a full general ledger and chart of accounts.
6. Extend currency management with third-party FX settlement, configurable fees, automated revaluation and gain/loss accounting only alongside validated balance semantics. Internal store-account transfers and rate history are core capabilities.
7. Keep additions modular so the sales, purchasing, inventory and finance functions remain operable without optional future modules.

## 17. Reference systems and technical sources

The following products provide functional and technical reference material for system requirements. FCSMS maintains an independent architecture and database design: - ERPNext: submitted sales/purchase invoices, stock ledger entries, posting-time currency rates, payment terms and party-linked receivables; reference: Sales Invoice, Payment Terms, Currency Exchange, Stock Ledger, Chart of Accounts. - Odoo 19: separate draft/posted invoice states, invoice due dates, partial payment reconciliation, serial numbers, returns and multi-currency; reference: Customer invoices, Payment terms, Product tracking, Multi-currency. - Dolibarr: third-party identity, invoices, inventory, loans and modular accounting; reference: User documentation, SQL table documentation, Developer documentation.

Architecture note: FCSMS uses Oracle, Flask and the logical data model in Section 4. ERPNext, Odoo and Dolibarr use different development frameworks and are used for conceptual comparison rather than direct table replication.
