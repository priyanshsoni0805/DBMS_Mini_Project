# DBMS MINI PROJECT REPORT
## GYM MEMBERSHIP MANAGER

### Title Page

```
DBMS MINI PROJECT REPORT
----------------------

Course Code: UE23CS351A
Course Title: Database Management Systems
Institution: PES University, Bengaluru

Project Title: GYM MEMBERSHIP MANAGER
Students:
1. Priyansh Soni     (SRN: PES1UG24CS344)
2. Pulkit Bhardwaj   (SRN: PES1UG24CS346)

Date: November 2026
```

### Abstract

```
This project implements a comprehensive Gym Membership Management System 
demonstrating relational database design, NoSQL document storage, and 
vector-based semantic search capabilities. The system encompasses:

1. Relational Schema: 12 normalized tables with primary keys, foreign keys, 
   check constraints, enum values, and unique constraints implementing 
   role-based access control (ADMIN/TRAINER/MEMBER), membership plans, 
   trainer assignments, payment processing, class bookings, and attendance 
   logging with full referential integrity.

2. NoSQL Database: MongoDB document store with JSON Schema validation for 
   member biometrics, cardiovascular metrics, health flags, wearable sensor 
   data, and historical check-ins with compound indexes for performance.

3. Vector Database: Custom Python implementation generating dense semantic 
   embeddings from workout plan text descriptions using a domain-specific 
   lexicon, enabling cosine similarity-based recommendations for members 
   based on their fitness goals, injuries, or preferences.

4. Advanced Features: Stored procedures, functions, database triggers, 
   recursive CTEs for referral network analysis, and correlated/sub-queries 
   for churn risk analysis and tier benchmarking.

The system integrates SQL relational integrity, NoSQL flexibility, and 
modern vector search to provide a complete gym management solution.
```

### Technology Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| **RDBMS** | MySQL / PostgreSQL | Relational data model with ACID transactions, constraints, and stored procedures |
| **NoSQL** | MongoDB | Document store with JSON Schema validation, flexible schema, and scalable storage |
| **Vector** | Python (Custom implementation) | Dense semantic embeddings and cosine similarity search for workout recommendations |
| **Frontend** | Next.js (to be integrated) | Web interface for member/trainer/admin interactions |
| **Programming** | Python, SQL | Data processing, analytics, and database operations |
| **Tools** | Git/GitHub | Version control and collaboration |

### Project Overview

The DBMS Mini Project - "Gym Membership Manager" is a comprehensive system 
that addresses modern gym management requirements through three complementary 
data management paradigms:

**1. Relational Database (SQL)**
- 12 fully normalized tables with proper integrity constraints
- Role-Based Access Control (RBAC) with ADMIN, TRAINER, and MEMBER roles
- Transactional processing with ACID compliance
- Stored procedures and functions for business logic encapsulation
- Database triggers for automated audit logging and capacity enforcement
- Recursive CTEs for hierarchical referral network analysis

**2. NoSQL Document Database (MongoDB)**
- Flexible schema with JSON Schema validation rules
- Compound indexes for high-performance query execution
- Document-based storage for member biometrics and wearable telemetry
- Atomic update operators ($push, $set, $inc) for progress tracking
- Health flag filtering and blood pressure metric queries

**3. Vector Similarity Search**
- Dense semantic embeddings from text descriptions using domain lexicon
- Cosine similarity-based workout plan recommendations
- L2 vector normalization for consistent similarity measurements
- CRUD operations with metadata-rich document storage
- Intelligent search based on user fitness goals, injuries, and preferences

### Originality and Contribution

This project demonstrates original integration of three distinct database 
technologies within a single coherent system, addressing the limitations of 
single-technology approaches:
- SQL alone lacks flexibility for evolving biometric data schemas
- NoSQL alone lacks complex transactional integrity and constraint enforcement
- Vector search alone cannot provide the structured data management needed 
  for membership, billing, and class scheduling

The combined approach provides a complete solution that is both technically 
innovative and practically useful for gym management scenarios.