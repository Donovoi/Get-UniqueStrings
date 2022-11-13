# Implement your module commands in this script.

function GetStrings {
  [CmdletBinding()]
  param
  (
    [Parameter(Position = 1, Mandatory = $True, ValueFromPipeline = $True)]
    [String[]]
    $Path,

    [uint32]
    $MinimumLength = 5
  )

  process {
    [string]$AsciiFileContents = $Path
    $AsciiRegex = [regex]"[\x20-\x7E]{$MinimumLength,}"
    $Results = $AsciiRegex.Matches($AsciiFileContents)

    $Results
  }
}



function Import-Content {
  [CmdletBinding()]
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      Position = 0
    )]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Path,

    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $true,
      Position = 1
    )]
    [string]
    $FinalFilePath
  )
  process {
    $Files = Get-ChildItem -LiteralPath $Path -Recurse -Force -File
    foreach ($file in (Resolve-Path -LiteralPath $Files)) {
      if (Test-Path -LiteralPath $file -PathType Leaf) {
        # fastest way to read a file (including a binary file) into memory
        [string[]]$Content = [System.IO.File]::ReadAllBytes($file) | ForEach-Object { [char]$_ }
        [string[]]$StringsOnly = GetStrings -Path $Content -MinimumLength $MinLength
        if (-not ([string]::IsNullOrWhiteSpace($StringsOnly))) {
          [string[]]$Words = if (-not ([string]::IsNullOrWhiteSpace($StringsOnly))) {
            $StringsOnly.Split()
          }
          if (-Not ([string]::IsNullOrWhiteSpace($Words))) {
            $UniqueWordList = [System.Collections.Generic.HashSet[string]]::new([string[]]($Words), [System.StringComparer]::OrdinalIgnoreCase)
          }

        }
        [string]$hashString = ($UniqueWordList | Out-String).Trim()
        $hashString | Out-File -FilePath $FinalFilePath -Encoding Ascii -Force
      }
      Write-Output "Done $File"
    }
  }
}


function Get-UniqueStrings {
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
    $FinalFile = "$ENV:USERPROFILE\Desktop\Unique.txt"
  )
  $Directory = $Path
  if (-Not ([string]::IsNullOrWhiteSpace($Directory))) {
    Import-Content -Path $Directory -Verbose -FinalFilePath $FinalFile

  }
}


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
Export-ModuleMember -Function GetStrings
