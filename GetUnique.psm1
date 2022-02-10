# Implement your module commands in this script.

# function GetUnique {
#   [CmdletBinding()]
#   param(
#     # Directory to process
#     [Parameter(Mandatory = $false)]
#     [string]
#     $Path = $(Get-Location).Path,
#     # Destination File
#     [Parameter(Mandatory = $false)]
#     [string]
#     $FinalFile = $(Get-Location).Path + "../Unique.txt"
#   )

#   $Directory = $Path
#   $FileToProcess = Get-ChildItem -Path $Directory -Recurse -File

#   ForEach-Object -InputObject $FileToProcess -Process {
#     $Lines = Get-Content $_.FullName
#     [string[]]$Words = $Lines.Split()
#     $UniqueWords = [System.Collections.Generic.HashSet[string]]::new($Words)

#   }

#   if (-not (Test-Path $FinalFile)) {
#     New-Item -Path $FinalFile -Force
#   }
#   $UniqueWords.ForEach{ Add-Content -Value $_ -Path $FinalFile -Encoding ascii }

# }


function Convert-HashToString
{
  param
  (
    [Parameter(Mandatory = $true)]
    [System.Collections.Hashtable]
    $Hash
  )
  $hashstr = "@{"
  $keys = $Hash.keys
  foreach ($key in $keys)
  {
    $v = $Hash[$key]
    if ($key -match "\s")
    {
      $hashstr += "`"$key`"" + "=" + "`"$v`"" + ";"
    }
    else
    {
      $hashstr += $key + "=" + "`"$v`"" + ";"
    }
  }
  $hashstr += "}"
  return $hashstr
}

function Remove-StringSpecialCharacter {
<#
.SYNOPSIS
  This function will remove the special character from a string.

.DESCRIPTION
  This function will remove the special character from a string.
  I'm using Unicode Regular Expressions with the following categories
  \p{L} : any kind of letter from any language.
  \p{Nd} : a digit zero through nine in any script except ideographic

  http://www.regular-expressions.info/unicode.html
  http://unicode.org/reports/tr18/

.PARAMETER String
  Specifies the String on which the special character will be removed

.PARAMETER SpecialCharacterToKeep
  Specifies the special character to keep in the output

.EXAMPLE
  Remove-StringSpecialCharacter -String "^&*@wow*(&(*&@"
  wow

.EXAMPLE
  Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*"

  wow
.EXAMPLE
  Remove-StringSpecialCharacter -String "wow#@!`~)(\|?/}{-_=+*" -SpecialCharacterToKeep "*","_","-"
  wow-_*

.NOTES
  Francois-Xavier Cat
  @lazywinadmin
  lazywinadmin.com
  github.com/lazywinadmin
#>
  [CmdletBinding()]
  param
  (
    [Parameter(ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [Alias('Text')]
    [System.String[]]$String,

    [Alias("Keep")]
    #[ValidateNotNullOrEmpty()]
    [String[]]$SpecialCharacterToKeep
  )
  process {
    try {
      if ($PSBoundParameters["SpecialCharacterToKeep"]) {
        $Regex = "[^\p{L}\p{Nd}"
        foreach ($Character in $SpecialCharacterToKeep) {
          if ($Character -eq "-") {
            $Regex += "-"
          }
          else {
            $Regex += [regex]::Escape($Character)
          }
          #$Regex += "/$character"
        }

        $Regex += "]+"
      } #IF($PSBoundParameters["SpecialCharacterToKeep"])
      else { $Regex = "[^\p{L}\p{Nd}]+" }

      foreach ($Str in $string) {
        Write-Verbose -Message "Original String: $Str"
        $Str -replace $regex,""
      }
    }
    catch {
      $PSCmdlet.ThrowTerminatingError($_)
    }
  } #PROCESS
}


function GetStrings
{

  param
  (
    [Parameter(Position = 1,Mandatory = $True,ValueFromPipelineByPropertyName = $True)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
    [String[]]
    [Alias('PSPath')]
    $Path,

    [ValidateSet('Default','Ascii','Unicode')]
    [string]
    $Encoding = 'Default',

    [uint32]
    $MinimumLength = 3
  )

  begin
  {
    $FileContents = ''
  }
  process
  {
    foreach ($File in $Path)
    {
      # if ($Encoding -eq 'Unicode' -or $Encoding -eq 'Default')
      # {
      #   $UnicodeFileContents = Get-Content -Encoding 'Unicode' $File -ReadCount 0 -Raw
      #   $UnicodeRegex = [regex]"[\u0020-\u007E]{$MinimumLength,}"
      #   $Results += $UnicodeRegex.Matches($UnicodeFileContents)
      # }

      if ($Encoding -eq 'Ascii' -or $Encoding -eq 'Default')
      {
        $AsciiFileContents = GetContentFast -readOnly -Path $_.FullName
        $AsciiRegex = [regex]"[\x20-\x7E]{$MinimumLength,}"
        $Results = $AsciiRegex.Matches($AsciiFileContents)
      }

      $Results | ForEach-Object -Parallel { Write-Output $_.Value }
    }
  }
  end {}
}

function GetContentFast {
  param(
    [Parameter(Position = 1,Mandatory = $True,ValueFromPipelineByPropertyName = $True)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
    [String[]]
    [Alias('PSPath')]
    $Path,
    [switch]$readOnly
  )

$FileToRead = Get-Item -Path $Path

  Write-Verbose "Reading $FileToRead..."
  $fs = [IO.File]::Open($FileToRead,[IO.FileMode]::Open,
    [IO.FileAccess]::Read,[IO.FileShare]::ReadWrite)
  #"`$readOnly is $readOnly"
  if ($readOnly) {
    $File = New-Object -TypeName System.IO.StreamReader -ArgumentList $fs
  } else {
    $File = New-Object -TypeName System.IO.StreamReader -ArgumentList $FileToRead
  }
  $LineCount = 0
  while ( $read = $File.ReadLine() ) {
    $Linecount++
}
  Out-Host -InputObject $read
  $File.Close()
}
GetContentFast -Path "C:\Users\micha\Desktop\test\vcredist2015_2017_2019_2022_x64.exe" -readOnly -Verbose

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
Export-ModuleMember -Function GetStrings
