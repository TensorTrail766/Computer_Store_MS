# FCSMS — Forqani Computer Store Management System

**A web-based computer store management system built with Python, Flask, Oracle Database, HTML, and CSS.**

FCSMS is an academic software engineering project designed to streamline computer store operations through centralized product management, inventory tracking, sales and purchases, customer and supplier records, financial transactions, and reporting.

The project emphasizes **data integrity, maintainability, security, and a structured software development process**.

## Project Overview

Traditional computer store operations often rely on manual records or disconnected tools, making it difficult to maintain accurate inventory, monitor financial transactions, and generate reliable reports.

FCSMS aims to address these challenges by providing a unified management platform where authorized employees can manage daily business activities efficiently.

### Project Objectives

- Centralize computer store information.
- Reduce manual recordkeeping and operational errors.
- Maintain accurate inventory and transaction histories.
- Manage sales, purchases, payments, and returns.
- Track customer receivables and supplier payables.
- Monitor loans, repayments, and financial accounts.
- Generate operational and financial reports.
- Enforce role-based access and database integrity.

## Technology Stack

| Component | Technology |
|---|---|
| Frontend | HTML5, CSS3 |
| Backend | Python, Flask |
| Template Engine | Jinja2 |
| Database | Oracle Database |
| Database Connectivity | python-oracledb |
| Database Language | Oracle SQL / PL/SQL |
| Version Control | Git |
| Collaboration | GitHub |
| Development Methodology | Hybrid (Plan-Driven + Agile) |

The application follows a layered architecture that separates presentation, business logic, and database operations.

Core functionality is designed around server-rendered pages and standard HTML forms, without requiring client-side JavaScript.

## Planned System Features

### Authentication and User Management

- Secure user authentication and logout.
- Role-based authorization.
- User account activation and deactivation.
- Employee information management.
- User activity auditing.

**Supported roles:** Administrator, Manager, Sales Staff, and Inventory Staff.

### Product and Category Management

- Product registration, modification, and searching.
- Unique SKU identification.
- Product brands, models, descriptions, and pricing.
- Hierarchical categories and subcategories.
- Product activation and deactivation.

### Inventory Management

- Real-time stock quantity tracking.
- Stock increases and decreases.
- Inventory movement history.
- Low-stock and out-of-stock identification.
- Inventory adjustments with responsible-user tracking.

### Sales and Purchase Management

- Sales transactions and invoice generation.
- Supplier purchase records.
- Multiple products per transaction.
- Full, partial, and credit payments.
- Transaction totals and payment status.
- Customer and supplier transaction histories.

### Returns and Refunds

- Sales return registration.
- Return-item tracking.
- Partial returns.
- Refund recording.
- Stock restoration based on returned-item condition.

### Financial Management

- Financial account registration.
- Incoming and outgoing payments.
- Customer receivables and supplier payables.
- Loans given and received.
- Loan repayment tracking.
- Financial ledger transactions.
- Account balance monitoring.
- Transaction and payment history.

### Reporting and Auditing

- Sales and purchase reports.
- Inventory and low-stock reports.
- Customer and supplier summaries.
- Financial account statements.
- Loan and repayment reports.
- Ledger transaction history.
- Report-generation history.
- User activity logs.

## System Architecture

FCSMS follows a three-layer architecture:

**1. Presentation Layer**

HTML, CSS, and Jinja2 templates provide the user interface and handle interactions through standard web forms.

**2. Application Layer**

Python and Flask manage request routing, validation, authentication, authorization, and business rules.

**3. Data Layer**

Oracle Database stores application data, while `python-oracledb` provides database connectivity and parameterized SQL execution.

The general request flow is:

`User → HTML Form → Flask Route → Business Logic → Oracle Database → Rendered Response`

## Database Design

The database design is based on the project's Software Requirements Specification (SRS v1.3).

The logical model contains **22 core entities**, organized into the following functional areas:

| Functional Area | Entities |
|---|---|
| User Management | USERS, EMPLOYEES |
| Business Contacts | CUSTOMERS, SUPPLIERS |
| Product Management | PRODUCTS, CATEGORIES |
| Inventory | INVENTORY, INVENTORY_MOVEMENTS |
| Purchases | PURCHASES, PURCHASE_ITEMS |
| Sales | SALES, SALE_ITEMS |
| Returns | RETURNS, RETURNS_ITEMS |
| Payments and Finance | FINANCIAL_ACCOUNT, PAYMENTS, LEDGER_TRANSACTIONS, ACCOUNT_BALANCES |
| Loans | LOANS, LOAN_PAYMENTS |
| Auditing and Reporting | AUDIT_LOG, REPORT_HISTORY |

