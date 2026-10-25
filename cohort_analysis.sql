use ecommerce_analytics;
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