$dir = Split-Path $Script:Myinvocation.Mycommand.path


#Import required modules
Write-Host "Loading Modules ConfigurationManager, ActiveDirectory..... Please wait" -ForegroundColor Yellow
Import-Module ConfigurationManager
Import-Module ActiveDirectory

Set-Location csn:

Write-Host "Loading all devices..."
$devices = Get-CMDevice

##for testing
#$devices = $devices | select -First 10 #remove after testing
#$devices[800] | select name,LastMPServerName,SiteCode

#output File
$outFile = "$dir\Output.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "NetBIOS,Domain,FQDN,Enabled_in_DC,Deleted,DC_Description,LastMPServerName,IPV4Address"

$x = 0
$count = $devices.Count

foreach($device in $devices){
    $percent = "{0:N2}" -f ($x/$count *100)
    Write-Progress -Activity "Remove Disabled Computers from SCCM" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $($device.Name)

    try{

        $server = $device.Name
        $domain = $device.Domain

        $dcComputer = Get-ADComputer -Identity $server -Server $domain -ErrorVariable er
        if($er -match "Cannot find an object with identity"){
                Remove-CMDevice -Name $server -Force
                Write-Host "$server `t $domain `t Not found in DC - Deleted" -ForegroundColor Yellow
                Add-Content -Path $outFile -Value "$server,$domain,,,Deleted from SCCM. Not found in DC"
        }else{
            $fqdn = $dcComputer.DNSHostName
            $enabled = $dcComputer.Enabled
            $descrip = $dcComputer.Description
            $LastMPServerName = $device.LastMPServerName
            if($enabled){

                $ip = Test-Connection $fqdn -Count 1 -ErrorAction SilentlyContinue | select IPV4Address
                $IPV4Address = ($ip.IPV4Address).IPAddressToString


                #Write-Host "$server `t $domain `t Active"
                Add-Content -Path $outFile -Value "$server,$domain,$fqdn,$enabled,NA,$descrip,$LastMPServerName,$IPV4Address"


    
            }else{
        
                Remove-CMDevice -Name $server -Force
                Write-Host "$server `t $domain `t Disabled - Deleted" -ForegroundColor Yellow
                Add-Content -Path $outFile -Value "$server,$domain,$fqdn,$enabled,Deleted from SCCM,$descrip"
            }
        }

    
    }catch{
            Write-Host "$server `t Error" -ForegroundColor Yellow
            Add-Content -Path $outFile -Value "$server,Error"
    
    }

    #reset variables
    $fqdn = ""
    $enabled = ""
    $descrip = ""
    $LastMPServerName = ""

    $x++
    
}

<#
#Use this section to remove server names with error.
#copy server names in c:\temp\1.txt

$servers = Get-Content C:\Temp\1.txt
foreach($server in $servers){
    Remove-CMDevice -Name $server -Force
    "$server Removed"
}
#>