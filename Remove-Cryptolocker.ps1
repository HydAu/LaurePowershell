# -------------------------------------------------  Author        :   Laure Kamalandua  ------------------------------------------------- #
# -------------------------------------------------  Version       :   1                 ------------------------------------------------- #
# -------------------------------------------------  Description   :   Cryptolocker removal ---------------------------------------------- #

"
                     ______   ______   __  __   ______  ______  ______   ______   __  __   ______   ______    
                    /\  ___\ /\  == \ /\ \_\ \ /\  == \/\__  _\/\  __ \ /\  ___\ /\ \/\ \ /\  == \ /\  ___\   
                    \ \ \____\ \  __< \ \____ \\ \  _-/\/_/\ \/\ \ \/\ \\ \ \____\ \ \_\ \\ \  __< \ \  __\   
                     \ \_____\\ \_\ \_\\/\_____\\ \_\     \ \_\ \ \_____\\ \_____\\ \_____\\ \_\ \_\\ \_____\ 
                      \/_____/ \/_/ /_/ \/_____/ \/_/      \/_/  \/_____/ \/_____/ \/_____/ \/_/ /_/ \/_____/


                                                           Removal Tool 
"

# Set timer
$startRuntime = (Get-Date)

# Initialize all modules 
Import-Module -Name "ActiveDirectory"
Write-Output "The Active Directory module has been loaded ..."
Write-Output "The Exchange session is established ..."
<# Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Write-Output "The Exchange Snap-In has been loaded ..." -Foregroundcolor "Yellow #>
Write-Output "The Citrix XenApp module has been loaded ... `n"
<# Add-PSSnapin -Name *.Citrix -ErrorAction SilentlyContinue
Write-Output "The Citrix Snap-In has been loaded ..." -Foregroundcolor "Yellow" #>

# Variables
$adminUser = (Get-WMIObject -class Win32_ComputerSystem | select username).username
$userEmail = ($userAccount.EmailAddresses  | Select -Index 2).SmtpAddress
$userPhoneNumber = $userAccount.officephone

# Find harmful files, retrief user information (name, workstation), pipe to Exchange 
$discoveryModule = Read-Host "Do you wish to run the discovery module first? [Y/N] "
switch ($discoveryModule) {
    "Y" {
        <# Get-Mailbox -Identity $userAccount | `
        Search-Mailbox -SearchQuery attachment:*.exe,from:"laure.kamalandua@synergics.be"`
        -TargetMailbox $adminUser -TargetFolder "CryptoContent"#>
        Write-Output "`nThe malicious mails have been deleted and forwarded to $userEmail...`n"
    }
    "N" {
        Write-Output "`n"
        Break
    }
}

# Disable the users AD account, workstation, remove xapp servers from farm and display messages
$infectedUser = Read-Host "Specify the account of the user that has been infected "
$userAccount = (Get-ADuser -Identity $infectedUser)
$userAbbreviated = $userAccount.SamAccountName
$userFullName = $userAccount.Givenname + " " + $userAccount.Surname
$userComputer = Read-Host "Specify the computer name of the user "
$filePath = Read-Host "Provide locations for the cryptolocker cleanup "
$filePathArray = $filePath -split ","
Foreach ($path in $filePathArray) {
    $pathCheck = Test-Path -Path $path 
    if ($pathCheck -eq $False) {
        Write-Host "The specified file location is unavailable...`n" -Foregroundcolor "Red"
        Exit
    }
    else {Continue}
}

$extentionArray = @()

do {
 $input = (Read-Host "Please enter the malicious file extention(s) ")
 if ($input -ne '') {
    $extentionArray += $input.Insert(0,"*")
    }
} until ($input -eq '')

Start-Sleep -Seconds 1
$initWarning = Write-Host "The script will remove files on the following locations and cleanup the cryptolocker:`n"
$filePathArray + "`n"
Start-Sleep -Seconds 1
$message = "Are you sure you want to continue with this procedure and remove files on the following location?" # exit if string is null

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Deletes all the encrypted files in the folders."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Retains all the encrypted files in the folders."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0) 
switch ($result) {
    0 {""}
    1 {
        Write-Host "The script has been terminated early." -Foregroundcolor "Red"
        Exit
    }
}

Write-Host "`n... Starting the Cryptolocker procedure ...`n" -Foregroundcolor "Red"
Start-Sleep -Seconds 5
# Write-Output $infectedUser $userComputer | Disable-ADAccount -PassThru
Write-Host "The user account $userAbbreviated and workstation $userComputer of $userFullName have been disabled `n" -Foregroundcolor "Yellow"

Foreach ($path in $filePathArray) {
    Write-Output "Directory: $path" | Format-Wide
    Get-ChildItem $path -ErrorAction "SilentlyContinue" -Include $extentionArray -Recurse | select Name, LastWriteTime, LastAccessTime | Format-List # | Remove-Item -Force
}

Write-Host "The encrypted files have been succesfully removed from the network's location " -Foregroundcolor "Yellow"
Start-Sleep -Seconds 2

$drivePath = '\\SYN037664\C$\users\adminlkam\desktop\'  # "\\"+"$userComputer"+"\"+"C$"+"$env:username" - check env
Get-ChildItem $drivePath -Include $extentionArray -Recurse | select Name, LastWriteTime, LastAccessTime | Format-List # | Remove-Item -Force

Start-Sleep -Seconds 2
Write-Host "The encrypted files have been succesfully removed from the user's homedrive " -Foregroundcolor "Yellow"
Start-Sleep -Seconds 2

$endRuntime = (Get-Date)
$totalRuntime = [string]($endRuntime - $startRuntime).Hours + " hour(s) " `
+ [string]($endRuntime - $startRuntime).Minutes + " minute(s) and " `
+ [string]($endRuntime - $startRuntime).Seconds + " second(s)"
Write-Host "The procedure has finished and took $totalRuntime seconds to complete`n" -Foregroundcolor "Green"

