-- =========================================================
-- E-COMMERCE ANALYTICS DATABASE
-- Seed Data
-- =========================================================
-- Run AFTER schema.sql. Provides enough realistic sample
-- data (customers, products, orders, payments, inventory)
-- to make every query in queries/ return meaningful results.
-- =========================================================

-- ---------------------------------------------------------
-- CUSTOMERS (20 customers, staggered signup dates -> cohorts)
-- ---------------------------------------------------------
INSERT INTO customers (first_name, last_name, email, signup_date, country, city, customer_segment) VALUES
('Aarav',   'Sharma',   'aarav.sharma@mail.com',   '2025-01-05', 'India',        'Nagpur',     'vip'),
('Priya',   'Verma',    'priya.verma@mail.com',    '2025-01-12', 'India',        'Mumbai',     'regular'),
('Rohan',   'Gupta',    'rohan.gupta@mail.com',    '2025-01-20', 'India',        'Delhi',      'regular'),
('Sara',    'Khan',     'sara.khan@mail.com',      '2025-02-02', 'India',        'Pune',       'regular'),
('James',   'Miller',   'james.miller@mail.com',   '2025-02-10', 'USA',          'Austin',     'vip'),
('Emma',    'Wilson',   'emma.wilson@mail.com',    '2025-02-18', 'USA',          'Seattle',    'regular'),
('Liam',    'Brown',    'liam.brown@mail.com',     '2025-03-01', 'UK',           'London',     'regular'),
('Olivia',  'Davis',    'olivia.davis@mail.com',   '2025-03-09', 'UK',           'Manchester', 'wholesale'),
('Noah',    'Taylor',   'noah.taylor@mail.com',    '2025-03-22', 'Canada',       'Toronto',    'regular'),
('Ava',     'Anderson', 'ava.anderson@mail.com',   '2025-04-03', 'Canada',       'Vancouver',  'regular'),
('Karan',   'Mehta',    'karan.mehta@mail.com',    '2025-04-15', 'India',        'Bengaluru',  'vip'),
('Diya',    'Patel',    'diya.patel@mail.com',     '2025-04-28', 'India',        'Ahmedabad',  'regular'),
('William', 'Thomas',   'william.thomas@mail.com', '2025-05-06', 'Australia',    'Sydney',     'regular'),
('Sophia',  'Jackson',  'sophia.jackson@mail.com', '2025-05-19', 'Australia',    'Melbourne',  'regular'),
('Ethan',   'White',    'ethan.white@mail.com',    '2025-06-02', 'USA',          'Chicago',    'wholesale'),
('Mia',     'Harris',   'mia.harris@mail.com',     '2025-06-14', 'USA',          'Denver',     'regular'),
('Aditya',  'Rao',      'aditya.rao@mail.com',     '2025-06-25', 'India',        'Hyderabad',  'regular'),
('Ishita',  'Nair',     'ishita.nair@mail.com',    '2025-07-04', 'India',        'Chennai',    'regular'),
('Lucas',   'Martin',   'lucas.martin@mail.com',   '2025-07-16', 'Germany',      'Berlin',     'regular'),
('Chloe',   'Thompson', 'chloe.thompson@mail.com', '2025-07-29', 'Germany',      'Munich',     'regular');

