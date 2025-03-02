# Define the kiosk machine details
$kioskNameOrIP = "KioskMachineNameOrIP"  # Replace with the actual kiosk name or IP address
$kioskUsername = "KioskUser"  # Replace with the username of the kiosk
$kioskPassword = "KioskPassword"  # Replace with the password of the kiosk user
$logDirectory = "C:\Program Files\InfoPoint\logs" #log file path
$processPath = "C:\Program Files\InfoPoint\TOURISTINFO.EXE" #process file location

# Define the log file path based on datetime
$logFileName = (Get-Date).ToString("yyyyMMdd_HHmmss") + ".log"
$logFilePath = Join-Path $logDirectory $logFileName

function Log-Event {
            param([string]$message)
            $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            $logMessage = "$timestamp - $message"
            Add-Content -Path $logFilePath -Value $logMessage
            Write-Host $logMessage
        }

# Function to run a script remotely on the kiosk
function Run-RemoteScript {
    param([string]$kioskNameOrIP, [string]$kioskUsername, [string]$kioskPassword, [string]$logFilePath, [string]$processPath)
    
    $securePassword = ConvertTo-SecureString $kioskPassword -AsPlainText -Force  # Replace with the kiosk user password
    $cred = New-Object System.Management.Automation.PSCredential ($kioskUsername, $securePassword)

    Invoke-Command -ComputerName $kioskNameOrIP -Credential $cred -ScriptBlock {
        param($logFilePath, $processPath, $username, $password)
        
        function Log-Event {
            param([string]$message)
            $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            $logMessage = "$timestamp - $message"
            Add-Content -Path $logFilePath -Value $logMessage
            Write-Host $logMessage
        }
        
        function Check-Process {
            param([string]$processName)
            $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
            return $process -ne $null
        }

        function Start-ProcessIfNeeded {
            param([string]$processPath)
            Log-Event "Checking if TOURISTINFO.EXE is running."
            
            if (-not (Check-Process -processName "TOURISTINFO")) {
                Log-Event "TOURISTINFO.EXE is not running. Attempting to start it."
                Start-Process $processPath
                Start-Sleep -Seconds 120
                if (-not (Check-Process -processName "TOURISTINFO")) {
                    Log-Event "TOURISTINFO.EXE still not running after waiting 2 minutes. Rebooting the system."
                    Restart-Computer -Force
                } else {
                    Log-Event "TOURISTINFO.EXE successfully started after first attempt."
                }
            } else {
                Log-Event "TOURISTINFO.EXE is already running."
            }
        }
        # Function to enable auto-login for the kiosk
        function Enable-AutoLogin {
            param([string]$username, [string]$password)
    
            # Set registry keys for auto-login
            Log-Event "Enabling auto-login for user $username."

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value $username
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Value $password
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value "LocalMachine"  # Or use domain name if applicable

            Log-Event "Auto-login enabled for user $username."
        }

        # Function to send email notification to support team
        function Send-EmailNotification {
            param([string]$subject, [string]$body)
            
            $smtpServer = "smtp.yourserver.com"  # Replace with your SMTP server
            $smtpPort = 587  # Replace with the port your SMTP server uses (587 for TLS, 25 or 465 for SSL)
            $smtpUsername = "youremail@domain.com"  # Replace with your email
            $smtpPassword = "yourpassword"  # Replace with your email password
            $supportEmail = "supportteam@domain.com"  # Email address to notify support team

            $securePassword = ConvertTo-SecureString $smtpPassword -AsPlainText -Force
            $cred = New-Object System.Management.Automation.PSCredential ($smtpUsername, $securePassword)

            Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -From $smtpUsername -To $supportEmail -Subject $subject -Body $body -Credential $cred -UseSsl
        }


        # Enable auto-login
        Enable-AutoLogin -username $username -password $password

        Start-ProcessIfNeeded -processPath $processPath
        
        if (-not (Check-Process -processName "TOURISTINFO")) {
            Log-Event "System rebooted. Re-checking process after reboot."
            Start-Sleep -Seconds 120
            if (-not (Check-Process -processName "TOURISTINFO")) {
                Log-Event "TOURISTINFO.EXE is still not running after reboot. Locking the system and notifying support team."
                rundll32.exe user32.dll,LockWorkStation #to lock the system
                Log-Event "System locked. Sending email notification to support team."

                # Send email notification
                Send-EmailNotification -subject "Kiosk System Locked $kioskNameOrIP" -body "The kiosk system was locked after failing to start TOURISTINFO.EXE."
            } else {
                Log-Event "TOURISTINFO.EXE successfully started after system reboot."
            }
        }

        Log-Event "Remediation process completed successfully."
    } -ArgumentList $logFilePath, $processPath, $username, $password
}

# Main script to remotely execute the process
try {
    Run-RemoteScript -kioskNameOrIP $kioskNameOrIP -kioskUsername $kioskUsername -kioskPassword $kioskPassword -logFilePath $logFilePath -processPath $processPath
} catch {
    Log-Event "An error occurred: $_"
}
