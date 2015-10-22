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

# -------------------------------------------------   Functions and Global Env   --------------------------------------------------------- #

function Check-AD ($infectedUser,$userComputer) {
    # 2 - check if Active Directory input is valid
    [Parameter(Mandatory=$True)] [string]$infectedUser,
    [Parameter(Mandatory=$True)] [string]$userComputer

}

# $ErrorActionPreference = "SilentlyContinue"

# ------------------------------------------------------------  Init  -------------------------------------------------------------------- #

# Load Active Directory Module
if ((Get-Module -Name "ActiveDirectory") -eq $null) {
    Import-Module -Name "ActiveDirectory"
    Write-Output "The Active Directory module has been loaded ..."
} else {Write-Output "The Active Directory module was already loaded"}

# Load Exchange Snap-In 
Write-Output "The Exchange session is established ..."

<#
If((Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null)
{
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
    Write-Output "The Exchange Snap-In has been loaded ..." -Foregroundcolor "Yellow"
}
else {Write-Output "Exchange snap-in already loaded"}
#>

# Load Citrix Snap-In
Write-Output "The Citrix XenApp module has been loaded ... `n"
<#
if((Get-PSSnapin -Name *.Citrix -ErrorAction SilentlyContinue) -eq $null)
{
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
    Write-Output "The Citrix Snap-In has been loaded ..." -Foregroundcolor "Yellow"
}
else {Write-Output "Exchange snap-in already loaded"}
#>

# Disable the users AD account, workstation, remove xapp servers from farm

# -------------------------------------------    Active Directory and Exchange procedure    ---------------------------------------------- #

$infectedUser = Read-Host "Specify the account of the user that has been infected "
$userComputer = Read-Host "Specify the computer name of the user "
$userAccount = (Get-ADuser -Identity $infectedUser)
$userAbbreviated = $userAccount.SamAccountName
$userFullName = $userAccount.Givenname + " " + $userAccount.Surname
$userEmail = $userAccount.mail
$userPhoneNumber = $userAccount.officephone

# Write-Output $infectedUser $userComputer | Disable-ADAccount -PassThru
Write-Host "The user account $userAbbreviated and workstation $userComputer of $userFullName have been disabled `n" -Foregroundcolor "Yellow" 

# -------------------------------------------------         Cleanup procedure           -------------------------------------------------- #

$startStopWatch = (Get-Date)
0..1000 | Foreach-Object {$i++}

$filePath = Read-Host "Provide locations for the cryptolocker cleanup "
$filePathArray = $filePath -split ","

# (2)

Foreach ($path in $filePathArray) {
    $pathCheck = Test-Path -Path $path -ErrorAction SilentlyContinue
    if ($pathCheck -eq $False) {
        Write-Host "The specified file location is unavailable...`n" -Foregroundcolor "Red"
        Exit
    }
    else {Continue}
}

$initWarning = Write-Host "The script will remove files on the following locations:`n" -Foregroundcolor "Yellow"
$filePathArray
$message = "Are you sure you want to delete the encrypted files on the specified locations`n?" # exit if string is null

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Deletes all the encrypted files in the folder."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Retains all the encrypted files in the folder."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0) 
switch ($result) {
    0 {""}
    1 {
        Write-Host "The script has been terminated early." -Foregroundcolor "Red"
        Exit
    }
}

$extentionArray = @()

do {
 $input = (Read-Host "Please enter the file extention(s) ")
 if ($input -ne '') {
    $extentionArray += $input.Insert(0,"*")
    }
} until ($input -eq '')

Foreach ($path in $filePathArray) {
    Write-Host "Directory: $path" | Format-Wide
    Get-ChildItem $path -Include $extentionArray -Recurse | select Name, LastWriteTime, LastAccessTime | Format-List # | Remove-Item -Force
}

Write-Output "The encrypted files have been succesfully removed from the user's homedrive "
Start-Sleep -Seconds 2

# Output directories where path was longer than 260 chars and start processing in robocopy

# -------------------------------------------------         Scan procedure            ---------------------------------------------------- #

$endStopWatch = (Get-Date)
$elapsedTime = $(($endStopWatch - $startStopWatch).totalseconds)
Write-Host "The script has finished running and took $elapsedTime seconds to complete" -Foregroundcolor "Yellow" -Backgroundcolor "Black"

