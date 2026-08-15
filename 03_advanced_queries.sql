-- =========================================================
-- 03_ADVANCED_QUERIES.SQL
-- Advanced / composite analytics: RFM segmentation, a full
-- cohort retention matrix, customer lifetime value, running
-- totals, and basket analysis.
-- =========================================================


-- ---------------------------------------------------------
-- 1. RFM SEGMENTATION
-- Recency, Frequency, Monetary scoring (1-5, 5 = best) to
-- segment customers for targeted marketing.
-- ---------------------------------------------------------
WITH order_stats AS (
    SELECT
        o.customer_id,
        MAX(o.order_date)               AS last_order_date,
        COUNT(DISTINCT o.order_id)      AS frequency,
        SUM(oi.line_total)              AS monetary
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'completed'
    GROUP BY o.customer_id
),
scored AS (
    SELECT
        customer_id,
        last_order_date,
        frequency,
        monetary,
        EXTRACT(DAY FROM (CURRENT_DATE - last_order_date))::INT AS recency_days,
        NTILE(5) OVER (ORDER BY EXTRACT(DAY FROM (CURRENT_DATE - last_order_date)) DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC)  AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC)   AS monetary_score
    FROM order_stats
)
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    s.recency_days,
    s.frequency,
    ROUND(s.monetary, 2) AS monetary,
    s.recency_score,
    s.frequency_score,
    s.monetary_score,
    (s.recency_score + s.frequency_score + s.monetary_score) AS rfm_total,
    CASE
        WHEN s.recency_score >= 4 AND s.frequency_score >= 4 AND s.monetary_score >= 4 THEN 'Champions'
        WHEN s.recency_score >= 3 AND s.frequency_score >= 3 THEN 'Loyal Customers'
        WHEN s.recency_score >= 4 AND s.frequency_score <= 2 THEN 'New / Promising'
        WHEN s.recency_score <= 2 AND s.frequency_score >= 3 THEN 'At Risk'
        WHEN s.recency_score <= 2 AND s.frequency_score <= 2 THEN 'Hibernating'
        ELSE 'Needs Attention'
    END AS rfm_segment
FROM scored s
JOIN customers c ON c.customer_id = s.customer_id
ORDER BY rfm_total DESC;


