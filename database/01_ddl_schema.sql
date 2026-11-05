-- ============================================================================
-- DBMS MINI PROJECT: GYM MEMBERSHIP MANAGER
-- File: 01_ddl_schema.sql
-- Course: Database Management Systems (UE23CS351A)
-- Students: Priyansh Soni (SRN: PES1UG24CS344)
--           Pulkit Bhardwaj (SRN: PES1UG24CS346)
-- Institution: PES University, Bengaluru
-- Description: Complete SQL DDL Implementation with relational integrity,
--              Primary Keys, Foreign Keys (CASCADE/RESTRICT), Check Constraints,
--              Enums, Unique Constraints, and Default values.
-- ============================================================================

DROP DATABASE IF EXISTS gym_management_db;
CREATE DATABASE gym_management_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE gym_management_db;

-- ----------------------------------------------------------------------------
-- 1. Table: ROLES (Role-Based Access Control)
-- ----------------------------------------------------------------------------
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_role_name CHECK (role_name IN ('ADMIN', 'TRAINER', 'MEMBER'))
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. Table: USERS (Authentication & Profile Identity)
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    status ENUM('Active', 'Inactive', 'Suspended') NOT NULL DEFAULT 'Active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) 
        REFERENCES roles(role_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_email_format CHECK (email LIKE '%_@__%.__%')
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. Table: MEMBERSHIP_PLANS
-- ----------------------------------------------------------------------------
CREATE TABLE membership_plans (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL UNIQUE,
    tier ENUM('Basic', 'Standard', 'Premium', 'VIP') NOT NULL DEFAULT 'Standard',
    duration_months INT NOT NULL,
    monthly_fee DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    max_classes_per_week INT NOT NULL DEFAULT 3,
    includes_personal_trainer BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_plan_duration CHECK (duration_months > 0),
    CONSTRAINT chk_plan_monthly_fee CHECK (monthly_fee >= 0),
    CONSTRAINT chk_plan_total_price CHECK (total_price >= 0),
    CONSTRAINT chk_plan_classes CHECK (max_classes_per_week >= 0)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. Table: TRAINERS
-- ----------------------------------------------------------------------------
CREATE TABLE trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    specialization VARCHAR(100) NOT NULL,
    experience_years INT NOT NULL,
    hourly_rate DECIMAL(10, 2) NOT NULL,
    rating DECIMAL(3, 2) NOT NULL DEFAULT 5.00,
    bio TEXT,
    CONSTRAINT fk_trainers_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT chk_trainer_exp CHECK (experience_years >= 0),
    CONSTRAINT chk_trainer_rate CHECK (hourly_rate >= 0),
    CONSTRAINT chk_trainer_rating CHECK (rating >= 1.00 AND rating <= 5.00)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. Table: MEMBERS
-- ----------------------------------------------------------------------------
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other', 'Prefer Not to Say') NOT NULL DEFAULT 'Prefer Not to Say',
    emergency_contact_name VARCHAR(100) NOT NULL,
    emergency_contact_phone VARCHAR(20) NOT NULL,
    fitness_goal VARCHAR(150) NOT NULL DEFAULT 'General Health & Fitness',
    referred_by_member_id INT NULL,
    loyalty_points INT NOT NULL DEFAULT 0,
    joined_date DATE NOT NULL,
    CONSTRAINT fk_members_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_members_referrer FOREIGN KEY (referred_by_member_id) 
        REFERENCES members(member_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    CONSTRAINT chk_loyalty_points CHECK (loyalty_points >= 0)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 6. Table: SUBSCRIPTIONS
-- ----------------------------------------------------------------------------
CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('Active', 'Expired', 'Cancelled', 'Pending_Payment') NOT NULL DEFAULT 'Pending_Payment',
    auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_subscriptions_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_subscriptions_plan FOREIGN KEY (plan_id) 
        REFERENCES membership_plans(plan_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_subscription_dates CHECK (end_date >= start_date)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. Table: TRAINER_ASSIGNMENTS
-- ----------------------------------------------------------------------------
CREATE TABLE trainer_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    trainer_id INT NOT NULL,
    assigned_date DATE NOT NULL,
    session_count INT NOT NULL DEFAULT 12,
    status ENUM('Active', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Active',
    CONSTRAINT fk_assignments_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_assignments_trainer FOREIGN KEY (trainer_id) 
        REFERENCES trainers(trainer_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_session_count CHECK (session_count >= 0)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 8. Table: PAYMENTS
-- ----------------------------------------------------------------------------
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Credit_Card', 'Debit_Card', 'UPI', 'Net_Banking', 'Cash') NOT NULL,
    payment_status ENUM('Completed', 'Pending', 'Failed', 'Refunded') NOT NULL DEFAULT 'Completed',
    invoice_no VARCHAR(60) NOT NULL UNIQUE,
    CONSTRAINT fk_payments_subscription FOREIGN KEY (subscription_id) 
        REFERENCES subscriptions(subscription_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_payments_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT chk_payment_amount CHECK (amount > 0)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 9. Table: GYM_CLASSES
-- ----------------------------------------------------------------------------
CREATE TABLE gym_classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    trainer_id INT NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    capacity INT NOT NULL,
    schedule_day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    start_time TIME NOT NULL,
    duration_minutes INT NOT NULL,
    CONSTRAINT fk_classes_trainer FOREIGN KEY (trainer_id) 
        REFERENCES trainers(trainer_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_class_capacity CHECK (capacity > 0),
    CONSTRAINT chk_class_duration CHECK (duration_minutes > 0)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 10. Table: CLASS_BOOKINGS
-- ----------------------------------------------------------------------------
CREATE TABLE class_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    member_id INT NOT NULL,
    booking_date DATE NOT NULL,
    booking_status ENUM('Confirmed', 'Waitlisted', 'Cancelled', 'Attended') NOT NULL DEFAULT 'Confirmed',
    booked_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bookings_class FOREIGN KEY (class_id) 
        REFERENCES gym_classes(class_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_bookings_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT uq_member_class_date UNIQUE (class_id, member_id, booking_date)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 11. Table: ATTENDANCE_LOGS
-- ----------------------------------------------------------------------------
CREATE TABLE attendance_logs (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    check_in_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_out_time DATETIME NULL,
    facility_zone ENUM('Main Gym Floor', 'Cardio Deck', 'Free Weights Area', 'Studio A', 'Pool & Spa') 
        NOT NULL DEFAULT 'Main Gym Floor',
    CONSTRAINT fk_attendance_member FOREIGN KEY (member_id) 
        REFERENCES members(member_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 12. Table: AUDIT_LOGS (For Automatic Database Triggers)
-- ----------------------------------------------------------------------------
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    old_value TEXT NULL,
    new_value TEXT NULL,
    performed_by VARCHAR(100) NOT NULL DEFAULT 'SYSTEM_TRIGGER',
    log_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;