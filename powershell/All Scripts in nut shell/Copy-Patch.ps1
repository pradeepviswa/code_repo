###########################
#change here
$basePath = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Pradeep\Check_Specific_Hotfix\Risk patches"
$outFile = "$basePath\Output.csv"
$filePath = $basePath
$servers = Get-Content "$basePath\Servers.txt"

#decom servers store in variable
$decomServers = Get-Content "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"

#store credential
$TmpFile = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Secure_Password_DO_NOT-DELETE\Infra.Service_SecurePassword.txt"
$username = "SERVICES\infra.service"
$password = Get-Content $TmpFile | ConvertTo-SecureString
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
###########################

Remove-Item -Path $outFile -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,CopyStatus"
$count = $servers.Count
$x = 0


foreach($server in $servers){

    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Copy" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server
    try{
        #open pssession before activity start. this will be used with invoke-command
        $session = New-PSSession -ComputerName $server -Credential $cred -ErrorAction stop

        try{
            #copy installer to remote machine C:\Temp folder
            Copy-Item -ToSession $session -Destination c:\temp\ -Path $filePath -Recurse -Force -ErrorAction Stop
            Write-Host "$server copy success"
            Add-Content -Path $outFile -Value "$server,Success"
        }catch{
            Write-Host "$server copy failed" -ForegroundColor Red
            Add-Content -Path $outFile -Value "$server,failed"
        }
    
    }catch{
            Write-Host "$server connection failed" -ForegroundColor Red
            Add-Content -Path $outFile -Value "$server,failed"
    }
 $x++
 }

notepad $outFile