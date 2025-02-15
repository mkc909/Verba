# Ensure 1Password CLI is signed in
if (-not (op signin --list)) {
    Write-Error "Please sign in to 1Password CLI first"
    exit 1
}

try {
    Write-Host "Fetching API keys from 1Password..."
    
    # Export OpenAI and Cohere API keys from 1password
    $env:OP_OPENAI_API_KEY = (op item get "OpenAI API Key" --format json | ConvertFrom-Json).fields | Where-Object { $_.label -eq "credential" } | Select-Object -ExpandProperty value
    $env:OP_COHERE_API_KEY = (op item get "Cohere API Key" --format json | ConvertFrom-Json).fields | Where-Object { $_.label -eq "credential" } | Select-Object -ExpandProperty value

    if (-not $env:OP_OPENAI_API_KEY -or -not $env:OP_COHERE_API_KEY) {
        throw "Failed to retrieve API keys from 1Password"
    }

    Write-Host "Starting Verba services..."
    docker-compose up --force-recreate
}
catch {
    Write-Error "Error: $_"
    exit 1
}
