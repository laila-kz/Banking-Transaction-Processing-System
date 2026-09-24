#!/usr/bin/env python3
"""
Seed script to populate bank_sys_final database with demo data.
Useful for development and staging environments without requiring 1GB dataset files.
"""

import os
import sys
import mysql.connector
from dotenv import load_dotenv

load_dotenv()

DB_HOST = os.getenv("BANK_DB_HOST", "127.0.0.1")
DB_PORT = int(os.getenv("BANK_DB_PORT", "3306"))
DB_USER = os.getenv("BANK_DB_USER", "root")
DB_PASSWORD = os.getenv("BANK_DB_PASSWORD", "")
DB_NAME = os.getenv("BANK_DB_NAME", "bank_sys_final")


def seed_data():
    print(f"Connecting to MySQL at {DB_HOST}:{DB_PORT}/{DB_NAME}...")
    try:
        conn = mysql.connector.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            autocommit=False,
        )
    except mysql.connector.Error as exc:
        print(f"❌ Connection failed: {exc}")
        sys.exit(1)

    cursor = conn.cursor()
    try:
        print("🌱 Seeding Demo Customers...")
        customers_sql = """
        INSERT INTO customers (
            customer_id, full_name, email, phone, current_age, retirement_age, birth_year,
            birth_month, gender, address, yearly_income, total_debt, credit_score,
            num_credit_cards, account_status
        ) VALUES
        (1, 'Alice Johnson', 'alice.johnson@example.com', '+1-555-0101', 34, 65, 1990, 5, 'Female', '123 Main St, New York, NY', 85000.00, 4500.00, 750, 2, 'ACTIVE'),
        (2, 'Bob Smith', 'bob.smith@example.com', '+1-555-0102', 42, 65, 1982, 9, 'Male', '456 Elm St, San Francisco, CA', 115000.00, 12000.00, 710, 3, 'ACTIVE'),
        (3, 'Carol Danvers', 'carol.danvers@example.com', '+1-555-0103', 29, 67, 1995, 2, 'Female', '789 Oak Ave, Chicago, IL', 68000.00, 2000.00, 680, 1, 'ACTIVE')
        ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);
        """
        cursor.execute(customers_sql)

        print("🌱 Seeding MCC Codes...")
        mcc_sql = """
        INSERT INTO mcc (mcc_code, mcc_description) VALUES
        ('5411', 'Grocery Stores, Supermarkets'),
        ('5812', 'Eating Places, Restaurants'),
        ('5541', 'Service Stations'),
        ('4829', 'Money Transfer - Merchant'),
        ('6011', 'Financial Institutions - Automated Cash')
        ON DUPLICATE KEY UPDATE mcc_description = VALUES(mcc_description);
        """
        cursor.execute(mcc_sql)

        print("🌱 Seeding Merchants...")
        merchants_sql = """
        INSERT INTO merchants (merchant_id, merchant_name, mcc_code, merchant_city, merchant_state, flag, active_status) VALUES
        (1001, 'Whole Foods Market', '5411', 'New York', 'NY', 0, 'ACTIVE'),
        (1002, 'Starbucks Coffee', '5812', 'San Francisco', 'CA', 0, 'ACTIVE'),
        (1003, 'Shell Gas Station', '5541', 'Chicago', 'IL', 0, 'ACTIVE')
        ON DUPLICATE KEY UPDATE merchant_name = VALUES(merchant_name);
        """
        cursor.execute(merchants_sql)

        conn.commit()

        print("🌱 Creating Accounts via sp_create_account...")
        # Create checking & savings accounts for Alice and Bob
        cursor.callproc("sp_create_account", [1, "CHECKING", "USD", 2500.00, "seeder"])
        for res in cursor.stored_results():
            res.fetchall()
        cursor.callproc("sp_create_account", [1, "SAVINGS", "USD", 10000.00, "seeder"])
        for res in cursor.stored_results():
            res.fetchall()

        cursor.callproc("sp_create_account", [2, "CHECKING", "USD", 5000.00, "seeder"])
        for res in cursor.stored_results():
            res.fetchall()

        conn.commit()
        print("✅ Demo data seeded successfully!")

    except mysql.connector.Error as exc:
        conn.rollback()
        print(f"❌ Error during seeding: {exc}")
    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    seed_data()
