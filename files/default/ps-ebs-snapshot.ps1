## Automatic EBS Volume Snapshot Creation & Clean-Up Script
#
# Written by Cosmin Banciu
#
# PURPOSE: This PS script can be used to take automatic snapshots of your Windows EC2 instance. Script process:
# - Determine the instance ID of the EC2 server on which the script runs
# - Gather a list of all volume IDs attached to that instance
# - Take a snapshot of each attached volume
# - The script will then delete all associated snapshots taken by the script that are older than 15 days
#


# get FQDN
$myFQDN=(Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain

# get instance ID
$instanceID=Invoke-WebRequest 'http://169.254.169.254/latest/meta-data/instance-id' | Select-Object -Expand Content

# get region
$instanceRegion=Invoke-WebRequest 'http://169.254.169.254/latest/meta-data/placement/availability-zone' | Select-Object -Expand Content

# set the log file variable
$logFile='C:\ebs-snapshot\ebs-snapshot.log'
$logFile_max_lines='5000'

# retention value and retention value in seconds
# pay attention of the value for retention days. must be the same in the next 2 lines and down bellow
$retentionDays=15
$dateDaysAgo = get-date -date $(get-date).adddays(-15) -format 'MM-dd-yyyy'
$startDate=[datetime]"1970-01-01 00:00" # fixed because of the %s value used in the script for Linux snapshots
$dateDaysAgo=[datetime]$dateDaysAgo
$timeSpan=NEW-TIMESPAN -Start $startDate -End $dateDaysAgo
$retentionDateInSeconds=$timeSpan.TotalSeconds

Add-content $logfile -value (get-date -format 'MM-dd-yyyy hh:mm:ss')
Add-content $logfile -value 'Snapshot process begin'

$attachedVolumes=(Get-EC2Volume -Filter @{ Name="attachment.instance-id"; Values=$instanceID } | Select -ExpandProperty "VolumeId")


$tags = (Get-EC2Instance).RunningInstance | Where-Object {$_.instanceId -eq $instanceID} |select Tag
$tagName = $tags.Tag | Where-Object {$_.Key -eq "stlx:snapshot_off"} | select -ExpandProperty Value

if ($tagName='true') {
    foreach ($volumeID in $attachedVolumes) {
       $newSnapshotDate=get-date -date $(get-date) -format "dd_mm_yyyy_hh_mm"
       New-EC2Snapshot -VolumeId $volumeID -Description ("snaps_" + $volumeID + "_" + $instanceID + "_" + $newSnapshotDate)
       $newSnapId=Get-EC2Snapshot -Filter @{ Name="description"; Values=("snaps_" + $volumeID + "_" + $instanceID + "_" + $newSnapshotDate)} | Select -ExpandProperty "SnapshotId"

       Add-content $logfile -value (get-date -format 'MM-dd-yyyy hh:mm:ss')
       Add-content $logfile -value ("Creating snapshot " + $newSnapId)

       New-EC2Tag -Resource $newSnapId -Tags @{ Key = "Name"; Value = "stlx_bkup" }
       New-EC2Tag -Resource $newSnapId -Tags @{ Key = "stlx_hostname"; Value = $myFQDN }

       $snapshots=Get-EC2Snapshot -Filter @{ Name="volume-id"; Values=$volumeID}, @{Name="status"; Values="completed"}
       foreach ($snapshot in $snapshots) {
            $snapshotID= $snapshot| Select -ExpandProperty "SnapshotID"
            $snapshotDate=$snapshot | Select -ExpandProperty "StartTime"
            Write-Host $snapshotID
            Write-Host $snapshotDate
            if ($snapshotDate -le  (get-date -date $(get-date).adddays(-15))) {
                Remove-EC2Snapshot -SnapshotId $snapshotID -Force
            }
       }
    }
}

Add-content $logfile -value (get-date -format 'MM-dd-yyyy hh:mm:ss')
Add-content $logfile -value 'Snapshot process end'
