$domain = "services"
$computers = Get-ADComputer -Server $domain -Filter * -Properties OperatingSystem,OperatingSystemVersion,PasswordLastSet,whenChanged,whenCreated,CanonicalName,DistinguishedName,DNSHostName,IPv4Address,IPv6Address,LastLogonDate


Function ConvertTo-Date {
    Param (
        [Parameter(ValueFromPipeline=$true,mandatory=$true)]$accountExpires
    )
    
    process {
        $lngValue = $accountExpires
        if(($lngValue -eq 0) -or ($lngValue -gt [DateTime]::MaxValue.Ticks)) {
            $AcctExpires = "<Never>"
        } else {
            $Date = [DateTime]$lngValue
            $AcctExpires = $Date.AddYears(1600).ToLocalTime()
        }
        $AcctExpires 
    }
}

#create Output File
$dir = Split-Path $Script:Myinvocation.Mycommand.Path
Set-Location -path $dir
$outFile = ".\Output-ADComputerInfo.csv"
Remove-Item -Path $outFile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "SamAccountName, Name, Enabled, EmailAddress, PasswordExpired, PasswordLastSet, PasswordNeverExpires, accountExpires, BadLogonCount, badPasswordTime, badPwdCount, CannotChangePassword, CanonicalName, Created, Department, Description, DisplayName, DistinguishedName, LastBadPasswordAttempt, modifyTimeStamp"
Write-Host "Total $($computers.Count) records found. Please wait..."
$count = $computers.Count
$x = 0

foreach($computer in $computers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Computer Detail Fetch" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $computer

    $OperatingSystem	 = $computer.$OperatingSystem
    $OperatingSystemVersion	 = $computer.$OperatingSystemVersion
    $PasswordLastSet	 = $computer.$PasswordLastSet
    $whenChanged	 = $computer.$whenChanged
    $whenCreated	 = $computer.$whenCreated
    $CanonicalName	 = $computer.$CanonicalName
    $DistinguishedName	 = $computer.$DistinguishedName
    $DNSHostName	 = $computer.$DNSHostName
    $IPv4Address	 = $computer.$IPv4Address
    $IPv6Address	 = $computer.$IPv6Address
    $LastLogonDate	 = $computer.$LastLogonDate
    $Enabled	 = $computer.$Enabled

    Add-Content -Path $outFile -Value "$OperatingSystem,$OperatingSystemVersion,$PasswordLastSet,$whenChanged,$whenCreated,$CanonicalName,$DistinguishedName,$DNSHostName,$IPv4Address,$IPv6Address,$LastLogonDate,$Enabled"
    

}


Send-MailMessage -To "pradeep.viswanathan@cognizant.com" -Attachments $outFile -From "Automated-HOC2@cognizant.com" -Subject "Computer detail of Domain : $domain" -BodyAsHtml "PFA file" -From "mail-2.trizetto.net"

Write-Host "Done"