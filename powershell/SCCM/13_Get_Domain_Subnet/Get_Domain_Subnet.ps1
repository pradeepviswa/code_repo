# this scritp connects each domain and gets subnet inforamtin from sites and services
$dir = Split-Path $Script:myinvocation.mycommand.path
Set-Location -Path $dir

$domains = Get-Content ".\Input.txt"
$output = ".\Output.csv"

Remove-Item -Path $output -ErrorAction SilentlyContinue -Force
New-Item -ItemType File -Path $output | Out-Null
Set-Content -Path $output -Value "Domain,Subnet,Site"

$count = $domains.count
$x = 0
foreach($domain in $domains){
    $percent = "{0:N2}" -f ($x/$count *100)
    Write-Progress -Activity "Extracting Subnet Info" `
        -Status "Progress ($x of $count)...$percent%" `
        -PercentComplete $percent `
        -CurrentOperation $domain

    try{
    
        $objs = Get-ADReplicationSubnet -Filter * -Server $domain -ErrorAction Stop | select Name,site
        foreach($obj in $objs){
            $subnet = $obj.Name
            $site = $obj.site
            $site = $site.split(",")[0].Replace("CN=","")
        
            Write-Host "$domain `t $subnet `t $site"
            Add-Content -Path $output -Value "$domain,$subnet,$site"
    
        }


    }catch{

            Write-Host "$domain `t Error" -ForegroundColor Yellow
            Add-Content -Path $output -Value "$domain, Error"
    
    }

    $x++
}

$to = "pradeep.viswanathan@cognizant.com"
$from = "automated-script@trizetto.com"
$smtp = "mail-2.trizetto.net"
$subject = "Subnet Information"
Send-MailMessage -To $to -From $from -SmtpServer $smtp -Subject $subject -Attachments $output
