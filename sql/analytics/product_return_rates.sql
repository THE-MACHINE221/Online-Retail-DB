-- WITH names two intermediate queries: sold and returned.
-- Calculate each total before joining, so multiple returns for one sale
-- do not cause the purchased quantity to be counted more than once.
WITH sold AS (
    SELECT product_id, SUM(quantity) AS units_sold
    FROM order_item
    GROUP BY product_id
), returned AS (
    SELECT product_id, SUM(quantity) AS units_returned
    FROM refund_line
    GROUP BY product_id
)
SELECT
    product.product_id,
    product.product_name,
    COALESCE(sold.units_sold, 0) AS units_sold,
    COALESCE(returned.units_returned, 0) AS units_returned,
    ROUND(100.0 * COALESCE(returned.units_returned, 0)
        / NULLIF(sold.units_sold, 0), 2) AS return_rate_pct
FROM product
LEFT JOIN sold ON product.product_id = sold.product_id
LEFT JOIN returned ON product.product_id = returned.product_id
ORDER BY product.product_id;
