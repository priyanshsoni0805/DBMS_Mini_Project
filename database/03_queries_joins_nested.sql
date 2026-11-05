-- ============================================================================
-- DBMS MINI PROJECT: GYM MEMBERSHIP MANAGER
-- File: 03_queries_joins_nested.sql
-- Students: Priyansh Soni (SRN: PES1UG24CS344)
--           Pulkit Bhardwaj (SRN: PES1UG24CS346)
-- Institution: PES University, Bengaluru
-- Description: Comprehensive SQL Queries demonstrating:
--              1. Multi-Table INNER JOINs
--              2. LEFT OUTER JOINs with aggregation
--              3. SELF JOIN on hierarchical referral relationship
--              4. CORRELATED Subquery with partitioned benchmarks
--              5. NESTED Subquery with NOT EXISTS (Churn Risk Analysis)
--              6. SET Operations (UNION / INTERSECT / EXCEPT emulation)
-- ============================================================================

USE gym_management_db;

-- ----------------------------------------------------------------------------
-- QUERY 1: Multi-Table INNER JOIN
-- Objective: Retrieve active member financial and subscription profiles by joining
--            USERS, MEMBERS, SUBSCRIPTIONS, MEMBERSHIP_PLANS, and PAYMENTS.
-- ----------------------------------------------------------------------------
SELECT 
    m.member_id,
    u.full_name AS member_name,
    u.email,
    p.plan_name,
    p.tier AS plan_tier,
    s.start_date,
    s.end_date,
    s.status AS subscription_status,
    pay.amount AS amount_paid,
    pay.payment_method,
    pay.invoice_no
FROM members m
INNER JOIN users u ON m.user_id = u.user_id
INNER JOIN subscriptions s ON m.member_id = s.member_id
INNER JOIN membership_plans p ON s.plan_id = p.plan_id
INNER JOIN payments pay ON s.subscription_id = pay.subscription_id
WHERE s.status = 'Active'
ORDER BY pay.amount DESC, m.member_id ASC;


-- ----------------------------------------------------------------------------
-- QUERY 2: LEFT OUTER JOIN with Aggregation & GROUP BY
-- Objective: Evaluate trainer workloads and total personal training revenue,
--            including trainers who currently have zero active assignments.
-- ----------------------------------------------------------------------------
SELECT 
    t.trainer_id,
    u.full_name AS trainer_name,
    t.specialization,
    t.hourly_rate,
    t.rating,
    COUNT(ta.assignment_id) AS active_clients_count,
    COALESCE(SUM(ta.session_count * t.hourly_rate), 0.00) AS potential_pt_revenue,
    COUNT(DISTINCT gc.class_id) AS scheduled_classes_count
FROM trainers t
INNER JOIN users u ON t.user_id = u.user_id
LEFT JOIN trainer_assignments ta ON t.trainer_id = ta.trainer_id AND ta.status = 'Active'
LEFT JOIN gym_classes gc ON t.trainer_id = gc.trainer_id
GROUP BY t.trainer_id, u.full_name, t.specialization, t.hourly_rate, t.rating
ORDER BY active_clients_count DESC, t.rating DESC;


-- ----------------------------------------------------------------------------
-- QUERY 3: SELF JOIN on Hierarchical Referral Relationship
-- Objective: Map member-to-member referrals showing who referred whom and
--            the respective loyalty rewards earned.
-- ----------------------------------------------------------------------------
SELECT 
    referrer_u.full_name AS referrer_name,
    referrer_u.email AS referrer_email,
    m_ref.loyalty_points AS referrer_points,
    referee_u.full_name AS invited_member_name,
    referee_u.email AS invited_member_email,
    m_child.joined_date AS invited_member_joined
FROM members m_child
INNER JOIN members m_ref ON m_child.referred_by_member_id = m_ref.member_id
INNER JOIN users referee_u ON m_child.user_id = referee_u.user_id
INNER JOIN users referrer_u ON m_ref.user_id = referrer_u.user_id
ORDER BY referrer_name ASC, invited_member_joined DESC;


-- ----------------------------------------------------------------------------
-- QUERY 4: CORRELATED SUBQUERY
-- Objective: Identify members who have paid MORE than the average payment
--            made by all members enrolled in the exact same membership plan tier.
-- ----------------------------------------------------------------------------
SELECT 
    m.member_id,
    u.full_name,
    mp.tier,
    mp.plan_name,
    pay.amount AS member_paid,
    (
        SELECT ROUND(AVG(p_inner.amount), 2)
        FROM payments p_inner
        JOIN subscriptions s_inner ON p_inner.subscription_id = s_inner.subscription_id
        JOIN membership_plans mp_inner ON s_inner.plan_id = mp_inner.plan_id
        WHERE mp_inner.tier = mp.tier
    ) AS tier_benchmark_avg
FROM members m
JOIN users u ON m.user_id = u.user_id
JOIN subscriptions s ON m.member_id = s.member_id
JOIN membership_plans mp ON s.plan_id = mp.plan_id
JOIN payments pay ON s.subscription_id = pay.subscription_id
WHERE pay.amount >= (
    SELECT AVG(p2.amount)
    FROM payments p2
    JOIN subscriptions s2 ON p2.subscription_id = s2.subscription_id
    JOIN membership_plans mp2 ON s2.plan_id = mp2.plan_id
    WHERE mp2.tier = mp.tier
)
ORDER BY member_paid DESC;


-- ----------------------------------------------------------------------------
-- QUERY 5: NESTED SUBQUERY with NOT EXISTS (Member Retention & Churn Risk)
-- Objective: Detect members with active subscriptions who have NOT checked in
--            or logged any gym attendance during the current evaluation cycle.
-- ----------------------------------------------------------------------------
SELECT 
    m.member_id,
    u.full_name AS member_name,
    u.email,
    u.phone,
    mp.plan_name,
    s.end_date AS membership_expires
FROM members m
JOIN users u ON m.user_id = u.user_id
JOIN subscriptions s ON m.member_id = s.member_id
JOIN membership_plans mp ON s.plan_id = mp.plan_id
WHERE s.status = 'Active'
  AND NOT EXISTS (
      SELECT 1 
      FROM attendance_logs al 
      WHERE al.member_id = m.member_id 
        AND al.check_in_time >= DATE_SUB('2026-03-07 23:59:59', INTERVAL 5 DAY)
  );


-- ----------------------------------------------------------------------------
-- QUERY 6: DML OPERATIONS (Insert, Update with calculation, Conditional Delete)
-- Objective: Demonstrate business transactions (Renewal payment and member upgrade)
-- ----------------------------------------------------------------------------
-- Update loyalty points based on attendance count
UPDATE members m
SET loyalty_points = loyalty_points + (
    SELECT COUNT(*) * 10
    FROM attendance_logs al
    WHERE al.member_id = m.member_id
)
WHERE m.member_id > 0;

-- Verify update
SELECT m.member_id, u.full_name, m.loyalty_points
FROM members m
JOIN users u ON m.user_id = u.user_id
ORDER BY m.loyalty_points DESC
LIMIT 5;