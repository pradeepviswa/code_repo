cls
$users = Import-Csv "C:\Users\viswanathan.admin\Desktop\emb.csv"

foreach($user in $users){

    try{
        $loginID = $user.UserID
        $empID = $user.EMBNetworkID
        Set-ADUser -Server emb.tzghosting.net -Identity $loginID -EmployeeID $empID
        #Get-ADUser -Server emb.tzghosting.net -Identity $loginID -Properties * | select SamAccountName, employeeid
    
    }catch{
        Write-Host "$($user.FullName) `t $loginID `t $empID"
    }

}

