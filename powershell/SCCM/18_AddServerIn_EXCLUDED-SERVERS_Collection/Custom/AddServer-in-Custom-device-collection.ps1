Import-Module ConfigurationManager
cd csn:
$dir = Split-Path $Script:Myinvocation.Mycommand.path

$rows = Import-Csv "$dir\Input.csv"

$x = 0
$count = $rows.count
if($count -lt 1){
    $count = 1
}

foreach($row in $rows){
    $collectionName = $row.DeviceCollection
    $computer = $row.Server
    
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
            Write-Host "$computer in $collectionName"
        
        }catch{
            $showError = $er[0]
        
            $msg = "$computer in $collectionName `t Error: $($showError.Message)"
            Write-Host $msg -ForegroundColor Yellow
                    
        
        }

    }
    
    
    
}

#Get-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName | select RuleName

