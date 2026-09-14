# Report guide

All amounts are in SAR. The reports use fictional data for 2024.

## Repeat customers

[SQL](../sql/analytics/repeat_customers.sql)

Join customers to orders, group by customer, and keep customers with at least two
orders using `HAVING COUNT(*) >= 2`. Count orders rather than order items: buying
three products in one order is still one purchase.

## Monthly order activity

[SQL](../sql/analytics/monthly_order_activity.sql)

- Order count: distinct order IDs in the month.
- Active customers: distinct customers with an order in the month.
- Average order value: sales after discounts, before refunds, divided by orders.
- Discount percentage: total discounts divided by sales before discounts, times 100.

The query joins orders to the sale-line view. `COUNT(DISTINCT ...)` avoids counting
an order several times when it has several items. An empty order counts as an order
with zero sales. Discount percentage is `N/A` when gross sales are zero.

## Monthly net sales

[SQL](../sql/analytics/monthly_net_sales.sql)

```text
Sale amount = quantity × (unit price − per-unit discount)
Refund amount = returned quantity × (original unit price − per-unit discount)
Net sales = sales − refunds
```

Sales belong to the purchase month; refunds belong to the return month. A January
purchase returned in February adds sales to January and a refund to February.

The query combines sales and refunds with `UNION ALL`, then adds up each month.
A month with only refunds appears with negative net sales. Months with neither
sales nor refunds are omitted.

## Product return rates

[SQL](../sql/analytics/product_return_rates.sql)

```text
Return rate (%) = returned units / sold units × 100
```

Sales and returns are added up separately for each product before they are joined.
Otherwise, two return rows for one purchased item could count the sale twice.

For example, the sample data has 43 running shoes sold and 10 returned:
`10 / 43 × 100 = 23.26%`. The unsold weekend duffel has an undefined return rate,
shown as `N/A`, while a sold product with no returns has a rate of `0%`.

## SQL used in the reports

| Expression | Purpose here |
|---|---|
| `JOIN ... ON ...` | Match related rows using their IDs |
| `LEFT JOIN` | Keep the left-hand row even when there is no match |
| `GROUP BY` | Collect rows so their values can be counted or added up |
| `HAVING` | Filter groups after counting them |
| `WITH name AS (...)` | Give an intermediate query a name for use in the main query |
| `UNION ALL` | Append one query's rows to another without removing duplicates |
| `substr(date, 1, 7)` | Extract `YYYY-MM` from a date |
| `COALESCE(value, 0)` | Use zero when a joined total is missing (`NULL`) |
| `NULLIF(value, 0)` | Return `NULL` for zero, so a rate with a zero denominator is undefined |
| `ROUND(value, 2)` | Round a report value to two decimal places |

## A small manual check

Open `02_seed.sql` and choose an order. For each of its items, multiply quantity
by price minus discount, then divide by 100 to get SAR. Compare with:

```sql
SELECT order_id, SUM(sales_halalas) / 100.0 AS sales_sar
FROM sale_line
WHERE order_id = 1
GROUP BY order_id;
```

Run this after loading the schema, seed, and views in SQLite. It is a way to follow
the calculation using the same data as the reports.
