use ecommerce_analytics;
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