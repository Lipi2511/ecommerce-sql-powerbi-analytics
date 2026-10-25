create database ecommerce_analytics;
SET GLOBAL local_infile = 1;
use ecommerce_analytics;
SHOW VARIABLES LIKE 'local_infile';
CREATE TABLE test_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/olist_orders_dataset.csv'
INTO TABLE test_orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM test_orders;
RENAME TABLE test_orders TO orders;
ALTER TABLE orders
ADD PRIMARY KEY (order_id);
DESCRIBE orders;
-- ============================================
-- 1. CUSTOMERS
-- ============================================

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);


-- ============================================
-- 2. ORDER ITEMS
-- ============================================

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id)
);
-- 3. ORDER PAYMENTS

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value DECIMAL(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- 4. ORDER REVIEWS

CREATE TABLE order_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

-- 5. PRODUCTS

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(255),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g DECIMAL(10,2),
    product_length_cm DECIMAL(10,2),
    product_height_cm DECIMAL(10,2),
    product_width_cm DECIMAL(10,2)
);


-- ============================================
-- 6. SELLERS


CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);


-- ============================================
-- 7. CATEGORY TRANSLATION
-- ============================================

CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(255) PRIMARY KEY,
    product_category_name_english VARCHAR(255)
);

-- 8. GEOLOCATION

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(10,7),
    geolocation_lng DECIMAL(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM order_items;
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) AS review_count FROM order_reviews;
SELECT COUNT(*) AS product_count FROM products;
SELECT COUNT(*) AS geo_count FROM geolocation;
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/Users/HP/Downloads/archive/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'category_translation', COUNT(*) FROM product_category_name_translation
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation;
-- ------------------------------------------------
SELECT
    COUNT(*) AS total_orders,
    SUM(order_approved_at IS NULL) AS null_approved,
    SUM(order_delivered_carrier_date IS NULL) AS null_delivered_carrier,
    SUM(order_delivered_customer_date IS NULL) AS null_delivered_customer,
    SUM(order_estimated_delivery_date IS NULL) AS null_estimated_delivery
FROM orders;
-- check the missing delivery dates by status
SELECT
    order_status,
    COUNT(*) AS cnt
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY cnt DESC;
-- duplicate check
SELECT
    order_id,
    COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    order_delivered_carrier_date
FROM orders
WHERE order_delivered_carrier_date IS NOT NULL
LIMIT 30;
-- ALTER TABLE orders
-- ADD CONSTRAINT fk_orders_customer
-- FOREIGN KEY (customer_id)
-- REFERENCES customers(customer_id);

-- SET SQL_SAFE_UPDATES = 0;
-- UPDATE orders
-- SET order_delivered_carrier_date = NULL
-- WHERE YEAR(order_delivered_carrier_date) = 0;
-- SELECT ROW_COUNT() AS cleaned_rows;
SET SQL_SAFE_UPDATES = 1;
-- Check for orphaned rows (referential integrity
SELECT COUNT(*) AS orphaned_product_refs
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;
SELECT COUNT(*) AS orphaned_order_refs
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
SELECT COUNT(*) AS orphaned_seller_refs
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Query 1) Categoiry standardization check
SELECT DISTINCT
    product_category_name
FROM products
ORDER BY product_category_name;
SELECT
    COUNT(*) AS total_products,
    SUM(product_category_name IS NULL) AS null_categories
FROM products;
SELECT
    product_category_name,
    COUNT(*) AS product_count
FROM products
GROUP BY product_category_name
ORDER BY product_count DESC;
SELECT COUNT(*) AS orphaned_payment_refs
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;
SELECT COUNT(*) AS orphaned_review_refs
FROM order_reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- RFM ANALYSISA
WITH customer_orders AS (
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(op.payment_value) AS monetary,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM orders),
            MAX(o.order_purchase_timestamp)
        ) AS recency
    FROM orders o
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
),
rfm_scored AS (
    SELECT
        customer_id,
        recency,
        frequency,
        monetary,
        CASE
            WHEN recency <= 90 AND frequency >= 2 AND monetary >= 500 THEN 'Champions'
            WHEN recency <= 180 AND frequency >= 1 THEN 'Loyal/Active'
            WHEN recency > 180 AND recency <= 365 THEN 'At Risk'
            WHEN recency > 365 THEN 'Lost'
            ELSE 'Other'
        END AS segment
    FROM customer_orders
)
SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(SUM(monetary) * 100.0 / (SELECT SUM(monetary) FROM rfm_scored), 2) AS pct_of_total_revenue
FROM rfm_scored
GROUP BY segment
ORDER BY total_revenue DESC;

-- Query 2) Monthly coherent retention
WITH first_purchase AS (
    SELECT
        c.customer_unique_id,
        DATE_FORMAT(MIN(o.order_purchase_timestamp), '%Y-%m-01') AS cohort_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
customer_activity AS (
    SELECT
        c.customer_unique_id,
        fp.cohort_month,
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS order_month
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN first_purchase fp ON c.customer_unique_id = fp.customer_unique_id
    WHERE o.order_status = 'delivered'
),
cohort_data AS (
    SELECT
        cohort_month,
        TIMESTAMPDIFF(MONTH, cohort_month, order_month) AS month_number,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM customer_activity
    GROUP BY cohort_month, order_month
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS total_customers
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    cd.cohort_month,
    cd.month_number,
    cd.active_customers,
    cs.total_customers,
    ROUND(cd.active_customers * 100.0 / cs.total_customers, 2) AS retention_pct
FROM cohort_data cd
JOIN cohort_size cs ON cd.cohort_month = cs.cohort_month
WHERE cd.month_number BETWEEN 0 AND 6
ORDER BY cd.cohort_month, cd.month_number;
-- Quesry 3)Month-over-Month Revenue Growth, using LAG() to compare each month against the prior one.
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS order_month,
        ROUND(SUM(op.payment_value), 2) AS revenue
    FROM orders o
    JOIN order_payments op ON o.order_id = op.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
),
revenue_with_lag AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT
    order_month,
    revenue,
    prev_month_revenue,
    ROUND(
        (revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2
    ) AS mom_growth_pct
FROM revenue_with_lag
ORDER BY order_month;

-- Query 4: Delivery Performance by Seller/Customer Region
WITH delivery_data AS (
    SELECT
        o.order_id,
        s.seller_state,
        c.customer_state,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delay_days
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN sellers s ON oi.seller_id = s.seller_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    customer_state,
    COUNT(*) AS total_orders,
    ROUND(AVG(delay_days), 2) AS avg_delay_days,
    SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_pct
FROM delivery_data
GROUP BY customer_state
HAVING total_orders > 30
ORDER BY late_pct DESC
LIMIT 15;

-- Query 5: Category-Level Review Score vs. Delivery Delay
CREATE INDEX idx_reviews_order ON order_reviews(order_id);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);