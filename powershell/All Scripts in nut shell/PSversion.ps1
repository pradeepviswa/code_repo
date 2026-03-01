
$servers = Get-Content "E:\AdminTools\Pradeep\PSVersion_Detail\Servers.txt"

$outfile = "E:\AdminTools\Pradeep\PSVersion_Detail\Output.csv"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,PSVersion"

$count = $servers.Count
$x = 0
foreach($server in $servers){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Check PSVersion" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    if(Test-Connection $server -Count 1 -Quiet){
        try{
            $session = New-PSSession -ComputerName $server -Authentication Negotiate -ErrorAction Stop
            $psversion = Invoke-Command -Session $session -ScriptBlock {
                $PSVersionTable.PSVersion.Major
            }
            Add-Content -Path $outfile -Value "$server,$psversion" 
            Write-Host "$server `t $psversion"
        }catch{
            Add-Content -Path $outfile -Value "$server,Connection-eror" 
            Write-Host "$server `t Connection-eror" -ForegroundColor Yellow
        }#end try catch
    
    }else{
        Add-Content -Path $outfile -Value "$server,Ping-failed" 
        Write-Host "$server `t Ping-failed" -ForegroundColor Yellow
    }#end if test-connection
    
    $x++
}

