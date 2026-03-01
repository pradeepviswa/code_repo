$hint = 1
$servers = Get-Content "E:\AdminTools\Pradeep\Check_Specific_Hotfix\$hint\servers.txt"
$outFile = "E:\AdminTools\Pradeep\Check_Specific_Hotfix\$hint\Output-$hint.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "ServerName,OS,Patch"

######
#store credential
$TmpFile = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Secure_Password_DO_NOT-DELETE\Infra.Service_SecurePassword.txt"
$username = "SERVICES\infra.service"
$password = Get-Content $TmpFile | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
###########################


$count = $servers.Count
$x = 0

foreach($server in $servers){

    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Folder $hint" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation "Checking $server"

    try{

        #open pssession before activity start. this will be used with invoke-command
        $session = New-PSSession -ComputerName $server -Credential $cred -ErrorAction stop

            $os =Invoke-Command -Session $session -ScriptBlock{
                param($server)
                Get-WmiObject -Class win32_operatingsystem -ErrorAction Stop| select  caption,OSArchitecture
            } -ArgumentList $server

        $osname = $os.caption
        $osname = $osname.Replace(","," ")
        $bit = $os.OSArchitecture

        #check 2003
        if($osname -match "2003"){
            #***********************
            $hotfixID = "KB4012598"
            $hotfix = Invoke-Command -Session $session -ScriptBlock{
                param($hotfixID)
                Get-HotFix | where {$_.hotfixid -eq $hotfixID}
            } -ArgumentList $hotfixID
            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed `t $osname $bit"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
            }
            #***********************
        }#check 2003


        #check 2008
        if($osname -match "2008"){
            if($osname -notmatch "R2"){
                #***********************
                $hotfixID = "KB4018466"
                $hotfix = Invoke-Command -Session $session -ScriptBlock{
                    param($hotfixID)
                    Get-HotFix | where {$_.hotfixid -eq $hotfixID}
                } -ArgumentList $hotfixID

                if($hotfix.HotFixID -eq $hotfixID){
                    Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Installed"
                    Write-Host "$server `t $hotfixID Installed `t $osname $bit"
                }else{
                    Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Missing"
                    Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
                }
                #***********************
            }

            #***********************
            $hotfixID = "KB4012212"
                $hotfix = Invoke-Command -Session $session -ScriptBlock{
                    param($hotfixID)
                    Get-HotFix | where {$_.hotfixid -eq $hotfixID}
                } -ArgumentList $hotfixID

            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed `t $osname $bit"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
            }
            #***********************

            $hotfixID = "KB4012215"
                $hotfix = Invoke-Command -Session $session -ScriptBlock{
                    param($hotfixID)
                    Get-HotFix | where {$_.hotfixid -eq $hotfixID}
                } -ArgumentList $hotfixID

            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed `t $osname $bit"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
            }

            #***********************
            $hotfixID = "KB4019264"
                $hotfix = Invoke-Command -Session $session -ScriptBlock{
                    param($hotfixID)
                    Get-HotFix | where {$_.hotfixid -eq $hotfixID}
                } -ArgumentList $hotfixID


            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed `t $osname $bit"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
            }
            #***********************

        }#check 2008


        #check  2012
        if($osname -match "2012"){
            #***********************
            $hotfixID = "KB4012213"
                $hotfix = Invoke-Command -Session $session -ScriptBlock{
                    param($hotfixID)
                    Get-HotFix | where {$_.hotfixid -eq $hotfixID}
                } -ArgumentList $hotfixID

            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed `t $osname $bit"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
            }
            #***********************

            $hotfixID = "KB4012216"
                $hotfix = Invoke-Command -Session $session -ScriptBlock{
                    param($hotfixID)
                    Get-HotFix | where {$_.hotfixid -eq $hotfixID}
                } -ArgumentList $hotfixID

            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed `t $osname $bit"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
            }
            #***********************

            $hotfixID = "KB4019215"
                $hotfix = Invoke-Command -Session $session -ScriptBlock{
                    param($hotfixID)
                    Get-HotFix | where {$_.hotfixid -eq $hotfixID}
                } -ArgumentList $hotfixID

            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed `t $osname $bit"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
            }
            #***********************

            $hotfixID = "KB4015550"
                $hotfix = Invoke-Command -Session $session -ScriptBlock{
                    param($hotfixID)
                    Get-HotFix | where {$_.hotfixid -eq $hotfixID}
                } -ArgumentList $hotfixID

            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed `t $osname $bit"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing `t $osname $bit" -ForegroundColor yellow
            }
            #***********************

        }#check 2012



    
    }catch{
        Add-Content -Path $outFile -Value "$server,Connection Error"
        Write-Host "$server `t Connection Error" -ForegroundColor red

    }
    $x++
}




Send-MailMessage -Attachments $outFile `
-To 'HS-SysAdmin-Windows-Offshore@trizetto.com' `
-Cc 'vishal.palekar@trizetto.com' `
-From 'Patches@trizetto.com' `
-SmtpServer 'mail-2.trizetto.net' `
-Subject "Patch Report Folder $hint" `
-BodyAsHtml "Folder-$hint report attached"
