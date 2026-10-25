USE ecommerce_analytics;
CREATE INDEX idx_reviews_order ON order_reviews(order_id);
CREATE INDEX idx_items_order ON order_items(order_id);
CREATE INDEX idx_items_product ON order_items(product_id);

WITH order_delay AS (
    SELECT
        o.order_id,
        DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delay_days
    FROM orders o
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
),
order_category AS (
    SELECT DISTINCT
        oi.order_id,
        COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
),
order_full AS (
    SELECT
        od.order_id,
        od.delay_days,
        oc.category,
        r.review_score
    FROM order_delay od
    JOIN order_category oc ON od.order_id = oc.order_id
    JOIN order_reviews r ON od.order_id = r.order_id
)
SELECT
    category,
    COUNT(*) AS total_orders,
    ROUND(AVG(delay_days), 2) AS avg_delay_days,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_pct
FROM order_full
GROUP BY category
HAVING total_orders > 100
ORDER BY late_pct DESC
LIMIT 15;