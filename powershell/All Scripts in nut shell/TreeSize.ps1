cls

$servers = Get-Content "E:\AdminTools\Pradeep Scripts\server.txt"
$outPath = "C:\Temp\TreeSize.csv"
Remove-Item -Path $outPath -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outPath | Out-Null
Set-Content -Path $outPath -Value "ServerName,Path,Folder,Size(MB)"

foreach($server in $servers){
    $paths = @()
    $paths += "\\$server\c$"
    $paths += "\\$server\d$"

    foreach($path in $paths){
        
    
        $folders = Get-ChildItem -Path $path
        foreach($folder in $folders){
            $check = $($folder.Attributes)
            if ($check -match "Directory"){
                $folderPath = "$path\$($folder.Name)"
            
                $allfiles = Get-ChildItem -Path $folderPath -Recurse | where {$_.Attributes -match "archive"}
                $length = 0
                foreach($file in $allfiles){
                    $length+= $file.length
                }
            
                $size = "{0:N2}" -f ($length/1MB)
                $size = $size -replace ",",""

                $pathTemp = $path -replace "$server",""
                $pathTemp = $pathTemp -replace "\\",""

                $output = "$servers `t $pathTemp `t $($folder.Name) `t $size"
                $output
                $csvOutput = "$servers,$pathTemp,$($folder.Name),$size"
                Add-Content -Path $outPath -Value $csvOutput

                #Add-Content -Path $path -Value $output
                $length = 0
                $size = 0
            }
        }
    }
}