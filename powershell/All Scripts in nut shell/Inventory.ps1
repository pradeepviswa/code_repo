$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $dir

$outFile = "$dir\Output-Inventory.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType file -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,Domain,Operating,SystemManufacturer,Model,TotalPhysicalMemory(GB),CPUs,NumberOfCores,NumberOfLogicalProcessors"
$servers = Get-Content -Path .\Input.txt

#create blank array to store problem servers
$problemList = @()

$count = $servers.Count
$x = 0
foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Fetch Server Inventory" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $server

    try{
    
        $common = Invoke-Command -ComputerName $server -Authentication Negotiate -ErrorAction Stop -ScriptBlock { 
        
            $OS = Get-WmiObject -Class Win32_OperatingSystem | select -ExpandProperty Caption 
            $CS = Get-WmiObject -Class Win32_computersystem | select Name,Domain, Manufacturer, Model, TotalPhysicalMemory
                $server = $cs.Name
                $domain = $CS.Domain
                $Manufacturer = ($cs.Manufacturer).Replace(",",".")
                $Model = ($CS.Model).Replace(",",".")
                $TotalPhysicalMemory = $($CS.TotalPhysicalMemory) / 1GB -as [INT]

            $procs = Get-WmiObject –class Win32_processor | select systemname,Name,DeviceID,NumberOfCores,NumberOfLogicalProcessors
                $CPUs = $procs.Count
                $NumberOfCores=""
                $NumberOfLogicalProcessors = ""
        
                if($CPUs -le 1){
                    $CPUs = 1
                    $NumberOfCores = $procs.NumberOfCores 
                    $NumberOfLogicalProcessors = $procs.NumberOfLogicalProcessors
                
                }else{
                    $NumberOfCores = $procs[0].NumberOfCores 
                    $NumberOfLogicalProcessors = $procs[0].NumberOfLogicalProcessors
                
                }

            return $Domain,$OS,$Manufacturer,$Model,$TotalPhysicalMemory,$CPUs,$NumberOfCores,$NumberOfLogicalProcessors
        }
        $outputText = "$server,"
        foreach($line in $common){
            $outputText += "$line,"
        }

        write-host "$server `t done"
        Add-Content -Path $outFile -Value $outputText

<#        
        $OS = Invoke-Command -ComputerName $server -Authentication Negotiate -ErrorAction Stop -ScriptBlock { Get-WmiObject -Class Win32_OperatingSystem | select -ExpandProperty Caption }
        #$OS = Get-WmiObject -ComputerName $server -Class Win32_OperatingSystem -ErrorAction Stop | select -ExpandProperty Caption

        $CS = Invoke-Command -ComputerName $server -Authentication Negotiate -ErrorAction Stop -ScriptBlock { Get-WmiObject -Class Win32_computersystem | select Domain, Manufacturer, Model, TotalPhysicalMemory }
        #$CS = Get-WmiObject -ComputerName $server -Class Win32_computersystem -ErrorAction Stop | select Domain, Manufacturer, Model, TotalPhysicalMemory
            $domain = $CS.Domain
            $Manufacturer = ($cs.Manufacturer).Replace(",",".")
            $Model = ($CS.Model).Replace(",",".")
            $TotalPhysicalMemory = $($CS.TotalPhysicalMemory) / 1GB -as [INT]



        $procs  = Invoke-Command -ComputerName $server -Authentication Negotiate -ErrorAction Stop -ScriptBlock { Get-WmiObject –class Win32_processor | select systemname,Name,DeviceID,NumberOfCores,NumberOfLogicalProcessors}
        #$procs = Get-WmiObject –class Win32_processor -ComputerName $server -ErrorAction Stop | select systemname,Name,DeviceID,NumberOfCores,NumberOfLogicalProcessors
        $CPUs = $procs.Count
        $NumberOfCores=""
        $NumberOfLogicalProcessors = ""
        
        if($CPUs -le 1){
            $CPUs = 1
            $NumberOfCores = $procs.NumberOfCores 
            $NumberOfLogicalProcessors = $procs.NumberOfLogicalProcessors
                
        }else{
            $NumberOfCores = $procs[0].NumberOfCores 
            $NumberOfLogicalProcessors = $procs[0].NumberOfLogicalProcessors
                
        }

        write-host "$server `t done"
        Add-Content -Path $outFile -Value "$server,$Domain,$OS,$Manufacturer,$Model,$TotalPhysicalMemory,$CPUs,$NumberOfCores,$NumberOfLogicalProcessors"
#>    
    }catch{
        $problemList += $server
        write-host "$server `t Error" -ForegroundColor Yellow
        Add-Content -Path $outFile -Value "$server,Error"
    }

}




#$to = "Chavan, Manoj (Cognizant) <Manoj.Chavan2@cognizant.com>","Deshpande, Amardip (Cognizant) <Amardip.Deshpande@cognizant.com>","Deshpande, Madhusudhan (Cognizant) <Madhusudhan.Deshpande@cognizant.com>","Joshi, Abhijeet (Cognizant) <Abhijeet.Joshi5@cognizant.com>","Kadam, Santosh (Cognizant) <Santosh.Kadam@cognizant.com>","Kambli, Vighnesh (Cognizant) <Vighnesh.Kambli@cognizant.com>","Kharge, Dhananjay (Cognizant) <Dhananjay.Kharge@cognizant.com>","Limaye, Mahesh (Cognizant) <Mahesh.Limaye@cognizant.com>","More, Dinesh (Cognizant) <Dinesh.More3@cognizant.com>","Mulik, Sachin (Cognizant) <Sachin.Mulik@cognizant.com>","Naik, Parag (Cognizant) <Parag.Naik@cognizant.com>","Viswanathan, Pradeep (Cognizant) <PRADEEP.VISWANATHAN@cognizant.com>"
$to = "Viswanathan, Pradeep (Cognizant) <PRADEEP.VISWANATHAN@cognizant.com>","Chavan, Manoj (Cognizant) <Manoj.Chavan2@cognizant.com>","Mulik, Sachin (Cognizant) <Sachin.Mulik@cognizant.com>","Kharge, Dhananjay (Cognizant) <Dhananjay.Kharge@cognizant.com>"
#$to = "Viswanathan, Pradeep (Cognizant) <PRADEEP.VISWANATHAN@cognizant.com>"
#$to = "CISTZInfraWindowsOperations@cognizant.com"
$from = 'Automated-HOC2@cognizant.com'
$loopServers = ""
foreach($line in $problemList){
    $splitLine = $line.split(",")
    
    $loopServers += "<tr><Td> $($splitLine[0]) </td></tr>"

}
$body = "
<center>
    <b> Inventory </b> <br>
    Input : <b> $count Servers </b> <br>
    Servers with error : <b> $($problemList.Count) Servers </b> <br>
    Servers with error mentioned below
    <br> <br> <br>

    <table border=1 align=center>
        <Tr bgcolor=#552211>
            <td>Server</td>
        </tr>
    $loopServers
    </table>
</center>

"
#Send-MailMessage -Attachments $outFile -To $to -From $from -SmtpServer 'mail-2.trizetto.net' -Subject 'Server Inventory - HOC2' -BodyAsHtml $body



