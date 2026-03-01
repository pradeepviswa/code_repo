$dir = Split-Path $Script:Myinvocation.Mycommand.path
Set-Location -Path $dir

$outfile = ".\Output-RegistryValueCheck.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "ServerName,Key,ItemProperly-Value"

$servers = Get-Content .\Input.txt

$x = 0
$count = $servers.count
foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    
    ############# CHANGE VALUE HERE     #############

    $keyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client"
    $keyValue = "Enabled"

    ##################################################

    Write-Progress -Activity "Check Key" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $keyPath
    try{
        $testKeyPath = Invoke-Command -ComputerName $server -Authentication Negotiate -ScriptBlock { 
            param ($keyPath)
            Test-Path -Path $keyPath 
        } -ArgumentList $keyPath -ErrorAction Stop

        

        if($testKeyPath){

            try{
                #$checkKeyValue = Get-ItemProperty -Path $keyPath -Name $keyValue -ErrorAction Stop
            

                $checkKeyValue = Invoke-Command -ComputerName $server -Authentication Negotiate -ScriptBlock { 
                    param ($keyPath,$keyValue)
                    Get-ItemProperty -Path $keyPath -Name $keyValue
                } -ArgumentList $keyPath,$keyValue -ErrorAction Stop -ErrorVariable ea



                Write-Host "$server `t $keyPath Present `t $keyValue = $($checkKeyValue.$keyValue)"
                Add-Content -path $outfile -Value "$server,$keyPath Present,$keyValue = $($checkKeyValue.$keyValue)"

            }catch{
        
                Write-Host "$server `t $keyPath Present `t Missing" -ForegroundColor Yellow
                Add-Content -Path $outfile -Value "$server,$keyPath Present,Missing"
            }

    
        }else{
            Add-Content -Path $outfile -Value "$server,$($ea.Message)"
            Write-Host "$server `t $($ea.Message)" -ForegroundColor Yellow
        }
    


    }catch{
            Write-Host "$server `t $keyPath Present `t Missing" -ForegroundColor Yellow
            Add-Content -Path $outfile -Value "$server,$keyPath Missing,Missing"
    }



    
}

