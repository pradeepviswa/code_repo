$myDir = split-path $Script:MyInvocation.mycommand.path
Set-Location $myDir
$custDomain = "EMB.tzghosting.net"
Write-Host "Saving computer names in variable" -ForegroundColor Yellow
$computers = Get-ADComputer -Server $custDomain -Filter * | select -ExpandProperty DNSHostName
write-host "$($computers.count) Computer objects found" -ForegroundColor Yellow

$x = 0
$count = $computers.Count

$excludedString = @()
$excludedString += "FXI"
$excludedString += "FHG"

$excludedServers = @()


Write-Host "Identifying excluded servers : $excludedString" -ForegroundColor Yellow
foreach($computer in $computers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Identify $excludedString Servers" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $computer

    foreach($ex in $excludedString){
        if($computer -match $ex){
            $excludedServers += $computer
            $computer
        }
    
    }#foreach excludedString
}


$excludedGroupName = "EMB Sweet32 Remediation Exclusion"
Write-Host "Adding excluded servers in '$excludedGroupName'" -ForegroundColor Yellow
$count = $excludedServers.Count
$x = 0
foreach($excludedServer in $excludedServers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Add Computer Object to '$excludedGroupName'" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $excludedServer
    $compObj = Get-ADComputer -Server $custDomain -Filter "dnshostname -eq '$excludedServer'"
    Add-ADGroupMember -Identity $excludedGroupName -Members $compObj -Server $custDomain
}

Write-Host "Done" -ForegroundColor Yellow





