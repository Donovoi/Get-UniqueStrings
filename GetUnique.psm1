# Implement your module commands in this script.

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
    $Lines = Get-Content $_.FullName
    [string[]]$Words = $Lines.Split()
    $UniqueWords = [System.Collections.Generic.HashSet[string]]::new($Words)

  }

  if (-not (Test-Path $FinalFile)) {
    New-Item -Path $FinalFile -Force
  }
  $UniqueWords.ForEach{ Add-Content -Value $_ -Path $FinalFile -Encoding ascii }

}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
