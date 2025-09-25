import os
import sys
import time
import psycopg2

DB_URL = os.environ.get("DATABASE_URL")
if not DB_URL:
    print("DATABASE_URL environment variable not set.")
    sys.exit(1)

MAX_RETRIES = 30
RETRY_INTERVAL = 2

print(f"Attempting to connect to database: {DB_URL}")

for i in range(MAX_RETRIES):
    try:
        conn = psycopg2.connect(DB_URL)
        conn.close()
        print("Database connection successful!")
        sys.exit(0)
    except psycopg2.OperationalError as e:
        print(f"Attempt {i+1}/{MAX_RETRIES}: Database connection failed - {e}")
        time.sleep(RETRY_INTERVAL)

print("Failed to connect to database after multiple retries.")
sys.exit(1)