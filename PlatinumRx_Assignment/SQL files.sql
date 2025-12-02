
use platinum;
DROP TABLE IF EXISTS booking_commercials;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  user_id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  phone_number VARCHAR(20),
  mail_id VARCHAR(100),
  billing_address TEXT
);

CREATE TABLE bookings (
  booking_id VARCHAR(50) PRIMARY KEY,
  booking_date DATETIME,
  room_no VARCHAR(20),
  user_id VARCHAR(50)
);

CREATE TABLE items (
  item_id VARCHAR(50) PRIMARY KEY,
  item_name VARCHAR(100),
  item_rate DECIMAL(10,2)
);

CREATE TABLE booking_commercials (
  id VARCHAR(50) PRIMARY KEY,
  booking_id VARCHAR(50),
  bill_id VARCHAR(50),
  bill_date DATETIME,
  item_id VARCHAR(50),
  item_quantity DECIMAL(8,3)
);

-- Sample data for Hotel (same as earlier)
INSERT INTO users VALUES
('u1','John Doe','9700000000','john@example.com','Addr 1'),
('u2','Jane Roe','9711111111','jane@example.com','Addr 2'),
('u3','Sam K','9722222222','sam@example.com','Addr 3'),
('u4','Asha P','9733333333','asha@example.com','Addr 4');

INSERT INTO bookings VALUES
('bk1','2021-09-23 07:36:48','RM-101','u1'),
('bk2','2021-10-05 13:10:00','RM-102','u2'),
('bk3','2021-10-20 19:00:00','RM-103','u1'),
('bk4','2021-11-11 09:00:00','RM-104','u3'),
('bk5','2021-11-30 22:30:00','RM-105','u4'),
('bk6','2021-12-02 08:15:00','RM-106','u1');

INSERT INTO items VALUES
('itm1','Tawa Paratha',18.00),
('itm2','Mix Veg',89.00),
('itm3','Paneer Butter Masala',150.00),
('itm4','Tea',10.00);

INSERT INTO booking_commercials VALUES
('bc1','bk1','bill-100','2021-09-23 12:03:22','itm1',3),
('bc2','bk1','bill-100','2021-09-23 12:03:22','itm4',2),
('bc3','bk2','bill-101','2021-10-05 13:15:00','itm2',1),
('bc4','bk3','bill-102','2021-10-20 19:02:00','itm3',2),
('bc5','bk4','bill-103','2021-11-11 09:30:00','itm2',5),
('bc6','bk5','bill-104','2021-11-30 22:45:00','itm3',1),
('bc7','bk5','bill-104','2021-11-30 22:45:00','itm4',4),
('bc8','bk6','bill-105','2021-12-02 08:20:00','itm1',2);

-- =========================
-- HOTEL QUERIES (A1 - A5) — MySQL compatible
-- =========================

-- A1: For every user, get user_id and last booked room_no
SELECT u.user_id,
       b.room_no,
       b.booking_date
FROM users u
LEFT JOIN (
  SELECT booking_id, user_id, room_no, booking_date,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
  FROM bookings
) b ON u.user_id = b.user_id AND b.rn = 1
ORDER BY u.user_id;

-- A2: booking_id and total billing amount for bookings created in NOV 2021
SELECT b.booking_id,
       ROUND(SUM(bc.item_quantity * i.item_rate), 2) AS total_amount
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE b.booking_date >= '2021-11-01' AND b.booking_date < '2021-12-01'
GROUP BY b.booking_id
ORDER BY total_amount DESC;

-- A3: bill_id and bill amount of bills raised in OCT 2021 having amount > 1000

SELECT bc.bill_id,
       ROUND(SUM(bc.item_quantity * i.item_rate), 2) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-10-01' AND bc.bill_date < '2021-11-01'
GROUP BY bc.bill_id
ORDER BY bill_amount DESC;


