-- Count order headers separately so multi-item baskets do not inflate order counts.
-- Average order value is after discounts, before refunds; empty headers count as orders.
WITH activity AS (
    SELECT substr(order_date, 1, 7) AS month, COUNT(*) AS order_count,
           COUNT(DISTINCT customer_id) AS active_customers
    FROM orders GROUP BY substr(order_date, 1, 7)
), sales AS (
    SELECT substr(order_date, 1, 7) AS month, SUM(sales_halalas) AS sales,
           SUM(gross_halalas) AS gross, SUM(discount_halalas) AS discounts
    FROM sale_line GROUP BY substr(order_date, 1, 7)
)
SELECT a.month, a.order_count, a.active_customers,
       ROUND(COALESCE(s.sales, 0) / (100.0 * a.order_count), 2) AS average_order_value_sar,
       ROUND(100.0 * COALESCE(s.discounts, 0) / NULLIF(s.gross, 0), 2) AS discount_rate_pct
FROM activity a LEFT JOIN sales s USING(month)
ORDER BY a.month;
