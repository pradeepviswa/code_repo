get-content "E:\AdminTools\Pradeep\GetLocalAccount\Server.txt" | foreach-object {
    $Comp = $_
	if (test-connection -computername $Comp -count 1 -quiet)
{
                    ([ADSI]"WinNT://$comp").Children | ?{$_.SchemaClassName -eq 'user'} | %{
                    $groups = $_.Groups() | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
                    $_ | Select @{n='Server';e={$comp}},
                    @{n='UserName';e={$_.Name}},
                    @{n='Active';e={if($_.PasswordAge -like 0){$false} else{$true}}},
                    @{n='PasswordExpired';e={if($_.PasswordExpired){$true} else{$false}}},
                    @{n='PasswordAgeDays';e={[math]::Round($_.PasswordAge[0]/86400,0)}},
                    @{n='LastLogin';e={$_.LastLogin}},
                    @{n='Groups';e={$groups -join ';'}},
                    @{n='Description';e={$_.Description}}
  
                 } 
           } Else {Write-Warning "Server '$Comp' is Unreachable hence Could not fetch data"}
     }|Export-Csv -NoTypeInformation "c:\users\joshi.admin\LocalUsers.csv" 