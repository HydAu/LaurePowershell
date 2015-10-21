# -------------------------------------------------  Author        :   Laure Kamalandua  ------------------------------------------------- #
# -------------------------------------------------  Version       :   1                 ------------------------------------------------- #
# -------------------------------------------------  Description   :   Cryptolocker removal ---------------------------------------------- #

"

                     ______   ______   __  __   ______  ______  ______   ______   __  __   ______   ______    
                    /\  ___\ /\  == \ /\ \_\ \ /\  == \/\__  _\/\  __ \ /\  ___\ /\ \/\ \ /\  == \ /\  ___\   
                    \ \ \____\ \  __< \ \____ \\ \  _-/\/_/\ \/\ \ \/\ \\ \ \____\ \ \_\ \\ \  __< \ \  __\   
                     \ \_____\\ \_\ \_\\/\_____\\ \_\     \ \_\ \ \_____\\ \_____\\ \_____\\ \_\ \_\\ \_____\ 
                      \/_____/ \/_/ /_/ \/_____/ \/_/      \/_/  \/_____/ \/_____/ \/_____/ \/_/ /_/ \/_____/


                                                         Deadly Removal Tool   

"

# -------------------------------------------------     Source infection procedure      -------------------------------------------------- #

# Disable the users AD account, workstation, remove xapp servers from farm

Import-Module -Name "ActiveDirectory"
Write-Output "The Active Directory module has been loaded ... "
# Import-PSSession (New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri *** -Authentication Kerberos) | Out-Null
Write-Output "The Exchange session is established ... "
# Get-PSSnapin -Name *.Citrix
Write-Output "The Citrix XenApp module has been loaded ... "

# -------------------------------------------    Active Directory and Exchange procedure    ---------------------------------------------- #

<#
Param (
    [Parameter(Mandatory=$True)] [string]$userAccount,
    [Parameter(Mandatory=$True)] [string]$userComputer
)
#>

$infectedUser = Read-Host "Specify the login name of the infected user "
$userComputer = 


# -------------------------------------------------         Cleanup procedure           -------------------------------------------------- #

$startStopWatch = (Get-Date)
0..1000 | Foreach-Object {$i++}

$filePath = Read-Host "Provide locations for the cryptolocker cleanup "
$filePathArray = $filePath -split ","
$initWarning = Write-Host "The script will remove files on the following locations:" -Foregroundcolor "Yellow"
$filePathArray
#$title = "Cryptolocker file removal"
$message = "Are you sure you want to delete the encrypted files on the specified locations?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Deletes all the encrypted files in the folder."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Retains all the encrypted files in the folder."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0) 
switch ($result)

    {
        0 {""}
        1 {
            Write-Host "The script has been terminated early."
            Exit
        }
    }

Foreach ($path in $filePathArray) {
    $pathCheck = Test-Path -Path $path
    if ($pathCheck -eq $False) {
        "The specified file location is unavailable... "
        Exit
    }
    Else {Continue}
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

Write-Output "The encrypted files have been succesfully removed ... "

# Output directories where path was longer than 260 chars

# -------------------------------------------------         Scan procedure            ---------------------------------------------------- #

$endStopWatch = (Get-Date)
$elapsedTime = $(($endStopWatch - $startStopWatch).totalseconds)
Write-Host "The script has finished running and took $elapsedTime seconds to complete" -Foregroundcolor "Yellow" -Backgroundcolor "Black"

