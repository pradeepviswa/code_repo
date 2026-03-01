$InputServers = Import-Csv "E:\AdminTools\Pradeep\Check_Specific_Hotfix\Check-Compliance\Input.csv"
$decomServers = Get-Content "E:\AdminTools\PatchingMW\MW_Scripts\Output\DecomServers.txt"

$outFile = "E:\AdminTools\Pradeep\Check_Specific_Hotfix\Check-Compliance\Output-NonPROD-Compliance.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,Status,OS,Comment"

$serverWithDuplicate = $InputServers.ServerName
Write-Host "Removing duplicate hostnames..." -ForegroundColor Yellow
$servers = $serverWithDuplicate | select -Unique

Write-Host "Patch verification in progress..."

$count = $servers.Count
$x = 0

foreach($server in $servers){
    $percent = "{0:N2}" -f ($x/$count *100)

    Write-Progress "check patch compliance - NonPROD" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    if($decomServers -contains $server){
        Write-Host "$server `t Decom" -ForegroundColor Yellow
        Add-Content -Path $outFile -Value "$server,Decom"
    }else{
        $os = $InputServers | where {$_.ServerName -eq $server} | select -ExpandProperty OS -First 1
        
        #check if Connection Error
        $criteria = "Connection Error"
        if($os -match $criteria){
                Write-Host "$server `t $criteria" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,$criteria"

        }

        #check 2003 OS
        if($os -match "2003"){
            $hotfix = "KB4012598"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            if($filterServer.Patch -eq "$hotfix Installed"){
                Write-Host "$server `t Compliant `t $os"
                Add-Content -Path $outFile -Value "$server,Compliant,$os,$hotfix Installed"
            }else{
                Write-Host "$server `t Non Compliant `t $os" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,Compliant,$os,$hotfix Missing"
            }#end check 2003 OS

        }


        #check 2008 plain OS without R2
        if(($os -match "2008") -and ($os -notmatch "R2")){
            
            $hotfix1 = "KB4012598"
            $hotfix = "KB4012598"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag1 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag1 = $true }else{ $flag1 = $false}

            $hotfix2 = "KB4018466"
            $hotfix = "KB4018466"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag2 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag2 = $true }else{ $flag2 = $false }

            if($flag1 -or $flag2){
                Write-Host "$server `t Compliant `t $os"
                Add-Content -Path $outFile -Value "$server,Compliant,$os,$hotfix1 ($flag1) or $hotfix2 ($flag2)"
            }else{
                Write-Host "$server `t Non Compliant `t $os" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,$os,Non Compliant,$os,$hotfix1 ($flag1) or $hotfix2 ($flag2)"
            
            }
        }#end check 2008 plain OS without R2



        #check 2008 with R2
        if(($os -match "2008") -and ($os -match "R2")){
            
            
            $hotfix1 = "KB4012212"
            $hotfix = "KB4012212"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag1 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag1 = $true }else{ $flag1 = $false}

            $hotfix2 = "KB4012215"
            $hotfix = "KB4012215"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag2 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag2 = $true }else{ $flag2 = $false}


            $hotfix3 = "KB4019264"
            $hotfix = "KB4019264"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag3 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag3 = $true }else{ $flag3 = $false}


            $hotfix4 = "KB4015549"
            $hotfix = "KB4015549"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag4 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag4 = $true }else{ $flag4 = $false}


            if(($flag1) -and ($flag2 -or $flag3 -or $flag4)){
                Write-Host "$server `t Compliant `t $os"
                Add-Content -Path $outFile -Value "$server,Compliant,$os,$hotfix1 ($flag1) and $hotfix2 ($flag2) or $hotfix3 ($flag3) or $hotfix4 ($flag4)"
            }else{
                Write-Host "$server `t Non Compliant `t $os" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,Non Compliant,$os,$hotfix1 ($flag1) and $hotfix2 ($flag2) or $hotfix3 ($flag3) or $hotfix4 ($flag4)"
            
            }
        }#end check 2008 with R2




    #check 2012
        if($os -match "2012"){
            $hotfix1 = "KB4012213"
            $hotfix = "KB4012213"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag1 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag1 = $true }else{ $flag1 = $false}

            $hotfix2 = "KB4012216"
            $hotfix = "KB4012216"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag2 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag2 = $true }else{ $flag2 = $false}


            $hotfix3 = "KB4019215"
            $hotfix = "KB4019215"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag3 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag3 = $true }else{ $flag3 = $false}


            $hotfix4 = "KB4015550"
            $hotfix = "KB4015550"
            $filterServer = $InputServers | where { ($_.servername -eq $server) -and ($_.Patch -match "$hotfix Installed") }
            $flag4 = ""
            if($filterServer.Patch -eq "$hotfix Installed"){ $flag4 = $true }else{ $flag4 = $false}



            if(($flag1) -and ($flag2 -or $flag3 -or $flag4)){
                Write-Host "$server `t Compliant `t $os"
                Add-Content -Path $outFile -Value "$server,Compliant,$os,$hotfix1 ($flag1) and $hotfix2 ($flag2) or $hotfix3 ($flag3) or $hotfix4 ($flag4)"
            }else{
                Write-Host "$server `t Non Compliant `t $os" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,Non Compliant,$os,$hotfix1 ($flag1) and $hotfix2 ($flag2) or $hotfix3 ($flag3) or $hotfix4 ($flag4)"
            
            }
        }#end check 2012



    }#else check decomservers

    $x++
}#foreach inputservers

#Send-MailMessage -Attachments $outFile -To "hs-sysadmin-windows-offshore@trizetto.com" -Cc "vishal.palekar@trizetto.com" -From "Patches@trizetto.com" -Body "Complaince report attached" -Subject "Patch compliance report - Non PROD" -SmtpServer "mail-2.trizetto.net"
