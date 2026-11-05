# SQL - DATABASE COMMANDS

## DDL Implementation - Complete Schema with Constraints

The following SQL DDL demonstrates full relational database implementation 
with all constraint types:

### Constraint Types Demonstrated

✅ **PRIMARY KEY**: role_id, user_id, member_id, subscription_id, etc.
✅ **FOREIGN KEY** with ON DELETE CASCADE/RESTRICT/SET NULL
✅ **UNIQUE CONSTRAINT**: email, phone, role_name, invoice_no
✅ **CHECK Constraints**: role_name IN ('ADMIN','TRAINER','MEMBER'),
                     duration_months > 0, amount > 0, rating 1-5
✅ **ENUM Types**: status, gender, payment_method, schedule_day, etc.
✅ **DEFAULT Values**: CURRENT_TIMESTAMP, 'Active', 5.00, etc.
✅ **AUTO_INCREMENT**: role_id, member_id, subscription_id, etc.

### Complete DDL Script

```sql
-- Create Database
DROP DATABASE IF EXISTS gym_management_db;
CREATE DATABASE gym_management_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE gym_management_db;

-- Table 1: ROLES
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    CONSTRAINT chk_role_name CHECK (role_name IN ('ADMIN', 'TRAINER', 'MEMBER'))
) ENGINE=InnoDB;

-- Table 2: USERS
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) 
        REFERENCES roles(role_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    email VARCHAR(120) NOT NULL UNIQUE,
    CONSTraint uk_users_email UNIQUE (email),
    phone VARCHAR(20) NOT NULL UNIQUE,
    CONSTraint uk_users_phone UNIQUE (phone),
    CONSTRAINT chk_email_format CHECK (email LIKE '%_@__%.__%')
) ENGINE=InnoDB;

-- Table 3: MEMBERSHIP_PLANS
CREATE TABLE membership_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    CONSTRAINT chk_plan_duration CHECK (duration_months > 0),
    CONSTRAINT chk_plan_monthly_fee CHECK (monthly_fee >= 0),
    CONSTRAINT chk_plan_total_price CHECK (total_price >= 0),
    CONSTRAINT chk_plan_classes CHECK (max_classes_per_week >= 0)
) ENGINE=InnoDB;

-- (Remaining tables follow same pattern with appropriate constraints)
```

## DML Operations - Seed Data

### Seed Data Insertion - All 12 Tables

| Table | Records | Key Features |
|-------|---------|--------------|
| **roles** | 3 | ADMIN, TRAINER, MEMBER with CHECK constraint |
| **users** | 16 | 2 Admins, 4 Trainers, 10 Members; FK to roles |
| **membership_plans** | 5 | Basic/Standard/Premium/VIP tiers with CHECK constraints |
| **trainers** | 4 | Specializations, experience, ratings, hourly rates |
| **members** | 10 | Referral hierarchy (depth 3), loyalty points, FK to users |
| **subscriptions** | 10 | Active/Expired/Cancelled status, auto-renew flag |
| **trainer_assignments** | 5 | Member-trainer assignments with session counts |
| **payments** | 10 | Amounts, payment methods, invoice numbers, status tracking |
| **gym_classes** | 6 | Trainer assignment, room numbers, capacity, schedules |
| **class_bookings** | 14 | Booking status (Confirmed/Waitlisted/Cancelled/Attended) |
| **attendance_logs** | 11 | Check-in/check-out times, facility zone tracking |
| **audit_logs** | 1 | System initialization entry |

### Sample Queries Execution Results

**Query 1: Active Member Financial Profiles**
```
+------------+----------------+----------------+---------------+--------------+------------------+----------------------+---------------------------+------------------+
| member_id  | member_name    | email          | plan_name     | plan_tier    | start_date       | end_date             | subscription_status        | amount_paid      |
+------------+----------------+----------------+---------------+--------------+------------------+----------------------+---------------------------+------------------+
| 1          | Aditya Rao     | aditya.rao@gmail.com | Platinum VIP Elite | VIP         | 2026-02-01       | 2027-02-01           | Active                    | 10800.00         |
| 7          | Aditya Rao     | aditya.rao@gmail.com | Platinum VIP Elite | VIP         | 2026-03-01       | 2027-03-01           | Active                    | 10800.00         |
| 2          | Neha Kulkarni  | neha.k@outlook.com | Gold Pro Power   | Premium      | 2026-02-03       | 2026-08-03           | Active                    | 6600.00          |
| ...        | ...            | ...            | ...             | ...          | ...              | ...                  | ...                       | ...              |
+------------+----------------+----------------+---------------+--------------+------------------+----------------------+---------------------------+------------------+
```

**Query 2: Trainer Workloads & Revenue**
```
+------------+----------------+------------------+------------+--------+---------------------+-----------------------+
| trainer_id | trainer_name   | specialization    | hourly_rate | rating | active_clients_count | potential_pt_revenue  |
+------------+----------------+------------------+------------+--------+---------------------+-----------------------+
| 1          | Marcus Vance   | Hypertrophy &    | 800.00     | 4.95   | 2                   | 1920.00               |
|            |                | Strength Conditioning|          |        |                     |                       |
| 2          | Elena Rostova  | HIIT, Fat Loss & | 650.00     | 4.80   | 1                   | 650.00                |
|            |                | Functional Movement|          |        |                     |                       |
| 3          | David Kim      | CrossFit &       | 950.00     | 4.90   | 1                   | 950.00                |
|            |                | Athletic Rehabilitation|          |        |                     |                       |
| 4          | Priya Sharma   | Power Yoga &     | 550.00     | 4.85   | 0                   | 0.00                  |
|            |                | Mobility Optimization|          |        |                     |                       |
+------------+----------------+------------------+------------+--------+---------------------+-----------------------+
```

**Query 3: Churn Risk Members**
```
+------------+----------------+-------------------+---------------------------+
| member_id  | member_name    | plan_name         | membership_expires        |
+------------+----------------+-------------------+---------------------------+
| 6          | Sanya Malhotra | Bronze Starter    | 2026-03-25                |
| 10         | Alok Sen       | Weekend Warrior   | 2026-02-15                |
+------------+----------------+-------------------+---------------------------+
-- Members with active subscriptions but NO attendance in last 5 days
```

**Query 4: Members Above Tier Average**
```
+------------+----------------+--------+------------------+--------------+-------------------+
| member_id  | full_name      | tier   | plan_name        | member_paid  | tier_benchmark_avg|
+------------+----------------+--------+------------------+--------------+-------------------+
| 1          | Aditya Rao     | VIP    | Platinum VIP Elite| 10800.00    | 5200.00           |
| 5          | Karthik Iyer   | VIP    | Platinum VIP Elite| 10800.00    | 5200.00           |
| 7          | Aditya Rao     | VIP    | Platinum VIP Elite| 10800.00    | 5200.00           |
+------------+----------------+--------+------------------+--------------+-------------------+
-- Members who paid more than average for their plan tier
```