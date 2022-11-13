# $ErrorActionPreference = 'silentlycontinue';
# Import-Module -Name .\Get-UniqueStrings.psm1 -Global


#     [string[]]$StringsOnly = $Content | GetStrings -MinimumLength $MinLength
#     if (-not ([string]::IsNullOrWhiteSpace($StringsOnly))) {
#       [string[]]$Words = if (-not ([string]::IsNullOrWhiteSpace($StringsOnly))) {
#         $StringsOnly.Split()
#       }
#       if (-Not ([string]::IsNullOrWhiteSpace($Words))) {
#         $UniqueWordList = [System.Collections.Generic.HashSet[string]]::new([string[]]($Words), [System.StringComparer]::OrdinalIgnoreCase)
#       }

#     }
#     [string]$hashString = ($UniqueWordList | Out-String).Trim()

#     $hashString | Out-File -FilePath $FinalFile -Encoding Ascii -Force
#   }



# }


# Measure-Command -Expression { Get-UniqueStrings -Path $ENV:USERPROFILE\case2 -FinalFile $ENV:USERPROFILE\case.txt -Verbose } -Verbose
# Start-Process Notepad++.exe -ArgumentList $("$ENV:USERPROFILE\case.txt")