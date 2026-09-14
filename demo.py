"""Load the SQL files into SQLite and print the four reports."""
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parent


def print_report(cursor):
    headers = [column[0] for column in cursor.description]
    rows = []
    for record in cursor:
        row = []
        for value in record:
            if value is None:
                row.append("N/A")
            elif isinstance(value, float):
                row.append(f"{value:.2f}")
            else:
                row.append(str(value))
        rows.append(row)

    # Find the space needed for each column, including its heading.
    widths = [len(header) for header in headers]
    for row in rows:
        for index, value in enumerate(row):
            widths[index] = max(widths[index], len(value))

    print(" | ".join(header.ljust(width) for header, width in zip(headers, widths)))
    print("-+-".join("-" * width for width in widths))
    for row in rows:
        print(" | ".join(value.ljust(width) for value, width in zip(row, widths)))


def main():
    # :memory: creates a temporary database. Every run starts with fresh data.
    connection = sqlite3.connect(":memory:")
    try:
        connection.execute("PRAGMA foreign_keys = ON")
        for filename in ["01_schema.sql", "02_seed.sql", "03_views.sql"]:
            sql = (ROOT / "sql" / filename).read_text(encoding="utf-8")
            connection.executescript(sql)

        print("Online Retail Database — sample data for 2024")
        reports = [
            ("monthly_net_sales.sql", "Monthly Net Sales"),
            ("monthly_order_activity.sql", "Monthly Order Activity"),
            ("product_return_rates.sql", "Product Return Rates"),
            ("repeat_customers.sql", "Repeat Customers"),
        ]
        for filename, title in reports:
            print("\n" + title)
            sql = (ROOT / "sql" / "analytics" / filename).read_text(encoding="utf-8")
            print_report(connection.execute(sql))
    finally:
        connection.close()


if __name__ == "__main__":
    main()
