<#
check installed hotfix status
Mention server file path in 
#>

cls
$InputFile = "C:\temp\Pradeep\1.txt"
$servers = Get-Content -Path $InputFile
$output = @()
$output += "Server `t patch `t InstlledOn `t InstalledBy"


foreach($server in $servers){
    try{
        $patch = Get-HotFix -ComputerName $server | `
        Where-Object -FilterScript {$_.InstalledOn -gt '22-Oct-2016'} -ErrorAction Stop
       Write-Host -ForegroundColor yellow "$server Done"

    }
    catch{
       Write-Host -ForegroundColor yellow "$server Done"
    }

}

Write-Host $output