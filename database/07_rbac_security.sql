-- ============================================================================
-- DBMS MINI PROJECT: GYM MEMBERSHIP MANAGER
-- File: 07_rbac_security.sql
-- Students: Priyansh Soni (SRN: PES1UG24CS344)
--           Pulkit Bhardwaj (SRN: PES1UG24CS346)
-- Institution: PES University, Bengaluru
-- Description: DATABASE-LEVEL Role-Based Access Control (MySQL 8.0+)
--              * 3 MySQL roles  : gym_admin_role, gym_trainer_role, gym_member_role
--              * 3 DB accounts  : one per application role (used by the Next.js API)
--              * Views + definer-rights stored procedures give members access
--                ONLY to their own rows (MySQL has no native row-level security)
-- Run AFTER 01-04 (needs tables + the procedures defined there).
-- Run as a privileged account (root).  CHANGE THE PASSWORDS before real use.
-- ============================================================================

USE gym_management_db;

-- ----------------------------------------------------------------------------
-- 1. Safe views (hide password_hash and other sensitive columns)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_member_directory AS
SELECT m.member_id, u.full_name, m.fitness_goal, m.joined_date, m.loyalty_points
FROM members m
JOIN users u ON u.user_id = m.user_id;

CREATE OR REPLACE VIEW v_trainer_directory AS
SELECT t.trainer_id, u.full_name, t.specialization, t.experience_years, t.rating, t.bio
FROM trainers t
JOIN users u ON u.user_id = t.user_id;

-- ----------------------------------------------------------------------------
-- 2. Row-scoped procedures for MEMBERS (run with DEFINER rights, so members
--    never need direct SELECT on subscriptions / payments / members)
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_GetMyProfile;
DELIMITER $$
CREATE PROCEDURE sp_GetMyProfile(IN p_user_id INT)
SQL SECURITY DEFINER
BEGIN
    SELECT m.member_id, u.full_name, u.email, m.fitness_goal, m.loyalty_points,
           m.joined_date, fn_CalculateMemberLoyaltyDiscount(m.member_id) AS discount_percent,
           fn_GetActiveSubscriptionDaysRemaining(m.member_id)            AS days_remaining
    FROM members m
    JOIN users u ON u.user_id = m.user_id
    WHERE m.user_id = p_user_id;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_GetMyPayments;
DELIMITER $$
CREATE PROCEDURE sp_GetMyPayments(IN p_user_id INT)
SQL SECURITY DEFINER
BEGIN
    SELECT pay.invoice_no, pay.amount, pay.payment_date, pay.payment_method, pay.payment_status,
           mp.plan_name
    FROM payments pay
    JOIN members m            ON m.member_id = pay.member_id
    JOIN subscriptions s      ON s.subscription_id = pay.subscription_id
    JOIN membership_plans mp  ON mp.plan_id = s.plan_id
    WHERE m.user_id = p_user_id
    ORDER BY pay.payment_date DESC;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_BookClass;
DELIMITER $$
CREATE PROCEDURE sp_BookClass(IN p_user_id INT, IN p_class_id INT, IN p_booking_date DATE)
SQL SECURITY DEFINER
BEGIN
    DECLARE v_member_id INT;
    SELECT member_id INTO v_member_id FROM members WHERE user_id = p_user_id;
    IF v_member_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Caller is not a member';
    END IF;
    -- trg_check_class_capacity still fires and enforces the capacity limit
    INSERT INTO class_bookings (class_id, member_id, booking_date, booking_status)
    VALUES (p_class_id, v_member_id, p_booking_date, 'Confirmed');
END$$
DELIMITER ;

-- ----------------------------------------------------------------------------
-- 3. Roles and privileges
-- ----------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'gym_admin_role', 'gym_trainer_role', 'gym_member_role';

-- ADMIN: everything in the gym database
GRANT ALL PRIVILEGES ON gym_management_db.* TO 'gym_admin_role';

