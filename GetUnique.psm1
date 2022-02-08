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
  PROCESS {
      try {
          IF ($PSBoundParameters["SpecialCharacterToKeep"]) {
              $Regex = "[^\p{L}\p{Nd}"
              Foreach ($Character in $SpecialCharacterToKeep) {
                  IF ($Character -eq "-") {
                      $Regex += "-"
                  }
                  else {
                      $Regex += [Regex]::Escape($Character)
                  }
                  #$Regex += "/$character"
              }

              $Regex += "]+"
          } #IF($PSBoundParameters["SpecialCharacterToKeep"])
          ELSE { $Regex = "[^\p{L}\p{Nd}]+" }

          FOREACH ($Str in $string) {
              Write-Verbose -Message "Original String: $Str"
              $Str -replace $regex, ""
          }
      }
      catch {
          $PSCmdlet.ThrowTerminatingError($_)
      }
  } #PROCESS
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*
