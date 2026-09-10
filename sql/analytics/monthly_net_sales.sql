-- Sales on purchase date; refunds on return date, including months with refunds only.
WITH events AS (
    SELECT substr(order_date, 1, 7) AS month, sales_halalas AS sales, 0 AS refunds FROM sale_line
    UNION ALL
    SELECT substr(return_date, 1, 7), 0, refund_halalas FROM refund_line
)
SELECT month, SUM(sales) / 100.0 AS sales_sar,
       SUM(refunds) / 100.0 AS refunds_sar,
       (SUM(sales) - SUM(refunds)) / 100.0 AS net_sales_sar
FROM events GROUP BY month ORDER BY month;
