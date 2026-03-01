Import-Module ConfigurationManager
Set-Location csn:


###########
# Change here
#####
# Email Values
$to = 'pradeep.viswanathan@trizetto.com'
$from = 'SCCM@trizetto.com'
$smtp = 'mail-2.trizetto.net'
$subject = "SCCM - Create Device Collection"
$bodyAsHtml = "PFA Report.<br>This report contains new device collection created"

# declare variables and set paths
$basePath = "E:\AdminTools\SCCM_Script"
$outFile = "$basePath\3_Create_Device_Collection\Report_DeviceCollection.csv"
$logFile = "$basePath\Reports\log.log"



# device collection path
    $basePath_DevCol = "CSN:\DeviceCollection"
    $pathNP = "$basePath_DevCol\NON-PROD"
    $pathPR = "$basePath_DevCol\PROD"
###########

#import SCCM Module
#Import-Module ConfigurationManager

#move pointer to PSDrive CSN:\
cd CSN:


function f_CreateFolder(){
    param(
    [String]$Folderpath
    )
    $check = Test-Path -Path $Folderpath
    if($check -eq $false){
        New-Item -ItemType folder -Path $Folderpath
        Write-Host "Folder Created: $Folderpath" -ForegroundColor Yellow

        writeLog -log "Folder Created: $Folderpath"

    }else{
        #Write-Host "Folder Already Exists: $Folderpath"
        #writeLog -log "Folder Already Exists: $Folderpath"
    
    }
}


function f_SendEmail{
    param(
    [String]$outFile
    )
    Send-MailMessage -Attachments $outFile -To $to -From $from -SmtpServer $smtp -Subject $subject -BodyAsHtml $bodyAsHtml
    writeLog -log "Email sent to $to. Report: $outFile"
}

function f_SCCM_Device{
    $dev = Get-CMDevice | where {
            ($_.name -notlike "*nas*") -and
            ($_.name -notlike "*clus*") -and
            ($_.name -notlike "*new*") -and
            ($_.name -like "*-*")
        }  | select -ExpandProperty name

    $dev | Out-File $DeviceOutPath
    #Send-MailMessage -Attachments $outFile -To $to -From $from -SmtpServer $smtp -Subject $subject -BodyAsHtml $bodyAsHtml
    Return $dev
}

function writeLog(){
    param(
    [String]$log
    )

    New-Item -ItemType file -Path $logFile -ErrorAction SilentlyContinue | Out-Null
    $date = Get-Date -Format 'MM-dd-yyyy hh:mm:ss'
    Add-Content -Path $logFile -Value "$date `t $log"
}

function f_CreateDeviceCollection{
    param(
        [String]$collectionName,
        [String]$deviceCollectionComment,
        [String]$folder
    )

    #check if Device Collection aleady exists or not
    $deviceCollection = Get-CMDeviceCollection -Name $collectionName

    #create device collection if count is 0
    if($deviceCollection.Count -eq 0){
        
        $msg = "Collection Missing: '$collectionName'. Creating collection now"
        writeLog -log $msg
        Write-Host $msg -ForegroundColor Yellow

                
        #create missing Device Collection
        $start = Get-Date
        $schedule = New-CMSchedule -Start $start -RecurInterval Days -RecurCount 1
        New-CMDeviceCollection -Name $collectionName -Comment $deviceCollectionComment -LimitingCollectionName "All Systems" -RefreshSchedule $schedule -RefreshType Periodic | Out-Null
            $msg = "Device Collection Created: $collectionName"
            writeLog -log $msg
            Write-Host $msg -ForegroundColor Yellow

        #move Device collection to respective folder
        $deviceCollection = Get-CMDeviceCollection -Name $collectionName
        Move-CMObject -InputObject $deviceCollection -FolderPath $folder
            $msg = "$collectionName collection Moved to: $folder"
            writeLog -log $msg
            Write-Host $msg -ForegroundColor Yellow

    }elseif($deviceCollection.Count -eq 1){
        $msg = "$collectionName collection Already Exists. If you want to recreate it, delete existing collection and execute this script again."
        writeLog -log $msg
        #Write-Host $msg
    }#if

    
   

}

