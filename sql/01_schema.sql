PRAGMA foreign_keys = ON;

CREATE TABLE territory (
    territory_id INTEGER PRIMARY KEY,
    country TEXT NOT NULL,
    region TEXT NOT NULL,
    city TEXT NOT NULL
);
CREATE TABLE address (
    address_id INTEGER PRIMARY KEY,
    territory_id INTEGER NOT NULL REFERENCES territory,
    neighborhood TEXT NOT NULL
);
CREATE TABLE customer (
    customer_id INTEGER PRIMARY KEY,
    display_name TEXT NOT NULL,
    address_id INTEGER NOT NULL REFERENCES address
);
CREATE TABLE category (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);
CREATE TABLE subcategory (
    subcategory_id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES category,
    subcategory_name TEXT NOT NULL,
    UNIQUE(category_id, subcategory_name)
);
CREATE TABLE product (
    product_id INTEGER PRIMARY KEY,
    subcategory_id INTEGER NOT NULL REFERENCES subcategory,
    product_name TEXT NOT NULL,
    price_halalas INTEGER NOT NULL CHECK(typeof(price_halalas) = 'integer' AND price_halalas >= 0)
);
CREATE TABLE payment_method (
    payment_method_id INTEGER PRIMARY KEY,
    method_name TEXT NOT NULL UNIQUE
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer,
    payment_method_id INTEGER NOT NULL REFERENCES payment_method,
    order_date TEXT NOT NULL CHECK(length(order_date) = 10 AND date(order_date, '+0 days') IS NOT NULL AND date(order_date, '+0 days') = order_date)
);
CREATE TABLE order_item (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders,
    product_id INTEGER NOT NULL REFERENCES product,
    quantity INTEGER NOT NULL CHECK(typeof(quantity) = 'integer' AND quantity > 0),
    unit_price_halalas INTEGER NOT NULL CHECK(typeof(unit_price_halalas) = 'integer' AND unit_price_halalas >= 0),
    unit_discount_halalas INTEGER NOT NULL DEFAULT 0 CHECK(typeof(unit_discount_halalas) = 'integer' AND unit_discount_halalas BETWEEN 0 AND unit_price_halalas)
);
CREATE TABLE return_item (
    return_id INTEGER PRIMARY KEY,
    order_item_id INTEGER NOT NULL REFERENCES order_item,
    return_date TEXT NOT NULL CHECK(length(return_date) = 10 AND date(return_date, '+0 days') IS NOT NULL AND date(return_date, '+0 days') = return_date),
    quantity INTEGER NOT NULL CHECK(typeof(quantity) = 'integer' AND quantity > 0)
);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_items_order ON order_item(order_id);
CREATE INDEX idx_items_product ON order_item(product_id);
CREATE INDEX idx_returns_item ON return_item(order_item_id);

-- Return records are append-only. Corrections require a deliberate rebuild in this demo.
CREATE TRIGGER validate_return BEFORE INSERT ON return_item
BEGIN
    SELECT CASE WHEN NEW.return_date < (
        SELECT o.order_date FROM orders o JOIN order_item i USING(order_id)
        WHERE i.order_item_id = NEW.order_item_id
    ) THEN RAISE(ABORT, 'return precedes purchase') END;
    SELECT CASE WHEN NEW.quantity + COALESCE((
        SELECT SUM(quantity) FROM return_item WHERE order_item_id = NEW.order_item_id
    ), 0) > (SELECT quantity FROM order_item WHERE order_item_id = NEW.order_item_id)
    THEN RAISE(ABORT, 'returned quantity exceeds purchased quantity') END;
END;
CREATE TRIGGER immutable_return_update BEFORE UPDATE ON return_item
BEGIN SELECT RAISE(ABORT, 'return records are append-only'); END;
CREATE TRIGGER immutable_return_delete BEFORE DELETE ON return_item
BEGIN SELECT RAISE(ABORT, 'return records are append-only'); END;
CREATE TRIGGER immutable_order_item_update BEFORE UPDATE ON order_item
BEGIN SELECT RAISE(ABORT, 'sale items are immutable'); END;
CREATE TRIGGER immutable_order_item_delete BEFORE DELETE ON order_item
BEGIN SELECT RAISE(ABORT, 'sale items are immutable'); END;
CREATE TRIGGER immutable_order_update BEFORE UPDATE ON orders
BEGIN SELECT RAISE(ABORT, 'orders are immutable'); END;
