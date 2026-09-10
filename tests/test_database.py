import sqlite3
import unittest
from demo import ROOT, build_database


class RetailDatabaseTests(unittest.TestCase):
    def setUp(self):
        self.db = build_database()

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


if __name__ == '__main__':
    unittest.main()
