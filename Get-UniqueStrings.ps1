# $ErrorActionPreference = 'silentlycontinue';
Import-Module -Name .\Get-UniqueStrings.psm1 -Global
Get-UniqueStrings -Path I:\ -FinalFile (Join-Path $env:USERPROFILE 'Desktop\unitue.txt') -Verbose
