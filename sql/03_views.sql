-- One row per sale line. Refund amounts use the original discounted unit price.
CREATE VIEW sale_line AS
SELECT i.*, o.customer_id, o.order_date,
       i.quantity * i.unit_price_halalas AS gross_halalas,
       i.quantity * i.unit_discount_halalas AS discount_halalas,
       i.quantity * (i.unit_price_halalas - i.unit_discount_halalas) AS sales_halalas
FROM order_item i JOIN orders o USING(order_id);

CREATE VIEW refund_line AS
SELECT r.*, i.product_id,
       r.quantity * (i.unit_price_halalas - i.unit_discount_halalas) AS refund_halalas
FROM return_item r JOIN order_item i USING(order_item_id);
