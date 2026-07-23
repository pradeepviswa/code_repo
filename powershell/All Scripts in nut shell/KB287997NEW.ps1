 $Server= "abn-svc-cwi-01.services.tzghosting.net"
  Invoke-Command  -ComputerName $Server -Authentication Default -ScriptBlock {
          param(
        [string] $Server
                )
       
       $path = 'HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest'
       New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest' -Name 'UseLogonCredential' -Value '0' -PropertyType 'Dword' -Force
       #Test-Path -Path 'HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest'
       #New-ItemProperty -path 'HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest' -name 'UseLogonCredential' -value '0' -PropertyType 'DWord' -Force 
       
       
} -ArgumentList $Server  


$ServersFile = Get-Content "E:\AdminTools\Remediation\KB2871997.txt"
#$global:cred = Get-Credential
ForEach ($ServerLine in $ServersFile){
$Server = $ServerLine

      Invoke-Command  -ComputerName $Server -Authentication Default -ScriptBlock {
              param(
            [string] $Server
                    )
       
           $path = 'HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest'
           New-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest' -Name 'UseLogonCredential' -Value '0' -PropertyType 'Dword' -Force
           #Test-Path -Path 'HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest'
           #New-ItemProperty -path 'HKLM:\System\CurrentControlSet\Control\SecurityProviders\Wdigest' -name 'UseLogonCredential' -value '0' -PropertyType 'DWord' -Force 
       
       
    } -ArgumentList $Server  

}


