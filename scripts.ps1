# Input parameters
Param (
    [Parameter(mandatory = $true)][string]$accessToken, # To receive Workato token
    [Parameter(mandatory = $true)][string]$manifestId # To receive manifest_ID      
)

$headers = @{ Authorization = "Bearer $accessToken" }

# create cicd folder if not exists
$cicdPath = "cicd"
if (!(Test-Path -PathType Container cicd)) {
    mkdir "cicd"
    cd cicd
    Write-Host "Inside if: Created and moved to $cicdPath"
} else {
    cd cicd
    Write-Host "Inside else: Moved to $cicdPath"
}


# Rest of your script...

# Initial API request to get the ID
$idPath = "https://www.workato.com/api/packages/export/$manifestId"

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
                
                # Check if download_url is obtained
                if ($downloadURL -ne $null -and $downloadURL -ne "null") {
                    # Write-Host "Download URL obtained: $downloadURL"

                    # Extract file name from the URL without query parameters
                    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($downloadURL)
                    
                    # Set the path where you want to save the file (inside the cicd folder)
                    $savePath = Join-Path $PSScriptRoot "cicd\$fileName.zip"
                    
                    Write-Host "Downloading file to: $savePath"
                    
                    # Download the file
                    Invoke-WebRequest -Uri $downloadURL -OutFile $savePath
                    
                    Write-Host "File downloaded successfully!"
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
cd ..

# Rest of your script...


