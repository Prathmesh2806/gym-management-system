# Using MySQL 8.0 to support the JSON data types in your schema
FROM mysql:8.0

# Environment variables for the database
# These must match the 'CREATE DATABASE' in your init.sql
ENV MYSQL_DATABASE=gymapp
ENV MYSQL_ROOT_PASSWORD=gym_admin_password_99

# Copy your schema file into the special entrypoint folder.
# MySQL automatically executes any .sql files found here on startup.
COPY ./init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306