-- ---------------------------------------------------------
-- PRODUCTS (15 products across a few categories)
-- ---------------------------------------------------------
INSERT INTO products (sku, product_name, category, subcategory, brand, cost_price, selling_price) VALUES
('ELEC-001', 'Wireless Earbuds Pro',       'Electronics', 'Audio',        'SoundWave',  35.00,  79.99),
('ELEC-002', '4K Streaming Stick',         'Electronics', 'Streaming',    'StreamGo',   18.00,  49.99),
('ELEC-003', 'Smart Fitness Watch',        'Electronics', 'Wearables',    'FitTrack',   55.00, 129.99),
('ELEC-004', 'Portable Bluetooth Speaker', 'Electronics', 'Audio',        'SoundWave',  22.00,  59.99),
('HOME-001', 'Ceramic Coffee Mug Set',     'Home',        'Kitchen',      'HomeCraft',   8.00,  24.99),
('HOME-002', 'Aroma Diffuser',             'Home',        'Decor',        'ZenLiving',  12.00,  34.99),
('HOME-003', 'Cotton Bedsheet Set',        'Home',        'Bedding',      'HomeCraft',  20.00,  54.99),
('FASH-001', 'Men''s Running Shoes',       'Fashion',     'Footwear',     'StrideFit',  30.00,  89.99),
('FASH-002', 'Women''s Denim Jacket',      'Fashion',     'Apparel',      'UrbanEdge',  25.00,  69.99),
('FASH-003', 'Leather Wallet',             'Fashion',     'Accessories',  'UrbanEdge',  10.00,  29.99),
('BEAU-001', 'Vitamin C Serum',            'Beauty',      'Skincare',     'GlowLab',     6.00,  19.99),
('BEAU-002', 'Hair Styling Kit',           'Beauty',      'Haircare',     'GlowLab',    14.00,  39.99),
('SPRT-001', 'Yoga Mat Premium',           'Sports',      'Fitness',      'FlexFit',     9.00,  29.99),
('SPRT-002', 'Adjustable Dumbbell Set',    'Sports',      'Fitness',      'FlexFit',    45.00, 119.99),
('BOOK-001', 'Productivity Planner 2025',  'Books',       'Stationery',   'PlanWell',    4.00,  14.99);

-- ---------------------------------------------------------
-- ORDERS + ORDER_ITEMS + PAYMENTS
-- Spread across Jan-Aug 2025 with repeat purchases for
-- several customers so retention/cohort queries have signal.
-- ---------------------------------------------------------

