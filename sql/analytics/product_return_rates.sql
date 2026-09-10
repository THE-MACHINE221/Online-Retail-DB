-- Aggregate sales and returns separately to avoid many-to-many join multiplication.
WITH sold AS (
    SELECT product_id, SUM(quantity) AS units_sold FROM order_item GROUP BY product_id
), returned AS (
    SELECT product_id, SUM(quantity) AS units_returned FROM refund_line GROUP BY product_id
)
SELECT p.product_id, p.product_name, COALESCE(s.units_sold, 0) AS units_sold,
       COALESCE(r.units_returned, 0) AS units_returned,
       ROUND(100.0 * COALESCE(r.units_returned, 0) / NULLIF(s.units_sold, 0), 2) AS return_rate_pct
FROM product p LEFT JOIN sold s USING(product_id) LEFT JOIN returned r USING(product_id)
ORDER BY p.product_id;
