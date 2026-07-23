Set-Location -Path "E:\AdminTools\Pradeep\Patch name from file" -ErrorAction SilentlyContinue

$file = Get-Content .\Input.txt
#remove duplicate lines
$file = $file | select -Unique
#$file = @()
#$file += "			| 4048957 | Not Approved | 2017-11 Security Monthly Quality Rollup for Windows Server 2008 R2 for x64-based Systems (KB4048957) | Critical | "
#$file += "			| MS14-074 | Not Approved | Security Update for Windows Server 2008 R2 x64 Edition (KB3003743) | Important | "
$patches = @()
$count = $file.Count
$x = 0
foreach($line in $file){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "out patch names" -Status "Progress ($x of $count lines)..$percent%" -PercentComplete $percent
    $splitLines = $line.Split(" ")
    foreach($splitLine in $splitLines){

        if(($splitLine -match "KB\d\d\d\d\d\d\d") -or  ($splitLine -match "KB\d\d\d\d\d\d")){
            foreach($patch in $Matches){
                $patches += $patch.Values
                $patch.Values
            }

        }#if
    
        if($splitLine -match "MS\d\d-\d\d\d"){
            #$Matches
            foreach($patch in $Matches){
                $patches += $patch.Values
                $patch.Values
            }
        }#if

    
    }#foreach splitLines


    
}#foreach file

$patches.toupper() | select -Unique | Out-File .\Output.txt
Notepad .\Output.txt

