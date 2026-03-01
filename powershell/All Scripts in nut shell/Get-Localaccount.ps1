$computers = Get-Content -Path E:\AdminTools\Pradeep\Get-localaccounts\Input.txt
Get-WmiObject -ComputerName $computers -Class Win32_UserAccount -Filter "LocalAccount='True'" |
Select PSComputername, Name, Status, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, SID | Export-csv E:\AdminTools\Pradeep\Get-localaccounts\local_users.csv -NoTypeInformation