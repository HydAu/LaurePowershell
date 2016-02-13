# -------------------------------------------------  Author        :   Laure Kamalandua  ------------------------------------------------- #
# -------------------------------------------------  Version       :   1                 ------------------------------------------------- #
# -------------------------------------------------  Description   :   Exchange OU shared mailboxes report    ---------------------------- #
# -------------------------------------------------  Additions     :   Enable input and generalize  -------------------------------------- #

# Import Modules 
Import-Module -Name ActiveDirectory 

$AgoriaUsers = (Get-Mailbox -OrganizationalUnit "localwan.net/DOMUSERS/COMPANIES/AGORIA/Mailbox Resources")
$AgoriaArray = @()
ForEach ($item in $AgoriaUsers) {
    $AgoriaEmail = Get-Mailbox -Identity $item.UserPrincipalName
    $AgoriaUsers = Get-MailboxStatistics -Identity $item.UserPrincipalName
    $object = New-Object PSObject
    Add-Member -InputObject $object -Membertype NoteProperty -Name "Mailbox" -Value (($AgoriaEmail.EmailAddresses | select -Index 0).SmtpAddress).ToLower()
    Add-Member -InputObject $object -Membertype NoteProperty -Name "Mailbox Name" -Value $AgoriaUsers.DisplayName 
    Add-Member -InputObject $object -Membertype NoteProperty -Name "Last Logged On" -Value $AgoriaUsers.LastLoggedOnUserAccount
    Add-Member -InputObject $object -MemberType NoteProperty -Name "Logged On User" -Value ((Get-ADUser -Identity (($AgoriaUsers.LastLoggedOnUserAccount).Remove(0,9))).Surname + " " + (Get-ADUser -Identity (($AgoriaUsers.LastLoggedOnUserAccount).Remove(0,9))).GivenName)
    Add-Member -InputObject $object -Membertype NoteProperty -Name "Logon Time" -Value $AgoriaUsers.LastLogonTime
    $AgoriaArray += $object
}

Write-Output -InputObject $AgoriaArray | Export-Csv C:\Users\adminlkam\Desktop\Agoria-Mailboxes.csv
