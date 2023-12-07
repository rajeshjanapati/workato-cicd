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


# Rest of your script...

# Initial API request to get the ID
$idPath = "https://www.workato.com/api/packages/export/101814"

try {
    $idResponse = Invoke-RestMethod -Uri $idPath -Method 'POST' -Headers $headers -ContentType "application/json" -ErrorAction Stop -TimeoutSec 60

    # Check if the response content is not empty
    if ($idResponse) {
        # Extract the "id" value
        $idValue = $idResponse.id

        # Print the result
        Write-Host "ID Value: $idValue"

        # Make subsequent API requests until download_url is not null
        $downloadURL = $null
        do {
            $downloadURLpath = "https://www.workato.com/api/packages/$idValue"
            Write-Host "downloadURLpath: $downloadURLpath"
        
            $downloadURLresponse = Invoke-RestMethod $downloadURLpath -Method 'GET' -Headers $headers
        
            if ($downloadURLresponse) {
                # Access the "download_url" property directly
                $downloadURL = $downloadURLresponse.download_url
        
                Write-Host "downloadURL: $downloadURL"
        
                # Check if download_url is obtained
                if ($downloadURL -ne $null -and $downloadURL -ne "null") {
                    Write-Host "Download URL obtained: $downloadURL"
                }
            } else {
                Write-Host "API Request Successful but response content is empty."
            }
        
            # Delay before making the next request (optional)
            Start-Sleep -Seconds 5
        } while ($downloadURL -eq $null -or $downloadURL -eq "null")
    } else {
        Write-Host "API Request Successful but response content is empty."
    }
}
catch {
    Write-Host "API Request Failed. Error: $_"
    Write-Host "Response Content: $_.Exception.Response.Content"
}

# Rest of your script...


