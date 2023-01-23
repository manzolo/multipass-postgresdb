#!/bin/bash

HOST_DIR_NAME=${PWD}
#------------------- Env vars ---------------------------------------------
#Number of Cpu for main VM
mainCpu=1
#GB of RAM for main VM
mainRam=1Gb
#GB of HDD for main VM
mainHddGb=10Gb
#--------------------------------------------------------------------------

#Include functions
. $(dirname $0)/script/__functions.sh 

msg_warn "Check prerequisites..."

#Check prerequisites
check_command_exists "multipass"

msg_warn "Creating vm"
multipass launch -m $mainRam -d $mainHddGb -c $mainCpu -n $VM_NAME

msg_info $VM_NAME" is up!"

msg_info "[Task 1]"
msg_warn "Mount host drive with installation scripts"

multipass mount ${HOST_DIR_NAME} $VM_NAME

multipass list

msg_info "[Task 2]"
msg_warn "Configure $VM_NAME"

cat <<EOF >${HOST_DIR_NAME}/config/docker-compose.yml
version: "3.8"

services:

  $DB_CONTAINER_NAME:
    image: $DB_CONTAINER_IMAGE
    container_name: $DB_CONTAINER_NAME
    restart: always
    volumes:
      - $DB_CONTAINER_NAME-pgdata:/var/lib/postgresql/data
    ports:
      - $DB_HOST_PORT:$DB_CONTAINER_PORT
    environment:
      POSTGRES_USER: $DB_ROOT_USER
      POSTGRES_PASSWORD: $DB_ROOT_PASS

  pgadmin:
    image: $PGADMIN_CONTAINER_IMAGE
    container_name: $PGADMIN_CONTAINER_NAME
    ports:
      - $PGADMIN_HOST_PORT:$PGADMIN_CONTAINER_PORT
    environment:
      PGADMIN_DEFAULT_EMAIL: $PGADMIN_DEFAULT_EMAIL
      PGADMIN_DEFAULT_PASSWORD: $PGADMIN_DEFAULT_PASSWORD
    volumes:
      - $DB_CONTAINER_NAME-data:/var/lib/pgadmin
    depends_on:
      - $DB_CONTAINER_NAME

volumes:
  $DB_CONTAINER_NAME-pgdata:
  $DB_CONTAINER_NAME-data:
EOF

run_command_on_vm "$VM_NAME" "${HOST_DIR_NAME}/script/_configure.sh ${HOST_DIR_NAME}"

msg_info "Check database..."
run_command_on_vm $VM_NAME $(dirname $0)/script/_create_database.sh

msg_info "[Task 3]"
msg_warn "Start env"
${HOST_DIR_NAME}/start.sh
