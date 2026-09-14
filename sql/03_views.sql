-- A view is a saved query. These two views keep the money calculations
-- in one place so the reports can reuse them.

-- One row for each purchased item, using its price at the time of sale.
CREATE VIEW sale_line AS
SELECT
    order_item.order_item_id,
    order_item.order_id,
    order_item.product_id,
    orders.customer_id,
    orders.order_date,
    order_item.quantity,
    order_item.quantity * order_item.unit_price_halalas AS gross_halalas,
    order_item.quantity * order_item.unit_discount_halalas AS discount_halalas,
    order_item.quantity * (order_item.unit_price_halalas - order_item.unit_discount_halalas) AS sales_halalas
FROM order_item
JOIN orders ON order_item.order_id = orders.order_id;

-- Refunds use the original discounted price, even if the product price changes.
CREATE VIEW refund_line AS
SELECT
    return_item.return_id,
    return_item.return_date,
    return_item.quantity,
    order_item.product_id,
    return_item.quantity * (order_item.unit_price_halalas - order_item.unit_discount_halalas) AS refund_halalas
FROM return_item
JOIN order_item ON return_item.order_item_id = order_item.order_item_id;
