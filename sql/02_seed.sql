-- Entirely synthetic fixture, unrelated to employer/customer records.
INSERT INTO territory VALUES
 (1, 'Saudi Arabia', 'Qassim', 'Buraidah'),
 (2, 'Saudi Arabia', 'Riyadh', 'Riyadh');
INSERT INTO address VALUES (1, 1, 'Demo district A'), (2, 2, 'Demo district B');
INSERT INTO customer VALUES (1, 'Demo Customer 01', 1), (2, 'Demo Customer 02', 2), (3, 'Demo Customer 03', 1);
INSERT INTO category VALUES (1, 'Clothing'), (2, 'Accessories');
INSERT INTO subcategory VALUES (1, 1, 'Shirts'), (2, 1, 'Trousers'), (3, 2, 'Bags');
INSERT INTO product VALUES (1, 1, 'Classic shirt', 5000), (2, 2, 'Cotton trousers', 8000), (3, 3, 'Everyday bag', 12000);
INSERT INTO payment_method VALUES (1, 'Card'), (2, 'Cash');
INSERT INTO orders VALUES
 (1, 1, 1, '2024-01-10'), (2, 2, 2, '2024-01-20'),
 (3, 1, 1, '2024-02-05'), (4, 3, 1, '2024-02-15');
INSERT INTO order_item VALUES
 (1, 1, 1, 2, 5000, 500),
 (2, 1, 2, 1, 8000, 0),
 (3, 2, 3, 1, 12000, 2000),
 (4, 3, 1, 1, 5000, 0),
 (5, 4, 2, 2, 8000, 1000);
INSERT INTO return_item VALUES
 (1, 1, '2024-02-01', 1),
 (2, 5, '2024-02-20', 1);
