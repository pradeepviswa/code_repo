
Import-Module ConfigurationManager
Set-Location csn:

$devCollections = Get-Content "E:\AdminTools\SCCM_Script\3_Create_Device_Collection\Create Custom Device Collection\Input-DeviceCollectionName.txt"
$count = $devCollections.Count
$x=0

foreach($devCollection in $devCollections){
    $x++
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Create Device Collection" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $devCollection

    try{
        $start = Get-Date
        $schedule = New-CMSchedule -Start $start -RecurInterval Days -RecurCount 1
        New-CMDeviceCollection -Name $devCollection -Comment $devCollection -LimitingCollectionName "All Systems" -RefreshSchedule $schedule -RefreshType Periodic -ErrorAction Stop -ErrorVariable er | Out-Null
    
        $msg = "Device Collection Created: $devCollection"
        Write-Host $msg
    }catch{
        $showError = $er[0]
        
        $msg = "$devCollection `t Error: $($showError.Message)"
        Write-Host $msg -ForegroundColor Yellow
        
    }


    


}
<#
        $start = Get-Date
        $schedule = New-CMSchedule -Start $start -RecurInterval Days -RecurCount 1
        New-CMDeviceCollection -Name $collectionName -Comment $deviceCollectionComment -LimitingCollectionName "All Systems" -RefreshSchedule $schedule -RefreshType Periodic | Out-Null
        $msg = "Device Collection Created: $collectionName"
        Write-Host $msg
#>