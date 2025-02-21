#!/bin/bash
: << 'EOF'
.SYNOPSIS
This script reads the contents of a file named '.env' and sets environment variables for each line in the file.
.DESCRIPTION
The '.env' file is a common convention for storing environment variables in a text file. Each line in the file is in the format 'VARIABLE=VALUE'. This script reads each line, splits it into the variable name and value, and sets the environment variable in the system.

.PARAMETER None
This script does not take any parameters.

.EXAMPLE
./export_env.sh
This command will read the '.env' file in the current directory and set environment variables for each line in the file.
EOF

# Read the contents of the '.env' file and loop through each line
while IFS='=' read -r name value; do
    # Skip empty lines and lines starting with #
    [[ -z "$name" || "$name" =~ ^# ]] && continue

    # Export the environment variable
    export "$name=$value"
done < .env
