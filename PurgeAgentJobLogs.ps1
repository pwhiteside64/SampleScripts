#
# PurgeAgentJobLogs.ps1
#
# Called by SQL agent maintenance jobs to purge old text file Agent logs from the
# file system
#
# See "param" section for standard/default purge paramaters
#

Param(
    [alias("f")]
    $PurgeFolder     = "C:\MSSQL\SQLJobOutput",
    [alias("t")]
    $PurgeTxnFolder  = "C:\MSSQL\SQLJobOutput\TransactionLogs",
    [alias("ld")]
    $LogFileAgeDays  = 30,
    [alias("td")]
    $TxnFileAgeDays  = 5
)

Set-Location $PurgeFolder

$logfile = "$PurgeFolder\PurgeAgentJobLogs_$(get-date -format `"yyyyMMdd_hhmmsstt`").log"

# Simple logging function
function Write-Log($string, $color)
{
   # Only write to output window if a ConsoleHost is attached (may not be when called from SQL Agent)
   if ( $host.Name -eq "ConsoleHost" )
   {
      if ($Color -eq $null) {$color = "white"}
      write-host $string -foregroundcolor $color
   }

   $string | out-file -Filepath $logfile -append
}



## Purge non-transaction log backup job logs
log "`nPurgeAgentJobLogs.ps1 starting at $(Get-Date)"

$PurgeDate = $( (Get-Date).AddDays(0 - $LogFileAgeDays) )

log "`nPurging job log files older than $PurgeDate"

Get-ChildItem -filter "*_*_*_*.txt" -path $PurgeFolder | Where-Object { ($_.CreationTime -lt $PurgeDate)} |
    ForEach-Object {
        log "Purging $($_.Name) "
        Remove-Item $_.Name -Force
    }


## Purge transaction log backup logs
$PurgeDate = $( (Get-Date).AddDays(0 - $TxnFileAgeDays) )

log "`nPurging transaction backup job log files older than $PurgeDate"

Set-Location $PurgeTxnFolder

Get-ChildItem -filter "*_*_*_*.txt" -path $PurgeTxnFolder | Where-Object { ($_.CreationTime -lt $PurgeDate)} |
    ForEach-Object {
        log "Purging $($_.Name) "
        Remove-Item $_.Name -Force
    }


## Finally, purge the log files from this script itself that are older than 10 days
$PurgeDate = $( (Get-Date).AddDays(-10) )

log "`nPurging this script's logs older than $PurgeDate"

Set-Location $PurgeFolder

Get-ChildItem -filter "PurgeAgentJobLogs*.log" -path $PurgeFolder | where { ($_.CreationTime -lt $PurgeDate)} |
    ForEach-Object {
        log "Purging $($_.Name) "
        Remove-Item $_.Name -Force
    }

log "`nPurge process completed"





