# Input parameters
Param (
    [Parameter(mandatory = $true)][string]$accessToken, # To receive Workato token
    [Parameter(mandatory = $true)][string]$folderId, # To receive folderId  
    [Parameter(mandatory = $true)][string]$manifestName # To receive manifest Name  
)

$headers = @{Authorization = "Bearer $accessToken " }

$manifestDirectory = "cicd"

Write-Host "Start Import manifest for $manifestName "
Set-Location $manifestDirectory
$currentdir = Get-Location
$manifestNameFolder = "$currentdir/$manifestName"

https://www.workato.com/api/packages/import/#{_('data.lookup_table.f64a4d0d.entry.col3')}?restart_recipes=true

if ($manifestName -ne 'null' -AND (Test-Path $manifestNameFolder )) {
    Set-Location $manifestNameFolder
    $zipFile = Get-ChildItem *.zip
    $requestFile = @{file = Get-Item -Path $zipFile }
    $uri = "https://www.workato.com/api/packages/import/$folderId?restart_recipes=true"
    Invoke-WebRequest  -Uri $uri -Method Post -Form $requestFile -Headers $headers
    Write-Host "manifestName $manifestName "
}
else {
    Write-Error "Error Import manifest for $manifestName : Invalid manifest Name"
}

