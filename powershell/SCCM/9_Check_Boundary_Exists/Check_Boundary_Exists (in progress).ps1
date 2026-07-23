Import-Module ConfigurationManager
Set-Location csn:

#output tile
$outfile = "E:\AdminTools\SCCM_Script\8_Check_BoundaryGroup_Exists\Check_BoundaryGroup_Output.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "name,DefaultSiteCode,SiteSystemCount"


#import SCCM Module
Import-Module ConfigurationManager

#change pointer to CSN: drive
cd CSN:

#get all input from csv file and save in variable
$lines = Get-Content "E:\AdminTools\SCCM_Script\8_Check_BoundaryGroup_Exists\Input.txt"


foreach($line in $lines){

    #check existing boundary with same name
    $existing = Get-CMBoundaryGroup -Name *$line*
    
    if($existing.count -gt 0){
 
        foreach($e in $existing){
            $name = $e.Name
            $DefaultSiteCode = $e.DefaultSiteCode
            $SiteSystemCount = $e.SiteSystemCount

            Add-Content -Path $outfile -Value "$name,$DefaultSiteCode,$SiteSystemCount"
            Write-Host "$name `t $DefaultSiteCode `t exists" -ForegroundColor Yellow
        }
        
    }else{
        Add-Content -Path $outfile -Value "$line,Missing"
        Write-Host "$line `t missing" -ForegroundColor Red
    }


}#foreach $lines

Send-MailMessage -Attachments $outfile -To "pradeep.viswanathan@trizetto.com" -Subject "SCCM Boundary Checked" -From "sccm@trizetto.com" -SmtpServer "mail-2.trizetto.net"





