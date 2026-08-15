-- =========================================================
-- 02_ANALYSIS.SQL
-- Core business queries: revenue, retention, cohort,
-- and best-seller analysis.
-- =========================================================
-- NOTE: "Revenue" throughout = successful/completed order
-- value (order_items.line_total), excluding cancelled orders
-- and failed/refunded payments, unless stated otherwise.
-- =========================================================


-- ---------------------------------------------------------
-- A. REVENUE ANALYSIS
-- ---------------------------------------------------------

-- A1. Total revenue, order count, and average order value (completed orders only)
SELECT
    COUNT(DISTINCT o.order_id)         AS total_orders,
    ROUND(SUM(oi.line_total), 2)       AS total_revenue,
    ROUND(SUM(oi.line_total) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'completed';

-- A2. Monthly revenue trend
SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS month,
    COUNT(DISTINCT o.order_id)               AS orders,
    ROUND(SUM(oi.line_total), 2)             AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY 1
ORDER BY 1;

-- A3. Month-over-month revenue growth (%)
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,
        SUM(oi.line_total)                       AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'completed'
    GROUP BY 1
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 2) AS revenue_change,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1
    ) AS growth_pct
FROM monthly
ORDER BY month;

-- A4. Revenue by product category
SELECT
    p.category,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    ROUND(100.0 * SUM(oi.line_total) / SUM(SUM(oi.line_total)) OVER (), 1) AS pct_of_total
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'completed'
GROUP BY p.category
ORDER BY revenue DESC;

-- A5. Revenue by country
SELECT
    o.shipping_country,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    COUNT(DISTINCT o.order_id)   AS orders
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'completed'
GROUP BY o.shipping_country
ORDER BY revenue DESC;

-- A6. Revenue by customer segment
SELECT
    c.customer_segment,
    ROUND(SUM(oi.line_total), 2) AS revenue,
    COUNT(DISTINCT o.customer_id) AS customers
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN customers c    ON c.customer_id = o.customer_id
WHERE o.order_status = 'completed'
GROUP BY c.customer_segment
ORDER BY revenue DESC;


-- ---------------------------------------------------------
-- B. RETENTION ANALYSIS
-- ---------------------------------------------------------

-- B1. New vs. repeat customers (overall)
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(*) AS num_orders
    FROM orders
    WHERE order_status = 'completed'
    GROUP BY customer_id
)
SELECT
    CASE WHEN num_orders = 1 THEN 'One-time buyer' ELSE 'Repeat buyer' END AS customer_type,
    COUNT(*) AS num_customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers
FROM customer_order_counts
GROUP BY 1;

-- B2. Overall repeat purchase rate
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(*) AS num_orders
    FROM orders
    WHERE order_status = 'completed'
    GROUP BY customer_id
)
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN num_orders > 1 THEN 1 ELSE 0 END) / COUNT(*), 1
    ) AS repeat_purchase_rate_pct
FROM customer_order_counts;

-- B3. Customer purchase frequency distribution
WITH customer_order_counts AS (
    SELECT customer_id, COUNT(*) AS num_orders
    FROM orders
    WHERE order_status = 'completed'
    GROUP BY customer_id
)
SELECT num_orders AS orders_placed, COUNT(*) AS num_customers
FROM customer_order_counts
GROUP BY num_orders
ORDER BY num_orders;

-- B4. Average days between a customer's first and second order
WITH ranked_orders AS (
    SELECT
        customer_id,
        order_date,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_rank
    FROM orders
    WHERE order_status = 'completed'
)
SELECT
    ROUND(AVG(EXTRACT(DAY FROM (o2.order_date - o1.order_date))), 1) AS avg_days_to_second_order
FROM ranked_orders o1
JOIN ranked_orders o2
    ON o1.customer_id = o2.customer_id
   AND o1.order_rank = 1
   AND o2.order_rank = 2;

-- B5. Customers who purchased in the most recent month vs. the prior month (simple churn view)
WITH monthly_customers AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date)::DATE AS order_month
    FROM orders
    WHERE order_status = 'completed'
),
months AS (
    SELECT DISTINCT order_month FROM monthly_customers ORDER BY order_month
)
SELECT
    curr.order_month,
    COUNT(DISTINCT curr.customer_id) AS active_customers,
    COUNT(DISTINCT prev.customer_id) AS retained_from_prior_month
