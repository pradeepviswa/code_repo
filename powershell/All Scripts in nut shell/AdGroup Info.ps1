$groups = Get-Content 'E:\AdminTools\Pradeep\ADGroup Info\Groups.txt'

$outFile = 'E:\AdminTools\Pradeep\ADGroup Info\Output.csv'
Remove-Item -Path $outFile -ErrorAction SilentlyContinue
New-Item -Path $outFile -ItemType File | Out-Null
Set-Content -Path $outFile -Value "Domain,Group,UserName,SAMAccount"

$count = $groups.Count
$x = 0

foreach($group in $groups){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Group Detail Fetch" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $group

    $output = ""
    $domain = "cmc.tzghosting.net"
    try{
        #$users = Get-ADGroupMember -Identity $group -Server $domain -ErrorAction stop | select Name,SamAccountName
        $users = Get-ADGroupMember -Identity $group  -Server $domain -ErrorAction stop | select Name,SamAccountName
        foreach($user in $users){
            $output = "$domain,$group,$($user.name),$($user.SamAccountName)"
            Add-Content -Path $outFile -Value $output
        }
    }catch{
        $output = "$group,Error"
        "'$group' `t Error"
    }
}
<#
$group = "WinRMRemoteWMIUsers__  "
#Get-ADGroupMember -Identity "CMC_SI_NONPROD_RO" -Server $domain 
Get-ADGroupMember -Identity "CMC_SI_NONPROD_RO"  -Server $domain -ErrorAction stop | select Name,SamAccountName
#>