-- A4: Most ordered and least ordered item for each month of 2021 (MySQL uses DATE_FORMAT)
WITH monthly_item_qty AS (
  SELECT
    DATE_FORMAT(bc.bill_date, '%Y-%m') AS month,
    bc.item_id,
    i.item_name,
    SUM(bc.item_quantity) AS total_qty
  FROM booking_commercials bc
  JOIN items i ON bc.item_id = i.item_id
  WHERE bc.bill_date >= '2021-01-01' AND bc.bill_date < '2022-01-01'
  GROUP BY month, bc.item_id, i.item_name
),
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY month ORDER BY total_qty DESC) AS rn_desc,
    ROW_NUMBER() OVER (PARTITION BY month ORDER BY total_qty ASC)  AS rn_asc
  FROM monthly_item_qty
)
SELECT
  month,
  MAX(CASE WHEN rn_desc = 1 THEN item_id END)   AS most_ordered_item_id,
  MAX(CASE WHEN rn_desc = 1 THEN item_name END) AS most_ordered_item_name,
  MAX(CASE WHEN rn_desc = 1 THEN total_qty END) AS most_ordered_qty,
  MAX(CASE WHEN rn_asc  = 1 THEN item_id END)   AS least_ordered_item_id,
  MAX(CASE WHEN rn_asc  = 1 THEN item_name END) AS least_ordered_item_name,
  MAX(CASE WHEN rn_asc  = 1 THEN total_qty END) AS least_ordered_qty
FROM ranked
GROUP BY month
ORDER BY month;

-- A5: Customers with the SECOND HIGHEST bill value of each month of 2021
WITH bill_totals AS (
  SELECT
    bc.bill_id,
    b.user_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount,
    DATE_FORMAT(bc.bill_date, '%Y-%m') AS month
  FROM booking_commercials bc
  JOIN bookings b ON bc.booking_id = b.booking_id
  JOIN items i ON bc.item_id = i.item_id
  WHERE bc.bill_date >= '2021-01-01' AND bc.bill_date < '2022-01-01'
  GROUP BY bc.bill_id, b.user_id, month
),
ranked AS (
  SELECT bt.*,
         ROW_NUMBER() OVER (PARTITION BY month ORDER BY bill_amount DESC) AS rn
  FROM bill_totals bt
)
SELECT month, bill_id, user_id, ROUND(bill_amount,2) AS bill_amount
FROM ranked
WHERE rn = 2
ORDER BY month;

-- =========================
-- CLINIC SCHEMA + SAMPLE DATA
-- =========================
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS clinic_sales;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS clinics;

CREATE TABLE clinics (
  cid VARCHAR(50) PRIMARY KEY,
  clinic_name VARCHAR(200),
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100)
);

CREATE TABLE customer (
  uid VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
  oid VARCHAR(50) PRIMARY KEY,
  uid VARCHAR(50),
  cid VARCHAR(50),
  amount DECIMAL(12,2),
  datetime DATETIME,
  sales_channel VARCHAR(50)
);

CREATE TABLE expenses (
  eid VARCHAR(50) PRIMARY KEY,
  cid VARCHAR(50),
  description TEXT,
  amount DECIMAL(12,2),
  datetime DATETIME
);

-- Sample clinic data
INSERT INTO clinics VALUES
('c1','Alpha Clinic','Chennai','Tamil Nadu','India'),
('c2','Beta Clinic','Chennai','Tamil Nadu','India'),
('c3','Gamma Clinic','Bengaluru','Karnataka','India');

INSERT INTO customer VALUES
('cust1','Jon Doe','9700000001'),
('cust2','Maya','9700000002'),
('cust3','Raju','9700000003'),
('cust4','Lina','9700000004'),
('cust5','Omar','9700000005');

INSERT INTO clinic_sales VALUES
('o1','cust1','c1',24999,'2021-09-23 12:03:22','online'),
('o2','cust2','c1',1500,'2021-09-25 10:00:00','walkin'),
('o3','cust3','c2',5000,'2021-10-12 09:30:00','online'),
('o4','cust4','c3',2000,'2021-10-15 11:20:00','tele'),
('o5','cust1','c2',12000,'2021-11-05 14:00:00','online'),
('o6','cust5','c3',300,'2021-11-10 16:00:00','walkin'),
('o7','cust2','c1',7000,'2021-11-12 10:00:00','online'),
('o8','cust3','c3',1000,'2021-09-10 09:00:00','walkin');

INSERT INTO expenses VALUES
('e1','c1','first-aid',557,'2021-09-23 07:36:48'),
('e2','c1','salaries',5000,'2021-09-30 18:00:00'),
('e3','c2','rent',6000,'2021-10-01 00:00:00'),
('e4','c3','supplies',300,'2021-10-05 12:00:00'),
('e5','c2','utilities',400,'2021-11-03 08:00:00'),
('e6','c1','maintenance',1200,'2021-11-20 09:00:00');

-- =========================
-- CLINIC QUERIES (B1 - B5) — MySQL compatible
-- =========================

