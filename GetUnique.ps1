
Import-Module -Name .\GetUnique.psm1 -Global
function GetUnique {
  [CmdletBinding()]
  param(
    # Directory to process
    [Parameter(Mandatory = $false)]
    [string]
    $Path = $(Get-Location).Path,
    # Destination File
    [Parameter(Mandatory = $false)]
    [string]
    $FinalFile = $(Get-Location).Path + "../Unique.txt"
  )

  $Directory = $Path
  $FileToProcess = Get-ChildItem -Path $Directory -Recurse -File

  ForEach-Object -InputObject $FileToProcess -Process {
    $Lines = Get-Content $_.FullName -Encoding ascii -ReadCount 0
    [string[]]$Words = $Lines.Split()
    $UniqueWordList = [System.Collections.Generic.HashSet[string]]::new([string[]]($Words), [System.StringComparer]::OrdinalIgnoreCase)

  }

# Regex for all characters on us keyboard including special characters

$uniqueWordList | Out-File $FinalFile -Encoding ascii -Force -Append -Verbose

}
#   if (-not (Test-Path $FinalFile)) {
#     New-Item -Path $FinalFile -Force
#   }

#   $UniqueWords.GetEnumerator() | ForEach-Object {"{0}" -f $_.Name} | Add-Content -Path $FinalFile -Encoding UTF8

# }

GetUnique -Path $ENV:USERPROFILE\Desktop\vc -FinalFile $ENV:USERPROFILE\Desktop\wordlist.txt -Verbose
