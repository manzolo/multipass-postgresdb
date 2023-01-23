#!/bin/bash

source $(dirname $0)/__functions.sh
DUMP_FILE="$1/data/$2"
if test -f "$DUMP_FILE"; then
    msg_warn "Restore database..."
    cat $DUMP_FILE | docker exec -i $DB_CONTAINER_NAME pg_restore --create --clean -d $DB_NAME
    msg_info "backup restored from $DUMP_FILE!"
else
    msg_error "Backup $DUMP_FILE not found!"
    exit 1
fi