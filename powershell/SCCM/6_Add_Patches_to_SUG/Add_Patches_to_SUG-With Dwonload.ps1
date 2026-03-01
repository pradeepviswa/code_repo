Import-Module ConfigurationManager
Set-Location csn:


################## validate package name first
$packageName = ""
$flag= $false
Function Read_PackageName(){
    $packageName = Read-Host "Enter Package Name. This package will be used if patch download is pending"
    $packageName = $packageName.Trim()
    return $packageName
}
Write-Host "Please wait. Fetching list of Existing Packages:" -ForegroundColor Cyan
$AllPkgs = get-CMSoftwareUpdateDeploymentPackage | select -ExpandProperty name
$AllPkgs | Sort-Object
do{
    $packageName = Read_PackageName
    $validPackage = get-CMSoftwareUpdateDeploymentPackage -Name $packageName
    
    if($validPackage -eq $null){
        $flag = $false
        "Invalid package name. Retry"
    }else{
        $flag = $true
        "Ok Valid package name. Moving to next step."
    }
}until($flag)

################


#output file settings
$dir  = Split-Path $Script:Myinvocation.Mycommand.path
$outpath = "$dir\Output-Add patches to SUG - With Download.csv"
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "BulletinID,ArticleID,SUGName,Status,Description"


#import values from csv file
$lines = Import-Csv -Path "$dir\Patches.csv"

#for loop to add each patch in SUG
Write-Host "In progress" -ForegroundColor Yellow
$count =0
if(!($lines.Count)){$count = 1}
else{$count = $lines.Count}
$x = 1

