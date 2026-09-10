# Metric definitions

## Monthly net sales

Sales = quantity × (sale-time unit price − per-unit discount). Refunds use the same discounted unit price multiplied by returned quantity. Net sales = sales − refunds. Sales are dated by purchase; refunds by return, so a later month's net sales can be negative. Tax and shipping are excluded.

| Month | Sales after discounts (SAR) | Refunds (SAR) | Net sales (SAR) |
|---|---:|---:|---:|
| 2024-01 | 270.00 | 0.00 | 270.00 |
| 2024-02 | 190.00 | 115.00 | 75.00 |

January order 1: two shirts at SAR 45 each plus trousers at SAR 80 = SAR 170. Order 2: a bag at SAR 100 = SAR 100. February sales: SAR 50 + SAR 140 = SAR 190. February refunds: one January shirt at SAR 45 and one February pair of trousers at SAR 70 = SAR 115.

## Repeat customers

A repeat customer has at least two order headers in the fixture, regardless of item count or returns. Customer 01 has two orders; customers 02 and 03 have one each. This is an all-fixture count, not a cohort-retention metric.

## Product return rate

Returned units / purchased units × 100, across the entire fixture. Shirts: 1/3; trousers: 1/3; bags: 0/1. A product with no purchased units has a NULL rate (undefined), not 0%. Multiple return events are aggregated before joining to sales totals to avoid multiplying line quantities. This is a unit rate, not a percentage of orders returned.
