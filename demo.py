"""Build the retail database and display its analytical reports."""
from contextlib import closing
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parent


def build_database(seed_path=None):
    """Create a fresh database; tests may supply a focused SQL fixture."""
    connection = sqlite3.connect(':memory:')
    connection.execute('PRAGMA foreign_keys = ON')
    try:
        for path in (ROOT / 'sql' / '01_schema.sql',
                     seed_path if seed_path is not None else ROOT / 'sql' / '02_seed.sql',
                     ROOT / 'sql' / '03_views.sql'):
            connection.executescript(path.read_text())
    except Exception:
        connection.close()
        raise
    return connection


def print_report(cursor):
    headers = [column[0] for column in cursor.description]
    rows = [["N/A" if value is None else f"{value:.2f}" if isinstance(value, float)
             else str(value) for value in row] for row in cursor]
    widths = [max(len(header), *(len(row[i]) for row in rows))
              if rows else len(header) for i, header in enumerate(headers)]
    def line(values):
        return ' | '.join(value.ljust(width) for value, width in zip(values, widths))
    print(line(headers))
    print('-+-'.join('-' * width for width in widths))
    for row in rows:
        print(line(row))


def main():
    with closing(build_database()) as connection:
        print('Online Retail Database — synthetic 2024 retail scenario')
        counts = [f"{connection.execute('SELECT COUNT(*) FROM ' + table).fetchone()[0]} {label}"
                  for table, label in [('customer', 'customers'), ('product', 'products'),
                                       ('orders', 'orders'), ('order_item', 'sale lines'),
                                       ('return_item', 'return events')]]
        print(' | '.join(counts))
        for path in sorted((ROOT / 'sql' / 'analytics').glob('*.sql')):
            print('\n' + path.stem.replace('_', ' ').title())
            print_report(connection.execute(path.read_text()))


if __name__ == '__main__':
    main()
