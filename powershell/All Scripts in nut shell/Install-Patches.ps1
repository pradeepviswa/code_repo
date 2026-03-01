$path = "C:\Temp\Patches\"
if(Test-Path -Path $path){
    $patches = Get-ChildItem -Path $path | where {$_.attributes -eq 'archive'}
    foreach($patch in $patches){
        $filePath = $patch.FullName
        #$filePath
        "wusa.exe $filePath /quiet /norestart"
        wusa.exe $filePath /quiet /norestart
        
    }

}else{
    Write-Host "Error: Path not found - $path" -ForegroundColor Red
}
