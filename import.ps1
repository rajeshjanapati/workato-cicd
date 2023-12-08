# Input parameters
Param (
  [Parameter(mandatory = $true)][string]$accessToken, # To receive Workato token
  [Parameter(mandatory = $true)][string]$manifestName, # To receive manifest name
  [Parameter(mandatory = $true)][string]$action, # To receive type of action script shall perform
  [Parameter(mandatory = $true)][string]$folderId # To receive folder ID
)

$headers = @{ 'Authorization' = "Bearer $accessToken" }

$manifestDirectory = "cicd"
Write-Host "manifestDirectory:$manifestDirectory"

if ($action -eq "Create") {
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

    Write-Host "Found ZIP file: $zipFile"
    
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
}
elseif ($action -eq "ImportAll") {
  Write-Host "Entered into IMPORTALL...!"
  Set-Location $manifestDirectory
  $currentdir = Get-Location
  $manifestNameFolder = "$currentdir"
  Set-Location $manifestNameFolder
  $zipFiles = Get-ChildItem -Filter "*.zip"

  foreach ($zipFile in $zipFiles) {
    Write-Host "Getting each ZIP FILE...!"
    # Read the ZIP file as byte array
    $fileContent = [System.IO.File]::ReadAllBytes($zipFile)

    Write-Host "Found ZIP file: $zipFile"
    
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
  }

}

else{
  Write-Host "Please atleast one action to perform...!"
}
