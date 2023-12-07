# write-output Apigee Artifacts
$github_token = $env:github_token
$access_token = $env:access_token

$headers = @{Authorization = "Bearer $access_token"}

# create cicd folder
if(!(test-path -PathType container cicd)){
      mkdir "cicd"
      cd cicd
      Write-Host "inside 2nd if"
}
else {
      cd cicd
      Write-Host "2nd else"
}

$path = "https://www.workato.com/api/packages/export/101814"
$proxies = Invoke-RestMethod -Uri $path -Method 'POST' -Headers $headers -ContentType "application/json" -ErrorAction:Stop -TimeoutSec 60

# Convert JSON data to PowerShell object
$dataObject = $proxies | ConvertFrom-Json

# Extract the "id" value
$idValue = $dataObject.id

# Print the result
Write-Host "ID Value: $idValue"
