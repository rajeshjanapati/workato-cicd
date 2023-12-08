# Input parameters
Param (
    [Parameter(mandatory = $true)][string]$accessToken, # To receive Workato token  
    [Parameter(mandatory = $true)][string]$manifestName, # To receive manifest Name
    [Parameter(mandatory = $true)][string]$folderId # To receive folderId
)

Write-Host "manifestName:$manifestName"
Write-Host "folderId:$folderId"

$headers = @{ 'Authorization' = "Bearer $accessToken" }

$manifestDirectory = "cicd"
Write-Host "manifestDirectory:$manifestDirectory"

Write-Host "Start Import manifest for $manifestName "
Set-Location $manifestDirectory
$currentdir = Get-Location
$manifestNameFolder = "$currentdir"

# https://www.workato.com/api/packages/import/#{_('data.lookup_table.f64a4d0d.entry.col3')}?restart_recipes=true

if ($manifestName -ne 'null' -AND (Test-Path $manifestNameFolder)) {
    Set-Location $manifestNameFolder
    $zipFile = Get-ChildItem -Filter "$manifestName.zip"

    if ($zipFile) {
        $zipContent = [Convert]::ToBase64String([IO.File]::ReadAllBytes($zipFile.FullName))
        $requestFile = @{ file = $zipContent; filename = $zipFile.Name }

        $uri = "https://www.workato.com/api/packages/import/$folderId?restart_recipes=true"

        $webHeaderCollection = New-Object 'System.Collections.Specialized.WebHeaderCollection'
        foreach ($key in $headers.Keys) {
            $webHeaderCollection.Add($key, $headers[$key])
        }

        Invoke-RestMethod -Uri $uri -Method 'POST' -Headers $webHeaderCollection -Body $requestFile -ContentType "multipart/form-data"
        Write-Host "manifestName $manifestName"
    }
    else {
        Write-Host "No zip file found with the name $manifestName"
    }
}
else {
    Write-Host "Either manifestName is 'null' or $manifestNameFolder does not exist."
}
