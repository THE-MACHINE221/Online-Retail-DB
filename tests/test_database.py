"""Small, hand-checkable examples: prepare data, act, then check the result.

Each test gets a fresh database containing tests/fixture.sql.
Run from the repository root: python3 -m unittest discover -s tests -v
"""
import sqlite3
import unittest
from demo import ROOT, build_database


class RetailDatabaseTests(unittest.TestCase):
    def setUp(self):
        self.db = build_database(ROOT / 'tests' / 'fixture.sql')

    def tearDown(self):
        self.db.close()

    def report(self, name):
        """Run the actual SQL report, rather than copying its calculation here."""
        sql = (ROOT / 'sql' / 'analytics' / (name + '.sql')).read_text()
        return self.db.execute(sql).fetchall()

    def test_sales_and_refunds(self):
        # January: 90 + 80 + 100 = 270 SAR.
        # February: 50 + 140 sales - (45 + 70 refunds) = 75 SAR.
        self.assertEqual(self.report('monthly_net_sales'), [
            ('2024-01', 270.0, 0.0, 270.0),
            ('2024-02', 190.0, 115.0, 75.0),
        ])

    def test_multiple_items_do_not_inflate_order_counts(self):
        # Order 1 has two lines, but is still only one order.
        self.assertEqual(self.report('repeat_customers'), [
            (1, 'Demo Customer 01', 2),
        ])
        # Columns: month, orders, customers, average order value, discount %.
        # Compare the whole report so a missing month also fails the test.
        self.assertEqual(self.report('monthly_order_activity'), [
            ('2024-01', 2, 2, 135.0, 10.0),
            ('2024-02', 2, 2, 95.0, 9.52),
        ])

    def test_catalogue_prices_do_not_change_history(self):
        before = self.report('monthly_net_sales')
        self.db.execute('UPDATE product SET price_halalas = 99999')
        self.assertEqual(self.report('monthly_net_sales'), before)

    def test_partial_returns_and_their_limit(self):
        # Two shirts were bought on line 1; one has already been returned.
        self.db.execute("INSERT INTO return_item VALUES (3, 1, '2024-03-01', 1)")
        # March has a refund without any sales and must remain in the report.
        self.assertEqual(self.report('monthly_net_sales'), [
            ('2024-01', 270.0, 0.0, 270.0),
            ('2024-02', 190.0, 115.0, 75.0),
            ('2024-03', 0.0, 45.0, -45.0),
        ])
        with self.assertRaisesRegex(sqlite3.IntegrityError, 'exceeds'):
            self.db.execute("INSERT INTO return_item VALUES (4, 1, '2024-03-02', 1)")
        self.assertEqual(self.db.execute(
            'SELECT SUM(quantity) FROM return_item WHERE order_item_id = 1'
        ).fetchone()[0], 2)
        # A return on the purchase date is valid.
        self.db.execute("INSERT INTO return_item VALUES (5, 2, '2024-01-10', 1)")

    def test_invalid_records_are_rejected(self):
        # Each example names the rule it tests. Unique IDs avoid accidental
        # primary-key conflicts masking a different validation error.
        cases = [
            ('missing customer', "INSERT INTO orders VALUES (90, 999, 1, '2024-03-01')", 'FOREIGN KEY'),
            ('missing purchase', "INSERT INTO return_item VALUES (91, 999, '2024-03-01', 1)", 'FOREIGN KEY'),
            ('zero sale quantity', 'INSERT INTO order_item VALUES (92, 1, 1, 0, 100, 0)', 'CHECK'),
            ('fractional sale quantity', 'INSERT INTO order_item VALUES (93, 1, 1, 1.5, 100, 0)', 'CHECK'),
            ('negative sale price', 'INSERT INTO order_item VALUES (94, 1, 1, 1, -1, 0)', 'CHECK'),
            ('discount exceeds price', 'INSERT INTO order_item VALUES (95, 1, 1, 1, 100, 101)', 'CHECK'),
            ('negative catalogue price', "INSERT INTO product VALUES (96, 1, 'Invalid', -1)", 'CHECK'),
            ('zero returned quantity', "INSERT INTO return_item VALUES (97, 1, '2024-03-01', 0)", 'CHECK'),
            ('negative returned quantity', "INSERT INTO return_item VALUES (98, 1, '2024-03-01', -1)", 'CHECK'),
            ('fractional returned quantity', "INSERT INTO return_item VALUES (99, 1, '2024-03-01', 0.5)", 'CHECK'),
            ('impossible order date', "INSERT INTO orders VALUES (100, 1, 1, '2024-02-30')", 'CHECK'),
            ('impossible return date', "INSERT INTO return_item VALUES (101, 1, '2024-02-30', 1)", 'CHECK'),
            ('malformed return date', "INSERT INTO return_item VALUES (102, 1, 'not-a-date', 1)", 'CHECK'),
            ('return before purchase', "INSERT INTO return_item VALUES (103, 1, '2023-12-01', 1)", 'precedes'),
        ]
        for rule, sql, message in cases:
            with self.subTest(rule=rule):
                with self.assertRaisesRegex(sqlite3.IntegrityError, message):
                    self.db.execute(sql)
        # A real leap-day date should be accepted.
        self.db.execute("INSERT INTO orders VALUES (104, 1, 1, '2024-02-29')")

    def test_return_rates_include_unsold_products(self):
        self.db.execute("INSERT INTO product VALUES (4, 1, 'Unsold demo shirt', 5000)")
        # Compare every row and column, including the unsold product's NULL rate.
        self.assertEqual(self.report('product_return_rates'), [
            (1, 'Classic shirt', 3, 1, 33.33),
            (2, 'Cotton trousers', 3, 1, 33.33),
            (3, 'Everyday bag', 1, 0, 0.0),
            (4, 'Unsold demo shirt', 0, 0, None),
        ])

    def test_transaction_history_cannot_be_overwritten(self):
        statements = [
            "UPDATE orders SET order_date = '2025-01-01' WHERE order_id = 1",
            'UPDATE order_item SET quantity = 1 WHERE order_item_id = 1',
            'UPDATE return_item SET quantity = 2 WHERE return_id = 1',
            # Line 2 has no returns: a foreign key cannot mask a missing trigger.
            'DELETE FROM order_item WHERE order_item_id = 2',
            'DELETE FROM return_item WHERE return_id = 1',
            "INSERT OR REPLACE INTO orders VALUES (1, 1, 1, '2025-01-01')",
            'INSERT OR REPLACE INTO order_item VALUES (1, 1, 1, 1, 100, 0)',
            "INSERT OR REPLACE INTO return_item VALUES (1, 1, '2024-04-01', 1)",
        ]
        tables = ('orders', 'order_item', 'return_item')
        before = [self.db.execute('SELECT * FROM ' + table + ' ORDER BY 1').fetchall()
                  for table in tables]
        for sql in statements:
            with self.subTest(statement=sql):
                with self.assertRaisesRegex(sqlite3.IntegrityError, 'immutable|append-only'):
                    self.db.execute(sql)
                after = [self.db.execute('SELECT * FROM ' + table + ' ORDER BY 1').fetchall()
                         for table in tables]
                self.assertEqual(after, before)


if __name__ == '__main__':
    unittest.main()
