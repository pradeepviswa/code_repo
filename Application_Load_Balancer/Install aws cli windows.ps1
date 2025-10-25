# Download the MSI installer correctly
Invoke-WebRequest -Uri "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi" -OutFile ".\AWSCLI64PY3.msi"

# Install the MSI silently
#Start-Process "msiexec.exe" -ArgumentList "/i `".\AWSCLI64PY3.msi`" /qn /norestart" -Wait
Start-Process "msiexec.exe" -ArgumentList "/i `".\AWSCLI64PY3.msi`" /passive" -Wait
#if it doesn't work then run msi manually

Write-Host "AWS CLI installation complete."

