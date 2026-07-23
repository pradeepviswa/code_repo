# Modify here
#common group Name
$GroupName = "TZG SCCM Certificate Authentication"
#---------------------------------------

Write-Host "Adding Customer SCCM group in Services SCCM Group: '$GroupName'" -ForegroundColor Yellow
$domains = Get-Content E:\AdminTools\SCCM_Script\SCCM_Install_Script\6_ServicesGroup_Add_Member\Domains.txt

$count = $domains.Count
$x = 0
$missing = @()
foreach($domain in $domains){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Add costomer SCCM group in Services SCCM Group" `
        -Status "Progress ($x of$count)...$percent%" `
        -PercentComplete $percent `
        -CurrentOperation $domain

    
    try{


        #store Client Group name in object
        $clientDomain = $domain
        $clientGroup = Get-ADGroup -Server $clientDomain -Identity $GroupName 

        #store Services Group name in object
        $servicesDomain = "services.tzghosting.net"
        $servicesGroup = Get-ADGroup -Server $servicesDomain -Identity $GroupName

        #add client group in services group
        Add-ADGroupMember -Identity $servicesGroup -Members $clientGroup -Server $servicesDomain

    }catch{
        Write-Host "'$domain' Error. Check Group Name Manually." -ForegroundColor Red
        $missing += $domain
    }

    $x++
}
$missing | Out-File "E:\AdminTools\SCCM_Script\SCCM_Install_Script\6_ServicesGroup_Add_Member\Output-MissingDomains.txt"


Write-Host "Done" -ForegroundColor Yellow
