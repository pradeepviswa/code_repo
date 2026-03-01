$groups = Get-Content 'E:\AdminTools\Pradeep\ADGroup Info\Groups.txt'

$outFile = 'E:\AdminTools\Pradeep\ADGroup Info\Output.csv'
Remove-Item -Path $outFile -ErrorAction SilentlyContinue
New-Item -Path $outFile -ItemType File | Out-Null
Set-Content -Path $outFile -Value "Domain,Group,UserName,SAMAccount"
foreach($group in $groups){
    $output = ""
    $domain = "topaz.tpzhsp.net"
    try{
        $users = Get-ADGroupMember -Identity $group -Server $domain -ErrorAction stop | select Name,SamAccountName
        foreach($user in $users){
            $output = "$domain,$group,$($user.name),$($user.SamAccountName)"
            Add-Content -Path $outFile -Value $output
        }
    }catch{
        $output = "$group,Error"
        $group
    }
}
