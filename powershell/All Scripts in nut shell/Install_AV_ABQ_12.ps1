Clear-Host
$script:startTime = Get-Date

function GetElapsedTime() {
    $runtime = $(Get-Date) - $script:StartTime
    $retStr = [String]::format("{0} days, {1} hours, {2} minutes, {3}.{4} seconds", `
        $runtime.Days, `
        $runtime.Hours, `
        $runtime.Minutes, `
        $runtime.Seconds, `
        $runtime.Milliseconds)
    $retStr
}

""
Write-Host check-TrendMicro-Service-Status.ps1 -ForegroundColor DarkBlue
Write-Host ==================== -ForegroundColor DarkGray       
Write-Host "Script to check the status of the TrendMicro Service." -ForegroundColor DarkBlue    
""
Write-Host "Requires PowerShell v2.0" -ForegroundColor Darkgray
""
""

Start-Sleep 2

#$erroractionpreference = "SilentlyContinue"

#Get credentials for the current run
$cred = Get-Credential #Read credentials 
$username = $cred.username 
$password = $cred.GetNetworkCredential().password 


#Set input list below
$inputlist = "$env:temp\server_inputlist.txt"

#Start with blank input list. 
new-item $inputlist -type file -Force | Out-Null

notepad $inputList

Write-Host "Press any key to continue..." -fo cyan
$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()

Do

{
$script:Servers = Get-Content $inputlist
""
Write-Host "1.) Paste server list."
Write-Host "2.) Save and close file to continue."
Start-Sleep 3
""
}


Until ($Servers.length -ne $null)

foreach ($server in $servers)
{

#Run ping check first
	if (! (test-connection -count 1 $server)) {
		Add-Content -path $log -value ($server + "`tPing check failed")
		Write-Host "Ping check failed" -ForegroundColor Red
		$pingcheck=$false	
	}
else
	{
	Write-Host "Ping successful" -ForegroundColor Green
	$pingcheck=$true
}

	if ($pingcheck) {

	""
 	Write-Host "Copying file to host $server" -ForegroundColor Magenta
	copy C:\AdminTools\TrendMicro\abn_svc_av_12.bat \\$server\c$\temp
	""
 	Write-Host "Executing install file on host $server" -ForegroundColor Cyan
	./psexec \\$server c:\temp\abn_svc_av_12.bat -d -u $username -p $password
	""
	Write-Host "Deleting batch file on host $server" -ForegroundColor Yellow
	del \\$server\c$\temp\abn_svc_av_12.bat
}
}

""
Write-Host "Done!" -ForegroundColor Green
Write-Host "Script Ended at $(get-date)"
Write-Host "Total Elapsed Time: $(GetElapsedTime)"
""
