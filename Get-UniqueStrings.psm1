# Implement your module commands in this script.
using namespace System
using namespace System.IO
using namespace System.Text

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
    # Only match valid UTF8 characters
    #$AsciiRegex = [regex]"[\x00-\x7F]{$MinimumLength,}"
    $Results = $AsciiRegex.Matches($AsciiFileContents)
    # Remove all question marks from a line that has two or more consecutive question marks
    # $Results = $Results | ForEach-Object { $_.Value -replace '\?{2,}', '' }
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
    $Files = Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue
    foreach ($file in (Resolve-Path -LiteralPath $Files)) {
      if (Test-Path -LiteralPath $file -PathType Leaf) {
        $fs = New-Object FileStream($file, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read, 8192, [System.IO.FileOptions]::SequentialScan)
        $binaryReader = New-Object System.IO.BinaryReader($fs)
        [byte[]]$buffer = [byte]::new(8192)
        $bufferoffset = 0
        $byteslefttoread = [int]$binaryReader.ReadInt64()
        $byteslefttorecieve = $fs.Length
        [System.Collections.Generic.List[int]]$bytes = New-Object System.Collections.Generic.List[long]
        while ($true) {
          $bytestoread = [Math]::Min($byteslefttoread, $buffer.Length - $bufferoffset)
          if ($byteslefttoread -eq 0) {
            break;
          }
          $bytesread = $binaryReader.Read($buffer, $bufferoffset, $bytestoread)
          if ($bytesread -eq 0) {
            break;
          }
          $byteslefttorecieve -= $bytesread
          $bytesread += $bufferoffset
          $wordstoadd = $bytesread % [System]::SizeOf([int64])
          for ($i = 0; $i -lt $wordstoadd.ToInt64(); $i++) {
            $bytes = $binaryReader.ReadBytes($i.ToByte())
            $Content = [System.Text.Encoding]::ASCII.GetString($bytes)
            $binaryReader.Close()
            $binaryReader.Dispose()

            [string[]]$StringsOnly = GetStrings -Path $Content -MinimumLength $MinLength
            if (-not ([string]::IsNullOrWhiteSpace($StringsOnly))) {
              [string[]]$Words = if (-not ([string]::IsNullOrWhiteSpace($StringsOnly))) {
                $StringsOnly.Split()
              }
              if (-Not ([string]::IsNullOrWhiteSpace($Words))) {
                $UniqueWordList = [System.Collections.Generic.HashSet[string]]::new([string[]]($Words), [System.StringComparer]::OrdinalIgnoreCase)
              }

            }
          }

          $binaryReader.BaseStream.Seek(0, [System.IO.SeekOrigin]::Begin)

          [string]$hashString = ($UniqueWordList | Out-String).Trim()
          $Tempbigfile = $hashString | Out-File -FilePath $ENV:USERPROFILE\Desktop\tempfile.txt -Encoding Ascii -Force -Appen
        }

      }
      Write-Output "Done $File"
    }
    $binaryReader = New-Object System.IO.BinaryReader([System.IO.File]::Open($Tempbigfile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read))
    $binaryReader.BaseStream.Position = 0
    $binaryReader.BaseStream.Seek(0, [System.IO.SeekOrigin]::Begin)
    $bytes = $binaryReader.ReadBytes($binaryReader.BaseStream.Length)
    $Content = [System.Text.Encoding]::ASCII.GetString($bytes)
    $binaryReader.Close()
    $binaryReader.Dispose()

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
    Write-Output "Finished all files the completed file is located at $FinalFilePath"
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
