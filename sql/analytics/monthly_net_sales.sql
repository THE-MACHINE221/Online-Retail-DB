-- WITH gives an intermediate query a name: events.
-- First list sales, then append refunds with UNION ALL.
-- Keeping both means a month with only refunds still appears.
WITH events AS (
    SELECT
        substr(order_date, 1, 7) AS month,
        sales_halalas AS sales,
        0 AS refunds
    FROM sale_line

    UNION ALL

    SELECT
        substr(return_date, 1, 7) AS month,
        0 AS sales,
        refund_halalas AS refunds
    FROM refund_line
)
SELECT
    month,
    SUM(sales) / 100.0 AS sales_sar,
    SUM(refunds) / 100.0 AS refunds_sar,
    (SUM(sales) - SUM(refunds)) / 100.0 AS net_sales_sar
FROM events
GROUP BY month
ORDER BY month;
