#based on api provided by https://www.gitignore.io
function Get-GitIgnore {
    param (

        [Parameter(Mandatory = $true)]
        [string[]]$gitignorelist
    )
    $params = ($gitignorelist | ForEach-Object {
            [uri]::EscapeDataString($_) }) -join ","
    Write-Host $params

    Invoke-RestMethod -Uri "https://www.gitignore.io/api/$params" | Select-Object -ExpandProperty content | Out-File $(Join-Path -Path $PWD -ChildPath ".gitignore") -Encoding ascii
}

function Get-GitIgnoreList{
  $webresponse=Invoke-WebRequest -Uri "https://www.gitignore.io/api/list?format=lines" | Select-Object -ExpandProperty content
  $webresponse.Split("`n") | Format-Wide { $_ }   -AutoSize -Force
}


