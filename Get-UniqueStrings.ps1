# $ErrorActionPreference = 'silentlycontinue';
Import-Module -Name .\Get-UniqueStrings.psm1 -Global
Get-UniqueStrings -Path $ENV:USERPROFILE\Downloads\ -FinalFile (Join-Path $env:USERPROFILE 'Desktop\unitue.txt') -Verbose
