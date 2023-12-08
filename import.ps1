# Input parameters
Param (
    [Parameter(mandatory = $true)][string]$accessToken, # To receive Workato token  
    [Parameter(mandatory = $true)][string]$manifestName, # To receive manifest Name
    [Parameter(mandatory = $true)][string]$folderId # To receive folderId
)

# Convert the $accessToken value to bytes and then back to a string to remove invalid characters
$accessTokenBytes = [System.Text.Encoding]::UTF8.GetBytes($accessToken)
$accessToken = [System.Text.Encoding]::UTF8.GetString($accessTokenBytes)

Write-Host "manifestName:$manifestName"
Write-Host "folderId:$folderId"

$headers = @{ 'Authorization' = "Bearer $accessToken" }

$manifestDirectory = "cicd"
Write-Host "manifestDirectory:$manifestDirectory"

Write-Host "Start Import manifest for $manifestName "
Set-Location $manifestDirectory
$currentdir = Get-Location
$manifestNameFolder = "$currentdir"

# Install the PSWriteHTML module
Install-Module -Name PSWriteHTML -Force -SkipPublisherCheck

# Import the PSWriteHTML module
Import-Module PSWriteHTML

if ($manifestName -ne 'null' -AND (Test-Path $manifestNameFolder)) {
    Set-Location $manifestNameFolder
    $zipFile = Get-ChildItem -Filter "$manifestName.zip"

    if ($zipFile) {
        $zipContent = [IO.File]::ReadAllBytes($zipFile.FullName)
        $requestFile = @{
            file = $zipContent
            filename = $zipFile.Name
        }

        $uri = "https://www.workato.com/api/packages/import/$folderId?restart_recipes=true"

        $webHeaderCollection = New-Object 'System.Net.WebHeaderCollection'
        foreach ($key in $headers.Keys) {
            $webHeaderCollection.Add($key, $headers[$key])
        }

        $formData = ConvertTo-Formdata -Hashtable $requestFile
        Invoke-RestMethod -Uri $uri -Method 'POST' -Headers $webHeaderCollection -Body $formData -ContentType "multipart/form-data"
        Write-Host "manifestName $manifestName"
    }
    else {
        Write-Host "No zip file found with the name $manifestName"
    }
}
else {
    Write-Host "Either manifestName is 'null' or $manifestNameFolder does not exist."
}
