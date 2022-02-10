function GetStrings
{
[CmdletBinding()]
  param
  (
    [Parameter(Position = 1,Mandatory = $True,ValueFromPipeline = $True)]
    [String[]]
    $Path,

    [uint32]
    $MinimumLength = 5
  )

  begin
  {
    $FileContents = ''
  }
  process
  {
    foreach ($Line in $Path)
    {

        $AsciiFileContents = Out-String -InputObject $Line
        $AsciiRegex = [regex]"[\x20-\x7E]{$MinimumLength,}"
        $Results = $AsciiRegex.Matches($AsciiFileContents)


      $Results | ForEach-Object -Parallel { Write-Output $_.Value }
    }
  }
  end {}
}


  function Import-Content
{
    <#
        .Description
            Reads the content of files using System.IO.File

        .Example
            Import-Content -Path $Path

        .Example
            Get-ChildItem -Filter *.txt | Import-Content -Raw
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path,
        [switch]
        $Raw
    )
    process
    {
        foreach( $file in ( Resolve-Path -Path $Path ) )
        {
            if(Test-Path -Path $file -PathType Leaf)
            {
                if($Raw)
                {
                  $global:OriginalStrings = [System.IO.File]::ReadAllText( $file )
                return $global:OriginalStrings
                }
                else
                {
                  $global:OriginalStrings =  [System.IO.File]::ReadAllLines( $file )
                return $global:OriginalStrings
                }
            }
        }
    }
}

# Measure-Command -Verbose {

Import-Content -Path "C:\Users\micha\Desktop\test\vcredist2015_2017_2019_2022_x64.exe" -Verbose
GetStrings -path $global:OriginalStrings -MinimumLength 5

# }