-- =========================================================
-- 01_EXPLORATION.SQL
-- Basic exploratory queries to sanity-check the dataset
-- and get a feel for its shape before deeper analysis.
-- =========================================================

-- 1. Row counts across all tables
SELECT 'customers'   AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments',    COUNT(*) FROM payments
UNION ALL SELECT 'inventory',   COUNT(*) FROM inventory;

-- 2. Date range covered by the orders table
SELECT
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    COUNT(*)        AS total_orders
FROM orders;

-- 3. Orders broken down by status
SELECT order_status, COUNT(*) AS num_orders
FROM orders
GROUP BY order_status
ORDER BY num_orders DESC;

-- 4. Customers by country
SELECT country, COUNT(*) AS num_customers
FROM customers
GROUP BY country
ORDER BY num_customers DESC;

-- 5. Customers by segment
SELECT customer_segment, COUNT(*) AS num_customers
FROM customers
GROUP BY customer_segment
ORDER BY num_customers DESC;

-- 6. Products by category
SELECT category, COUNT(*) AS num_products, ROUND(AVG(selling_price), 2) AS avg_price
FROM products
GROUP BY category
ORDER BY num_products DESC;

-- 7. Payment methods used and their success rate
SELECT
    payment_method,
    COUNT(*) AS total_payments,
    SUM(CASE WHEN payment_status = 'success' THEN 1 ELSE 0 END) AS successful,
    ROUND(
        100.0 * SUM(CASE WHEN payment_status = 'success' THEN 1 ELSE 0 END) / COUNT(*), 1
    ) AS success_rate_pct
FROM payments
GROUP BY payment_method
ORDER BY total_payments DESC;

-- 8. Sample of 10 most recent orders with customer name
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    o.order_status,
    o.order_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC
LIMIT 10;

-- 9. Products currently below their reorder level (low stock)
SELECT
    p.product_name,
    i.warehouse_location,
    i.quantity_on_hand,
    i.reorder_level
FROM inventory i
JOIN products p ON p.product_id = i.product_id
WHERE i.quantity_on_hand < i.reorder_level
ORDER BY i.quantity_on_hand ASC;

-- 10. Quick look at order line items with product + order context
SELECT
    oi.order_item_id,
    o.order_id,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.discount_pct,
    oi.line_total
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
ORDER BY o.order_id
LIMIT 15;
