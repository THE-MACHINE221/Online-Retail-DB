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

## Design choices

1. **Orders and items:** separate headers and lines support multi-product baskets without repeating customer and order-level information on every line.
2. **Purchase-linked returns:** each return references an order item. Its customer, product, and refund price are derived through that purchase relationship.
3. **Historical money:** unit price and per-unit discount are captured at sale time. Money uses integer halalas (100 = SAR 1), preserving exact underlying arithmetic. A transaction price describes the sale; the catalogue price describes the product today.
4. **Product scope:** the catalogue models products without size/colour variants. A variant model would be needed to track individual sellable combinations.
5. **SQLite:** a standard-library Python runner makes setup reproducible without an external server. SQL files use consistent snake_case identifiers.

## Return rules

Positive integer quantities are required. Cumulative returns cannot exceed the original line quantity. Return dates cannot precede purchase dates. Foreign keys reject returns for missing lines. Returns and sale lines are immutable; order headers cannot be updated. Insert guards also reject reused transaction IDs, including `INSERT OR REPLACE`, so replacement cannot overwrite this history. These choices simplify history preservation and are not a complete accounting correction system. A production system would need explicit reversal/adjustment events and access controls.

## Normalization

Customer, product classification, and payment-method labels are separated from transactions. The schema uses primary keys for entity identity and foreign keys for relationships. This project does not claim that normalization automatically improves every query: it reduces particular forms of redundancy, while analytical joins have their own costs. Historical prices are facts of the sale, not functions of the product's current price.

## Dataset and testing

The main seed contains 167 orders and 410 sale lines across twelve months. It is a fixed synthetic scenario with varied order frequency, baskets, discounts, and return behavior. It includes 24 fictional customers, 13 products (one unsold), and 53 return events. Its patterns were designed for analytical exploration and cannot establish real-world customer behavior or promotional effectiveness.

Seven focused tests use a separate, minimal fixture with expected values that can be calculated by hand. They cover sales and refunds, multi-item order counts, historical prices, partial-return limits, invalid records, unsold products, and history protection. Complete expected report rows catch missing or duplicated results in the fixture. Each test starts with a fresh database. The demo uses the full-year seed; CI runs it as a setup/execution check, without asserting every full-dataset result.

## Deliberate limits

Single currency (SAR), with no tax, shipping, inventory, payment processing, authentication, or cancellation workflow. Refunds equal the original discounted price per returned unit. Product variants and historical shipping addresses are outside scope. Indexes support common lookups, but the dataset is not a large-scale benchmark. Foreign-key enforcement must be enabled on every SQLite connection; the runner does this explicitly.
