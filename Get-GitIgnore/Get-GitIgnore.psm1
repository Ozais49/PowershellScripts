# Implement your module commands in this script.


# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
function Get-GitIgnore {
    param (

        [Parameter(Mandatory = $true)]
        [string[]]$gitignorelist
    )
    $params = ($gitignorelist | ForEach-Object {
            [uri]::EscapeDataString($_) }) -join ","
    Write-Host $params

    Invoke-WebRequest -Uri "https://www.gitignore.io/api/$params" | Select-Object -ExpandProperty content | Out-File $(Join-Path -Path $PWD -ChildPath ".gitignore") -Encoding ascii
}

function Get-GitIgnoreList{
    $webresponse=Invoke-WebRequest -Uri "https://www.gitignore.io/api/list?format=lines" | Select-Object -ExpandProperty content
    $webresponse.Split("`n") | Format-Wide { $_ }   -AutoSize -Force
}

Export-ModuleMember -Function Get-GitIgnore, Get-GitIgnoreList
