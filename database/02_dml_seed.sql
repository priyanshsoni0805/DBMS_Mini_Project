-- ============================================================================
-- DBMS MINI PROJECT: GYM MEMBERSHIP MANAGER
-- File: 02_dml_seed.sql
-- Students: Priyansh Soni (SRN: PES1UG24CS344)
--           Pulkit Bhardwaj (SRN: PES1UG24CS346)
-- Institution: PES University, Bengaluru
-- Description: Comprehensive DML Seed Data for all 12 relational tables
-- ============================================================================

USE gym_management_db;

-- ----------------------------------------------------------------------------
-- 1. Insert ROLES
-- ----------------------------------------------------------------------------
INSERT INTO roles (role_id, role_name, description) VALUES
(1, 'ADMIN', 'Gym general manager with full administrative and financial authority'),
(2, 'TRAINER', 'Certified fitness trainer managing schedules, classes, and member workouts'),
(3, 'MEMBER', 'Standard gym member subscribing to plans and booking classes');

-- ----------------------------------------------------------------------------
-- 2. Insert USERS (Passwords hashed or simulated bcrypt)
-- ----------------------------------------------------------------------------
INSERT INTO users (user_id, role_id, full_name, email, password_hash, phone, status, created_at) VALUES
-- Admins
(1, 1, 'Pulkit Bhardwaj', 'admin@fitpulse.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919876543210', 'Active', '2026-01-01 08:00:00'),
(2, 1, 'Priyansh Soni', 'priyansh.admin@fitpulse.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919876543211', 'Active', '2026-01-05 09:30:00'),

-- Trainers
(3, 2, 'Marcus Vance', 'marcus.v@fitpulse.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919811223344', 'Active', '2026-01-10 10:00:00'),
(4, 2, 'Elena Rostova', 'elena.r@fitpulse.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919822334455', 'Active', '2026-01-12 11:00:00'),
(5, 2, 'David Kim', 'david.k@fitpulse.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919833445566', 'Active', '2026-01-15 08:30:00'),
(6, 2, 'Priya Sharma', 'priya.s@fitpulse.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919844556677', 'Active', '2026-01-20 09:00:00'),

