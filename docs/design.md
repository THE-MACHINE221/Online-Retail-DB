# Design decisions

## Row meaning and relationships

| Table | One row represents |
|---|---|
| territory | A city and its regional/country context |
| address | A synthetic neighborhood in a territory |
| customer | A synthetic customer with a current address |
| category | A top-level product group |
| subcategory | A named group within a category |
| product | A catalogue product with its current price |
| payment_method | A payment-method label, not a payment transaction |
| orders | A customer's purchase date and payment method |
| order_item | One product line within an order, with quantity and historical price |
| return_item | A return event against a purchased line |

Orders can contain multiple lines for the same product. An empty order header is allowed by the schema; a checkout workflow ensuring at least one line is outside this demo. The customer address is current profile data, not a historical shipping address. Geography must not be interpreted as purchase-time shipping geography.

## Changes from the source

1. **Order headers and items:** the original order row referred to a single product. Separate tables represent baskets without repeating customer and order-level information on every line.
2. **Return lineage:** the original return linked to customer and product but not the purchase. Returns now reference an order item; customer and product are derived through that relationship.
3. **Historical money:** current catalogue prices can change. Unit price and per-unit discount are captured at sale time, and money uses integer halalas (100 = SAR 1). Keeping a historical transaction price is intentional, not accidental duplication of current catalogue price.
4. **Sizing:** the original category-level size table could pair incompatible products and sizes. It is removed from this bounded revision; a future variant model should attach an actual size/colour combination to a product.
5. **Executable queries:** identifiers are consistently snake_case; the revision replaces inconsistent source query identifiers and Oracle-specific functions with SQLite syntax.

## Return rules

Positive integer quantities are required. Cumulative returns cannot exceed the original line quantity. Return dates cannot precede purchase dates. Foreign keys reject returns for missing lines. Returns and sale lines are immutable; order headers cannot be updated. These choices simplify history preservation and are not a complete accounting correction system. A production system would need explicit reversal/adjustment events and access controls.

## Normalization

Customer, product classification, and payment-method labels are separated from transactions. The schema uses primary keys for entity identity and foreign keys for relationships. This project does not claim that normalization automatically improves every query: it reduces particular forms of redundancy, while analytical joins have their own costs. Historical prices are facts of the sale, not functions of the product's current price.

## Deliberate limits

SQLite is used for accessibility and repeatability. This is a new implementation informed by the original project, not a tested Oracle migration. Only the SQLite revision is executed by the included tests. The original documents and their personal identifiers are not republished. Indexes support common lookups, but no large-scale benchmark or production-readiness claim is made.
