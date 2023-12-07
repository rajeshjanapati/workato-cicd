# write-output Apigee Artifacts
$github_token = $env:github_token
$access_token = $env:access_token

$headers = @{ Authorization = "Bearer $access_token" }

# create cicd folder if not exists
$cicdPath = "cicd"
if (!(Test-Path -PathType Container $cicdPath)) {
    mkdir $cicdPath
    Set-Location -Path $cicdPath
    Write-Host "Inside if: Created and moved to $cicdPath"
} else {
    Set-Location -Path $cicdPath
    Write-Host "Inside else: Moved to $cicdPath"
}

# API request
$path = "https://www.workato.com/api/packages/export/101814"
try {
    $response = Invoke-RestMethod -Uri $path -Method 'POST' -Headers $headers -ContentType "application/json" -ErrorAction Stop -TimeoutSec 60
    Write-Host "API Request Successful"
    
    # Convert JSON data to PowerShell object
    $dataObject = $response | ConvertFrom-Json

    # Extract the "id" value
    $idValue = $dataObject.id

    # Print the result
    Write-Host "ID Value: $idValue"
} catch {
    Write-Host "API Request Failed. Error: $_"
}
