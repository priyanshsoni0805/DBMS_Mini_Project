-- ============================================================================
-- DBMS MINI PROJECT: GYM MEMBERSHIP MANAGER
-- File: 04_advanced_sql.sql
-- Students: Priyansh Soni (SRN: PES1UG24CS344)
--           Pulkit Bhardwaj (SRN: PES1UG24CS346)
-- Institution: PES University, Bengaluru
-- Description: Advanced SQL Concepts:
--              1. STORED PROCEDURES (Transactional Member Enrollment & Financial Audit)
--              2. STORED FUNCTIONS (Loyalty Discount Calculator & Subscription Validator)
--              3. DATABASE TRIGGERS (Audit Logging, Capacity Enforcement, Payment Automation)
--              4. ADVANCED CTEs & RECURSIVE CTE (Referral Network Tree Hierarchy)
-- ============================================================================

USE gym_management_db;

-- ============================================================================
-- SECTION 1: STORED PROCEDURES
-- ============================================================================

DROP PROCEDURE IF EXISTS sp_EnrollNewMember;
DELIMITER $$
CREATE PROCEDURE sp_EnrollNewMember(
    IN p_full_name VARCHAR(100),
    IN p_email VARCHAR(120),
    IN p_phone VARCHAR(20),
    IN p_dob DATE,
    IN p_gender VARCHAR(20),
    IN p_emergency_name VARCHAR(100),
    IN p_emergency_phone VARCHAR(20),
    IN p_fitness_goal VARCHAR(150),
    IN p_plan_id INT,
    IN p_payment_method VARCHAR(30),
    IN p_referred_by INT,
    OUT p_out_member_id INT,
    OUT p_out_invoice_no VARCHAR(60),
    OUT p_status_message VARCHAR(255)
)
proc_body: BEGIN
    DECLARE v_user_id INT;
    DECLARE v_plan_duration INT;
    DECLARE v_plan_price DECIMAL(10,2);
    DECLARE v_start_date DATE;
    DECLARE v_end_date DATE;
    DECLARE v_subscription_id INT;
    DECLARE v_inv VARCHAR(60);

    -- Error Handler: Rollback on any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_out_member_id = -1;
        SET p_out_invoice_no = NULL;
        SET p_status_message = 'ERROR: Transaction rolled back due to database constraint violation.';
    END;

    -- Validate plan exists and is active
    SELECT duration_months, total_price 
    INTO v_plan_duration, v_plan_price
    FROM membership_plans
    WHERE plan_id = p_plan_id AND is_active = TRUE;

    IF v_plan_duration IS NULL THEN
        SET p_out_member_id = -1;
        SET p_out_invoice_no = NULL;
        SET p_status_message = 'ERROR: Invalid or inactive membership plan selected.';
        LEAVE proc_body;
    END IF;

    -- START TRANSACTION
    START TRANSACTION;

    -- 1. Insert into USERS table (Role 3 = MEMBER)
    INSERT INTO users (role_id, full_name, email, password_hash, phone, status)
    VALUES (3, p_full_name, p_email, '$2b$10$defaultPlaceholderHashedPassword123', p_phone, 'Active');
    SET v_user_id = LAST_INSERT_ID();

    -- 2. Insert into MEMBERS table
    INSERT INTO members (user_id, date_of_birth, gender, emergency_contact_name, 
                         emergency_contact_phone, fitness_goal, referred_by_member_id, 
                         loyalty_points, joined_date)
    VALUES (v_user_id, p_dob, p_gender, p_emergency_name, 
            p_emergency_phone, p_fitness_goal, p_referred_by, 100, CURDATE());
    SET p_out_member_id = LAST_INSERT_ID();

    -- 3. Calculate Subscription Duration
    SET v_start_date = CURDATE();
    SET v_end_date = DATE_ADD(v_start_date, INTERVAL v_plan_duration MONTH);

    -- 4. Insert into SUBSCRIPTIONS table
    INSERT INTO subscriptions (member_id, plan_id, start_date, end_date, status, auto_renew)
    VALUES (p_out_member_id, p_plan_id, v_start_date, v_end_date, 'Active', TRUE);
    SET v_subscription_id = LAST_INSERT_ID();

    -- 5. Generate Unique Invoice Number & Insert into PAYMENTS
    SET v_inv = CONCAT('INV-', YEAR(CURDATE()), '-', LPAD(FLOOR(RAND() * 90000 + 10000), 5, '0'));
    SET p_out_invoice_no = v_inv;

    INSERT INTO payments (subscription_id, member_id, amount, payment_date, payment_method, payment_status, invoice_no)
    VALUES (v_subscription_id, p_out_member_id, v_plan_price, NOW(), p_payment_method, 'Completed', v_inv);

    -- 6. Award referral bonus points if referred
    IF p_referred_by IS NOT NULL THEN
        UPDATE members 
        SET loyalty_points = loyalty_points + 50 
        WHERE member_id = p_referred_by;

        INSERT INTO audit_logs (action_type, table_name, record_id, new_value, performed_by)
        VALUES ('REFERRAL_BONUS', 'members', p_referred_by, '+50 points awarded for referral', 'sp_EnrollNewMember');
    END IF;

    -- COMMIT TRANSACTION
    COMMIT;
    SET p_status_message = 'SUCCESS: Member enrolled, subscription activated, and payment receipt issued.';
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_GetGymExecutiveKPIs;
DELIMITER $$
CREATE PROCEDURE sp_GetGymExecutiveKPIs()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM members) AS total_registered_members,
        (SELECT COUNT(*) FROM subscriptions WHERE status = 'Active') AS active_subscriptions,
        (SELECT COUNT(*) FROM trainers) AS active_trainers,
        (SELECT COALESCE(SUM(amount), 0.00) FROM payments WHERE payment_status = 'Completed') AS total_gross_revenue,
        (SELECT ROUND(AVG(amount), 2) FROM payments WHERE payment_status = 'Completed') AS average_revenue_per_member,
        (SELECT COUNT(*) FROM class_bookings WHERE booking_date = CURDATE() OR booking_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)) AS recent_class_attendees;
