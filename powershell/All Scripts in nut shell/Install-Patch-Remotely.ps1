$servers = Get-Content E:\AdminTools\Pradeep\Install-Patches\Servers.txt

#store credential
$TmpFile = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Secure_Password_DO_NOT-DELETE\Infra.Service_SecurePassword.txt"
$username = "SERVICES\infra.service"
$password = Get-Content $TmpFile | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password


foreach($server in $servers){
    #4012216
    $filePath = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Pradeep\Install-Patches\Risk patches\March, 2017 Security Monthly Quality Rollup for Windows Server 2012 R2 (KB4012216)\KB4012216.msu"

    $session = New-PSSession -ComputerName $server -Credential $cred -ErrorAction stop
    $server
    Invoke-Command -ComputerName $server -Credential services\viswanathan.admin -ScriptBlock{
        param($filePath)
        wusa.exe $filePath /quiet /norestart
        
               
    } -ArgumentList $filePath
    #wusa.exe $filePath /quiet /norestart
    #Remove-PSSession -Session $session

    #Get-HotFix -ComputerName $server | where {$_.hotfixid -eq "kb4012216"}
}
    $filePath = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Pradeep\Install-Patches\Risk patches\March, 2017 Security Monthly Quality Rollup for Windows Server 2012 R2 (KB4012216)\KB4012216.msu"

$server = "ABN-TPZ-APP-E25.TPZ.tzghosting.net"
$command = "wusa.exe $filePath /quiet /norestart"
$process = [WMICLASS]"\\$server\ROOT\CIMV2:win32_process"
$process.Create($command)

$server = "ABN-AAH-DC-01.AAH.tzghosting.net"
Get-HotFix -ComputerName $server | where {$_.hotfixid -eq "KB4012212"}
$filePath = "\\csn-svc-util-08\E$\AdminTools\Pradeep\Install-Patches\Risk patches\March, 2017 Security Only Quality Update for Windows Server 2008 R2 for x64-based Systems (KB4012212)\kb4012212.msu"
([WMICLASS]"\\$server\root\cimv2:win32_process").create("cmd.exe /c `"$filePath /quiet /norestart`" /q")


$server = "ABN-AAH-DC-01.AAH.tzghosting.net"
Get-HotFix -ComputerName $server | where {$_.hotfixid -eq "KB4012212"}

Invoke-Command -ComputerName $server -Credential services\viswanathan.admin -ScriptBlock {
$filePath = "c:\temp\kb4012212.msu"
([WMICLASS]"\\.\root\cimv2:win32_process").create("cmd.exe /c `"$filePath /quiet /norestart`" /q")
}


$filePath = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Pradeep\Install-Patches\Risk patches\March, 2017 Security Monthly Quality Rollup for Windows Server 2012 R2 (KB4012216)\KB4012216.msu"
$server = "abn-hzn-app-t17.hzn.tzghosting.net"
Copy-Item -Path $filePath -Destination "\\$server\c$\temp" -Credential services\viswanathan.admin



wusa.exe $filePath /quiet /norestart
wusa.exe $filePath /quiet /norestart

wusa.exe "E:\AdminTools\Pradeep\Check_Specific_Hotfix\Risk patches\2008\kb4012212.msu" /quiet /norestart
wusa.exe "E:\AdminTools\Pradeep\Check_Specific_Hotfix\Risk patches\2008\kb4012215.msu" /quiet /norestart
wusa.exe "E:\AdminTools\Pradeep\Check_Specific_Hotfix\Risk patches\2012\kb4012213.msu" /quiet /norestart
wusa.exe "E:\AdminTools\Pradeep\Check_Specific_Hotfix\Risk patches\2012\KB4012216.msu" /quiet /norestart

















<#
    #4012216
    $patch = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Pradeep\Install-Patches\Risk patches\March, 2017 Security Monthly Quality Rollup for Windows Server 2012 R2 (KB4012216)\KB4012216.msu"
    $dest = "c:\temp"
    $filePath = "c:\temp\AMD64-all-windows8.1-kb4012216-x64_cd5e0a62e602176f0078778548796e2d47cfa15b.msu"

    $session = New-PSSession -ComputerName $server -Credential $cred -ErrorAction stop
    Copy-Item -ToSession $session -Destination c:\temp\ -Path $patch216 -Recurse -Force

    Invoke-Command -Session $session -ScriptBlock{
        param($filePath)
        New-Item -ItemType Directory -Path C:\Temp -ErrorAction SilentlyContinue | Out-Null
        wusa.exe $filePath /quiet /norestart
                        
    } -ArgumentList $filePath
    #wusa.exe $filePath /quiet /norestart
    Remove-PSSession -Session $session
}

$filePath = "c:\temp\AMD64-all-windows8.1-kb4012216-x64_cd5e0a62e602176f0078778548796e2d47cfa15b.msu"
$server = "csn-cmc-xen-03.cmc.tzghosting.net"
PSexec \\csn-cmc-xen-03.cmc.tzghosting.net wusa.exe c:\temp\AMD64-all-windows8.1-kb4012216-x64_cd5e0a62e602176f0078778548796e2d47cfa15b.msu /quiet /norestart
Get-HotFix -ComputerName $server | where {$_.hotfixid -eq "kb4012216"}

#>