#Variables 
$renewalDays = 30 
$certTemplate = "ConfigMgrClient" 
$certStore = "ConfigMgr" 
#Create ConfigMgr certificate store if it does not exist 
if (!(Get-ChildItem -Path Cert:\LocalMachine\$certStore -ErrorAction SilentlyContinue)) 
{ 
    New-Item -Path Cert:\LocalMachine\$certStore 
} 
#Get a client auth certificate if it does not exist in ConfigMgr store, check if renewal is needed otherwise 
if (!($cert=Get-ChildItem -Path Cert:\LocalMachine\$certStore -ErrorAction SilentlyContinue)) 
{ 
    $cert=Get-Certificate -Template $certTemplate -CertStoreLocation Cert:\LocalMachine\My 
    Move-Item -Path $cert.Certificate.PSPath -Destination Cert:\LocalMachine\$certStore 
} 
else 
{ 
    $goodCert = 0 
    foreach ($c in $cert) 
    { 
        if ($c.notafter -ge (get-date).AddDays($renewalDays)) 
        { 
        $goodCert = 1 
        } 
    } 
    if ($goodCert -eq 0) 
    { 
        $cert=Get-Certificate -Template $certTemplate -CertStoreLocation Cert:\LocalMachine\My 
        Move-Item -Path $cert.Certificate.PSPath -Destination Cert:\LocalMachine\$certStore 
    } 
}