END$$
DELIMITER ;



-- ============================================================================
-- SECTION 2: STORED FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS fn_CalculateMemberLoyaltyDiscount;
DELIMITER $$
CREATE FUNCTION fn_CalculateMemberLoyaltyDiscount(p_member_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_points INT DEFAULT 0;
    DECLARE v_months_active INT DEFAULT 0;
    DECLARE v_discount_percent DECIMAL(5,2) DEFAULT 0.00;

    -- Retrieve loyalty points and tenure
    SELECT 
        loyalty_points, 
        TIMESTAMPDIFF(MONTH, joined_date, CURDATE())
    INTO v_points, v_months_active
    FROM members
    WHERE member_id = p_member_id;

    -- Business Rules for Tiered Loyalty Discount:
    -- Points >= 500 OR 12+ Months active -> 20% discount
    -- Points >= 300 OR 6+ Months active  -> 15% discount
    -- Points >= 150 OR 3+ Months active  -> 10% discount
    -- Default                            -> 5% discount
    IF v_points >= 500 OR v_months_active >= 12 THEN
        SET v_discount_percent = 20.00;
    ELSEIF v_points >= 300 OR v_months_active >= 6 THEN
        SET v_discount_percent = 15.00;
    ELSEIF v_points >= 150 OR v_months_active >= 3 THEN
        SET v_discount_percent = 10.00;
    ELSE
        SET v_discount_percent = 5.00;
    END IF;

    RETURN v_discount_percent;
END$$
DELIMITER ;


DROP FUNCTION IF EXISTS fn_GetActiveSubscriptionDaysRemaining;
DELIMITER $$
CREATE FUNCTION fn_GetActiveSubscriptionDaysRemaining(p_member_id INT) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_days_remaining INT DEFAULT 0;

    SELECT DATEDIFF(end_date, CURDATE())
    INTO v_days_remaining
    FROM subscriptions
    WHERE member_id = p_member_id AND status = 'Active'
    ORDER BY end_date DESC
    LIMIT 1;

    IF v_days_remaining IS NULL OR v_days_remaining < 0 THEN
        SET v_days_remaining = 0;
    END IF;

    RETURN v_days_remaining;
END$$
DELIMITER ;


-- ============================================================================
-- SECTION 3: DATABASE TRIGGERS
-- ============================================================================

-- TRIGGER 1: trg_after_subscription_status_update
-- Automatically audits any change in subscription status into the audit_logs table
DROP TRIGGER IF EXISTS trg_after_subscription_status_update;
DELIMITER $$
CREATE TRIGGER trg_after_subscription_status_update
AFTER UPDATE ON subscriptions
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_logs (
            action_type, 
            table_name, 
            record_id, 
            old_value, 
            new_value, 
            performed_by
        ) VALUES (
            'SUBSCRIPTION_STATUS_CHANGE', 
            'subscriptions', 
            NEW.subscription_id, 
            CONCAT('Status: ', OLD.status), 
            CONCAT('Status: ', NEW.status, ' | MemberID: ', NEW.member_id), 
            'trg_after_subscription_status_update'
        );
    END IF;
END$$
DELIMITER ;


-- TRIGGER 2: trg_check_class_capacity
-- Enforces class room capacity before booking insertion
DROP TRIGGER IF EXISTS trg_check_class_capacity;
DELIMITER $$
CREATE TRIGGER trg_check_class_capacity
BEFORE INSERT ON class_bookings
FOR EACH ROW
BEGIN
    DECLARE v_current_booked INT;
    DECLARE v_max_capacity INT;

    -- Get maximum capacity of the target class
    SELECT capacity INTO v_max_capacity
    FROM gym_classes
    WHERE class_id = NEW.class_id;

    -- Count active bookings for this specific class and date
    SELECT COUNT(*) INTO v_current_booked
    FROM class_bookings
    WHERE class_id = NEW.class_id 
      AND booking_date = NEW.booking_date 
      AND booking_status IN ('Confirmed', 'Attended');

    -- If room capacity reached, abort insert with standard custom error
    IF v_current_booked >= v_max_capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CapacityExceededError: Class room is fully booked for this date!';
    END IF;
END$$
DELIMITER ;


-- TRIGGER 3: trg_after_payment_insert
-- When a payment is recorded as Completed, automatically activates subscription and awards points
DROP TRIGGER IF EXISTS trg_after_payment_insert;
DELIMITER $$
CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.payment_status = 'Completed' THEN
        -- Activate the subscription
        UPDATE subscriptions 
        SET status = 'Active' 
        WHERE subscription_id = NEW.subscription_id;

        -- Award 1 point for every 100 currency units spent
        UPDATE members 
        SET loyalty_points = loyalty_points + FLOOR(NEW.amount / 100)
        WHERE member_id = NEW.member_id;

        -- Audit log entry
        INSERT INTO audit_logs (
            action_type, 
            table_name, 
            record_id, 
            new_value, 
            performed_by
        ) VALUES (
            'PAYMENT_CONFIRMED', 
            'payments', 
            NEW.payment_id, 
            CONCAT('Invoice: ', NEW.invoice_no, ' | Amount: ', NEW.amount), 
            'trg_after_payment_insert'
        );
    END IF;
END$$
DELIMITER ;


-- ============================================================================
-- SECTION 4: ADVANCED CTEs & RECURSIVE CTE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CTE 1: Multi-Level CTE with Window Functions & Plan Tier Benchmarks
-- ----------------------------------------------------------------------------
WITH member_spending AS (
    SELECT 
        m.member_id,
        u.full_name AS member_name,
        mp.tier AS plan_tier,
        mp.plan_name,
        COALESCE(SUM(p.amount), 0) AS total_spend,
        COUNT(p.payment_id) AS total_transactions
    FROM members m
    JOIN users u ON m.user_id = u.user_id
    JOIN subscriptions s ON m.member_id = s.member_id
    JOIN membership_plans mp ON s.plan_id = mp.plan_id
    LEFT JOIN payments p ON s.subscription_id = p.subscription_id
    GROUP BY m.member_id, u.full_name, mp.tier, mp.plan_name
),
tier_averages AS (
    SELECT 
        plan_tier,
        ROUND(AVG(total_spend), 2) AS avg_tier_spend,
        MAX(total_spend) AS max_tier_spend
    FROM member_spending
    GROUP BY plan_tier
),
spending_ranked AS (
    SELECT 
        ms.member_id,
        ms.member_name,
        ms.plan_tier,
        ms.plan_name,
        ms.total_spend,
        ta.avg_tier_spend,
        (ms.total_spend - ta.avg_tier_spend) AS variance_from_tier_avg,
        DENSE_RANK() OVER (PARTITION BY ms.plan_tier ORDER BY ms.total_spend DESC) AS tier_rank,
        ROUND(PERCENT_RANK() OVER (ORDER BY ms.total_spend), 2) AS overall_percentile
    FROM member_spending ms
    JOIN tier_averages ta ON ms.plan_tier = ta.plan_tier
)
SELECT 
    member_id,
    member_name,
    plan_tier,
    plan_name,
    total_spend,
    avg_tier_spend,
    variance_from_tier_avg,
    tier_rank,
    overall_percentile,
    CASE 
        WHEN overall_percentile >= 0.75 THEN 'High Roller / VIP Patron'
        WHEN overall_percentile >= 0.40 THEN 'Consistent Core Member'
        ELSE 'Budget / Occasional Tier'
    END AS member_segment
FROM spending_ranked
ORDER BY total_spend DESC;


-- ----------------------------------------------------------------------------
-- CTE 2: RECURSIVE CTE - Member Referral Tree Network & Commission Attribution
-- Computes the multi-level hierarchical tree of member referrals, measuring
-- referral depth, complete hierarchical ancestral path, and bonus shares!
-- ----------------------------------------------------------------------------
WITH RECURSIVE member_referral_tree AS (
    -- Anchor Member: Root referrers (members who were not referred by anyone)
    SELECT 
        m.member_id,
        u.full_name AS member_name,
        m.referred_by_member_id,
        CAST(u.full_name AS CHAR(500)) AS referral_path,
        0 AS referral_level,
        m.loyalty_points
    FROM members m
    JOIN users u ON m.user_id = u.user_id
    WHERE m.referred_by_member_id IS NULL

    UNION ALL

    -- Recursive Member: Child members referred by parent members in the tree
    SELECT 
        child.member_id,
        child_u.full_name AS member_name,
        child.referred_by_member_id,
        CONCAT(parent.referral_path, ' -> ', child_u.full_name) AS referral_path,
        parent.referral_level + 1 AS referral_level,
        child.loyalty_points
    FROM members child
    JOIN users child_u ON child.user_id = child_u.user_id
    JOIN member_referral_tree parent ON child.referred_by_member_id = parent.member_id
)
SELECT 
    member_id,
    member_name,
    referral_level,
    referral_path,
    loyalty_points,
    -- Compute dynamic recursive referral commission potential
    CASE 
        WHEN referral_level = 0 THEN 'Root Ambassador (Originator)'
        WHEN referral_level = 1 THEN 'Tier 1 Referral (Direct Invite)'
        WHEN referral_level = 2 THEN 'Tier 2 Referral (Sub-Network)'
        ELSE CONCAT('Tier ', referral_level, ' Referral (Extended Network)')
    END AS network_tier_badge
FROM member_referral_tree
ORDER BY referral_level ASC, member_id ASC;