-- ---------------------------------------------------------
-- 2. COHORT RETENTION MATRIX (pivoted)
-- One row per signup cohort, one column per month offset,
-- showing retention % — the classic cohort heatmap shape.
-- ---------------------------------------------------------
WITH cohorts AS (
    SELECT customer_id, DATE_TRUNC('month', signup_date)::DATE AS cohort_month
    FROM customers
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS cohort_size
    FROM cohorts
    GROUP BY cohort_month
),
activity AS (
    SELECT DISTINCT customer_id, DATE_TRUNC('month', order_date)::DATE AS activity_month
    FROM orders
    WHERE order_status = 'completed'
),
cohort_activity AS (
    SELECT
        c.cohort_month,
        ( (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
          + (EXTRACT(MONTH FROM a.activity_month) - EXTRACT(MONTH FROM c.cohort_month)) )::INT AS month_offset,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM cohorts c
    JOIN activity a ON a.customer_id = c.customer_id
    GROUP BY c.cohort_month, month_offset
)
SELECT
    ca.cohort_month,
    cs.cohort_size,
    ROUND(100.0 * MAX(CASE WHEN month_offset = 0 THEN active_customers END) / cs.cohort_size, 1) AS month_0,
    ROUND(100.0 * MAX(CASE WHEN month_offset = 1 THEN active_customers END) / cs.cohort_size, 1) AS month_1,
    ROUND(100.0 * MAX(CASE WHEN month_offset = 2 THEN active_customers END) / cs.cohort_size, 1) AS month_2,
    ROUND(100.0 * MAX(CASE WHEN month_offset = 3 THEN active_customers END) / cs.cohort_size, 1) AS month_3,
    ROUND(100.0 * MAX(CASE WHEN month_offset = 4 THEN active_customers END) / cs.cohort_size, 1) AS month_4
FROM cohort_activity ca
JOIN cohort_sizes cs ON cs.cohort_month = ca.cohort_month
GROUP BY ca.cohort_month, cs.cohort_size
ORDER BY ca.cohort_month;


-- ---------------------------------------------------------
-- 3. CUSTOMER LIFETIME VALUE (CLV) — top 10 by revenue
-- ---------------------------------------------------------
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.customer_segment,
    c.signup_date,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    ROUND(SUM(oi.line_total), 2)                        AS lifetime_revenue,
    ROUND(SUM(oi.line_total) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
    MAX(o.order_date)                                   AS last_order_date
FROM customers c
JOIN orders o        ON o.customer_id = c.customer_id AND o.order_status = 'completed'
JOIN order_items oi  ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment, c.signup_date
ORDER BY lifetime_revenue DESC
LIMIT 10;


-- ---------------------------------------------------------
-- 4. RUNNING (CUMULATIVE) REVENUE TOTAL BY DAY
-- ---------------------------------------------------------
WITH daily_revenue AS (
    SELECT
        o.order_date::DATE AS order_day,
        SUM(oi.line_total) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'completed'
    GROUP BY o.order_date::DATE
)
SELECT
    order_day,
    ROUND(revenue, 2) AS daily_revenue,
    ROUND(SUM(revenue) OVER (ORDER BY order_day), 2) AS cumulative_revenue
FROM daily_revenue
ORDER BY order_day;


-- ---------------------------------------------------------
-- 5. MARKET BASKET — products most frequently bought together
-- ---------------------------------------------------------
SELECT
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    COUNT(*)         AS times_bought_together
FROM order_items oi1
JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
   AND oi1.product_id < oi2.product_id      -- avoid duplicate pairs & self-pairs
JOIN products p1 ON p1.product_id = oi1.product_id
JOIN products p2 ON p2.product_id = oi2.product_id
GROUP BY p1.product_name, p2.product_name
ORDER BY times_bought_together DESC
LIMIT 10;


-- ---------------------------------------------------------
-- 6. CUSTOMER RANKING WITHIN THEIR COUNTRY (window function)
-- ---------------------------------------------------------
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name AS customer_name,
        c.country,
        SUM(oi.line_total) AS revenue
    FROM customers c
    JOIN orders o        ON o.customer_id = c.customer_id AND o.order_status = 'completed'
    JOIN order_items oi  ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT
    country,
    customer_name,
    ROUND(revenue, 2) AS revenue,
    RANK() OVER (PARTITION BY country ORDER BY revenue DESC) AS rank_in_country
FROM customer_revenue
ORDER BY country, rank_in_country;


-- ---------------------------------------------------------
-- 7. INVENTORY HEALTH — days of stock remaining based on
-- recent 90-day sales velocity
-- ---------------------------------------------------------
WITH recent_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity) AS units_sold_90d
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'completed'
      AND o.order_date >= (SELECT MAX(order_date) FROM orders) - INTERVAL '90 days'
    GROUP BY oi.product_id
)
SELECT
    p.product_name,
    i.warehouse_location,
    i.quantity_on_hand,
    COALESCE(rs.units_sold_90d, 0)                                        AS units_sold_last_90d,
    ROUND(COALESCE(rs.units_sold_90d, 0) / 90.0, 2)                       AS avg_daily_sales,
    CASE
        WHEN COALESCE(rs.units_sold_90d, 0) = 0 THEN NULL
        ELSE ROUND(i.quantity_on_hand / (rs.units_sold_90d / 90.0), 1)
    END AS est_days_of_stock_left
FROM inventory i
JOIN products p ON p.product_id = i.product_id
LEFT JOIN recent_sales rs ON rs.product_id = i.product_id
ORDER BY est_days_of_stock_left ASC NULLS LAST;