-- Order 1 — Aarav, Jan
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (1, '2025-01-08 10:15:00', 'completed', 'India', 'Nagpur', 129.98);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(1, 1, 1, 79.99, 0), (1, 5, 2, 24.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (1, '2025-01-08 10:16:00', 'credit_card', 'success', 129.98);

-- Order 2 — Priya, Jan
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (2, '2025-01-15 14:30:00', 'completed', 'India', 'Mumbai', 89.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(2, 8, 1, 89.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (2, '2025-01-15 14:31:00', 'upi', 'success', 89.99);

-- Order 3 — Rohan, Jan
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (3, '2025-01-25 09:00:00', 'completed', 'India', 'Delhi', 49.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(3, 2, 1, 49.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (3, '2025-01-25 09:01:00', 'debit_card', 'success', 49.99);

-- Order 4 — Aarav repeat purchase, Feb (retention signal)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (1, '2025-02-10 11:20:00', 'completed', 'India', 'Nagpur', 129.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(4, 3, 1, 129.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (4, '2025-02-10 11:21:00', 'credit_card', 'success', 129.99);

-- Order 5 — Sara, Feb
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (4, '2025-02-05 16:45:00', 'completed', 'India', 'Pune', 94.98);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(5, 11, 2, 19.99, 0), (5, 12, 1, 39.99, 0), (5, 15, 1, 14.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (5, '2025-02-05 16:46:00', 'wallet', 'success', 94.98);

-- Order 6 — James, Feb
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (5, '2025-02-14 08:10:00', 'completed', 'USA', 'Austin', 179.98);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(6, 3, 1, 129.99, 0), (6, 4, 1, 59.99, 10);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (6, '2025-02-14 08:11:00', 'paypal', 'success', 173.98);

-- Order 7 — Emma, Feb
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (6, '2025-02-22 13:00:00', 'completed', 'USA', 'Seattle', 59.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(7, 4, 1, 59.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (7, '2025-02-22 13:01:00', 'credit_card', 'success', 59.99);

-- Order 8 — Priya repeat, Mar (retention)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (2, '2025-03-03 10:00:00', 'completed', 'India', 'Mumbai', 79.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(8, 1, 1, 79.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (8, '2025-03-03 10:01:00', 'upi', 'success', 79.99);

-- Order 9 — Liam, Mar
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (7, '2025-03-05 09:30:00', 'completed', 'UK', 'London', 69.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(9, 9, 1, 69.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (9, '2025-03-05 09:31:00', 'credit_card', 'success', 69.99);

-- Order 10 — Olivia (wholesale, bulk order), Mar
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (8, '2025-03-12 15:00:00', 'completed', 'UK', 'Manchester', 599.90);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(10, 14, 5, 119.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (10, '2025-03-12 15:02:00', 'credit_card', 'success', 599.90);

-- Order 11 — Noah, Mar
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (9, '2025-03-25 12:15:00', 'completed', 'Canada', 'Toronto', 29.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(11, 13, 1, 29.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (11, '2025-03-25 12:16:00', 'debit_card', 'success', 29.99);

-- Order 12 — Aarav repeat, Apr (retention, 3rd order)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (1, '2025-04-02 09:45:00', 'completed', 'India', 'Nagpur', 59.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(12, 4, 1, 59.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (12, '2025-04-02 09:46:00', 'credit_card', 'success', 59.99);

-- Order 13 — Ava, Apr
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (10, '2025-04-10 17:20:00', 'completed', 'Canada', 'Vancouver', 44.98);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(13, 6, 1, 34.99, 0), (13, 15, 1, 14.99, 5);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (13, '2025-04-10 17:21:00', 'paypal', 'success', 43.24);

-- Order 14 — Karan, Apr
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (11, '2025-04-18 08:00:00', 'completed', 'India', 'Bengaluru', 209.97);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(14, 3, 1, 129.99, 0), (14, 1, 1, 79.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (14, '2025-04-18 08:01:00', 'credit_card', 'success', 209.98);

-- Order 15 — Diya, Apr
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (12, '2025-04-29 14:10:00', 'completed', 'India', 'Ahmedabad', 24.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(15, 5, 1, 24.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (15, '2025-04-29 14:11:00', 'upi', 'success', 24.99);

-- Order 16 — Priya repeat, May (retention, 3rd order)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (2, '2025-05-06 11:00:00', 'completed', 'India', 'Mumbai', 119.98);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(16, 3, 1, 129.99, 8);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (16, '2025-05-06 11:01:00', 'upi', 'success', 119.59);

-- Order 17 — William, May
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (13, '2025-05-14 09:15:00', 'completed', 'Australia', 'Sydney', 89.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(17, 8, 1, 89.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (17, '2025-05-14 09:16:00', 'credit_card', 'success', 89.99);

-- Order 18 — Sophia, May
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (14, '2025-05-22 16:30:00', 'cancelled', 'Australia', 'Melbourne', 54.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(18, 7, 1, 54.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (18, '2025-05-22 16:31:00', 'debit_card', 'refunded', 54.99);

-- Order 19 — Ethan (wholesale), Jun
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (15, '2025-06-05 10:00:00', 'completed', 'USA', 'Chicago', 449.95);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(19, 14, 3, 119.99, 0), (19, 5, 4, 24.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (19, '2025-06-05 10:02:00', 'credit_card', 'success', 449.95);

-- Order 20 — Aarav repeat, Jun (retention, 4th order)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (1, '2025-06-11 13:40:00', 'completed', 'India', 'Nagpur', 79.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(20, 1, 1, 79.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (20, '2025-06-11 13:41:00', 'credit_card', 'success', 79.99);

-- Order 21 — Mia, Jun
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (16, '2025-06-19 15:00:00', 'completed', 'USA', 'Denver', 29.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(21, 13, 1, 29.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (21, '2025-06-19 15:01:00', 'wallet', 'success', 29.99);

-- Order 22 — Aditya, Jun
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (17, '2025-06-28 08:50:00', 'completed', 'India', 'Hyderabad', 39.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(22, 12, 1, 39.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (22, '2025-06-28 08:51:00', 'upi', 'success', 39.99);

-- Order 23 — Karan repeat, Jul (retention)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (11, '2025-07-02 12:00:00', 'completed', 'India', 'Bengaluru', 79.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(23, 1, 1, 79.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (23, '2025-07-02 12:01:00', 'credit_card', 'success', 79.99);

-- Order 24 — Ishita, Jul
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (18, '2025-07-08 09:20:00', 'completed', 'India', 'Chennai', 19.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(24, 11, 1, 19.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (24, '2025-07-08 09:21:00', 'upi', 'success', 19.99);

-- Order 25 — Lucas, Jul
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (19, '2025-07-19 14:00:00', 'completed', 'Germany', 'Berlin', 89.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(25, 8, 1, 89.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (25, '2025-07-19 14:01:00', 'paypal', 'success', 89.99);

-- Order 26 — Aarav repeat, Jul (retention, 5th order — top loyal customer)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (1, '2025-07-24 10:10:00', 'completed', 'India', 'Nagpur', 149.98);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(26, 3, 1, 129.99, 0), (26, 15, 1, 14.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (26, '2025-07-24 10:11:00', 'credit_card', 'success', 144.98);

-- Order 27 — Chloe, Aug
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (20, '2025-08-02 11:30:00', 'completed', 'Germany', 'Munich', 59.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(27, 4, 1, 59.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (27, '2025-08-02 11:31:00', 'credit_card', 'success', 59.99);

-- Order 28 — James repeat, Aug (retention)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (5, '2025-08-09 09:00:00', 'completed', 'USA', 'Austin', 79.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(28, 1, 1, 79.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (28, '2025-08-09 09:01:00', 'paypal', 'success', 79.99);

-- Order 29 — Rohan repeat, Aug (retention)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (3, '2025-08-12 16:00:00', 'pending', 'India', 'Delhi', 89.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(29, 8, 1, 89.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (29, '2025-08-12 16:01:00', 'cod', 'pending', 89.99);

-- Order 30 — Aarav repeat, Aug (retention, 6th order)
INSERT INTO orders (customer_id, order_date, order_status, shipping_country, shipping_city, order_total)
VALUES (1, '2025-08-13 10:00:00', 'completed', 'India', 'Nagpur', 34.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct) VALUES
(30, 6, 1, 34.99, 0);
INSERT INTO payments (order_id, payment_date, payment_method, payment_status, amount)
VALUES (30, '2025-08-13 10:01:00', 'credit_card', 'success', 34.99);

-- ---------------------------------------------------------
-- INVENTORY (stock levels for all 15 products)
-- ---------------------------------------------------------
INSERT INTO inventory (product_id, warehouse_location, quantity_on_hand, reorder_level, last_restock_date) VALUES
(1,  'Central-WH-1', 120, 30, '2025-07-20'),
(2,  'Central-WH-1',  85, 25, '2025-07-15'),
(3,  'Central-WH-1',  45, 15, '2025-07-28'),
(4,  'Central-WH-1',  95, 30, '2025-07-18'),
(5,  'East-WH-2',    200, 50, '2025-07-10'),
(6,  'East-WH-2',    130, 40, '2025-07-22'),
(7,  'East-WH-2',     60, 20, '2025-06-30'),
(8,  'West-WH-3',      8,  20, '2025-08-01'),   -- below reorder level
(9,  'West-WH-3',     70, 25, '2025-07-12'),
(10, 'West-WH-3',    110, 30, '2025-07-08'),
(11, 'Central-WH-1', 150, 40, '2025-07-25'),
(12, 'Central-WH-1',  90, 30, '2025-07-19'),
(13, 'East-WH-2',      5,  15, '2025-07-30'),   -- below reorder level
(14, 'East-WH-2',     18,  10, '2025-07-05'),
(15, 'West-WH-3',    220, 50, '2025-07-27');

-- =========================================================
-- End of seed_data.sql
-- =========================================================
