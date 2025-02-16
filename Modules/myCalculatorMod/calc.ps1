# Calulater App
# how would I start a proscess calculator App by stoping it.
# Start-Process -name ""
#Stop-Process -name "CalculatorApp"
#exit 0 # success


function Start-Calculator {
    Start-Process "calc.exe"
    exit 0 # success
}

 Start-Calculator

function Stop-Calculator {
    Stop-Process -name "CalculatorApp"
    exit 0 # success
}

 Stop-Calculator

# Export functions (if used as a module)
 Export-ModuleMember -Function Start-Calculator, Stop-Calculator