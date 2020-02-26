#based on api provided by https://www.gitignore.io

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

function Get-GitIgnoreList {
  $webresponse = Invoke-WebRequest -Uri "https://www.gitignore.io/api/list?format=lines" | Select-Object -ExpandProperty content
  #$webresponse.Split("`n") 
  return $webresponse.Split("`n") | Format-Wide { $_ }   -AutoSize -Force
}


function levenshteinDistance() {
  param([string] $first, [string] $second, [switch] $ignoreCase)
 
  $len1 = $first.length
  $len2 = $second.length
 
  if ($len1 -eq 0)
  { return $len2 }
 
  if ($len2 -eq 0)
  { return $len1 }
 
  if ($ignoreCase -eq $true) {
    $first = $first.tolowerinvariant()
    $second = $second.tolowerinvariant()
  }
    
  if ($first -ceq $second) { return 0 }
    
  $v0 = 0..$len1
  $v1 = 0..$len1

  for ($i = 0; $i -lt $len2; $i++) {
    $v1[0] = $i + 1

    for ($j = 0; $j -lt $len1; $j++) {
      $cost = if ($first[$j] -ceq $second[$i]) { 0 } else { 1 }
      $v1[$j + 1] = [math]::Min($v1[$j] + 1, [math]::Min($v0[$j + 1] + 1, $v0[$j] + $cost))
    }

    $v0, $v1 = $v1, $v0
  }
    
  return $v1[-1]
}