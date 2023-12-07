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
$idPath = "https://www.workato.com/api/packages/export/101814"

try {
    $idResponse = Invoke-RestMethod -Uri $idPath -Method 'POST' -Headers $headers -ContentType "application/json" -ErrorAction Stop -TimeoutSec 60

    # Check if the response content is not empty
    if ($idResponse) {
        # Convert JSON data to PowerShell object
        # $dataObject = $proxies | ConvertTo-Json
        # Write-Host "JsonObject: $idResponse"

        # Extract the "id" value
        $idValue = $idResponse.id

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

$downloadURLpath = "https://www.workato.com/api/packages/"+$idValue
Write-Host "downloadURLpath: $downloadURLpath"

try {
    $downloadURLresponse = Invoke-RestMethod -Uri $downloadURLpath -Method 'GET' -Headers $headers -ContentType "application/json" -ErrorAction Stop -TimeoutSec 60

    # Check if the response content is not empty
    if ($downloadURLresponse) {
        # Convert JSON data to PowerShell object
        # $dataObject = $proxies | ConvertTo-Json
        Write-Host "JsonObject: $downloadURLresponse"

        # Extract the "id" value
        $downloadURL = $downloadURLresponse.download_url

        # Print the result
        Write-Host "downloadURL: $downloadURL"
    } else {
        Write-Host "API Request Successful but response content is empty."
    }
}
catch {
    Write-Host "API Request Failed. Error: $_"
    Write-Host "Response Content: $_.Exception.Response.Content"
}


