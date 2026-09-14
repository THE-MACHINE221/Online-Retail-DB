-- Count each order once, even when it contains several items.
-- LEFT JOIN also includes orders that have no items.
SELECT
    substr(orders.order_date, 1, 7) AS month,
    COUNT(DISTINCT orders.order_id) AS order_count,
    COUNT(DISTINCT orders.customer_id) AS active_customers,
    ROUND(COALESCE(SUM(sale_line.sales_halalas), 0)
        / (100.0 * COUNT(DISTINCT orders.order_id)), 2) AS average_order_value_sar,
    ROUND(100.0 * COALESCE(SUM(sale_line.discount_halalas), 0)
        / NULLIF(SUM(sale_line.gross_halalas), 0), 2) AS discount_rate_pct
FROM orders
LEFT JOIN sale_line ON orders.order_id = sale_line.order_id
GROUP BY substr(orders.order_date, 1, 7)
ORDER BY month;
