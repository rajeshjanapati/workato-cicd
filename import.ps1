# Input parameters
Param (
  [Parameter(mandatory = $true)][string]$accessToken, # To receive Workato token
  [Parameter(mandatory = $true)][string]$manifestName, # To receive manifest name
  [Parameter(mandatory = $true)][string]$folderId # To receive folder ID
)

$headers = @{ 'Authorization' = "Bearer $accessToken" }

$manifestDirectory = "cicd"
Write-Host "manifestDirectory:$manifestDirectory"
Set-Location $manifestDirectory
$currentdir = Get-Location
$manifestNameFolder = "$currentdir"
Set-Location $manifestNameFolder


# Check if the ZIP file exists in the current directory
$zipFile = Get-ChildItem -Filter "$manifestName.zip"
Write-Host "FileName:$zipFile"

if ($zipFile) {
  # Read the ZIP file as byte array
  $fileContent = [System.IO.File]::ReadAllBytes($zipFile)

  Write-Host "Found ZIP file: $zipFile.FullName"
  Write-Host "Start Import manifest for $manifestName"

  # Upload the ZIP file content to Workato
  Write-Host "Uploading ZIP file content to $uri..."
  $uri = "https://www.workato.com/api/packages/import/"+$folderId+"?restart_recipes=true"
  Write-Host "API:$uri"

  try {
    Invoke-RestMethod -Uri $uri -Method "POST" -Headers $headers -Body $fileContent -ContentType "application/zip"

    Write-Host "manifestName $manifestName"
  } catch {
    Write-Host "Error uploading ZIP file: $($_.Exception.Message)"
  }
} else {
  Write-Host "No ZIP file found with the name $manifestName"
}
















# # Input parameters
# Param (
#     [Parameter(mandatory = $true)][string]$accessToken, # To receive Workato token  
#     [Parameter(mandatory = $true)][string]$manifestName, # To receive manifest Name
#     [Parameter(mandatory = $true)][string]$folderId # To receive folderId
# )

# $headers = @{ 'Authorization' = "Bearer $accessToken" }

# $manifestDirectory = "cicd"
# Write-Host "manifestDirectory:$manifestDirectory"

# Write-Host "Start Import manifest for $manifestName "
# Set-Location $manifestDirectory
# $currentdir = Get-Location
# $manifestNameFolder = "$currentdir"

# # https://www.workato.com/api/packages/import/#{_('data.lookup_table.f64a4d0d.entry.col3')}?restart_recipes=true

# if ($manifestName -ne 'null' -AND (Test-Path $manifestNameFolder)) {
#     Set-Location $manifestNameFolder
#     $zipFile = Get-ChildItem -Filter "$manifestName.zip"

#     if ($zipFile) {
#         $zipContent = [Convert]::ToBase64String([IO.File]::ReadAllBytes($zipFile.FullName))
#         $requestFile = @{ file = $zipContent; filename = $zipFile.Name }

#         $uri = "https://www.workato.com/api/packages/import/$folderId?restart_recipes=true"
#         Invoke-RestMethod -Uri $uri -Method 'POST' -Headers $headers -Body $requestFile -ContentType "multipart/form-data"
#         Write-Host "manifestName $manifestName"
#     }
#     else {
#         Write-Host "No zip file found with the name $manifestName"
#     }
# }
# else {
#     Write-Host "Either manifestName is 'null' or $manifestNameFolder does not exist."
# }
