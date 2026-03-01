$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Set-Location -Path $ScriptDir -ErrorAction SilentlyContinue

function Install-MissingUpdate {
    [CmdletBinding()]
    param (
        $ComputerName = "Remote-Computer"
    )
      # ([wmiclass]'ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager').InstallUpdates([System.Management.ManagementObject[]] (
      #   Get-WmiObject -Query 'SELECT * FROM CCM_SoftwareUpdate' -namespace 'ROOT\ccm\ClientSDK'))
    Start-Job -ScriptBlock {
    param($ComputerName)
    
    $UpdateList = [System.Management.ManagementObject[]](Get-WmiObject -ComputerName $ComputerName -Query 'SELECT * FROM CCM_SoftwareUpdate' -Namespace ROOT\ccm\ClientSDK);
    ([wmiclass]"\\$ComputerName\ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager").InstallUpdates($UpdateList);
    } -ArgumentList $ComputerName
    Remove-Job -State Completed
}
$servers = Get-Content ".\Servers.txt"
$count = $servers.count
$x = 0
$i = 0
$set = 100
$waitSecs = 120
foreach($server in $servers){
    $i++
    $x++

    $percent = "{0:N2}" -f (($x/$count)*100)
    Write-Progress -Activity "Install updates - $a" `
        -Status "In Progress($x of $count)...$percent%" `
        -PercentComplete $percent `
        -CurrentOperation "$server" `
        
    Install-MissingUpdate -ComputerName $server

    
    if($i -eq $set){
        $i = 1

        Write-Host "Set of $set. Total count $count. Wait for $waitSecs secs" -ForegroundColor Yellow
        Start-Sleep -Seconds $waitSecs
    }

}

# get-job -Id 1
#Receive-Job -Id 800
<#
$jobs = get-job
$x = 0
foreach($job in $jobs){
    $id = $job.Id
    
    $recJob = Receive-Job -Id 1554
}
#>
