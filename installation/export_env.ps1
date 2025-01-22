<#
.SYNOPSIS
This script reads the contents of a file named '.env' and sets environment variables for each line in the file.
.DESCRIPTION
The '.env' file is a common convention for storing environment variables in a text file. Each line in the file is in the format 'VARIABLE=VALUE'. This script reads each line, splits it into the variable name and value, and sets the environment variable in the system.

.PARAMETER None
This script does not take any parameters.

.EXAMPLE
PS C:\> .\export_env.ps1
This command will read the '.env' file in the current directory and set environment variables for each line in the file.

.NOTES
This script was written by [Your Name]. You can find more information about me at [Your Website].
#>

# Read the contents of the '.env' file and loop through each line
get-content .env | foreach {
    # Split each line into the variable name and value
    $name, $value = $_.split('=')

    # Set the environment variable in the system
    set-content env:\$name $value
}
