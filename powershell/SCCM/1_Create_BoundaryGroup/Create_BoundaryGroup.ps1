Import-Module ConfigurationManager
Set-Location csn:

#create boundary group

#output tile
$outpath = "E:\AdminTools\SCCM_Script\1_Create_BoundaryGroup\Create_BoundaryGroup_Output.csv"
Remove-Item -Path $outpath -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Customer,BGName,Site,SCCM_Server,Remarks"

#import SCCM Module
Import-Module ConfigurationManager

#change pointer to CSN: drive
cd CSN:

#get all input from csv file and save in variable
$lines = Import-Csv E:\AdminTools\SCCM_Script\1_Create_BoundaryGroup\New_BoundaryGroup_Input.csv


foreach($line in $lines){

    $remarks = ""

    $name = $line.name
    $env = $line.env
    $domain = $line.domain
    

    #store description. Add 'Prod' or 'Non Prod' based on CSN or ABN
    $tmpEnv = ""
    if($env -eq "ABN"){$tmpEnv = "Non Prod"}
    if($env -eq "CSN"){$tmpEnv = "Prod"}
    $description = "$tmpEnv $domain servers"

    #store SCCM server name based on env
    $sccmServer = ""
    if($env -eq "ABN"){$sccmServer = "abn-svc-sccm-01.services.tzghosting.net"}
    if($env -eq "CSN"){$sccmServer = "csn-svc-sccm-01.services.tzghosting.net"}

  

    $existing = Get-CMBoundaryGroup -Name $name
    if($existing.Count -gt 0){
        #Write-Host "'$($existing.name)' Boundary Group already exists" -ForegroundColor Red
        $groupID = $existing.GroupID
        #Remove-CMBoundaryGroup -Id $groupID -Force
        #Write-Host "'$($existing.name)' existing boundary group deleted" -ForegroundColor Yellow
        #$remarks += "'$($existing.name)' existing boundary group deleted. "

        Write-Host "'$($existing.name)' boundary group already exists. " -ForegroundColor Yellow
        $remarks += "'$($existing.name)' boundary group already exists. "
    }else{
        #New-CMBoundaryGroup -Name aa -Description aa -DefaultSiteCode ABN -AddSiteSystemServer @{"abn-svc-sccm-01.services.tzghosting.net" = "FastLink"}
        $newBoundaryGroup = New-CMBoundaryGroup `
            -Name $name `
            -Description $description `
            -DefaultSiteCode $env `
            -AddSiteSystemServer @{"$sccmServer" = "FastLink"}

            Write-Host "'$($newBoundaryGroup.name)' New Boundary Group Created"

            $remarks += "'$($newBoundaryGroup.name)' New Boundary Group Created"
    
    }


        Add-Content -Path $outpath -Value "$($line.Customer),$name,$env,$sccmServer,$remarks"
        

    Write-Host "`n"
    

}#foreach $lines



