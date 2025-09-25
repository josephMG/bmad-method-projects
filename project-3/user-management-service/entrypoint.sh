#!/bin/sh

# Function to create database if it doesn't exist
create_database_if_not_exists() {
  DATABASE_URL="$1"
  DB_NAME=$(echo "$DATABASE_URL" | sed -n 's/.*\/[^?]*\/\([^?]*\).*/\1/p')
  DB_USER=$(echo "$DATABASE_URL" | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
  DB_PASSWORD=$(echo "$DATABASE_URL" | sed -n 's/.*:\/\/[^:]*:\([^@]*\).*/\1/p')
  DB_HOST=$(echo "$DATABASE_URL" | sed -n 's/.*@\([^:]*\):.*/\1/p')
  DB_PORT=$(echo "$DATABASE_URL" | sed -n 's/.*:\([0-9]*\)\/[^?]*$/\1/p')

  export PGPASSWORD=$DB_PASSWORD

  echo "Checking if database '$DB_NAME' exists on $DB_HOST:$DB_PORT..."
  if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -lqt | cut -d \| -f 1 | grep -wq "$DB_NAME"; then
    echo "Database '$DB_NAME' already exists."
  else
    echo "Database '$DB_NAME' does not exist. Creating..."
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d postgres -c "CREATE DATABASE $DB_NAME;"
    echo "Database '$DB_NAME' created."
  fi
}

# Wait for the database to be ready using the Python script
/app/.venv/bin/python /app/scripts/check_db.py

# Create the database if it doesn't exist
create_database_if_not_exists "$DATABASE_URL"

# Execute the main command
. .venv/bin/activate

exec "$@"
