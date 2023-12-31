# Input parameters
Param (
    [Parameter(mandatory = $true)][string]$workatoToken, # To receive Workato token
    [Parameter(mandatory = $true)][string]$manifestId, # To receive manifest_ID    
    [Parameter(mandatory = $true)][string]$summary_file_name,
    [Parameter(mandatory = $true)][string]$prodToken, # To receive Workato token
    [Parameter(mandatory = $true)][string]$action, # To receive type of action script shall perform
    [Parameter(mandatory = $true)][string]$folderId, # To receive folder ID
    [Parameter(mandatory = $true)][string]$manifestName # To receive manifest name    
)

# Get the script directory
$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Print input parameters
Write-Host "manifestId:$manifestId"
Write-Host "action:$action"
Write-Host "folderId:$folderId"
Write-Host "workatoToken:$workatoToken"
Write-Host "prodToken:$prodToken"

# Set full path for cicd folder
$cicdPath = Join-Path $ScriptDirectory "cicd"

# Navigate to the root directory of the repository
cd $env:GITHUB_WORKSPACE

# create cicd folder if not exists
if (!(Test-Path -PathType Container $cicdPath)) {
    mkdir $cicdPath
    Write-Host "Created $cicdPath"
} else {
    Write-Host "cicd folder already exists."
}

# Initialize an empty string to store all environment summaries
$allSummaries_Log = ""

# Initialize arrays to store manifest names
$manifestName_Success = @()
$manifestName_Failure = @()

# Initial API request to get the ID
$idPath = "https://www.workato.com/api/packages/export/"+$manifestId
Write-Host "idPath:$idPath"

# Variable to track initial API success
$initialApiSuccess = $false