The design incorporates primary and foreign keys, unique constraints, referential integrity, hierarchical categories, and transaction consistency.

Financial balances and inventory updates must remain consistent with their underlying transaction records.

## Project Structure

The following structure represents the intended organization of the application and may evolve during development.

```text
Computer_Store_MS/
│
├── docs/                  # Project documentation
├── scripts/               # Oracle SQL scripts
├── tests/                 # Application tests
│
├── src/
│   ├── app.py             # Flask application
│   ├── db/                # Database connectivity
│   ├── logic/             # Business logic
│   ├── web/               # Request handlers
│   ├── templates/         # HTML/Jinja2 templates
│   └── static/
│       └── css/           # Stylesheets
│
├── .gitignore
├── requirements.txt
└── README.md
```

## Getting Started

### Prerequisites

Before running the application, ensure that the following are installed:

- Python 3
- Oracle Database or access to an Oracle database instance
- Git
- A code editor such as Visual Studio Code

### Clone the Repository

```bash
git clone https://github.com/TensorTrail766/Computer_Store_MS.git
cd Computer_Store_MS
```

### Create a Virtual Environment

```bash
python -m venv .venv
```

Activate it on Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

### Install Dependencies

```bash
pip install -r requirements.txt
```

### Configure the Database

Configure the Oracle connection credentials according to the project's database configuration.

Database credentials and other secrets must not be committed to GitHub.

Create the required Oracle database objects using the SQL scripts provided by the project.

### Run the Application

Once the Flask application and database configuration are implemented, start the development server using the project's configured application entry point.

For an application factory named `create_app` in `src/app.py`, the command is:

```bash
flask --app src.app:create_app run --debug
```

The exact startup command and configuration requirements should be verified against the implemented application.

**Note:** Setup instructions may change as development progresses.

## Development Methodology

The project follows a **Hybrid Software Development Approach**, combining structured planning with iterative implementation.

**Plan-Driven Practices**

- Requirements specification.
- Database and system design.
- Architecture documentation.
- Development planning.
- Formal review and validation.

**Agile Practices**

- Feature-based implementation.
- Short development iterations.
- GitHub Issues for task tracking.
- Feature branches and pull requests.
- Continuous team collaboration.
- Incremental testing and integration.

This approach supports academic documentation requirements while allowing the team to develop and refine system modules incrementally.

## GitHub Collaboration Workflow

All team members are encouraged to follow a consistent Git workflow.

**1. Update the main branch**

```bash
git switch main
git pull origin main
```

**2. Create a feature branch**

```bash
git switch -c feature/module-name
```

**3. Commit changes**

```bash
git add .
git commit -m "feat: implement module functionality"
```

**4. Push the branch**

```bash
git push -u origin feature/module-name
```

**5. Open a Pull Request**

Create a pull request targeting `main`, describe the changes, reference the related GitHub Issue, and request review before merging.

Direct pushes to `main` should be avoided during collaborative development.

### Commit Message Conventions

| Prefix | Purpose |
|---|---|
| `feat:` | New functionality |
| `fix:` | Bug fixes |
| `docs:` | Documentation updates |
| `refactor:` | Code restructuring |
| `test:` | Testing changes |
| `chore:` | Maintenance tasks |

## Documentation

Project documentation is maintained in the `docs/` directory.

Planned documentation includes:

- Software Requirements Specification (SRS)
- Entity-Relationship Diagram (ERD)
- Database Design Documentation
- System Architecture Documentation
- Testing and Validation Documentation

Documentation should be updated whenever approved changes affect the system's requirements, design, or implementation.

## Security and Data Integrity

The project is designed to incorporate the following security and integrity practices:

- Secure password hashing.
- Role-based authorization.
- Parameterized database queries.
- Server-side input validation.
- Primary and foreign key enforcement.
- Prevention of duplicate financial postings.
- Atomic inventory and financial transactions.
- Audit trails for sensitive operations.
- Protection of database credentials.
- Database backup and recovery procedures.

## Project Status

**Status: Under Development**

FCSMS is an academic project. Features described in this README represent the intended system scope and should not be interpreted as completed or production-ready functionality unless verified in the implementation.

Development progress is managed through GitHub Issues, branches, commits, and pull requests.

## Project Team

FCSMS is being developed collaboratively by a four-member academic development team.

Responsibilities include frontend development, backend development, database implementation, documentation, testing, and integration.

## Academic Purpose

This repository is maintained for educational and academic purposes, demonstrating practical application of:

- Software engineering principles
- Database design and management
- Web application development
- Object-oriented and modular programming
- Collaborative software development
- Version control and project documentation

---

**FCSMS — Forqani Computer Store Management System**

*An academic project focused on building a structured, reliable, and maintainable computer store management solution.*
