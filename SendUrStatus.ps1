# SendUrStatus.ps1
# Moves Excel files from a status/source folder into a different destination folder.
# Intended for a different source/destination pair than SendUrFinal.ps1.
# CompleteFTP server destination: C:\FTPRoot\medx_ur\ur_status_rpt

$Source      = "\\review-dc1\MSOfficeFiles\Allstate_ur_status_out_tst"
$Destination = "C:\FTPRoot\medx_ur\ur_status_rpt"
$LogDirectory = "C:\Users\kmcfadden\projects\allstate\urlog"
$LogFile     = Join-Path $LogDirectory "SendUrStatus.log"

if (-not (Test-Path -LiteralPath $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

function Write-Log {

    param (
        [string]$Message
    )

    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$TimeStamp  $Message"

    Write-Host $LogEntry
    Add-Content -LiteralPath $LogFile -Value $LogEntry
}

Write-Log "SendUrStatus.ps1 started."

$Files = Get-ChildItem -LiteralPath $Source -File |
    Where-Object { $_.Extension.ToLowerInvariant() -in '.xlsx', '.xls', '.zip' }

if ($Files.Count -eq 0) {
    Write-Log "No Excel or ZIP files found."
}

foreach ($File in $Files) {

    try {

        Write-Log "Moving $($File.Name)"

        Move-Item `
            -LiteralPath $File.FullName `
            -Destination $Destination `
            -ErrorAction Stop

        Write-Log "SUCCESS: Moved $($File.Name) to $Destination"

    }
    catch {

        Write-Log "ERROR moving $($File.Name): $($_.Exception.Message)"

    }

}

Write-Log "SendUrStatus.ps1 finished. See log"
