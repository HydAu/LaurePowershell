# -------------------------------------------------  Author        :   Laure Kamalandua  ------------------------------------------------- #
# -------------------------------------------------  Version       :   1                 ------------------------------------------------- #
# -------------------------------------------------  Description   :   Remove encrypted files -------------------------------------------- #
# -------------------------------------------------  Beta          :   ###               ------------------------------------------------- #

# Automated procedure to remove Cryptolocker infections

$startStopWatch = (Get-Date)


Write-Host "This script will scan and remove Cryptolocker infected files "
$userName = Read-Host "Provide a username "
$extentionArray = @()

do {
 $input = (Read-Host "Please enter the file extention(s) ")
 if ($input -ne '') {$extentionArray += $input}
} until ($input -eq '')

Foreach ($string in $fileArray) {
    "*" + $string
}

$endStopWatch = (Get-Date)
$elapsedTime = $(($endStopWatch-$startStopWatch).totalseconds)
Write-Host "The script has finished running and took $elapsedTime seconds to complete" -Foregroundcolor "Green" -Backgroundcolor "Black"

<#
Foreach ($user in $userName) {
    $userPath = "\\SYN037664\C$\users\adminlkam\Documents\Coding Workspace\test\$user\"
    Get-ChildItem "$userPath" -Include $fileExtention -Recurse 
    #| Remove-Item -Force
}
#>