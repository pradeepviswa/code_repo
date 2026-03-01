# Modify here
$NewGroup = "TZG SCCM Certificate Authentication"
#---------------------------------------

Write-Host "Creating Group: '$NewGroup'" -ForegroundColor Yellow
$domains = Get-Content E:\AdminTools\Pradeep\Create-Group\Domains.txt

$count = $domains.Count
$x = 0
$missing = @()
foreach($domain in $domains){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Creating group $NewGroup" `
        -Status "Progress ($x of$count)...$percent$" `
        -PercentComplete $percent `
        -CurrentOperation $domain

    
    try{
        $OldGroup = Get-ADGroup `
                    -Identity $NewGroup `
                    -Server $domain `
                    -ErrorAction stop
        if($OldGroup.name -match $NewGroup){

            Add-ADGroupMember -Identity $NewGroup `
            -Server $domain `
            -Members "Domain Computers" `
            -ErrorAction SilentlyContinue
            

            Add-ADGroupMember -Identity $NewGroup `
            -Server $domain `
            -Members "Domain Controllers" `
            -ErrorAction SilentlyContinue

            Add-ADGroupMember -Identity $NewGroup `
            -Server $domain `
            -Members "Domain Users" `
            -ErrorAction SilentlyContinue

            Write-Host "Group Exists in $domain, members added"
        }else{
            New-ADGroup -Server $domain `
            -Name $NewGroup `
            -GroupScope Global `
            -GroupCategory Security `
            -Description "Members of this gorup will be allowed to auto-enroll certificate" `
            -ErrorAction Stop

        
            Add-ADGroupMember -Identity $NewGroup `
            -Server $domain `
            -Members "Domain Computers"

            Add-ADGroupMember -Identity $NewGroup `
            -Server $domain `
            -Members "Domain Controllers"

            Add-ADGroupMember -Identity $NewGroup `
            -Server $domain `
            -Members "Domain Users"        
        }

    }catch{
        Write-Host "Group creation failed in $domain" -ForegroundColor Red
        $missing += $domain
    }

    $x++
}
$missing | Out-File "E:\AdminTools\Pradeep\Create-Group\Output-MissingDomains.txt"


Write-Host "Done" -ForegroundColor Yellow
