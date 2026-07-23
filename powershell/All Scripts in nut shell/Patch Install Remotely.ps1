#"\\csn-svc-util-08\c$\Temp\PatchList\Update for Windows Server 2012 R2 (KB4049068)\AMD64-all-windows8.1-kb4049068-x64_f581f75f2d33052e613afae0faeae65457097f12.msu"

$computers = Get-Content "\\csn-svc-util-08\c$\Temp\1.txt"
$FilePath = "\\csn-svc-util-08\c$\Temp\PatchList\kb4049068.msu"
$FilePath = "C:\Temp\1\kb4049068.msu"

$HotFixID = "KB4049068"
foreach ($computer in $computers){
    Write-Host "Processing computer: $computer" -ForegroundColor green   
    
        $SB={ 
        Start-Process -FilePath 'wusa.exe' -ArgumentList "$FilePath /extract:C:\temp\ /q /norestart" -Wait -PassThru 
        }
        Invoke-Command -AsJob -ComputerName $computer -ScriptBlock $SB
        <#
        $process = Get-Process -ComputerName $computer -Name "wusa" -ErrorAction SilentlyContinue
        if($process.count -eq 0){
            Write-Host "$computer `t patch install cmd failed" -ForegroundColor Yellow
        }else{
            Write-Host "$computer `t patch install in progress"
        }
        #>
}
#Start-Sleep -Seconds 2
#Get-Job | Receive-Job -Keep | Format-Table PSComputerName, ProcessName, ID -AutoSize -Wrap
#Get-HotFix -ComputerName $computer | where {$_.HotFixID -eq $HotFixID}



$SB={ Start-Process -FilePath 'wusa.exe' -ArgumentList "$FilePath /extract:C:\temp\2\" -Wait -PassThru }
    
Invoke-Command -ComputerName $computer -ScriptBlock $SB

$SB={ Start-Process -FilePath 'dism.exe' -ArgumentList "/online /add-package /PackagePath:C:\temp\KBxxxxxx.cab" -Wait -PassThru }

Invoke-Command -ComputerName testcomputer -ScriptBlock $SB