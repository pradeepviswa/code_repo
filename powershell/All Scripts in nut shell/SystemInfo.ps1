<#
ServerName,Make,Model,RAM,SerialNumber
#>

$path = Split-Path $Script:Myinvocation.Mycommand.Path
Set-Location -Path $path

$servers = Get-Content -Path .\Input.txt
$outfile = ".\Output-SystemInfo.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -Path $outfile -ItemType File | Out-Null
Set-Content -Path $outfile -Value "ServerName,Make,Model,RAM(GB),SerialNumber" 


foreach($server in $servers){
    if(Test-Connection -ComputerName $server -Count 1 -Quiet){
        try{
            $cs = Get-WmiObject -Class win32_ComputerSystem -ComputerName $server -ErrorAction Stop | Select-Object -Property Manufacturer, Model, TotalPhysicalMemory
            $Manufacturer = $cs.Manufacturer
                $Manufacturer = $Manufacturer.Replace(",","-")
            $Model = $cs.Model
            $TotalPhysicalMemory = "{0:N2}" -f ($cs.TotalPhysicalMemory / 1gb)

            $SerialNumber = Get-WmiObject -Class win32_bios -ComputerName $server -ErrorAction Stop | Select-Object -ExpandProperty SerialNumber
 
            Write-Host "$server `t $Manufacturer `t $Model `t $TotalPhysicalMemory `t $SerialNumber"
            Add-Content -Path $outfile -Value "$server,$Manufacturer,$Model,$TotalPhysicalMemory,$SerialNumber"

        }catch{
            Write-Host "Error: $server" -ForegroundColor Yellow
            Add-Content -Path $outfile -Value "$server,Error"
    
        }#catch
    
    }else{
            Write-Host "Error Ping Failed: $server" -ForegroundColor Yellow
            Add-Content -Path $outfile -Value "$server,Ping Failed"
    }


}

