# Analytics guide

The reports explore a fixed synthetic retail dataset covering January–December 2024: 24 customers, 13 products, 167 orders, 410 sale lines, and 53 return events. Every customer and transaction is fictional. The figures illustrate SQL behavior and analytical interpretation, not real business performance.

## Monthly net sales

**Sales = quantity × (sale-time unit price − per-unit discount).** Refunds use the same discounted unit price multiplied by the returned quantity. **Net sales = sales − refunds.** Sales are dated by purchase; refunds by return. Tax and shipping are excluded.

| Month | Sales after discounts (SAR) | Refunds (SAR) | Net sales (SAR) |
|---|---:|---:|---:|
| 2024-01 | 2,072.00 | 210.00 | 1,862.00 |
| 2024-02 | 3,778.25 | 0.00 | 3,778.25 |
| 2024-03 | 2,800.00 | 135.00 | 2,665.00 |
| 2024-04 | 4,234.50 | 323.00 | 3,911.50 |
| 2024-05 | 4,597.00 | 764.00 | 3,833.00 |
| 2024-06 | 5,663.00 | 390.00 | 5,273.00 |
| 2024-07 | 5,341.00 | 895.00 | 4,446.00 |
| 2024-08 | 2,831.00 | 494.00 | 2,337.00 |
| 2024-09 | 4,705.00 | 449.00 | 4,256.00 |
| 2024-10 | 4,609.00 | 427.50 | 4,181.50 |
| 2024-11 | 5,865.00 | 950.00 | 4,915.00 |
| 2024-12 | 8,429.50 | 1,094.50 | 7,335.00 |

December has the highest net sales, SAR 7,335.00. July has SAR 5,341.00 in sales but SAR 895.00 in refunds, leaving SAR 4,446.00. Some refunds relate to earlier purchases, so a month's refund-to-sales ratio is not a return rate for that month's purchases.

The query combines sale and refund events with `UNION ALL`, then groups by month. A month with refunds but no sales is retained and may have negative net sales. Months with neither kind of event are omitted.

## Monthly order activity

- **Order count:** number of order headers, not number of purchased lines.
- **Active customers:** distinct customers with an order in that month.
- **Average order value:** sales after discounts, before refunds, divided by order count.
- **Weighted discount rate:** total discount amount divided by gross sales before discounts × 100. This is not a simple average of line-level percentages.

November contains 20 orders from 13 customers, SAR 293.25 average order value, and a 15.31% weighted discount rate. December contains 24 orders with SAR 351.23 average order value. These figures allow comparisons of volume, basket value, and discounting; the synthetic promotion scenario cannot demonstrate that discounts caused a change in demand.

Order headers are counted separately from sale lines to avoid inflating order counts for multi-item baskets. Empty headers count as orders and contribute zero sales; a month with no gross sales has an undefined discount rate.

## Repeat customers

A repeat customer has at least two orders across the dataset, regardless of item count or returns. There are 21 repeat customers and three one-time customers. Demo Customer 02 placed the most orders (19).

This is an all-period purchase-frequency measure. It is not cohort retention, a measure of customer satisfaction, or evidence of future loyalty.

## Product return rates

**Returned units / purchased units × 100**, across the whole dataset. Running shoes have 10 of 43 units returned (23.26%); cotton socks have 0 of 33 (0%). The weekend duffel has no sales, so its return rate is `NULL`, displayed as `N/A` by the demo.

Sales and returns are aggregated separately before joining, preventing multiple return events from duplicating purchased quantities. This is a unit return rate, not the percentage of orders returned. Differences invite investigation but do not establish a cause such as product quality or sizing. The fixed observation window also limits follow-up for late-year purchases.

## Validation

Seven focused tests use a small fixture with amounts that can be checked by hand. Tests compare complete expected report rows and exercise invalid records and return boundaries. The demo always uses the full-year seed; GitHub Actions runs it to check setup and report execution. The full-year highlights above are illustrative results, not hard-coded test expectations.
