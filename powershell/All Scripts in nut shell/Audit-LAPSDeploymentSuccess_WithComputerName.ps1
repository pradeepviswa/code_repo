$dir = Split-Path $Script:Myinvocation.Mycommand.path
Set-Location -Path $dir
$outFile = ".\Output-LAPS.csv"
Remove-Item -Path $outFile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,Domain"

$Domains = Get-Content -Path ".\Domains.txt"
$count = $Domains.Count
$x = 0
foreach ($Domain in $Domains){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Checking LAPS missing computers" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $Domain

    $EnabledComputers = Get-ADComputer -Server $Domain -Filter {(Enabled -eq $true) -and (OperatingSystem -like "*Windows*")} -Properties *
    $DomainControllers = Get-ADGroupMember -Identity "Domain Controllers" -Server $Domain
    $ComputersWithLAPSPassword = Get-ADComputer -Server $Domain -Filter {(Enabled -eq $true) -and (OperatingSystem -like "*Windows*") -and (ms-Mcs-AdmPwd -ne "*")} -Properties *
    #$EnabledLessDCs = $EnabledComputers - $DomainControllers
    #Add-Content -Value "$EnabledLessDCs,$Domain,$ComputersWithLAPSPassword" -Path "\\csn-svc-util-08.services.tzghosting.net\admintools\levi\Audit-LAPSDeploymentSuccess\Audit-Output.txt"
    
    foreach($line in $EnabledComputers){
        $name = $line.name
        $flag = $true
        foreach($dc in $DomainControllers){
            if($($dc.name) -eq $name){
            Write-Host "skipped DC: $($dc.name)" -ForegroundColor Yellow
            $flag = $false 
            continue
            }
        }#dc

        if (($($line.'ms-Mcs-AdmPwd') -eq $null) -and ($flag)){
            
            $nameSplit = $($line.DNSHostName).Split(".")
            $d1 = $nameSplit[1]
            $d2 = $nameSplit[2]
            $d3 = $nameSplit[3]

            $d = "$d1.$d2.$d3"
            Add-Content -Path $outFile -Value "$($line.DNSHostName),$d"
            "$($line.DNSHostName) `t $d"
        }
    
    }#allenabled

}

