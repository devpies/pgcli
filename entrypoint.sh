#!/bin/bash

# Function to URL encode the password using jq
urlencode() {
    local raw_password="$1"
    # Use jq to URL encode the password
    local encoded_password=$(printf '%s' "$raw_password" | jq -sRr @uri)
    echo "$encoded_password"
}

# Function to attempt connecting with pgcli
attempt_connection() {
    local url="$1"
    pgcli "$url"
}

# Get the CONN from environment variable or command argument
conn=${1:-$CONN}

if [ -n "$conn" ]; then
    # Split the dsn connection string into its components
    proto="$(echo $conn | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    db_url="$(echo ${conn/$proto/})"
    
    userpass="$(echo $db_url | grep @ | cut -d@ -f1)"
    user="$(echo $userpass | cut -d: -f1)"
    pass="$(echo $userpass | cut -d: -f2)"
    hostport_db="$(echo ${db_url/$userpass@/})"
    
    # Attempt to connect without encoding the password, suppressing any output
    url="$proto$user:$pass@$hostport_db"
    attempt_connection "$url" 2> /dev/null
    connection_status=$?

    if [ $connection_status -ne 0 ]; then
        # If the first attempt fails, URL encode the password and try again
        encoded_pass=$(urlencode "$pass")
        url="$proto$user:$encoded_pass@$hostport_db"
        attempt_connection "$url"
    fi
elif [ -n "$POSTGRES_PORT_5432_TCP_ADDR" ]; then
    # Fallback to Docker environment variables for linking
    pgcli postgres://$POSTGRES_ENV_POSTGRES_USER:$POSTGRES_ENV_POSTGRES_PASSWORD@$POSTGRES_PORT_5432_TCP_ADDR:$POSTGRES_PORT_5432_TCP_PORT
else
    echo "Database URL not provided, please try again."
    echo ""
fi