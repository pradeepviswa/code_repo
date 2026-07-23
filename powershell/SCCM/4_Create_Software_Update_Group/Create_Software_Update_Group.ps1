Import-Module ConfigurationManager
Set-Location csn:

#output file settings
$outpath = "E:\AdminTools\SCCM_Script\4_Create_Software_Update_Group\Output.csv"
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "SUGName,Status"

#import values from csv file
$lines = Import-Csv -Path E:\AdminTools\SCCM_Script\4_Create_Software_Update_Group\Create_Software_Update_Group.csv

#for loop to check each SU group
foreach($line in $lines){
    #variables
    $SUGName = $line.SUGName
    $SUGDescrip = $line.SUGDescription
    $output = ""

    #check if group already exists
    $existing = Get-CMSoftwareUpdateGroup -Name $SUGName
    if($existing.Count -gt 0){
        $output = "$SUGName,Already Exists"
        Write-Host "$SUGName `t Already Exists" -ForegroundColor Yellow
    }else{
        #create software update group
        New-CMSoftwareUpdateGroup -Name $SUGName -Description $SUGDescrip | Out-Null
        $output = "$SUGName,Created"
        Write-Host "$SUGName `t Created"
    }

    Add-Content -Path $outpath -Value $output
}#foreach

