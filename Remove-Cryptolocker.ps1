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
Import-Module -Name ActiveDirectory
Write-Output "The Active Directory module has been loaded ..."
Write-Output "The Exchange session is established ..."
<# Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
Write-Output "The Exchange Snap-In has been loaded ..." -Foregroundcolor "Yellow #>
Write-Output "The Citrix XenApp module has been loaded ... `n"
<# Add-PSSnapin -Name *.Citrix
Write-Output "The Citrix Snap-In has been loaded ..." -Foregroundcolor "Yellow" #>

# Variables
$adminUser = (Get-ChildItem env:username).Value
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
        Break
    }
}

# Disable the users AD account, workstation, remove xapp servers from farm and display messages
$infectedUser = [string](Read-Host "Specify the account of the user that has been infected ")
$userAccount = (Get-ADuser -Identity $infectedUser)
$userAbbreviated = ($userAccount.SamAccountName)
$userFullName = ($userAccount.Givenname + " " + (($userAccount.Surname)).Substring(0,1) + (($userAccount.Surname).ToLower()).Remove(0,1))
$userComputer = [string](Read-Host "Specify the computer name of the user ")
$serverXAP = [string](Read-Host "Specify the compromised XAP server(s) ")
$infectedUserHomeDrive = "\\$userComputer\C$\users\$adminUser\desktop" # production -> '\\$userComputer\users\$userAbbreviated'
$infectedUserRES = ("\\files.attentia.be\users\$userAbbreviated\pwrmenu_1','\\files.attentia.be\users\$userAbbreviated\pwrmenu_2")
$filePath = Read-Host "Provide additional network locations for the cryptolocker cleanup "
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
 if ($input -ne "") {
    $extentionArray += $input.Insert(0,"*")
    }
} until ($input -eq "")

Start-Sleep -Seconds 2
$initWarning = Write-Host "The script will remove files on the following locations:`n"

do {
    $val++
    Write-Host "$val." $filePathArray[$val-1]
}   until ($val -eq $filePathArray.length)
Write-Host ([string]($val + 1)).Insert(1,".") $infectedUserHomeDrive

#$infectedUserHomeDrive + "`n"
Start-Sleep -Seconds 1
$message = "`nAre you sure you want to continue with this procedure?" # exit if string is null

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
Write-Host "The user account $userAbbreviated and workstation $userComputer of $userFullName have been disabled" -Foregroundcolor "Yellow"

Foreach ($path in $filePathArray) {
    # Write-Output "Directory: $path" | Format-Wide
    Get-ChildItem $path -Include $extentionArray -Recurse | select Name, LastAccessTime | Format-List # | Out-Null | Remove-Item -Force
}

Write-Host "The encrypted files have been succesfully removed from the network's location " -Foregroundcolor "Yellow"
Get-ChildItem $infectedUserHomeDrive -Include $extentionArray -Recurse | select Name, LastAccessTime | Format-List # | Out-Null # Remove-Item -Force
Write-Host "The encrypted files have been succesfully removed from the user's homedrive " -Foregroundcolor "Yellow"
Start-Sleep -Seconds 2

$endRuntime = (Get-Date)
$totalRuntime = [string]($endRuntime - $startRuntime).Hours + " hour(s) " `
+ [string]($endRuntime - $startRuntime).Minutes + " minute(s) and " `
+ [string]($endRuntime - $startRuntime).Seconds + " second(s)"
Write-Host "The procedure has finished and took $totalRuntime to complete" -Foregroundcolor "Green"

