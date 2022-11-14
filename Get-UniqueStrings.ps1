# $ErrorActionPreference = 'silentlycontinue';
Import-Module -Name .\Get-UniqueStrings.psm1 -Global
Get-UniqueStrings -Path $ENV:USERPROFILE\Downloads\ -FinalFile C:\Users\micha\Desktop\unitue.txt -Verbose
