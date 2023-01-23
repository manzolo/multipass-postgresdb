#!/bin/bash

source $(dirname $0)/__functions.sh
NOW="$(date +"%Y-%m-%d-%H-%M")"
DUMP_FILE="$1/data/$DB_NAME"_"$NOW.dump"

msg_warn "Backup database..."

PSQL_CMD="pg_dump -Fc $DB_NAME"
#echo $PSQL_CMD
docker exec -i $DB_CONTAINER_NAME sh -c "$PSQL_CMD" > $DUMP_FILE
if test -f "$DUMP_FILE"; then
    msg_info "Backup done in $DUMP_FILE!"
else
    msg_error "Unable to backup $DUMP_FILE!"
fi


