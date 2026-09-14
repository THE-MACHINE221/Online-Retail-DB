# Database notes

## Tables

| Table | Stores |
|---|---|
| territory | Country, region, and city |
| address | A neighborhood and its territory |
| customer | Customer name and current address |
| category | Main product groups |
| subcategory | Product groups within a category |
| product | Product name, subcategory, and current price |
| payment_method | Payment-method names |
| orders | Customer, order date, and payment method |
| order_item | Products in an order, quantities, sale prices, and discounts |
| return_item | Returned quantities, dates, and the purchased items they refer to |

Primary keys identify rows. Foreign keys connect related tables. For example,
`order_item.order_id` refers to `orders.order_id`.

## Orders, prices, and returns

An order can have several items. Keeping the items in a separate table avoids
repeating the customer and order date for every product in the basket.

`product.price_halalas` holds the current price. Each order item stores its own
`unit_price_halalas` and `unit_discount_halalas` from the purchase. A later change
to the product price therefore leaves earlier sales amounts unchanged.

A return points to an order item, which identifies the product and its purchase
price. A partial return can return fewer units than were purchased.

For example, two shirts priced at SAR 50 each, with a SAR 5 discount per shirt,
produce SAR 90 in sales. Returning one shirt produces a SAR 45 refund.

Money uses whole halalas: SAR 50 is stored as `5000`. This avoids storing the
underlying amounts as approximate decimal fractions in SQLite.

## Rules and assumptions

The schema enforces primary and foreign keys, required fields, positive whole-number
quantities, nonnegative whole-number prices, and per-unit discounts between zero
and the sale price. Date checks require valid dates in `YYYY-MM-DD` format. SQLite's `typeof` checks ensure quantities and money are
stored as integers. Category and payment-method names are unique; subcategory
names are unique within a category.

In the sample data, returns occur on or after the purchase date, and total returned
units do not exceed purchased units. These two rules involve comparing different
rows and are not automatically enforced. Keep them in mind when editing records.
The schema validates each date individually, but does not compare purchase and return dates.

Rows can be updated or deleted subject to foreign keys and the basic constraints.
An order without items is allowed. Customer addresses represent current profiles.
Products do not have separate size or colour variants.

When opening the SQL in another SQLite tool, enable foreign keys for that connection:

```sql
PRAGMA foreign_keys = ON;
```

## Normalization in this design

The tables separate facts to reduce repeated data:

- **First normal form (1NF):** each field holds one value. An order's products
  are separate item rows, rather than a list stored in one field.
- **Second normal form (2NF):** item quantity, sale price, and discount belong
  to the individual order item. Order date and customer belong to the order.
  The tables use single-column primary keys, so there is no partial dependency
  on part of a composite primary key.
- **Third normal form (3NF):** category names are stored in `category`, rather
  than repeated on every product. Payment-method names are stored separately
  from orders. Updating one of these names requires changing one row.

These examples explain the main normalization choices; they are not a formal
proof of every possible dependency. For example, city names are not assumed to
be unique worldwide. Sale-time prices remain on order items because they describe
that purchase, independently of the product's current price.

## Changes from the university version

The original project used Oracle-style SQL and included sizes, more customer and
product details, and a collection of SQL exercises. This version uses SQLite,
separates orders from their items, links returns to purchases, and focuses on four
reports. It is an updated version of that project rather than a copy of the original
submission.
