# -------------------------------------------------  Author        :   Laure Kamalandua  ------------------------------------------------- #
# -------------------------------------------------  Version       :   1                 ------------------------------------------------- #
# -------------------------------------------------  Description   :   Check add-in misconfigurations on servers    ---------------------- #
# -------------------------------------------------  Additions     :   Input formatting, calculate timeouts, enhance runtime ------------- #

Write-Host "This script will show add-in misconfigurations on servers "
$programName = Read-Host "Specify the plugin's name "
$programLocation = Read-Host "Specify a CSV file to import computers "
$programFiles = Read-Host "Specify the file location(s) of the program "

$programArray = $programFiles -split ","
$csv = Import-CSV -Path $programLocation
$strArray = $csv | Foreach {"$($_.Computer)"}

$totalResults = @()

Foreach ($computer in $strArray) {
    Foreach ($program in $programArray) {
        $programPath = "\\" + $computer + "\" + $program 
        $outputProgram = Test-Path -Path $programPath # while loop
        if ($outputProgram -eq $True) {
            Write-Verbose "The installation is complete for the $programName plugin on $computer" # for $programPath"
            $object = New-Object PSObject
            Add-Member -InputObject $object -Membertype NoteProperty -Name Computer -Value $computer
            Add-Member -InputObject $object -Membertype NoteProperty -Name Plugin -Value $programName
            Add-Member -InputObject $object -Membertype NoteProperty -Name Path -Value $program
            Add-Member -InputObject $object -Membertype NoteProperty -Name Installation -Value "Complete"
            $totalResults += $object
        }
        elseif ($outputProgram -eq $False) {
            Write-Warning "The installation is incomplete for the $programName plugin on $computer" # for $programPath" 
            $object = New-Object PSObject
            Add-Member -InputObject $object -Membertype NoteProperty -Name Computer -Value $computer
            Add-Member -InputObject $object -Membertype NoteProperty -Name Plugin -Value $programName
            Add-Member -InputObject $object -Membertype NoteProperty -Name Path -Value $program
            Add-Member -InputObject $object -Membertype NoteProperty -Name Installation -Value "Incomplete"
            $totalResults += $object
        }
        else {
            Write-Host "An error occured while looking for your files"
        }
    }
}

$totalResults # format custom PSO