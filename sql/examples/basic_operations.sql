-- Run after loading 01_schema.sql, 02_seed.sql, and 03_views.sql.
-- Use a freshly loaded sample database: product ID 1000 is reserved here.
-- Run these statements in order in a SQLite editor.
-- BEGIN groups the example changes; ROLLBACK undoes them at the end.
BEGIN TRANSACTION;

-- Create a product in the existing subcategory 1.
INSERT INTO product (product_id, subcategory_id, product_name, price_halalas)
VALUES (1000, 1, 'Example shirt', 5000);

-- Read the new product. 5000 halalas = SAR 50.
SELECT product_id, product_name, price_halalas / 100.0 AS price_sar
FROM product
WHERE product_id = 1000;

-- Change its current price to SAR 55.
UPDATE product
SET price_halalas = 5500
WHERE product_id = 1000;

SELECT product_id, product_name, price_halalas / 100.0 AS price_sar
FROM product
WHERE product_id = 1000;

-- This product has no order items, so a foreign key does not block deletion.
DELETE FROM product
WHERE product_id = 1000;

-- Expected result: zero rows remaining for this ID.
SELECT COUNT(*) AS remaining_products
FROM product
WHERE product_id = 1000;

ROLLBACK;
