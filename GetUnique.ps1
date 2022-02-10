
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

  $FunctionDef = $function:GetStrings.ToString()
  ForEach-Object -InputObject $FileToProcess -Parallel {
    $function:GetStrings = $using:FunctionDef
    $Lines = GetStrings -Path $_.FullName -MinimumLength 3 -Encoding Ascii
    [string[]]$Words = $Lines.Split()
    $UniqueWordList = [System.Collections.Generic.HashSet[string]]::new([string[]]($Words),[System.StringComparer]::OrdinalIgnoreCase)
  }

  [string]$hashString = ($UniqueWordList | Out-String).Trim()

  $hashString | Out-File -FilePath $FinalFile -Encoding Ascii



}


GetUnique -Path $ENV:USERPROFILE\Desktop\test -FinalFile $ENV:USERPROFILE\Desktop\wordlist.txt -Verbose