try {
    $idResponse = Invoke-RestMethod -Uri $idPath -Method 'POST' -Headers @{ Authorization = "Bearer $workatoToken" } -ContentType "application/json" -ErrorAction Stop -TimeoutSec 60

    # Check if the response content is not empty
    if ($idResponse) {
        # Extract the "id" value
        $idValue = $idResponse.id
        $initialApiSuccess = $true

        # Print the result
        Write-Host "ID Value: $idValue"

        # Make subsequent API requests until download_url is not null
        $downloadURL = $null
        do {
            $downloadURLpath = "https://www.workato.com/api/packages/$idValue"
            Write-Host "downloadURLpath: $downloadURLpath"

            $downloadURLresponse = Invoke-RestMethod $downloadURLpath -Method 'GET' -Headers @{ Authorization = "Bearer $workatoToken" }

            if ($downloadURLresponse) {
                $currentdir = Get-Location
                $downloadURL = $downloadURLresponse.download_url

                if ($downloadURL -ne $null -and $downloadURL -ne "null") {
                    # Extract file name from the URL without query parameters
                    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($downloadURL)

                    # Set the path where you want to save the file (inside the cicd folder)
                    $savePath = Join-Path $cicdPath "$fileName.zip"

                    # Check if the file already exists, and delete it if it does
                    if (Test-Path $savePath) {
                        Remove-Item $savePath -Force
                        Write-Host "Deleted existing file: $savePath"
                    }

                    try {
                        $manifestName_Success += $fileName
                        # Download the file
                        Invoke-WebRequest -Uri $downloadURL -OutFile $savePath

                        Write-Host "File downloaded successfully!"
                    }
                    catch {
                        $manifestName_Failure += $fileName
                        Write-Host "API Request Failed. Error: $_"
                        Write-Host "Response Content: $_.Exception.Response.Content"
                    }
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
    $allSummaries_Log += "API Request Failed, recipe is not Exported and Imported, Please try again...!"
    Write-Host "API Request Failed, recipe is not Exported and Imported, Please try again...!"
    Write-Host "API Request Failed. Error: $_"
    Write-Host "Response Content: $_.Exception.Response.Content"
}

$manifestNameList_Success =  $($manifestName_Success -join ', ')
$manifestNameList_Failed =  $($manifestName_Failure -join ', ')

$manifestNameCountIn_Success = $manifestName_Success.Count
$manifestNameCountIn_Failed = $manifestName_Failure.Count

$manifestName_Log_Success = ("manifest Recipe Exported Successfully to GitHub: Count - $manifestNameCountIn_Success, Manifest Names - $manifestNameList_Success`r`n")
$manifestName_Log_Failed = ("manifest Recipe Export Failed: Count - $manifestNameCountIn_Failed, Manifest Names - $manifestNameList_Failed`r`n")

$allSummaries_Log += $manifestName_Log_Success + $manifestName_Log_Failed

# Set full path for the manifest directory
$manifestDirectory = Join-Path $ScriptDirectory "cicd"
Write-Host "manifestDirectory:$manifestDirectory"

# Check if the initial API request was successful before proceeding
if ($initialApiSuccess) {
    if ($action -eq "Create") {
        Set-Location $manifestDirectory
        $currentdir = Get-Location
        $manifestNameFolder = "$currentdir"
        Set-Location $manifestNameFolder

        # Check if the ZIP file exists in the current directory
        $zipFile = Get-ChildItem -Path $manifestDirectory -Filter "$manifestName.zip"
        Write-Host "FileName:$zipFile"

        $allSummaries_Log += $manifestName

        if ($zipFile) {
            # Read the ZIP file as byte array
            $fileContent = [System.IO.File]::ReadAllBytes($zipFile)

            Write-Host "Found ZIP file: $zipFile"
            Write-Host "Start Import manifest for $manifestName"

            # Upload the ZIP file content to Workato
            Write-Host "Uploading ZIP file content to $uri..."
            $uri = "https://www.workato.com/api/packages/import/"+$folderId+"?restart_recipes=true"
            Write-Host "API:$uri"

            try {
                Invoke-RestMethod -Uri $uri -Method "POST" -Headers @{ 'Authorization' = "Bearer $prodToken" } -Body $fileContent -ContentType "application/zip"

                Write-Host "manifestName $manifestName"
            } catch {
                Write-Host "Error uploading ZIP file: $($_.Exception.Message)"
            }
        } else {
            Write-Host "No ZIP file found with the name $manifestName"
        }
    }
    elseif ($action -eq "ImportAll") {
        # Initialize arrays to store manifest names
        $manifestName_Success = @()
        $manifestName_Failure = @()

        # Set full path for the manifest directory
        $manifestDirectory = Join-Path $ScriptDirectory "cicd"

        # Set-Location $manifestDirectory
        $currentdir = Get-Location
        $zipFiles = Get-ChildItem -Path $manifestDirectory -Filter "*.zip"

        foreach ($zipFile in $zipFiles) {
            $fileContent = [System.IO.File]::ReadAllBytes($zipFile)

            Write-Host "Found ZIP file: $zipFile"
            # File path
            $filePath = $zipFile
            
            # Extract the base name without extension
            $baseNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
            
            # Output the result
            Write-Host "Base name without extension: $baseNameWithoutExtension"

            $manifestName_Success += $baseNameWithoutExtension

            # Upload the ZIP file content to Workato
            $uri = "https://www.workato.com/api/packages/import/"+$folderId+"?restart_recipes=true"
            Write-Host "API:$uri"

            try {
                Invoke-RestMethod -Uri $uri -Method "POST" -Headers @{ 'Authorization' = "Bearer $prodToken" } -Body $fileContent -ContentType "application/zip"
                Write-Host "manifestName $($zipFile.BaseName)"
            } catch {
                $manifestName_Failure += $baseNameWithoutExtension
                Write-Host "Error uploading ZIP file $($zipFile.BaseName): $($_.Exception.Message)"
            }
        }

        $manifestNameList_Success =  $($manifestName_Success -join ', ')
        $manifestNameList_Failed =  $($manifestName_Failure -join ', ')

        $manifestNameCountIn_Success = $manifestName_Success.Count
        $manifestNameCountIn_Failed = $manifestName_Failure.Count

        $manifestName_Log_Success = ("manifest Recipes Imported Successfully to Workato: Count - $manifestNameCountIn_Success, Manifest Names - $manifestNameList_Success`r`n")
        $manifestName_Log_Failed = ("manifest Recipes Import Failed: Count - $manifestNameCountIn_Failed, Manifest Names - $manifestNameList_Failed`r`n")

        $allSummaries_Log += $manifestName_Log_Success + $manifestName_Log_Failed
    }
    else {
        Write-Host "Please specify at least one action to perform...!"
    }
}
else {
    Write-Host "Initial API is not successful, Please try again...!"
}

# Set full path for the parent directory
Set-Location $ScriptDirectory

# Combine the current directory path with the file name
$filePath = Join-Path $ScriptDirectory $summary_file_name

# Write the combined summaries to the summary file
$allSummaries_Log | Out-File -FilePath $filePath -Append -Encoding UTF8

Write-Host "Script execution completed."
