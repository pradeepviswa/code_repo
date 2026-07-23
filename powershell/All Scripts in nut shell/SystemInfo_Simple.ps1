$path = Split-Path $Script:Myinvocation.Mycommand.Path
Set-Location -Path $path

$servers = Get-Content -Path .\Input.txt




$outfile = ".\Output-SystemInfo.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -Path $outfile -ItemType File | Out-Null
Set-Content -Path $outfile -Value "ServerName,Make,Model,RAM(GB),SerialNumber" 


foreach($server in $servers){
            $cs = Get-WmiObject -Class win32_ComputerSystem -ComputerName $server | Select-Object -Property Manufacturer, Model, TotalPhysicalMemory
            $Manufacturer = $cs.Manufacturer
                $Manufacturer = $Manufacturer.Replace(",","-")
            $Model = $cs.Model
            $TotalPhysicalMemory = "{0:N2}" -f ($cs.TotalPhysicalMemory / 1gb)

            $SerialNumber = Get-WmiObject -Class win32_bios -ComputerName $server | Select-Object -ExpandProperty SerialNumber
            Write-Host "$server `t $Manufacturer `t $Model `t $TotalPhysicalMemory `t $SerialNumber"
            Add-Content -Path $outfile -Value "$server,$Manufacturer,$Model,$TotalPhysicalMemory,$SerialNumber"

 }

