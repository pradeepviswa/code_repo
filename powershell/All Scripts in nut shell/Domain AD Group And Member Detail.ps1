$dir = Split-Path $Script:Myinvocation.Mycommand.path
Set-Location -Path $dir

$outfile = ".\Output-ADGroupDetail.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "GroupName,MemberName,Ddomain,CompleteOUPath"
$domain = "services.tzghosting.net"
$groups = Get-ADGroup -Server $domain -Filter * -Properties *
$x = 0
$count = $groups.Count
foreach($group in $groups){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "'$domain' group detail" -Status "In progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $groupName
    $groupName = $group.Name
    $members = $group.Members
    Write-Host "Checking Group - $groupName" -ForegroundColor Yellow
    foreach($member in $members){
        $name = $member.Split(",")[0]
        $name = $name.Replace("CN=","")
        $CompleteOUPath = $member.Replace(",",";")
        "`t $groupName `t $name"
        Add-Content -Path $outfile -Value "$groupName,$name,$domain,$CompleteOUPath"
    }

}


Send-MailMessage -To 'pradeep.viswanathan@cognizant.com','Rahul.Karhadkar@cognizant.com' -From 'Automated-HOC2@trizetto.com' `
    -Body "PFA file" -SmtpServer 'mail-2.trizetto.net' -Subject "Domain Grop Detail" -Attachments $outfile
