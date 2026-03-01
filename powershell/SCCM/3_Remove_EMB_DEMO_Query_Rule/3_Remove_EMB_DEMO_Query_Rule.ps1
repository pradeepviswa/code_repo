Import-Module ConfigurationManager
Set-Location CSN:


$collectionNames =@()
$collectionNames += "MW NON PROD SERVERS"
$collectionNames += "MW NON PROD REGULAR SERVERS"
$collectionNames += "MW NON PROD EARLY SERVERS"

$collectionNames += "MW PROD SERVERS"
$collectionNames += "MW PROD REGULAR SERVERS"
$collectionNames += "MW PROD EARLY SERVERS"

foreach($collectionName in $collectionNames){
    $rules = Get-CMDeviceCollectionQueryMembershipRule -CollectionName $collectionName
    foreach($rule in $rules){
        if(($rule.RuleName -match "EMB") -and ($collectionName -ne "MW NON PROD SERVERS") -and ($collectionName -ne "MW PROD SERVERS")){
            $RuleName = $rule.RuleName
            Remove-CMDeviceCollectionQueryMembershipRule -CollectionName $collectionName -RuleName $RuleName -Force
            Write-Host "$RuleName `t removed from '$collectionName'" -ForegroundColor Yellow

        }elseif($rule.RuleName -match "DEMO"){
            $RuleName = $rule.RuleName
            Remove-CMDeviceCollectionQueryMembershipRule -CollectionName $collectionName -RuleName $RuleName -Force
            Write-Host "$RuleName `t removed from '$collectionName'" -ForegroundColor Yellow

        }
    }

}

