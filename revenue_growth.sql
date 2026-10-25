use ecommerce_analytics;
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