FROM monthly_customers curr
LEFT JOIN monthly_customers prev
    ON prev.customer_id = curr.customer_id
   AND prev.order_month = (curr.order_month - INTERVAL '1 month')::DATE
GROUP BY curr.order_month
ORDER BY curr.order_month;


-- ---------------------------------------------------------
-- C. COHORT ANALYSIS
-- Cohort = the month a customer signed up (or placed their
-- first order). We track how many of them come back to
-- purchase in subsequent months.
-- ---------------------------------------------------------

-- C1. Cohort sizes by signup month
SELECT
    DATE_TRUNC('month', signup_date)::DATE AS cohort_month,
    COUNT(*) AS num_customers
FROM customers
GROUP BY 1
ORDER BY 1;

-- C2. Cohort retention counts — customers active N months after signup
WITH cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', signup_date)::DATE AS cohort_month
    FROM customers
),
customer_activity AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date)::DATE AS activity_month
    FROM orders
    WHERE order_status = 'completed'
)
SELECT
    c.cohort_month,
    ( (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
      + (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM c.cohort_month)) )::INT AS months_since_signup,
    COUNT(DISTINCT c.customer_id) AS active_customers
FROM cohorts c
JOIN customer_activity a ON a.customer_id = c.customer_id
GROUP BY c.cohort_month, months_since_signup
ORDER BY c.cohort_month, months_since_signup;

-- C3. Cohort retention rate (%) — active customers / original cohort size
WITH cohorts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', signup_date)::DATE AS cohort_month
    FROM customers
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
),
customer_activity AS (
    SELECT DISTINCT
        customer_id,
        DATE_TRUNC('month', order_date)::DATE AS activity_month
    FROM orders
    WHERE order_status = 'completed'
),
cohort_activity AS (
    SELECT
        c.cohort_month,
        ( (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
          + (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM c.cohort_month)) )::INT AS months_since_signup,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM cohorts c
    JOIN customer_activity a ON a.customer_id = c.customer_id
    GROUP BY c.cohort_month, months_since_signup
)
SELECT
    ca.cohort_month,
    ca.months_since_signup,
    ca.active_customers,
    cs.cohort_size,
    ROUND(100.0 * ca.active_customers / cs.cohort_size, 1) AS retention_pct
FROM cohort_activity ca
JOIN cohort_sizes cs ON cs.cohort_month = ca.cohort_month
ORDER BY ca.cohort_month, ca.months_since_signup;


-- ---------------------------------------------------------
-- D. BEST-SELLER ANALYSIS
-- ---------------------------------------------------------

-- D1. Top 10 products by revenue
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)              AS units_sold,
    ROUND(SUM(oi.line_total), 2)  AS revenue
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-- D2. Top 10 products by units sold
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY units_sold DESC
LIMIT 10;

-- D3. Best-seller per category
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity)             AS units_sold,
        SUM(oi.line_total)           AS revenue,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.line_total) DESC) AS category_rank
    FROM order_items oi
    JOIN orders o   ON o.order_id = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.order_status = 'completed'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT category, product_name, units_sold, ROUND(revenue, 2) AS revenue
FROM product_sales
WHERE category_rank = 1
ORDER BY revenue DESC;

-- D4. Product profitability (margin) leaderboard
SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity)                                   AS units_sold,
    ROUND(SUM(oi.line_total), 2)                       AS revenue,
    ROUND(SUM(oi.quantity * p.cost_price), 2)          AS total_cost,
    ROUND(SUM(oi.line_total) - SUM(oi.quantity * p.cost_price), 2) AS gross_profit,
    ROUND(
        100.0 * (SUM(oi.line_total) - SUM(oi.quantity * p.cost_price)) / NULLIF(SUM(oi.line_total), 0), 1
    ) AS margin_pct
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.order_status = 'completed'
GROUP BY p.product_id, p.product_name, p.category
ORDER BY gross_profit DESC;
