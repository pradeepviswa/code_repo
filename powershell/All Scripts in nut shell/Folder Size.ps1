$rootpath = "\\CSN-SVC-UTIL-07\d$\AdminTools"
$DirStructure =  Get-ChildItem -Path $rootpath -Directory | Select-Object -Property FullName,Name
$a = ""
foreach($dir in $DirStructure){
    $path = $dir.FullName
    $folderName = $dir.Name

    $folderSize = Get-ChildItem -Force -Path $path -File -Recurse | Measure-Object -Sum -Property length | select @{n='FolderSize'; e={ $_.sum / 1mb  } }

    [double]$size = "{0:N2}" -f $($folderSize | select -ExpandProperty FolderSize)
   
    IF($size -ge 2048){
        Write-Host "$folderName `t $size MB"
        $a = $a + "$folderName `t $size MB`n"
    }
    
}


$tomy = "pradeep.viswanathan@cognizant.com","ashok.kokate@cognizant.com"
$frommy = "AshokNoReply@cognizant.com"
$smtpmy = "mail-2.trizetto.net"
$subectmy = "Folder Size"
$bodymy = "Please find attached file. This contains report of last patch installed detail on servers."

Send-MailMessage -To $tomy -From $frommy -Subject $subectmy -Body $a -SmtpServer $smtpmy


 

