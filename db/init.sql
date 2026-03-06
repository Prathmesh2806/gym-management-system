-- ══════════════════════════════════════════════════════════════════
-- GYM APP — MySQL Schema Initialization
-- ══════════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS gymapp;
USE gymapp;

-- ── Classes (seeded data) ─────────────────────────────────────────
CREATE TABLE classes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    instructor VARCHAR(100) NOT NULL,
    time VARCHAR(10) NOT NULL,
    duration INT NOT NULL,
    capacity INT NOT NULL,
    day VARCHAR(20) NOT NULL
);

INSERT INTO classes (name, instructor, time, duration, capacity, day) VALUES
('Morning Yoga',        'Sarah Lee',    '07:00', 60, 20, 'Monday'),
('HIIT Blast',          'Mike Torres',  '08:30', 45, 15, 'Monday'),
('Spin Cycle',          'Alex Johnson', '10:00', 45, 25, 'Tuesday'),
('Strength Training',   'Chris Patel',  '12:00', 60, 12, 'Tuesday'),
('Pilates',             'Sarah Lee',    '14:00', 50, 18, 'Wednesday'),
('Boxing Fundamentals', 'Mike Torres',  '16:00', 60, 10, 'Wednesday'),
('Zumba Dance',         'Lisa Chen',    '18:00', 55, 30, 'Thursday'),
('CrossFit WOD',        'Chris Patel',  '06:00', 60, 15, 'Friday'),
('Evening Stretch',     'Sarah Lee',    '19:00', 30, 25, 'Friday'),
('Weekend Bootcamp',    'Mike Torres',  '09:00', 75, 20, 'Saturday');

-- ── Bookings ──────────────────────────────────────────────────────
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    class_name VARCHAR(100) NOT NULL,
    instructor VARCHAR(100) NOT NULL,
    time VARCHAR(10) NOT NULL,
    day VARCHAR(20) NOT NULL,
    member_name VARCHAR(100) NOT NULL,
    member_email VARCHAR(150) DEFAULT '',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

-- ── Membership Plans (seeded data) ────────────────────────────────
CREATE TABLE plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration VARCHAR(20) NOT NULL,
    features JSON NOT NULL
);

INSERT INTO plans (name, price, duration, features) VALUES
('Basic',           29.99,  '1 month',   '["Gym access", "Locker room"]'),
('Standard',        49.99,  '1 month',   '["Gym access", "Locker room", "Group classes", "Sauna"]'),
('Premium',         79.99,  '1 month',   '["Gym access", "Locker room", "All classes", "Sauna", "Personal trainer (2x/mo)", "Nutrition plan"]'),
('Annual Basic',   299.99,  '12 months', '["Gym access", "Locker room"]'),
('Annual Premium', 799.99,  '12 months', '["Gym access", "Locker room", "All classes", "Sauna", "Personal trainer (4x/mo)", "Nutrition plan", "Free merchandise"]');

-- ── Members ───────────────────────────────────────────────────────
CREATE TABLE members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(30) DEFAULT '',
    plan_id INT NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    plan_price DECIMAL(10,2) NOT NULL,
    status ENUM('active','inactive') DEFAULT 'active',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES plans(id)
);

-- ── Notifications ─────────────────────────────────────────────────
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50) NOT NULL,
    message VARCHAR(500) NOT NULL,
    data JSON,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
