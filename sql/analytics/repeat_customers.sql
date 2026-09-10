-- Order counts come from order headers, avoiding inflation from multi-item baskets.
SELECT c.customer_id, c.display_name, COUNT(*) AS order_count
FROM customer c JOIN orders o USING(customer_id)
GROUP BY c.customer_id, c.display_name HAVING COUNT(*) >= 2
ORDER BY order_count DESC, c.customer_id;