-- TRAINER: read operational data, record attendance, update booking status
GRANT SELECT ON gym_management_db.v_member_directory   TO 'gym_trainer_role';
GRANT SELECT ON gym_management_db.v_trainer_directory   TO 'gym_trainer_role';
GRANT SELECT ON gym_management_db.gym_classes           TO 'gym_trainer_role';
GRANT SELECT ON gym_management_db.class_bookings        TO 'gym_trainer_role';
GRANT SELECT ON gym_management_db.trainer_assignments   TO 'gym_trainer_role';
GRANT SELECT ON gym_management_db.membership_plans      TO 'gym_trainer_role';
GRANT SELECT, INSERT ON gym_management_db.attendance_logs TO 'gym_trainer_role';
GRANT UPDATE (booking_status) ON gym_management_db.class_bookings TO 'gym_trainer_role';
-- (no access to users, payments, subscriptions -> trainers cannot see passwords or revenue)

-- MEMBER: browse catalogue, otherwise only the row-scoped procedures above
GRANT SELECT ON gym_management_db.membership_plans  TO 'gym_member_role';
GRANT SELECT ON gym_management_db.gym_classes       TO 'gym_member_role';
GRANT SELECT ON gym_management_db.v_trainer_directory TO 'gym_member_role';
GRANT EXECUTE ON PROCEDURE gym_management_db.sp_GetMyProfile  TO 'gym_member_role';
GRANT EXECUTE ON PROCEDURE gym_management_db.sp_GetMyPayments TO 'gym_member_role';
GRANT EXECUTE ON PROCEDURE gym_management_db.sp_BookClass     TO 'gym_member_role';

-- ----------------------------------------------------------------------------
-- 4. Accounts used by the Next.js API (one connection pool per role)
-- ----------------------------------------------------------------------------
CREATE USER IF NOT EXISTS 'gym_admin_app'@'localhost'   IDENTIFIED BY 'ChangeMe_Admin_1!';
CREATE USER IF NOT EXISTS 'gym_trainer_app'@'localhost' IDENTIFIED BY 'ChangeMe_Trainer_1!';
CREATE USER IF NOT EXISTS 'gym_member_app'@'localhost'  IDENTIFIED BY 'ChangeMe_Member_1!';

GRANT 'gym_admin_role'   TO 'gym_admin_app'@'localhost';
GRANT 'gym_trainer_role' TO 'gym_trainer_app'@'localhost';
GRANT 'gym_member_role'  TO 'gym_member_app'@'localhost';

SET DEFAULT ROLE 'gym_admin_role'   TO 'gym_admin_app'@'localhost';
SET DEFAULT ROLE 'gym_trainer_role' TO 'gym_trainer_app'@'localhost';
SET DEFAULT ROLE 'gym_member_role'  TO 'gym_member_app'@'localhost';

FLUSH PRIVILEGES;

-- ----------------------------------------------------------------------------
-- 5. Verification (screenshot these for the report)
-- ----------------------------------------------------------------------------
SHOW GRANTS FOR 'gym_admin_app'@'localhost'   USING 'gym_admin_role';
SHOW GRANTS FOR 'gym_trainer_app'@'localhost' USING 'gym_trainer_role';
SHOW GRANTS FOR 'gym_member_app'@'localhost'  USING 'gym_member_role';

-- Negative tests - run each while connected as the stated account; each must FAIL:
--   mysql -u gym_member_app  -p gym_management_db -e "SELECT * FROM payments;"        -- ERROR 1142 (SELECT denied)
--   mysql -u gym_trainer_app -p gym_management_db -e "SELECT * FROM users;"           -- ERROR 1142 (SELECT denied)
--   mysql -u gym_trainer_app -p gym_management_db -e "UPDATE gym_classes SET capacity=99;" -- ERROR 1142 (UPDATE denied)
-- Positive tests - must succeed:
--   mysql -u gym_member_app  -p gym_management_db -e "CALL sp_GetMyProfile(7);"
--   mysql -u gym_member_app  -p gym_management_db -e "CALL sp_GetMyPayments(7);"
