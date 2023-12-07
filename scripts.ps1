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
    $proxies = Invoke-RestMethod -Uri $path -Method 'POST' -Headers $headers -ContentType "application/json" -ErrorAction Stop -TimeoutSec 60
    Write-Host "Response: $proxies"

    # Check if the response content is not empty
    if ($proxies) {
        # Convert JSON data to PowerShell object
        $dataObject = $proxies | ConvertTo-Json
        Write-Host "JsonObject: $dataObject"

        # Extract the "id" value
        $idValue = $dataObject.id

        # Print the result
        Write-Host "ID Value: $idValue"
    } else {
        Write-Host "API Request Successful but response content is empty."
    }
}
catch {
    Write-Host "API Request Failed. Error: $_"
    Write-Host "Response Content: $_.Exception.Response.Content"
}
