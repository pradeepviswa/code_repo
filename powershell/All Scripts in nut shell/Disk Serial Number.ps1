<#
Server,DriveLetter,Size,Partition,DiskNumber,DiskSerialNumber
#>

$path = Split-Path $Script:MyInvocation.Mycommand.Path
Set-Location -Path $path

$servers = Get-Content -Path .\Input.txt
$count = $servers.Count
$x = 1

foreach($server in $servers){
    Invoke-Command -ComputerName $server -Authentication Negotiate -ScriptBlock{
        Get-CimInstance -ClassName Win32_LogicalDiskToPartition | select -First 1
        "ok"
        Get-CimInstance -ClassName Win32_DiskDrive -Property * | select * -First 1
        "ok"
        Get-CimInstance -ClassName Win32_PhysicalMedia -Property * | select * -First 1
        "ok"
        #Get-CimInstance -ClassName Win32_DiskDriveToDiskPartition -Property * | select * -First 1
        #"ok"
        <#
        $LogicalDisk = Get-CimInstance -ClassName Win32_LogicalDisk -Property *
        $DiskDrive = Get-CimInstance -ClassName Win32_DiskDrive -pro *
        $DiskDriveToDiskPartition = Get-CimInstance -ClassName Win32_DiskDriveToDiskPartition -KeyOnly
        $LogicalDisk
        $DiskDrive
        $DiskDriveToDiskPartition
        #>
    }

}

