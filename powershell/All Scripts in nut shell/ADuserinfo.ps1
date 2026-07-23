$domain = "services"
$users = Get-ADUser -server $domain -Filter * -Properties * 


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
$outFile = ".\Output-ADUserInfo.csv"
Remove-Item -Path $outFile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "SamAccountName, Name, Enabled, EmailAddress, PasswordExpired, PasswordLastSet, PasswordNeverExpires, accountExpires, BadLogonCount, badPasswordTime, badPwdCount, CannotChangePassword, CanonicalName, Created, Department, Description, DisplayName, DistinguishedName, LastBadPasswordAttempt, modifyTimeStamp"
Write-Host "Total $($users.Count) records found. Please wait..."
foreach($user in $users){
    $SamAccountName=$user.SamAccountName
    $Name=$user.Name
    $Enabled=$user.Enabled
    $EmailAddress=$user.EmailAddress
    $PasswordExpired=$user.PasswordExpired
    $PasswordLastSet=$user.PasswordLastSet
    $PasswordNeverExpires=$user.PasswordNeverExpires
    $accountExpires=$user.accountExpires
        $accountExpires = ConvertTo-Date -accountExpires $accountExpires
    $BadLogonCount=$user.BadLogonCount
    $badPasswordTime=$user.badPasswordTime
    $badPwdCount=$user.badPwdCount
    $CannotChangePassword=$user.CannotChangePassword
    $CanonicalName=$user.CanonicalName
    $Created=$user.Created
    $Department=$user.Department
    $Description=$user.Description
    $DisplayName=$user.DisplayName
    $DistinguishedName=$user.DistinguishedName
        $DistinguishedName = $DistinguishedName.Replace(",",".")
    $LastBadPasswordAttempt=$user.LastBadPasswordAttempt
    $modifyTimeStamp=$user.modifyTimeStamp


    Add-Content -Path $outFile -Value "$SamAccountName,$Name,$Enabled,$EmailAddress,$PasswordExpired,$PasswordLastSet,$PasswordNeverExpires,$accountExpires,$BadLogonCount,$badPasswordTime,$badPwdCount,$CannotChangePassword,$CanonicalName,$Created,$Department,$Description,$DisplayName,$DistinguishedName,$LastBadPasswordAttempt,$modifyTimeStamp"
    

}

Write-Host "Done"