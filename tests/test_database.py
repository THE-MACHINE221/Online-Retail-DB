from collections import Counter, defaultdict
import sqlite3
import unittest
from demo import ROOT, build_database


class RetailDatabaseTests(unittest.TestCase):
    def setUp(self):
        self.db = build_database(ROOT / 'tests' / 'fixture.sql')

    def tearDown(self):
        self.db.close()

    def query(self, name):
        return self.db.execute((ROOT / 'sql' / 'analytics' / (name + '.sql')).read_text()).fetchall()

    def test_expected_business_results(self):
        self.assertEqual(self.query('monthly_net_sales'), [('2024-01', 270.0, 0.0, 270.0), ('2024-02', 190.0, 115.0, 75.0)])
        self.assertEqual(self.query('repeat_customers'), [(1, 'Demo Customer 01', 2)])
        self.assertEqual([row[-1] for row in self.query('product_return_rates')], [33.33, 33.33, 0.0])

    def test_price_change_preserves_sales_and_refunds(self):
        before = self.query('monthly_net_sales')
        self.db.execute('UPDATE product SET price_halalas = 99999')
        self.assertEqual(before, self.query('monthly_net_sales'))

    def test_cumulative_partial_returns_and_refund_only_month(self):
        self.db.execute("INSERT INTO return_item VALUES (3, 1, '2024-03-01', 1)")
        self.assertEqual(self.query('monthly_net_sales')[-1], ('2024-03', 0.0, 45.0, -45.0))
        self.assertEqual(self.query('product_return_rates')[0][-1], 66.67)
        with self.assertRaisesRegex(sqlite3.IntegrityError, 'exceeds'):
            self.db.execute("INSERT INTO return_item VALUES (4, 1, '2024-03-02', 1)")

    def test_return_before_purchase_rejected(self):
        with self.assertRaisesRegex(sqlite3.IntegrityError, 'precedes'):
            self.db.execute("INSERT INTO return_item VALUES (3, 1, '2023-12-01', 1)")

    def test_foreign_keys(self):
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute("INSERT INTO return_item VALUES (3, 999, '2024-03-01', 1)")
        self.assertEqual(self.db.execute('PRAGMA foreign_key_check').fetchall(), [])

    def test_invalid_values_rejected(self):
        for quantity, price, discount in [(0, 100, 0), (-1, 100, 0), (1.5, 100, 0), (1, -1, 0), (1, 100, 101), (1, 100, -1), (1, 100.5, 0)]:
            with self.subTest(values=(quantity, price, discount)):
                with self.assertRaises(sqlite3.IntegrityError):
                    self.db.execute('INSERT INTO order_item VALUES (99, 1, 1, ?, ?, ?)', (quantity, price, discount))

    def test_invalid_dates_rejected(self):
        for value in ('not-a-date', '2024-02-30', '2024-1-1'):
            with self.subTest(date=value):
                with self.assertRaises(sqlite3.IntegrityError):
                    self.db.execute('INSERT INTO orders VALUES (99, 1, 1, ?)', (value,))

    def test_historical_records_immutable(self):
        for statement in ('UPDATE order_item SET quantity = 1 WHERE order_item_id = 1', "UPDATE orders SET order_date = '2025-01-01' WHERE order_id = 1", 'UPDATE return_item SET quantity = 2 WHERE return_id = 1', 'DELETE FROM return_item', 'DELETE FROM order_item'):
            with self.subTest(sql=statement):
                with self.assertRaises(sqlite3.IntegrityError):
                    self.db.execute(statement)

    def test_unsold_product_has_undefined_return_rate(self):
        self.db.execute("INSERT INTO product VALUES (4, 1, 'Unsold demo shirt', 5000)")
        self.assertEqual(self.query('product_return_rates')[-1][-3:], (0, 0, None))


