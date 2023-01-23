#!/bin/bash

source $(dirname $0)/__functions.sh

msg_warn "Create database..."
sleep 30

CREATE_DB_CMD="create database $DB_NAME;"
PSQL_CMD="psql -c '$CREATE_DB_CMD'"
docker exec -i $DB_CONTAINER_NAME sh -c "$PSQL_CMD"

msg_warn "Create user database..."
CREATE_USER_CMD="create user $DB_USER;"
PSQL_CMD="psql -c '$CREATE_USER_CMD'"
docker exec -i $DB_CONTAINER_NAME sh -c "$PSQL_CMD"

msg_warn "Grant user database..."

CREATE_USER_GRANT_CMD="alter user $DB_USER with password '$DB_PASS';"
PSQL_CMD="psql -c \"$CREATE_USER_GRANT_CMD\""
docker exec -i $DB_CONTAINER_NAME sh -c "$PSQL_CMD"

CREATE_USER_GRANT_CMD="grant all privileges on database $DB_NAME to $DB_USER;"
PSQL_CMD="psql -c '$CREATE_USER_GRANT_CMD'"
docker exec -i $DB_CONTAINER_NAME sh -c "$PSQL_CMD"

# msg_info "Database ready!"
