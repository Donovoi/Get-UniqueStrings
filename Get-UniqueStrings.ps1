# $ErrorActionPreference = 'silentlycontinue';
Import-Module -Name .\Get-UniqueStrings.psm1 -Global
Get-UniqueStrings -Path I:\ -FinalFile C:\Users\micha\Desktop\unitue.txt -Verbose
