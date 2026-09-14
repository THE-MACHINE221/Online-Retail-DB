-- A repeat customer has placed at least two orders.
SELECT
    customer.customer_id,
    customer.display_name,
    COUNT(*) AS order_count
FROM customer
JOIN orders ON customer.customer_id = orders.customer_id
GROUP BY customer.customer_id, customer.display_name
HAVING COUNT(*) >= 2
ORDER BY order_count DESC, customer.customer_id;
