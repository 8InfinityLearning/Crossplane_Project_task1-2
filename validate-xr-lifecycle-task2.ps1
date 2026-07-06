# ==============================================================================
# Task 2 : VALIDATING CROSSPLANE TEST XR LIFECYCLE AND RECONCILIATION
# ==============================================================================

# --- Declaration of Configuration Properties ---
$ManifestFile      = "claim.yaml"                       # Defines the Path to your test manifest
$ResourceGroupKind = "xconfigmapv3s.demo.crossplane.io" # This is our defined V3 API Kind
$ResourceName      = "my-first-configmap"               # Target instance name
$PollIntervalSec   = 10                                 # Poll loop step duration of 10 sec
$TimeoutMinutes    = 5                                  # Maximum safety window limits of 5 sec
$ReportFilePath    = "xr-validation-report.txt"         # Validation output log path as Text File

# ===============================================================================
# <--- Declaration of Calculations and Initializer Blocks --->
# ================================================================================
$MaxAttempts = ($TimeoutMinutes * 60) / $PollIntervalSec
$Attempt = 1
$PassedStatus = $false
$StartTime = Get-Date

Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " INITIALIZING CROSSPLANE AUTOMATED LIFECYCLE RECONCILIATION SCRIPT  " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

# --- Step 1: Manifest Deployment Execution ---
if (-not (Test-Path $ManifestFile)) {
    Write-Host "X Deployment Broken: Manifest template '$ManifestFile' not found." -ForegroundColor Red
    Exit 1
}

Write-Host "`n Step 1: Applying target Test XR manifest payload..." -ForegroundColor Yellow
$DeployResult = kubectl apply -f $ManifestFile 2>&1
Write-Host $DeployResult -ForegroundColor Gray

# --- Step 2: Continuous Status Tracking Validation Loop ---
Write-Host "`n Step 2: Entering tracking loop (Interval: ${PollIntervalSec}s, Max Timeout: ${TimeoutMinutes}m)..." -ForegroundColor Yellow

while ($Attempt -le $MaxAttempts) {
    $ElapsedTimeSec = [Math]::Round(((Get-Date) - $StartTime).TotalSeconds)
    
    # Query raw database status objects directly to bypass blank terminal column viewer errors
    $RawConditions = kubectl get $ResourceGroupKind $ResourceName -o jsonpath='{.status.conditions}' 2>$null
    
    $SyncedValue = "Unknown"
    $ReadyValue  = "Unknown"
    
    if ($RawConditions) {
        # Cast the JSON payload token back to a PowerShell object array
        $ConditionArray = ConvertFrom-Json $RawConditions
        foreach ($Condition in $ConditionArray) {
            if ($Condition.type -eq "Synced") { $SyncedValue = $Condition.status }
            if ($Condition.type -eq "Ready")  { $ReadyValue  = $Condition.status }
        }
    }
    
    Write-Host "[Attempt $Attempt/$MaxAttempts | ${ElapsedTimeSec}s elapsed] Status conditions -> Synced: $SyncedValue | Ready: $ReadyValue" -ForegroundColor White
    
    # Evaluate target criteria match conditions
    if ($SyncedValue -eq "True" -and $ReadyValue -eq "True") {
        $PassedStatus = $true
        break
    }
    
    Start-Sleep -Seconds $PollIntervalSec
    $Attempt++
}

# --- Step 3: Compile Metrics and Write Execution Report ---
$EndTime = Get-Date
$TotalExecutionTime = [Math]::Round(($EndTime - $StartTime).TotalSeconds)
$ReportTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Build report matrix block text
$ReportText = @"
======================================================================
                  CROSSPLANE TESTING PIPELINE REPORT                  
======================================================================
Timestamp          : $ReportTimestamp
Target Resource    : $ResourceGroupKind/$ResourceName
Manifest Source    : $ManifestFile
Total Duration     : $TotalExecutionTime seconds
Polling Attempts   : $Attempt out of $MaxAttempts
----------------------------------------------------------------------
FINAL RESULT       : $(if ($PassedStatus) { "PASS " } else { "FAIL " })
----------------------------------------------------------------------
Details:
$(if ($PassedStatus) { "The Crossplane Test XR successfully reconciled. Ready=True and Synced=True achieved inside safety limit timeouts." } 
else { "The evaluation window was broken. The Test XR exceeded maximum timeout ($TimeoutMinutes minutes) or returned invalid status fields." })
======================================================================
"@

# Display report out to the active console terminal window
Write-Host "`n"
if ($PassedStatus) {
    Write-Host $ReportText -ForegroundColor Green
} else {
    Write-Host $ReportText -ForegroundColor Red
}

# Write out report out to file system to easily share with your friend
$ReportText | Out-File -FilePath $ReportFilePath -Force
Write-Host " Persistent execution summary written to folder path: .\$ReportFilePath" -ForegroundColor Cyan
