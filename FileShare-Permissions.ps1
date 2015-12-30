# -------------------------------------------------  Author        :   Laure Kamalandua  ------------------------------------------------- #
# -------------------------------------------------  Version       :   1                 ------------------------------------------------- #
# -------------------------------------------------  Description   :   File Server access    --------------------------------------------- #
# -------------------------------------------------  Additions     :   Creates AD SG's, file permissions o  ------------------------------ #


# user inputs the name of the company
# user provides if RW,W permissions are applicable 
# user specifies

# Import Modules 
Import-Module -Name ActiveDirectory 

# Provide input to handle request 
$Company = [string]Read-Host "Provide the name of the company"
$FolderName = [string]Read-Host "Provide the name of the folder"
$FolderLocation = [string]Read-Host "Provide the folder path"

$FolderPermissions [sring]Read-Host ""