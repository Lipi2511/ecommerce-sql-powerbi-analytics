USE ecommerce_analytics;
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