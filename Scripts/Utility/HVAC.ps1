## Convert Fahrenheit to Celsius
function ConvertFahrenheitToCelsius {
    param(
        [double]$fahrenheit
    )
    
    $celsius = $fahrenheit - 32
    $celsius = $celsius / 1.8
    return $celsius
}

## Convert Celsius to Fahrenheit
function ConvertCelsiusToFahrenheit {
    param(
        [double]$celsius
    )
    
    $fahrenheit = ($celsius * 1.8) + 32
    return $fahrenheit
}

# Example usage:
# ConvertFahrenheitToCelsius -fahrenheit 98.6
# ConvertCelsiusToFahrenheit -celsius 37