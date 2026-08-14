
# sndurfinal.ps1
# send ur final reports from O drive to the completeftp server to be sent to medx
# Moves PDF files from the internal Windows file share O:drive
# ur O: drive folder is Allstate_ur_out
# CompleteFTP server destination folders:
#   FTPRoot\medx_ur\ur_final_rpt (live)
# Log directory: C:\Logs\medx_ur

$Source      = "\\review-dc1\MSOfficeFiles\Allstate_ur_final_out_tst"
$Destination = "C:\FTPRoot\medx_ur\ur_final_rpt"
$LogDirectory = "C:\Logs\medx_ur\"
$LogFile     = Join-Path $LogDirectory "SendUrFinal.log"

if (-not (Test-Path -LiteralPath $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

# ------------------------------------------------------------
# Logging function
# ------------------------------------------------------------
function Write-Log {

    param (
        [string]$Message
    )

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $LogEntry = "$TimeStamp  $Message"

    # Display on screen
    Write-Host $LogEntry

    # Write to log file
    Add-Content -LiteralPath $LogFile -Value $LogEntry
}


Write-Log "SendUrFinal.ps1 started."


# Find only PDF and ZIP files
$Files = Get-ChildItem -LiteralPath $Source -File |
    Where-Object { $_.Extension.ToLowerInvariant() -in '.pdf', '.zip' }

if ($Files.Count -eq 0) {

    Write-Log "No PDF or ZIP files found."

}


foreach ($File in $Files) {

    try {

        Write-Log "Moving $($File.Name)"

        Move-Item `
            -LiteralPath $File.FullName `
            -Destination $Destination `
            -ErrorAction Stop

        Write-Log "SUCCESS: Moved $($File.Name) to CompleteFTP ur_final_rpt."

    }
    catch {

        Write-Log "ERROR moving $($File.Name): $($_.Exception.Message)"

    }

}


Write-Log "SendUrFinal.ps1 finished.  See log"
