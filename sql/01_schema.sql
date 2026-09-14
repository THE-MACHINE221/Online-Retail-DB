-- Enable foreign keys whenever opening this database.
PRAGMA foreign_keys = ON;

-- Money is stored in whole halalas: 100 halalas = 1 SAR.
-- typeof checks ensure SQLite stores quantities and money as integers.

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
    -- SQLite stores dates as text. Require a real date in YYYY-MM-DD format.
    order_date TEXT NOT NULL CHECK (
        length(order_date) = 10
        AND date(order_date, '+0 days') IS NOT NULL
        AND date(order_date, '+0 days') = order_date
    )
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
    return_date TEXT NOT NULL CHECK (
        length(return_date) = 10
        AND date(return_date, '+0 days') IS NOT NULL
        AND date(return_date, '+0 days') = return_date
    ),
    quantity INTEGER NOT NULL CHECK(typeof(quantity) = 'integer' AND quantity > 0)
);
