# Data Dictionary

Full column-level reference for the E-Commerce Analytics Database.

---

## `customers`

| Column | Type | Description |
|---|---|---|
| `customer_id` | SERIAL, PK | Unique customer identifier |
| `first_name` | VARCHAR(50) | Customer first name |
| `last_name` | VARCHAR(50) | Customer last name |
| `email` | VARCHAR(120), UNIQUE | Customer email address |
| `signup_date` | DATE | Date the customer registered — used as the **cohort key** |
| `country` | VARCHAR(60) | Customer's country |
| `city` | VARCHAR(60) | Customer's city |
| `customer_segment` | VARCHAR(20) | `regular`, `vip`, or `wholesale` |
| `is_active` | BOOLEAN | Whether the account is currently active |
| `created_at` | TIMESTAMP | Row insertion timestamp |

## `products`

| Column | Type | Description |
|---|---|---|
| `product_id` | SERIAL, PK | Unique product identifier |
| `sku` | VARCHAR(30), UNIQUE | Stock keeping unit code |
| `product_name` | VARCHAR(150) | Display name |
| `category` | VARCHAR(60) | Top-level category (Electronics, Home, Fashion, Beauty, Sports, Books) |
| `subcategory` | VARCHAR(60) | Secondary classification |
| `brand` | VARCHAR(60) | Brand name |
| `cost_price` | NUMERIC(10,2) | What it costs the business to acquire/produce one unit |
| `selling_price` | NUMERIC(10,2) | List price shown to customers |
| `is_active` | BOOLEAN | Whether the product is currently sellable |
| `created_at` | TIMESTAMP | Row insertion timestamp |

## `orders`

Order header — one row per transaction.

| Column | Type | Description |
|---|---|---|
| `order_id` | SERIAL, PK | Unique order identifier |
| `customer_id` | INTEGER, FK → customers | Who placed the order |
| `order_date` | TIMESTAMP | When the order was placed |
| `order_status` | VARCHAR(20) | `completed`, `pending`, `cancelled`, `returned` |
| `shipping_country` | VARCHAR(60) | Destination country |
| `shipping_city` | VARCHAR(60) | Destination city |
| `order_total` | NUMERIC(12,2) | Order total as recorded at checkout (denormalized convenience field — for precise line-level totals, aggregate `order_items.line_total` instead) |

## `order_items`

Line items — one row per product per order (order/product detail level).

| Column | Type | Description |
|---|---|---|
| `order_item_id` | SERIAL, PK | Unique line item identifier |
| `order_id` | INTEGER, FK → orders | Parent order |
| `product_id` | INTEGER, FK → products | Product purchased |
| `quantity` | INTEGER | Units purchased (> 0) |
| `unit_price` | NUMERIC(10,2) | Price per unit at time of sale |
| `discount_pct` | NUMERIC(5,2) | Discount applied, 0–100 |
| `line_total` | NUMERIC(12,2), GENERATED | `quantity * unit_price * (1 - discount_pct/100)`, auto-computed — the canonical revenue figure used across all analysis queries |

## `payments`

| Column | Type | Description |
|---|---|---|
| `payment_id` | SERIAL, PK | Unique payment identifier |
| `order_id` | INTEGER, FK → orders | Order being paid for |
| `payment_date` | TIMESTAMP | When payment was processed |
| `payment_method` | VARCHAR(30) | `credit_card`, `debit_card`, `paypal`, `upi`, `wallet`, `cod` |
| `payment_status` | VARCHAR(20) | `success`, `failed`, `refunded`, `pending` |
| `amount` | NUMERIC(12,2) | Amount charged |

## `inventory`

Stock levels per product per warehouse.

| Column | Type | Description |
|---|---|---|
| `inventory_id` | SERIAL, PK | Unique inventory record identifier |
| `product_id` | INTEGER, FK → products | Product being tracked |
| `warehouse_location` | VARCHAR(60) | Warehouse/fulfillment center name |
| `quantity_on_hand` | INTEGER | Current stock count |
| `reorder_level` | INTEGER | Threshold below which restocking is needed |
| `last_restock_date` | DATE | Date stock was last replenished |

---

## Entity Relationships

```
customers 1───* orders 1───* order_items *───1 products
                  │                              │
                  1                              1
                  │                              │
                  *                              *
              payments                      inventory
```

- One **customer** can place many **orders**.
- One **order** can have many **order_items** (line items) and many **payments** (e.g., partial payments, refund records).
- One **product** can appear in many **order_items** and has stock tracked across one or more **inventory** rows (one per warehouse).

## Key Business Rules

- **Revenue** = `SUM(order_items.line_total)` for orders where `order_status = 'completed'`. Cancelled orders and non-successful payments are excluded from all revenue queries by default.
- **Cohort** = the calendar month of `customers.signup_date`.
- **Retention** = a customer from a given cohort placing at least one *completed* order in a later calendar month.
- **Best-seller** = ranked by either total revenue or total units sold (both provided) — always computed from completed orders only.
