# -------------------------------------------------  Author        :   Laure Kamalandua  ------------------------------------------------- #
# -------------------------------------------------  Version       :   1                 ------------------------------------------------- #
# -------------------------------------------------  Description   :   Remove encrypted files -------------------------------------------- #
# -------------------------------------------------  Beta          :   ###               ------------------------------------------------- #

# Automated procedure to remove Cryptolocker infections

$startStopWatch = (Get-Date)
0..1000 | Foreach-Object {$i++}

$genInformation = "This script will scan and remove Cryptolocker infected files "
# $userName = Read-Host "Provide a username "
$filePath = Read-Host "Provide locations for the cryptolocker cleanup "
$filePathArray = $filePath -split ","
$initWarning = Write-Warning "The script will remove files on the following locations:"
$filePathArray

$title = "Cryptolocker file removal"
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
    $extentionArray
    Get-ChildItem $path -Include $extentionArray -Recurse | select Name, DirectoryName | Format-Table # | Remove-Item -Force
}

$endStopWatch = (Get-Date)
$elapsedTime = $(($endStopWatch - $startStopWatch).totalseconds)
Write-Host "The script has finished running and took $elapsedTime seconds to complete" -Foregroundcolor "Yellow" -Backgroundcolor "Black"

