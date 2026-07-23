#Enter Policy name here
$gpoName1 = "TZC WSUS Policy - ABN"
$gpoName2 = "TZC WSUS Policy - ABN"

#get domiin names
$domains = Get-Content "E:\AdminTools\Pradeep\Get-GPOReport\Domains.txt"

#variable where failed domain names will be saved
$failed_Domains = @()

#start looping all domains
foreach($domain in $domains){
    $Path = "E:\AdminTools\Pradeep\Get-GPOReport\GPO\$domain.html"
    try{
        Get-GPOReport -Name $gpoName1 -Path $Path -ReportType Html -Domain $domain -ErrorAction Stop
    }catch{
        try{
            Get-GPOReport -Name $gpoName2 -Path $Path -ReportType Html -Domain $domain -ErrorAction Stop
        }catch{
            Write-Host "$domain Report failed" -ForegroundColor Red
            $failed_Domains += $domain
        }
        
    }
}

$failed_Domains | Out-File "E:\AdminTools\Pradeep\Get-GPOReport\Failed_Domains.txt"
Write-Host "GPO Export Done" -ForegroundColor Yellow


################################
#search this in GPO
$searchString = "Specify intranet Microsoft update service location"

Write-Host "Search text '$searchString' is in GPO in progress..." -ForegroundColor Yellow

#get GPOs from this path
$path = "E:\AdminTools\Pradeep\Get-GPOReport\GPO\"

#variable to store GPOs where piolicy setting is missing
$missing_policy = @()

#save file names
$gpos = Get-ChildItem -Path $path | select FullName,name
Write-Host "Checking In Progress. Please wait..."

foreach($gpo in $gpos){
    
    #Get-Content gpo.FullName
    $gpoFile = Get-Content ($gpo.FullName).ToString()


    if($gpoFile -match $searchString){
        
    }else{
        $missing_policy += ($gpo.Name).ToString()
        Write-Host "$(($gpo.Name).ToString()) missing" -ForegroundColor Red
    }

}
$missing_policy | Out-File "E:\AdminTools\Pradeep\Get-GPOReport\Missing_Policy.txt"
Write-Host "Search text in GPO done" -ForegroundColor Yellow