foreach($line in $lines){

    #variables
    $output = ""
    $patch = $($line.patch).trim()
    $SUGName = $($line.SUGName).trim()

    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Add patches to SUG" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation "$patch to $SUGName" 


    #remove KB string from patch
    $patch = $patch.Replace("KB","")
    
    if( ($patch.Trim() -eq "") -or ($SUGName.Trim() -eq "")){
        $patch = "BlankPatch or SUG name; Patch - '$patch'; SUG - '$SUGName';"
    }

    #get patch software updaet ID
    $softwareUpdates = @()
    if($patch -match "KB"){
        $softwareUpdates = Get-CMSoftwareUpdate -Fast -ArticleId $patch
     
    }elseif($patch -match "MS"){
        $softwareUpdates = Get-CMSoftwareUpdate -Fast -BulletinId $patch
    }else{
        $softwareUpdates = Get-CMSoftwareUpdate -Fast -ArticleId $patch
        #$softwareUpdates = Get-CMSoftwareUpdate -Fast | where {($_.ArticleID -eq $patch) -or ($_.BulletinID -eq $patch)}
    }
    

    #add each Software Update ID in SUG
    $req = 0
    
    foreach($softwareUpdate in $softwareUpdates){
            if( 
                ( $softwareUpdate.nummissing -ne 0 )            
            ){


                #get software update ID
                $SoftwareUpdateId = $softwareUpdate.CI_ID
                
                $description = ""
                

                #find software update gorup
                $sug = Get-CMSoftwareUpdateGroup -Name $SUGName
                if($sug.count -lt 1){
                    New-CMSoftwareUpdateGroup -Name $SUGName -Description "$SUGName Servers" | Out-Null
                    Write-Host "'$SUGName' SUG not found. Created It" -ForegroundColor Yellow
                }

                #check whther software-update is IsDeployable or not
                if($softwareUpdate.IsDeployable){
                    #Add patch to SUG
                    Add-CMSoftwareUpdateToGroup `
                        -SoftwareUpdateGroupName $SUGName `
                        -SoftwareUpdateId $SoftwareUpdateId
        
                    $BulletinID = $softwareUpdate.BulletinID
                    $ArticleID = $softwareUpdate.ArticleID
                    $description = $softwareUpdate.LocalizedDisplayName

                    Write-Host "'$BulletinID' `t '$ArticleID' `t Added to '$SUGName'"
                    $output = "$BulletinID,$ArticleID,$SUGName,Added,$description"
                    Add-Content -Path $outpath -Value $output
                }else{
                    #download patch
                    Write-Host "Downloading..... `t '$BulletinID' `t '$ArticleID' in Package '$packageName'"
                    try{
                        Invoke-CMSoftwareUpdateDownload `
                            -SoftwareUpdateId $SoftwareUpdateId `
                            -DeploymentPackageName $packageName -ErrorAction Stop -ErrorVariable er


                        #Add patch to SUG
                        Add-CMSoftwareUpdateToGroup `
                            -SoftwareUpdateGroupName $SUGName `
                            -SoftwareUpdateId $SoftwareUpdateId
        
                        $BulletinID = $softwareUpdate.BulletinID
                        $ArticleID = $softwareUpdate.ArticleID
                        $description = $softwareUpdate.LocalizedDisplayName

                        Write-Host "'$BulletinID' `t '$ArticleID' `t Added to '$SUGName'"
                        $output = "$BulletinID,$ArticleID,$SUGName,Added,$description"
                        Add-Content -Path $outpath -Value $output


                    }catch{
                        $msg = $er.message
                        Write-Host "'$patch' `t Download Failed. $msg" -ForegroundColor Yellow
                        $output = ",$patch,$SUGName,Download Failed. $msg"
                        Add-Content -Path $outpath -Value $output
                    }

                
                }


                $req++
            }#if
            
     
        }#foreach softwareUpdates
        
        if($softwareUpdates.count -lt 1){
                    Write-Host "$patch Not found" -ForegroundColor Red
                    $output = "$patch,$patch,,Not Found"
                    Add-Content -Path $outpath -Value $output
    
        }elseif( $req -eq 0){
                    Write-Host "$patch Not Required" -ForegroundColor Red
                    $output = ",$patch,$SUGName,Not Required,Supported OS not present "
                    Add-Content -Path $outpath -Value $output
                    
        <#

                    #THIS SECTION DOWNLOADES PATCHES WHICH ARE NOT REQURIED. HIDING IT
                    
                    Write-Host "$patch Not Required. Adding all available patches now. Count is: $($softwareUpdates.Count)" -ForegroundColor yellow
                    $output = "$patch,Not Required. Adding all available patches now:"
                    #Add-Content -Path $outpath -Value $output

                #find software update gorup
                $sug = Get-CMSoftwareUpdateGroup -Name $SUGName
                if($sug.count -lt 1){
                    New-CMSoftwareUpdateGroup -Name $SUGName -Description "$SUGName Servers" | Out-Null
                    Write-Host "'$SUGName' SUG not found. Created It" -ForegroundColor Yellow
                }
                    
                    

                    foreach($softwareUpdate in $softwareUpdates){
                    
                            #if(( $softwareUpdate.nummissing -ne 0 ) -or ( $softwareUpdate.nummissing -eq 0 )){
                            
                    if( 
                        ( $softwareUpdate.LocalizedDisplayName -notmatch "itanium") -and 
                        ( ($softwareUpdate.LocalizedDisplayName -match "server") -or 
                            ($softwareUpdate.LocalizedDisplayName -match "Windows 7") -or
                            ($softwareUpdate.LocalizedDisplayName -match "Windows 8") -or 
                            ($softwareUpdate.LocalizedDisplayName -match "Windows 10") ) -and 
                        ( $softwareUpdate.nummissing -eq 0 )            
                    ){
                                #get software update ID
                                $SoftwareUpdateId = $softwareUpdate.CI_ID

                                #check whther software-update is IsDeployable or not
                                if($softwareUpdate.IsDeployable){
                                    #Add patch to SUG
                                    Add-CMSoftwareUpdateToGroup `
                                        -SoftwareUpdateGroupName $SUGName `
                                        -SoftwareUpdateId $SoftwareUpdateId
        
                                    $BulletinID = $softwareUpdate.BulletinID
                                    $ArticleID = $softwareUpdate.ArticleID
                                    $description = $softwareUpdate.LocalizedDisplayName

                                    Write-Host "'$BulletinID' `t '$ArticleID' `t Added to '$SUGName'"
                                    $output = "$BulletinID,$ArticleID,$SUGName,Added,$description"
                                    Add-Content -Path $outpath -Value $output
                                }else{
                                    #download patch
                                    Write-Host "Downloading..... `t '$BulletinID' `t '$ArticleID' in Package '$packageName'"
                                    Invoke-CMSoftwareUpdateDownload `
                                        -SoftwareUpdateId $SoftwareUpdateId `
                                        -DeploymentPackageName $packageName


                                    #Add patch to SUG
                                    Add-CMSoftwareUpdateToGroup `
                                        -SoftwareUpdateGroupName $SUGName `
                                        -SoftwareUpdateId $SoftwareUpdateId
        
                                    $BulletinID = $softwareUpdate.BulletinID
                                    $ArticleID = $softwareUpdate.ArticleID
                                    $description = $softwareUpdate.LocalizedDisplayName

                                    Write-Host "'$BulletinID' `t '$ArticleID' `t Added to '$SUGName'"
                                    $output = "$BulletinID,$ArticleID,$SUGName,Added,$description"
                                    Add-Content -Path $outpath -Value $output

                
                                }





                                
                            }#if
            
                        
                        }#foreach softwareUpdates
                        
        #>



        }

        
        $x++
}#foreach patches


 