-- B1: Revenue from each sales_channel in a given year (2021)
SELECT cs.sales_channel, SUM(cs.amount) AS revenue
FROM clinic_sales cs
WHERE YEAR(cs.datetime) = 2021
GROUP BY cs.sales_channel
ORDER BY revenue DESC;

-- B2: Top 10 most valuable customers for a given year (2021)
SELECT cs.uid, c.name, SUM(cs.amount) AS total_spend
FROM clinic_sales cs
LEFT JOIN customer c ON cs.uid = c.uid
WHERE YEAR(cs.datetime) = 2021
GROUP BY cs.uid, c.name
ORDER BY total_spend DESC
LIMIT 10;

-- B3: Month-wise revenue, expense, profit, status for a given year (2021)
-- MySQL does not have FULL OUTER JOIN, so build months via UNION and left join aggregates.

-- revenue by month
WITH revenue_monthly AS (
  SELECT YEAR(datetime) AS yr, MONTH(datetime) AS mon, SUM(amount) AS revenue
  FROM clinic_sales
  WHERE YEAR(datetime) = 2021
  GROUP BY yr, mon
),
expense_monthly AS (
  SELECT YEAR(datetime) AS yr, MONTH(datetime) AS mon, SUM(amount) AS expense
  FROM expenses
  WHERE YEAR(datetime) = 2021
  GROUP BY yr, mon
),
months AS (
  SELECT yr, mon FROM revenue_monthly
  UNION
  SELECT yr, mon FROM expense_monthly
)
SELECT
  m.yr AS year,
  m.mon AS month,
  COALESCE(r.revenue, 0) AS revenue,
  COALESCE(e.expense, 0) AS expense,
  COALESCE(r.revenue, 0) - COALESCE(e.expense, 0) AS profit,
  CASE WHEN COALESCE(r.revenue, 0) - COALESCE(e.expense, 0) > 0 THEN 'profitable' ELSE 'not-profitable' END AS status
FROM months m
LEFT JOIN revenue_monthly r ON m.yr = r.yr AND m.mon = r.mon
LEFT JOIN expense_monthly e ON m.yr = e.yr AND m.mon = e.mon
ORDER BY m.mon;

-- B4: For each city, find the most profitable clinic for a given month (example: Sep 2021)
WITH sales AS (
  SELECT cid, SUM(amount) AS revenue
  FROM clinic_sales
  WHERE datetime >= '2021-09-01' AND datetime < '2021-10-01'
  GROUP BY cid
),
exps AS (
  SELECT cid, SUM(amount) AS expense
  FROM expenses
  WHERE datetime >= '2021-09-01' AND datetime < '2021-10-01'
  GROUP BY cid
),
profit_per_clinic AS (
  SELECT cl.cid, cl.clinic_name, cl.city, cl.state,
         COALESCE(s.revenue,0) AS revenue,
         COALESCE(e.expense,0) AS expense,
         COALESCE(s.revenue,0) - COALESCE(e.expense,0) AS profit
  FROM clinics cl
  LEFT JOIN sales s ON cl.cid = s.cid
  LEFT JOIN exps  e ON cl.cid = e.cid
),
ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY city ORDER BY profit DESC) AS rn
  FROM profit_per_clinic
)
SELECT city, cid, clinic_name, revenue, expense, profit
FROM ranked
WHERE rn = 1
ORDER BY city;

-- B5: For each state, find the second least profitable clinic for a given month (example: Sep 2021)
WITH sales2 AS (
  SELECT cid, SUM(amount) AS revenue
  FROM clinic_sales
  WHERE datetime >= '2021-09-01' AND datetime < '2021-10-01'
  GROUP BY cid
),
exps2 AS (
  SELECT cid, SUM(amount) AS expense
  FROM expenses
  WHERE datetime >= '2021-09-01' AND datetime < '2021-10-01'
  GROUP BY cid
),
profit_per_clinic2 AS (
  SELECT cl.cid, cl.clinic_name, cl.city, cl.state,
         COALESCE(s2.revenue,0) AS revenue,
         COALESCE(e2.expense,0) AS expense,
         COALESCE(s2.revenue,0) - COALESCE(e2.expense,0) AS profit
  FROM clinics cl
  LEFT JOIN sales2 s2 ON cl.cid = s2.cid
  LEFT JOIN exps2  e2 ON cl.cid = e2.cid
),
ranked2 AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY state ORDER BY profit ASC) AS rn
  FROM profit_per_clinic2
)
SELECT state, cid, clinic_name, revenue, expense, profit
FROM ranked2
WHERE rn = 2
ORDER BY state;
