Import-Module ConfigurationManager
Set-Location csn:

#create boundary

#output tile
$outpath = "E:\AdminTools\SCCM_Script\2_Create_Boundary\Create_Boundary_Output.csv"
Remove-Item -Path $outpath -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Description,IPRange,BoundaryGroup,Remarks"


#import SCCM Module
Import-Module ConfigurationManager

#change pointer to CSN: drive
cd CSN:

#get all input from csv file and save in variable
$lines = Import-Csv E:\AdminTools\SCCM_Script\2_Create_Boundary\New_Boundary_Input.csv

$count = $lines.Count
$x = 1

foreach($line in $lines){

    $remarks = ""

    #set values for Boundary creation
    $Description = $line.Description
        $Description = $Description.Replace("TCS","CSN")
        $Description = $Description.Replace("ABQ","ABN")
    $StartIPAddress = $line.StartIPAddress
    $EndIPAddress =  $line.EndIPAddress
    $IPRange = "$StartIPAddress-$EndIPAddress"

    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Add Boundary" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $Description

    #check existing boundary with same name
    $existing = Get-CMBoundary -DisplayName $Description

    $existingRange = Get-CMBoundary  | 
                    where {$_.value -eq $IPRange}

    if($existing.count -gt 0){
        $BoundaryID = $existing.BoundaryID
        #Remove-CMBoundary -Id $BoundaryID -Force
        #Write-Host "'$Description' removed" -ForegroundColor Yellow
        #$remarks += "Existing boundary deleted. "
        
        $remarks = "'$Description' Same Name already exists"
        Write-Host "$x) $remarks" -ForegroundColor Yellow
        Add-Content -Path $outpath -Value "$Description,$IPRange,$BoundaryName,$remarks"

    }elseif($existingRange.count -gt 0){
        #Write-Host "IP Range conflict with boundary '$($existingRange.DisplayName)'. It's deleted" -ForegroundColor Yellow
        #$BoundaryID = $existingRange.BoundaryID
        #Remove-CMBoundary -Id $BoundaryID -Force
        #$remarks += "Same IP range found in '$($existingRange.DisplayName)'* it's deleted. "
        
        $remarks = "'$Description' Same IP range found in '$($existingRange.DisplayName)'"
        Write-Host "$x) $remarks" -ForegroundColor Yellow
        Add-Content -Path $outpath -Value "$Description,$IPRange,$BoundaryName,$remarks"
    }else{
        #create new boundary
        $newBoundary = New-CMBoundary -DisplayName $Description -Type IPRange -Value $IPRange
        $NewBoundaryID = $newBoundary.BoundaryID
        #Write-Host "'$Description' Boundary created"
        $remarks = "'$Description' New Boundary Created "


        #add boundary to boundary group
        $BoundaryName =$Description
        $BoundaryGroupName = $line.BoundaryGroupName
        Add-CMBoundaryToGroup -BoundaryName $BoundaryName -BoundaryGroupName $BoundaryGroupName
        $remarks += " & Added to Boundary Group '$BoundaryGroupName'"

        Write-Host "$x) $remarks"
        Add-Content -Path $outpath -Value "$Description,$IPRange,$BoundaryName,$remarks"
    
    }

    
    $x++
    #Write-Host "`n"
    

}#foreach $lines





