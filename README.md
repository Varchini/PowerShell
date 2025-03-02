# Description
This PowerShell script is designed to remotely manage kiosk systems, ensuring that a specific application (TOURISTINFO.EXE) is running. The script performs the following tasks:

* Checks if the TOURISTINFO.EXE process is running on the kiosk.
* Starts the process if it is not running.
* Reboots the kiosk system if the process cannot be started after a delay.
* Locks the system and sends an email notification to the support team if the process fails to start even after the reboot.
# Prerequisites
* PowerShell Remoting must be enabled on the kiosk system for the script to run remotely.
* The user running the script must have administrative privileges on the kiosk system.
* Access to an SMTP server is required to send email notifications (for the support team).
* The script assumes the kiosk machine uses a Windows OS.
# Script Details
* **Kiosk Information:** The script requires details about the kiosk system such as IP address, username, and password.
* **Log Directory:** Logs the events in the specified directory.
* **Process Path:** The path to the TOURISTINFO.EXE application.
* **Email Notification:** Sends an email to the support team if the system is locked due to process failure.
# Configuration
Before running the script, you must update the following variables:

## Kiosk Details
* **$kioskNameOrIP:** The name or IP address of the kiosk machine.
* **$kioskUsername:** The username of the kiosk user.
* **$kioskPassword:** The password for the kiosk user.
## Logging
* **$logDirectory:** The directory where log files will be stored (e.g., "C:\Program Files\InfoPoint\logs").
* **$logFileName:** The log file is named based on the current date and time.
## Email Notification
* **$smtpServer:** SMTP server address (e.g., smtp.yourserver.com).
* **$smtpPort:** The SMTP port (e.g., 587 for TLS).
* **$smtpUsername:** The username for SMTP authentication (e.g., your email address).
* **$smtpPassword:** The password for the SMTP account (e.g., your email password or app-specific password).
* **$supportEmail:** The email address to notify when the system is locked.
# Script Workflow
## Step-by-Step Actions:
* **Check if Process is Running:** The script checks whether the TOURISTINFO.EXE process is running on the kiosk.
* **Start Process if Needed:** If the process isn't running, it tries to start it. If unsuccessful after 2 minutes, it reboots the system.
* **Recheck After Reboot:** After rebooting, the script checks again if the process is running. If still unsuccessful, it locks the system and sends an email notification.
* **Email Notification:** If the system is locked, an email notification is sent to the support team with details.
## Log Entries:
* The script logs detailed events at each step, including when processes are checked, started, or if the system is rebooted or locked.
* The logs are saved in a file named with the current date and time in the specified log directory.
## Email Notification:
* When the system is locked due to repeated failure to start the process, an email is sent to the support team.
* The email includes a subject indicating the kiosk system is locked and a body with the reason.
