# Implement your module commands in this script.


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
function Get-GitIgnore {
    [CmdletBinding()]
    param (
  
      [Parameter(Mandatory = $true)]
      [string[]]$GitIgnoreFor,
      [switch] $Append
  
    )
    $params = ($GitIgnoreFor | ForEach-Object {
        [uri]::EscapeDataString($_) }) -join ","
    $filePath = Join-Path -Path $PWD -ChildPath ".gitignore"
    try {
      $webResponse = Invoke-WebRequest -Uri "https://www.gitignore.io/api/$params" | Select-Object -ExpandProperty content 
      if ($Append) {
        $webResponse | Out-File $filePath -Encoding ascii -Append
      }
      else {
        $webResponse | Out-File $filePath -Encoding ascii 
      }
      Write-Host  "Gitignore file created for $params at $filePath" 
      
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException] {
      $pattern = "(?<=!! ERROR:).*?(?=is undefined.)"
      $errorval = ($_ | Select-String -Pattern "!! ERROR:(.*?) !!" -AllMatches).Matches.Value | ForEach-Object { [regex]::Match($_ , $pattern).Value.Trim() } | Sort-Object -Descending
      $errorInputs = $errorval -join ","
      $input = Read-Host "GitIgnore for input $errorInputs  you provided was not found.List all available for gitignore? [y/n]"
      if ($input -ieq "y") {
        Get-GitIgnoreList
      }
      Write-Host "The List can be viewed using command Get-GitIgnoreList"
  
    }
  }

function Get-GitIgnoreList{
    $webresponse=Invoke-WebRequest -Uri "https://www.gitignore.io/api/list?format=lines" | Select-Object -ExpandProperty content
    $webresponse.Split("`n") | Format-Wide { $_ }   -AutoSize -Force
}

Export-ModuleMember -Function Get-GitIgnore, Get-GitIgnoreList
