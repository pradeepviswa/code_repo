Import-Module ConfigurationManager
cd csn:
$dir = Split-Path $Script:Myinvocation.Mycommand.Path
$computers = Get-Content "$dir\Input.txt"
$collectionName = "Decom Servers"
#$collectionName = "August_Test"

$x = 0
$count = $computers.count
foreach($computer in $computers){
    $x++
    $percent = "{0:N2}" -f ($x/$count * 100)
    $computer = $computer.Split(".")[0]
    Write-Progress -Activity "$computer" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent

    $ResourceId = Get-CMDevice -Name $computer | select -ExpandProperty ResourceId
    if($ResourceId -eq $null){
        Write-Host "Computer not found - $computer" -ForegroundColor Yellow
    }else{
        try{
            Add-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName -ResourceId $ResourceId -ErrorAction Stop -ErrorVariable er
            Write-Host "$computer added"
        }catch{
            $msg = $er.message
            Write-Host "$computer`t $msg"
        }
    }
    
    
    
}
#Get-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName | select RuleName

