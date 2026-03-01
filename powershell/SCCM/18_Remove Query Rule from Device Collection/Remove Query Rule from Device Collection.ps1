Import-Module ConfigurationManager
cd csn:

$dir = Split-Path $Script:Myinvocation.Mycommand.Path
$computers = Get-Content "$dir\Input.txt"

$collectionName = "Decom Servers"

$x = 0
$count = $computers.count
foreach($computer in $computers){
    $x++
    $percent = "{0:N2}" -f ($x/$count * 100)
    $computer = $computer.Split(".")[0]
    $RuleName = $computer
    Write-Progress -Activity "$computer" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent

    #Search for existing QuerMembershipRule. Delete if same name already exists
    $rules = @()
    $rules = Get-CMDeviceCollectionQueryMembershipRule -CollectionName $collectionName
    $rules += Get-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName
    $msg = ""
    $msg = "Existing Rules in '$collectionName':$($rules.count)"
    foreach($rule in $rules){
        if($RuleName -eq $rule.RuleName){
            Remove-CMDeviceCollectionQueryMembershipRule -CollectionName $collectionName -RuleName $RuleName -Force
            Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName -ResourceName $RuleName -Force
            $msg = "Removed Query Rule. RuleName '$RuleName', QueryID/ResourceID '$($rule.QueryID)$($rule.ResourceID)'"
            Write-Host $msg -ForegroundColor Yellow
            
        }
    }    
    
}


#Get-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName