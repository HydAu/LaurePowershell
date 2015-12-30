# -------------------------------------------------  Author        :   Laure Kamalandua  ------------------------------------------------- #
# -------------------------------------------------  Version       :   1                 ------------------------------------------------- #
# -------------------------------------------------  Description   :   Import Lync numbers to AD   --------------------------------------- #

#Import Module
Import-Module Lync 
Write-Host "The Lync module has been loaded ..." -Foregroundcolor "Yellow"

#Input
$Company = Read-Host "Provide the company name"
$ExportPath = [string](Get-ChildItem env:userprofile).Value + "\desktop\$Company-Lync-Export.csv"

#Output
Get-CsAdUser | where {$_.Enabled -eq 'True' -AND $_.Company -like $Company} | `
select Name,UserPrincipalName,Phone,SipAddress,Enabled,Company | `
Export-Csv $ExportPath -NoteTypeInformation
Write-Host "Enabled Lync users have been exported to '$ExportPath'" -Foregroundcolor "Yellow"