-- Members
(7, 3, 'Aditya Rao', 'aditya.rao@gmail.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919900112233', 'Active', '2026-02-01 10:00:00'),
(8, 3, 'Neha Kulkarni', 'neha.k@outlook.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919911223344', 'Active', '2026-02-03 14:20:00'),
(9, 3, 'Rohan Verma', 'rohan.v@gmail.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919922334455', 'Active', '2026-02-10 11:15:00'),
(10, 3, 'Ananya Patel', 'ananya.p@yahoo.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919933445566', 'Active', '2026-02-15 16:45:00'),
(11, 3, 'Karthik Iyer', 'karthik.i@gmail.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919944556677', 'Active', '2026-02-20 08:10:00'),
(12, 3, 'Sanya Malhotra', 'sanya.m@gmail.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919955667788', 'Active', '2026-02-25 12:00:00'),
(13, 3, 'Vikram Singhania', 'vikram.s@corp.in', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919966778899', 'Active', '2026-03-01 17:30:00'),
(14, 3, 'Meera Nair', 'meera.n@live.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919977889900', 'Active', '2026-03-05 09:40:00'),
(15, 3, 'Tanmay Joshi', 'tanmay.j@gmail.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919988990011', 'Active', '2026-03-10 18:00:00'),
(16, 3, 'Rhea Sen', 'rhea.sen@gmail.com', '$2b$10$e8ZbzK/9P2v77Nf0wIe34.W.r9Kq/k1q3J8D.p39bWw/1A.q2E9K6', '+919999001122', 'Inactive', '2026-01-15 07:45:00');

-- ----------------------------------------------------------------------------
-- 3. Insert MEMBERSHIP_PLANS
-- ----------------------------------------------------------------------------
INSERT INTO membership_plans (plan_id, plan_name, tier, duration_months, monthly_fee, total_price, max_classes_per_week, includes_personal_trainer, is_active) VALUES
(1, 'Bronze Starter', 'Basic', 1, 1500.00, 1500.00, 2, FALSE, TRUE),
(2, 'Silver Fitness', 'Standard', 3, 1300.00, 3900.00, 4, FALSE, TRUE),
(3, 'Gold Pro Power', 'Premium', 6, 1100.00, 6600.00, 6, TRUE, TRUE),
(4, 'Platinum VIP Elite', 'VIP', 12, 900.00, 10800.00, 10, TRUE, TRUE),
(5, 'Weekend Warrior', 'Basic', 1, 1000.00, 1000.00, 2, FALSE, TRUE);

-- ----------------------------------------------------------------------------
-- 4. Insert TRAINERS
-- ----------------------------------------------------------------------------
INSERT INTO trainers (trainer_id, user_id, specialization, experience_years, hourly_rate, rating, bio) VALUES
(1, 3, 'Hypertrophy & Strength Conditioning', 8, 800.00, 4.95, 'Former national powerlifter specializing in progressive overload and barbell mechanics.'),
(2, 4, 'HIIT, Fat Loss & Functional Movement', 6, 650.00, 4.80, 'Certified kettlebell specialist focusing on metabolic conditioning and cardiac stamina.'),
(3, 5, 'CrossFit & Athletic Rehabilitation', 10, 950.00, 4.90, 'Physiotherapy-backed functional training and injury recovery specialist.'),
(4, 6, 'Power Yoga & Mobility Optimization', 5, 550.00, 4.85, 'Ashtanga yoga practitioner improving joint mobility, flexibility, and core stability.');

-- ----------------------------------------------------------------------------
-- 5. Insert MEMBERS (With Referral Trees for Recursive CTE testing)
-- ----------------------------------------------------------------------------
-- Member 1 (Aditya) has no referrer
INSERT INTO members (member_id, user_id, date_of_birth, gender, emergency_contact_name, emergency_contact_phone, fitness_goal, referred_by_member_id, loyalty_points, joined_date) VALUES
(1, 7, '1998-05-14', 'Male', 'Sunil Rao', '+919900000001', 'Muscle Gain & Strength', NULL, 350, '2026-02-01'),
-- Member 2 (Neha) referred by Aditya (1)
(2, 8, '2001-09-22', 'Female', 'Anand Kulkarni', '+919900000002', 'Fat Loss & Core Toning', 1, 220, '2026-02-03'),
-- Member 3 (Rohan) referred by Neha (2) -> Hierarchical depth 2
(3, 9, '1995-12-11', 'Male', 'Manish Verma', '+919900000003', 'Endurance & Stamina', 2, 180, '2026-02-10'),
-- Member 4 (Ananya) referred by Rohan (3) -> Hierarchical depth 3
(4, 10, '2000-04-18', 'Female', 'Pooja Patel', '+919900000004', 'Flexibility & Yoga', 3, 150, '2026-02-15'),
-- Member 5 (Karthik) referred by Aditya (1)
(5, 11, '1997-07-30', 'Male', 'Ganesh Iyer', '+919900000005', 'Athletic Bodybuilding', 1, 280, '2026-02-20'),
-- Other independent members
(6, 12, '1999-03-08', 'Female', 'Rekha Malhotra', '+919900000006', 'General Health', NULL, 120, '2026-02-25'),
(7, 13, '1992-11-05', 'Male', 'Naveen Singhania', '+919900000007', 'Stress Relief & Mobility', NULL, 400, '2026-03-01'),
(8, 14, '2002-01-19', 'Female', 'Radha Nair', '+919900000008', 'Cardio & Agility', 7, 190, '2026-03-05'),
(9, 15, '1996-08-14', 'Male', 'Deepak Joshi', '+919900000009', 'Heavy Powerlifting', NULL, 90, '2026-03-10'),
(10, 16, '1994-10-25', 'Female', 'Alok Sen', '+919900000010', 'Body Recomposition', NULL, 40, '2026-01-15');

-- ----------------------------------------------------------------------------
-- 6. Insert SUBSCRIPTIONS
-- ----------------------------------------------------------------------------
INSERT INTO subscriptions (subscription_id, member_id, plan_id, start_date, end_date, status, auto_renew) VALUES
(1, 1, 4, '2026-02-01', '2027-02-01', 'Active', TRUE),
(2, 2, 3, '2026-02-03', '2026-08-03', 'Active', TRUE),
(3, 3, 2, '2026-02-10', '2026-05-10', 'Active', FALSE),
(4, 4, 2, '2026-02-15', '2026-05-15', 'Active', TRUE),
(5, 5, 4, '2026-02-20', '2027-02-20', 'Active', TRUE),
(6, 6, 1, '2026-02-25', '2026-03-25', 'Expired', FALSE),
(7, 7, 4, '2026-03-01', '2027-03-01', 'Active', TRUE),
(8, 8, 3, '2026-03-05', '2026-09-05', 'Active', TRUE),
(9, 9, 2, '2026-03-10', '2026-06-10', 'Active', TRUE),
(10, 10, 1, '2026-01-15', '2026-02-15', 'Expired', FALSE);

-- ----------------------------------------------------------------------------
-- 7. Insert TRAINER_ASSIGNMENTS
-- ----------------------------------------------------------------------------
INSERT INTO trainer_assignments (assignment_id, member_id, trainer_id, assigned_date, session_count, status) VALUES
(1, 1, 1, '2026-02-02', 24, 'Active'),
(2, 2, 2, '2026-02-05', 12, 'Active'),
(3, 5, 1, '2026-02-22', 20, 'Active'),
(4, 7, 4, '2026-03-02', 15, 'Active'),
(5, 8, 3, '2026-03-06', 12, 'Active');

-- ----------------------------------------------------------------------------
-- 8. Insert PAYMENTS
-- ----------------------------------------------------------------------------
INSERT INTO payments (payment_id, subscription_id, member_id, amount, payment_date, payment_method, payment_status, invoice_no) VALUES
(1, 1, 1, 10800.00, '2026-02-01 10:15:00', 'Credit_Card', 'Completed', 'INV-2026-0001'),
(2, 2, 2, 6600.00, '2026-02-03 14:35:00', 'UPI', 'Completed', 'INV-2026-0002'),
(3, 3, 3, 3900.00, '2026-02-10 11:20:00', 'Net_Banking', 'Completed', 'INV-2026-0003'),
(4, 4, 4, 3900.00, '2026-02-15 16:50:00', 'UPI', 'Completed', 'INV-2026-0004'),
(5, 5, 5, 10800.00, '2026-02-20 08:30:00', 'Credit_Card', 'Completed', 'INV-2026-0005'),
(6, 6, 6, 1500.00, '2026-02-25 12:10:00', 'Debit_Card', 'Completed', 'INV-2026-0006'),
(7, 7, 7, 10800.00, '2026-03-01 17:45:00', 'UPI', 'Completed', 'INV-2026-0007'),
(8, 8, 8, 6600.00, '2026-03-05 09:55:00', 'Net_Banking', 'Completed', 'INV-2026-0008'),
(9, 9, 9, 3900.00, '2026-03-10 18:20:00', 'UPI', 'Completed', 'INV-2026-0009'),
(10, 10, 10, 1500.00, '2026-01-15 08:00:00', 'Cash', 'Completed', 'INV-2026-0010');

-- ----------------------------------------------------------------------------
-- 9. Insert GYM_CLASSES
-- ----------------------------------------------------------------------------
INSERT INTO gym_classes (class_id, class_name, trainer_id, room_number, capacity, schedule_day, start_time, duration_minutes) VALUES
(1, 'Olympic Barbell Technique', 1, 'Studio-A', 15, 'Monday', '06:30:00', 60),
(2, 'Metabolic HIIT Inferno', 2, 'Studio-B', 20, 'Tuesday', '07:00:00', 45),
(3, 'Ashtanga Vinyasa Flow', 4, 'Zen-Room', 12, 'Wednesday', '07:30:00', 60),
(4, 'CrossFit WOD Performance', 3, 'CrossFit-Box', 16, 'Thursday', '18:00:00', 60),
(5, 'Hypertrophy Leg Hyperdrive', 1, 'Main-Floor', 10, 'Friday', '18:30:00', 75),
(6, 'Full-Body Core & Mobility', 4, 'Zen-Room', 15, 'Saturday', '08:00:00', 50);

-- ----------------------------------------------------------------------------
-- 10. Insert CLASS_BOOKINGS
-- ----------------------------------------------------------------------------
INSERT INTO class_bookings (booking_id, class_id, member_id, booking_date, booking_status) VALUES
(1, 1, 1, '2026-03-02', 'Attended'),
(2, 1, 5, '2026-03-02', 'Attended'),
(3, 1, 7, '2026-03-02', 'Attended'),
(4, 2, 2, '2026-03-03', 'Attended'),
(5, 2, 8, '2026-03-03', 'Attended'),
(6, 3, 4, '2026-03-04', 'Attended'),
(7, 3, 7, '2026-03-04', 'Attended'),
(8, 4, 3, '2026-03-05', 'Attended'),
(9, 4, 9, '2026-03-05', 'Attended'),
(10, 5, 1, '2026-03-06', 'Attended'),
(11, 5, 5, '2026-03-06', 'Attended'),
(12, 6, 2, '2026-03-07', 'Confirmed'),
(13, 6, 4, '2026-03-07', 'Confirmed');

-- ----------------------------------------------------------------------------
-- 11. Insert ATTENDANCE_LOGS
-- ----------------------------------------------------------------------------
INSERT INTO attendance_logs (attendance_id, member_id, check_in_time, check_out_time, facility_zone) VALUES
(1, 1, '2026-03-02 06:15:00', '2026-03-02 07:45:00', 'Studio A'),
(2, 5, '2026-03-02 06:20:00', '2026-03-02 08:00:00', 'Free Weights Area'),
(3, 7, '2026-03-02 06:25:00', '2026-03-02 07:35:00', 'Studio A'),
(4, 2, '2026-03-03 06:50:00', '2026-03-03 08:15:00', 'Cardio Deck'),
(5, 8, '2026-03-03 06:55:00', '2026-03-03 08:05:00', 'Cardio Deck'),
(6, 4, '2026-03-04 07:15:00', '2026-03-04 08:45:00', 'Studio A'),
(7, 7, '2026-03-04 07:20:00', '2026-03-04 08:30:00', 'Studio A'),
(8, 3, '2026-03-05 17:45:00', '2026-03-05 19:15:00', 'Main Gym Floor'),
(9, 9, '2026-03-05 17:50:00', '2026-03-05 19:30:00', 'Main Gym Floor'),
(10, 1, '2026-03-06 18:15:00', '2026-03-06 20:00:00', 'Free Weights Area'),
(11, 5, '2026-03-06 18:20:00', '2026-03-06 19:50:00', 'Free Weights Area');

-- ----------------------------------------------------------------------------
-- 12. Insert AUDIT_LOGS (Initial system entries)
-- ----------------------------------------------------------------------------
INSERT INTO audit_logs (action_type, table_name, record_id, old_value, new_value, performed_by) VALUES
('SYSTEM_INIT', 'SYSTEM', 0, NULL, 'Database schema initialized and seed data successfully populated', 'ADMIN_PULKIT');