class FullDatasetTests(unittest.TestCase):
    def setUp(self):
        self.db = build_database()

    def tearDown(self):
        self.db.close()

    def query(self, name):
        return self.db.execute((ROOT / 'sql' / 'analytics' / (name + '.sql')).read_text()).fetchall()

    def test_reports_reconcile_with_underlying_records(self):
        # Calculate independently in Python, without relying on the SQL views/CTEs.
        orders = {oid: (cid, date) for oid, cid, _, date in self.db.execute('SELECT * FROM orders')}
        items = {iid: (oid, pid, qty, price, discount)
                 for iid, oid, pid, qty, price, discount in self.db.execute('SELECT * FROM order_item')}
        sales, refunds, gross, discounts = (defaultdict(int) for _ in range(4))
        sold, returned, frequency, order_counts = (Counter() for _ in range(4))
        active = defaultdict(set)
        for cid, date in orders.values():
            frequency[cid] += 1
            order_counts[date[:7]] += 1
            active[date[:7]].add(cid)
        for oid, pid, qty, price, discount in items.values():
            month = orders[oid][1][:7]
            sales[month] += qty * (price - discount)
            gross[month] += qty * price
            discounts[month] += qty * discount
            sold[pid] += qty
        for _, iid, date, qty in self.db.execute('SELECT * FROM return_item'):
            _, pid, _, price, discount = items[iid]
            refunds[date[:7]] += qty * (price - discount)
            returned[pid] += qty
        expected = [(month, sales[month] / 100, refunds[month] / 100,
                     (sales[month] - refunds[month]) / 100)
                    for month in sorted(sales.keys() | refunds.keys())]
        self.assertEqual(self.query('monthly_net_sales'), expected)
        for month, count, customers, aov, rate in self.query('monthly_order_activity'):
            self.assertEqual((count, customers), (order_counts[month], len(active[month])))
            self.assertAlmostEqual(aov, sales[month] / (100 * count), delta=0.00501)
            self.assertAlmostEqual(rate, 100 * discounts[month] / gross[month], delta=0.00501)
        expected_repeat = [(cid, name, frequency[cid])
                           for cid, name in self.db.execute('SELECT customer_id, display_name FROM customer')
                           if frequency[cid] >= 2]
        expected_repeat.sort(key=lambda row: (-row[2], row[0]))
        self.assertEqual(self.query('repeat_customers'), expected_repeat)
        for pid, _, units, returns, rate in self.query('product_return_rates'):
            self.assertEqual((units, returns), (sold[pid], returned[pid]))
            self.assertEqual(rate, round(100 * returned[pid] / sold[pid], 2) if sold[pid] else None)
        self.assertEqual(self.db.execute('PRAGMA foreign_key_check').fetchall(), [])

    def test_scenario_coverage_and_documented_highlights(self):
        self.assertEqual([self.db.execute('SELECT COUNT(*) FROM ' + table).fetchone()[0]
                          for table in ['customer', 'product', 'orders', 'order_item', 'return_item']],
                         [24, 13, 167, 410, 53])
        monthly = self.query('monthly_net_sales')
        self.assertEqual([row[0] for row in monthly], [f'2024-{month:02}' for month in range(1, 13)])
        self.assertEqual(max(monthly, key=lambda row: row[3]), ('2024-12', 8429.5, 1094.5, 7335.0))
        self.assertEqual(self.query('monthly_order_activity')[10], ('2024-11', 20, 13, 293.25, 15.31))
        self.assertEqual(len(self.query('repeat_customers')), 21)
        self.assertEqual(self.query('repeat_customers')[0], (2, 'Demo Customer 02', 19))
        self.assertEqual(self.query('product_return_rates')[8], (9, 'Running shoes', 43, 10, 23.26))
        self.assertTrue(self.db.execute('SELECT order_item_id FROM return_item GROUP BY order_item_id HAVING COUNT(*) > 1').fetchall())

    def test_order_activity_includes_empty_order_headers(self):
        self.db.execute("INSERT INTO orders VALUES (999, 1, 1, '2025-01-01')")
        self.assertEqual(self.query('monthly_order_activity')[-1], ('2025-01', 1, 1, 0.0, None))


if __name__ == '__main__':
    unittest.main()
