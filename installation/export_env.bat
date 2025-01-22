:: Set the local environment to preserve variables after the script ends
setlocal

:: Read the .env file line by line and set each variable
:: This loop assumes that each line in the .env file is in the format "VARIABLE=VALUE"
FOR /F "tokens=*" %%i in ('type .env') do (
    :: Set the variable named in the current line to its corresponding value
    set %%i
)

:: End the local environment to release any variables set within
endlocal
