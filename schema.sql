-- =========================================================
-- E-COMMERCE ANALYTICS DATABASE
-- Schema Definition (PostgreSQL)
-- =========================================================
-- Run this file first to create all tables, constraints,
-- and indexes. Designed for analytics workloads: revenue,
-- retention, cohort, and best-seller reporting.
-- =========================================================

DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ---------------------------------------------------------
-- CUSTOMERS
-- ---------------------------------------------------------
CREATE TABLE customers (
    customer_id       SERIAL PRIMARY KEY,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    email             VARCHAR(120) NOT NULL UNIQUE,
    signup_date       DATE         NOT NULL,
    country            VARCHAR(60),
    city               VARCHAR(60),
    customer_segment   VARCHAR(20) DEFAULT 'regular'   -- regular, vip, wholesale
        CHECK (customer_segment IN ('regular', 'vip', 'wholesale')),
    is_active          BOOLEAN     DEFAULT TRUE,
    created_at         TIMESTAMP   DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_customers_signup_date ON customers (signup_date);
CREATE INDEX idx_customers_country     ON customers (country);

-- ---------------------------------------------------------
-- PRODUCTS
-- ---------------------------------------------------------
CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    sku             VARCHAR(30)  NOT NULL UNIQUE,
    product_name    VARCHAR(150) NOT NULL,
    category        VARCHAR(60)  NOT NULL,
    subcategory     VARCHAR(60),
    brand           VARCHAR(60),
    cost_price      NUMERIC(10,2) NOT NULL CHECK (cost_price >= 0),
    selling_price   NUMERIC(10,2) NOT NULL CHECK (selling_price >= 0),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_category ON products (category);

-- ---------------------------------------------------------
-- ORDERS  (order header / transaction level)
-- ---------------------------------------------------------
CREATE TABLE orders (
    order_id          SERIAL PRIMARY KEY,
    customer_id       INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date        TIMESTAMP NOT NULL,
    order_status      VARCHAR(20) DEFAULT 'completed'
        CHECK (order_status IN ('completed', 'pending', 'cancelled', 'returned')),
    shipping_country  VARCHAR(60),
    shipping_city     VARCHAR(60),
    order_total       NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (order_total >= 0)
);

CREATE INDEX idx_orders_customer_id ON orders (customer_id);
CREATE INDEX idx_orders_order_date  ON orders (order_date);
CREATE INDEX idx_orders_status      ON orders (order_status);

-- ---------------------------------------------------------
-- ORDER_ITEMS (line items — one row per product per order)
-- ---------------------------------------------------------
CREATE TABLE order_items (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      INTEGER NOT NULL REFERENCES products(product_id),
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    discount_pct    NUMERIC(5,2)  DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 100),
    line_total      NUMERIC(12,2) GENERATED ALWAYS AS
                        (ROUND(quantity * unit_price * (1 - discount_pct / 100.0), 2)) STORED
);

CREATE INDEX idx_order_items_order_id   ON order_items (order_id);
CREATE INDEX idx_order_items_product_id ON order_items (product_id);

-- ---------------------------------------------------------
-- PAYMENTS
-- ---------------------------------------------------------
CREATE TABLE payments (
    payment_id      SERIAL PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_date    TIMESTAMP NOT NULL,
    payment_method  VARCHAR(30) NOT NULL
        CHECK (payment_method IN ('credit_card', 'debit_card', 'paypal', 'upi', 'wallet', 'cod')),
    payment_status  VARCHAR(20) DEFAULT 'success'
        CHECK (payment_status IN ('success', 'failed', 'refunded', 'pending')),
    amount          NUMERIC(12,2) NOT NULL CHECK (amount >= 0)
);

CREATE INDEX idx_payments_order_id ON payments (order_id);
CREATE INDEX idx_payments_date     ON payments (payment_date);

-- ---------------------------------------------------------
-- INVENTORY (stock levels per product / warehouse)
-- ---------------------------------------------------------
CREATE TABLE inventory (
    inventory_id        SERIAL PRIMARY KEY,
    product_id           INTEGER NOT NULL REFERENCES products(product_id),
    warehouse_location   VARCHAR(60) NOT NULL,
    quantity_on_hand     INTEGER NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
    reorder_level         INTEGER NOT NULL DEFAULT 10,
    last_restock_date     DATE,
    UNIQUE (product_id, warehouse_location)
);

CREATE INDEX idx_inventory_product_id ON inventory (product_id);

-- =========================================================
-- End of schema.sql
-- =========================================================
