function Get-IPs { 
 
        Param( 
        [Parameter(Mandatory = $true)] 
        [array] $Subnets 
        ) 
 
foreach ($subnet in $subnets) 
    { 
         
        #Split IP and subnet 
        $IP = ($Subnet -split "\/")[0] 
        $SubnetBits = ($Subnet -split "\/")[1] 
         
        #Convert IP into binary 
        #Split IP into different octects and for each one, figure out the binary with leading zeros and add to the total 
        $Octets = $IP -split "\." 
        $IPInBinary = @() 
        foreach($Octet in $Octets) 
            { 
                #convert to binary 
                $OctetInBinary = [convert]::ToString($Octet,2) 
                 
                #get length of binary string add leading zeros to make octet 
                $OctetInBinary = ("0" * (8 - ($OctetInBinary).Length) + $OctetInBinary) 
 
                $IPInBinary = $IPInBinary + $OctetInBinary 
            } 
        $IPInBinary = $IPInBinary -join "" 
 
        #Get network ID by subtracting subnet mask 
        $HostBits = 32-$SubnetBits 
        $NetworkIDInBinary = $IPInBinary.Substring(0,$SubnetBits) 
         
        #Get host ID and get the first host ID by converting all 1s into 0s 
        $HostIDInBinary = $IPInBinary.Substring($SubnetBits,$HostBits)         
        $HostIDInBinary = $HostIDInBinary -replace "1","0" 
 
        #Work out all the host IDs in that subnet by cycling through $i from 1 up to max $HostIDInBinary (i.e. 1s stringed up to $HostBits) 
        #Work out max $HostIDInBinary 
        $imax = [convert]::ToInt32(("1" * $HostBits),2) -1 
 
        $IPs = @() 
 
        #Next ID is first network ID converted to decimal plus $i then converted to binary 
        For ($i = 1 ; $i -le $imax ; $i++) 
            { 
                #Convert to decimal and add $i 
                $NextHostIDInDecimal = ([convert]::ToInt32($HostIDInBinary,2) + $i) 
                #Convert back to binary 
                $NextHostIDInBinary = [convert]::ToString($NextHostIDInDecimal,2) 
                #Add leading zeros 
                #Number of zeros to add  
                $NoOfZerosToAdd = $HostIDInBinary.Length - $NextHostIDInBinary.Length 
                $NextHostIDInBinary = ("0" * $NoOfZerosToAdd) + $NextHostIDInBinary 
 
                #Work out next IP 
                #Add networkID to hostID 
                $NextIPInBinary = $NetworkIDInBinary + $NextHostIDInBinary 
                #Split into octets and separate by . then join 
                $IP = @() 
                For ($x = 1 ; $x -le 4 ; $x++) 
                    { 
                        #Work out start character position 
                        $StartCharNumber = ($x-1)*8 
                        #Get octet in binary 
                        $IPOctetInBinary = $NextIPInBinary.Substring($StartCharNumber,8) 
                        #Convert octet into decimal 
                        $IPOctetInDecimal = [convert]::ToInt32($IPOctetInBinary,2) 
                        #Add octet to IP  
                        $IP += $IPOctetInDecimal 
 
                    } 
 
                #Separate by . 
                $IP = $IP -join "." 
                $IPs += $IP 
$IP
                 
            } 
        $IPs 
    } 
} 

$dir = Split-Path $Script:MyInvocation.Mycommand.Path
Set-Location -Path $dir

#Get-IPs -Subnets $subnet

$subnets = Get-Content .\Input.txt
$outpath = ".\Output.csv"
Remove-Item -Path $outpath -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Subnet,StartIPAddress,EndIPAddress"
$count = $subnets.Count
$x = 0
foreach($subnet in $subnets){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Subnet calculator" -Status "In Progress($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $subnet
    $subnet = $subnet.Trim()
    $IPs = Get-IPs -Subnets $subnet
    #Get-IPs -Subnets $subnet
    $first_IP = $IPs[0]
    $last_IP = $IPs[$IPs.Length - 1]
   
   Add-Content $outpath -Value "$subnet,$first_IP,$last_IP"
    "$subnet `t $first_IP `t $last_IP"
}