function f_DeviceCollectionQueryMembershipRule{
    param(
    [String]$collectionName,
    [String]$RuleName,
    [String]$QueryExpression
    )
    #Search for existing QuerMembershipRule. Delete if same name already exists
    $rules = Get-CMDeviceCollectionQueryMembershipRule -CollectionName $collectionName
    $msg = "Existing Rules in '$collectionName':$($rules.count)"
    #Write-Host $msg
    writeLog -log $msg
    foreach($rule in $rules){
        if($RuleName -eq $rule.RuleName){
            Remove-CMDeviceCollectionQueryMembershipRule -CollectionName $collectionName -RuleName $RuleName -Force
            $msg = "Removed Query Rule. RuleName '$RuleName', QueryID '$($rule.QueryID)'"
            #Write-Host $msg -ForegroundColor Yellow
            writeLog -log $msg
        }
    }

    #add Device Collection Query Membership Rule
    Add-CMDeviceCollectionQueryMembershipRule `
    -CollectionName $collectionName `
    -RuleName $RuleName `
    -QueryExpression $QueryExpression

    $msg = "CMDeviceCollectionQueryMembershipRule '$RuleName' added to '$collectionName' Device-Collection"
    Write-Host $msg -ForegroundColor Yellow
    writeLog $msg
}

function f_main{


    ## Create folders in Under Device Collection in SCCM
        #check Whether PROD and NON-PROD foldes exists or not. Create if missing
        f_CreateFolder -Folderpath $pathNP
        f_CreateFolder -Folderpath $pathPR        


        $msg = ""

        #get domain name and client Name
        $client = ($domain.Split("."))[0]
        $client = $client.ToUpper()


        #create prod and non prod master device collection if NOT exists
        f_CreateDeviceCollection -collectionName "MW NON PROD SERVERS" -deviceCollectionComment "All Non Prod Servers" -folder $pathNP
        f_CreateDeviceCollection -collectionName "MW PROD SERVERS" -deviceCollectionComment "All Prod Servers" -folder $pathPR


        #****************************************************************
        #Create Collection and Query MembershipRule
        #****************************************************************
            
            #Create Non Prod client device collection
            $env = "Non Prod" #change here
            $domain = "Windows 7"
            $collectionName = "$domain $env Servers"
            $deviceCollectionComment = "$domain $env Servers Only" 
            $folder = "$pathNP" #change here
            f_CreateDeviceCollection -collectionName $collectionName -deviceCollectionComment $deviceCollectionComment -folder $folder

            #Create Non Prod QueryMembershipRule
            $RuleName = "$domain $env Server query"
            $envType = "ABN-" #change here
            #$QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.FullDomainName like ""%$domain%"" and SMS_R_System.Name like ""%$envType%"""
            $QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.Name like ""%$envType%"" and SMS_G_System_OPERATING_SYSTEM.Caption like ""%$domain%"""
            f_DeviceCollectionQueryMembershipRule -collectionName $collectionName -RuleName $RuleName -QueryExpression $QueryExpression



            #Create Prod client device collection
            $env = "Prod" #change here
            $domain = "Windows 7"
            $collectionName = "$domain $env Servers"
            $deviceCollectionComment = "$domain $env Servers Only" 
            $folder = "$pathPR" #change here
            f_CreateDeviceCollection -collectionName $collectionName -deviceCollectionComment $deviceCollectionComment -folder $folder

            #Create Non Prod QueryMembershipRule
            $RuleName = "$domain $env Server query"
            $envType = "CSN-" #change here
            #$QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System where SMS_R_System.FullDomainName like ""%$domain%"" and SMS_R_System.Name like ""%$envType%"""
            $QueryExpression = "select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client from SMS_R_System inner join SMS_G_System_OPERATING_SYSTEM on SMS_G_System_OPERATING_SYSTEM.ResourceId = SMS_R_System.ResourceId where SMS_R_System.Name like ""%$envType%"" and SMS_G_System_OPERATING_SYSTEM.Caption like ""%$domain%"""
            f_DeviceCollectionQueryMembershipRule -collectionName $collectionName -RuleName $RuleName -QueryExpression $QueryExpression


        

}#function f_CreateDeviceFolder



#creaet 'Reports' folder if missing
f_CreateFolder -Folderpath "$basePath\Reports"

f_main
Write-Host "Done"
writeLog -log "Done"
