
Import-Module -Name .\GetUnique.psm1 -Global
function GetUnique {
  [CmdletBinding()]
  param(
    # Directory to process
    [Parameter(Mandatory = $false)]
    [string]
    $Path = $(Get-Location).Path,
    # Minimum length of strings to work with
    [Parameter(Mandatory = $false)]
    [int16]
    $MinLength = 5,
    # Destination File
    [Parameter(Mandatory = $false)]
    [string]
    $FinalFile = $(Get-Location).Path + "../Unique.txt"
  )

  $Directory = $Path
  if (-Not ([string]::IsNullOrWhiteSpace($Directory))) {
    Import-Content -Path $Directory | ForEach-Object -Process {
      if (-not ([string]::IsNullOrWhiteSpace($_))) {
        $Lines = GetStrings -Path $_ -MinimumLength $MinLength
        [string[]]$Words = if (-not ([string]::IsNullOrWhiteSpace($Lines))) {
          $Lines.Split()
        }
        if (-Not ([string]::IsNullOrWhiteSpace($Words))) {
          $UniqueWordList = [System.Collections.Generic.HashSet[string]]::new([string[]]($Words),[System.StringComparer]::OrdinalIgnoreCase)
        }

      }


    }
    [string]$hashString = ($UniqueWordList | Out-String).Trim()

    $hashString | Out-File -FilePath $FinalFile -Encoding Ascii -Force
  }
 Write-Output "Done"


}


GetUnique -Path "C:\Users\micha\OneDrive\Desktop\SuperMem" -FinalFile $ENV:USERPROFILE\wordsyo.txt -Verbose
