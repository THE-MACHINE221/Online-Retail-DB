"""Run the SQL portfolio demo with Python's standard library only."""
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parent


def build_database():
    connection = sqlite3.connect(':memory:')
    connection.execute('PRAGMA foreign_keys = ON')
    for name in ('01_schema.sql', '02_seed.sql', '03_views.sql'):
        connection.executescript((ROOT / 'sql' / name).read_text())
    return connection


def main():
    with build_database() as connection:
        for path in sorted((ROOT / 'sql' / 'analytics').glob('*.sql')):
            print('\n' + path.stem.replace('_', ' ').title())
            cursor = connection.execute(path.read_text())
            print(' | '.join(column[0] for column in cursor.description))
            for row in cursor:
                print(' | '.join(str(value) for value in row))


if __name__ == '__main__':
    main()
