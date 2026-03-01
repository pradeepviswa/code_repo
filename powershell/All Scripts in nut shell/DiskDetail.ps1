$path = Split-Path $Script:MyInvocation.Mycommand.Path
Set-Location -Path $path

$outfile = ".\Output-DiskDetail.csv"
Remove-Item -Path $outfile -Force
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,DiskNumber,DiskSize,DiskModel,DiskSerialNumber,DriveLetter,DriveSize,Comment"

$servers = Get-Content .\Input.txt
$count = $servers.Count
$x = 0

Function getDiskSize{
    Param(
    $size
    )
    
    [double]$size = "{0:N2}" -f ($size / 1GB)
    
    $returnSize = "$size GB"

    if($size -gt 1024){
        $size = "{0:N2}" -f ($size / 1024)
        $returnSize = "$size TB"
        
    }

    return $returnSize

}

#$server = "csn-tpz-sql-03.tpz.tzghosting.net"

foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Disk Detail" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server
    if(Test-Connection -ComputerName $server -Count 1 -Quiet){

    $driveLetterArray = @() #to check repeated drive letter / spanned volume
    $LogicalDiskToPartitions = Get-WmiObject -Class Win32_LogicalDiskToPartition -ComputerName $server
    #Save all Drive letters in $driveLetterArray
        foreach($LogicalDiskToPartition in $LogicalDiskToPartitions){
        $driveLetterArray += $($($LogicalDiskToPartition.Dependent).Split("`"")[-2]).trim()
        }


        #STEP 1 :  collect	TAG (ex. \\.\PHYSICALDRIVE9) AND SerialNumber (ex. DB6C4D9170FD4CA9000110E1)
        try{
            $PhysicalMedias = Get-WmiObject -Class Win32_PhysicalMedia -ComputerName $server -ErrorAction Stop | Where-Object -FilterScript {$_.SerialNumber -ne $null}

            foreach($PhysicalMedia in $PhysicalMedias){
                #saved TAG, SerialNumber
                $tag = $($PhysicalMedia.TAG).Replace("\","")
                $tag = $($tag).Replace(".","")
                $SerialNumber = $PhysicalMedia.SerialNumber


                #STEP2 : collect store Dependent, split using " and store -2 (.DeviceID="Disk #9, Partition #1") using Antecedent (ex:\\.\\PHYSICALDEIVE9)
                $DiskDriveToDiskPartitions = Get-WmiObject -Class Win32_DiskDriveToDiskPartition -ComputerName $server
                foreach($DiskDriveToDiskPartition in $DiskDriveToDiskPartitions){
                    $antecedent = $($DiskDriveToDiskPartition.Antecedent).Split("`"")[-2]
                        $antecedent = $antecedent.Replace("\","")
                        $antecedent = $antecedent.Replace(".","")
                    $dependent = $($DiskDriveToDiskPartition.Dependent).Split("`"")[-2]
                        $dependent = $dependent.Trim()
                        if($antecedent -eq $tag){

                            #STEP 3 : Identify drive letter
                            $LogicalDiskToPartitions = Get-WmiObject -Class Win32_LogicalDiskToPartition -ComputerName $server
                            foreach($LogicalDiskToPartition in $LogicalDiskToPartitions){
                                $partitionLocation = $($($LogicalDiskToPartition.Antecedent).Split("`"")[-2]).trim()
                                #compare partitionLocation with $dependent
                                
                                if($partitionLocation -eq $dependent){
                        
                                    #STEP 4 : get size of drive letter
                                    $driveLetter = $($($LogicalDiskToPartition.Dependent).Split("`"")[-2]).trim()
                                    $letters = $driveLetterArray | Where-Object -FilterScript  {$_ -eq $driveLetter}
                                    if($letters.Count -gt 1){

                                        $LogicalDisk = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $server -Filter "DeviceID = '$driveLetter'"
                                        $driveSize = getDiskSize -size $($LogicalDisk.Size)
                        
                                        $DiskDrive = Get-WmiObject -Class Win32_DiskDrive -ComputerName $server | Where-Object -FilterScript {$_.DeviceID -eq "\\.\$tag"}
                                        $diskSize = getDiskSize -size $DiskDrive.Size
                                        $diskModel = $DiskDrive.Model
                                        Write-Host "$server | $tag of $diskSize | $SerialNumber | $driveLetter of $driveSize | Spanned Volume" -ForegroundColor Yellow
                                        Add-Content -path $outfile -Value "$server,$tag,$diskSize,$diskModel,$SerialNumber,$driveLetter,$driveSize,Spanned Volume"

                                    
                                    }else{
                                        $LogicalDisk = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $server -Filter "DeviceID = '$driveLetter'"
                                        $driveSize = getDiskSize -size $($LogicalDisk.Size)
                        
                                        $DiskDrive = Get-WmiObject -Class Win32_DiskDrive -ComputerName $server | Where-Object -FilterScript {$_.DeviceID -eq "\\.\$tag"}
                                        $diskSize = getDiskSize -size $DiskDrive.Size
                                        $diskModel = $DiskDrive.Model
                                        Write-Host "$server | $tag of $diskSize | $SerialNumber | $driveLetter of $driveSize"
                                        Add-Content -path $outfile -Value "$server,$tag,$diskSize,$diskModel,$SerialNumber,$driveLetter,$driveSize"

                                    }#else: check drive letter in array
                                    
                                    

                                

                                }#if
                
                            }#step3: foreach LogicalDiskToPartition
                 
                        }#if STEP2
                }#STEP 2 : foreach $DiskDriveToDiskPartitions

     
    
    
            }#foreach PhysicalMedia STEP 1

        
        }catch{
            Write-Host "$server `t Error: PS Connection Issue" -ForegroundColor Yellow
            Add-Content -Path $outfile -Value "$server,Error: PS Connection Issue"
        }

    
    }else{
        Write-Host "$server `t Error: Ping Failed" -ForegroundColor Yellow
        Add-Content -Path $outfile -Value "$server,Error: Ping Failed"
    }

}#foreach server

<#
CSN-LAC-SQL-13.lac.tzghosting.net
csn-tpz-sql-03.tpz.tzghosting.net
csn-tpz-sql-04.tpz.tzghosting.net
ABN-BCN-SQL-T23.bcn.tzghosting.net
ABN-BCN-SQL-T25.bcn.tzghosting.net
ABN-BCN-SQL-T27.bcn.tzghosting.net
ABN-BCN-SQL-T34.bcn.tzghosting.net


Win32_PhysicalMedia
	collect	TAG (ex. \\.\PHYSICALDRIVE9)
		SerialNumber (ex. DB6C4D9170FD4CA9000110E1)
Win32_DiskDriveToDiskPartition
	collect Antecedent (ex:\\.\\PHYSICALDEIVE9)
	check Antecedent match TAG 
	store Dependent, split using " and store -1 (.DeviceID="Disk #9, Partition #1")
	
Win32_DiskDrive
	compare TAG with DeviceID (ex. \\.\PHYSICALDRIVE9)
	collect Model (ex. PURE FlashArray  Multi-Path Disk Device)
	colelct size as DiskSize (ex. 645314342400)

Win32_LogicalDiskToPartition
	Antecedent       : \\CSN-SVC-UTIL-08\root\cimv2:Win32_DiskPartition.DeviceID="Disk #0, Partition #3"
	compare LogicalDiskToPartition.Antecedent = $dependent
	and collect DriveLetter = LogicalDiskToPartition.Dependent: \\CS.....LogicalDisk.DeviceID="E:"


Win32_LogicalDisk, filter DriveType = 3
	compare DriveLetter  with DriveLetter found above
	collect Size as DriveSize,DriveFreeSpace

Now Print
TAG, SerialNumber, Dependent, Model, DiskSize, DriveLetter, DriveSize, DriveFreeSpace

TAG,SerialNumber,DiskPartition,Model,DiskSize,DdriveLetter,DdriveSize,DriveFreeSpace,DriveVolumeName

#>


