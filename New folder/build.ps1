function Build {
    param (
        [string]$source,
        [string] $configuration='Release',
        [string] $outputLocation
    )
    try{
        $msbuild=(Get-Command msbuild.exe).Source
        &"$msbuild /p:Configuration=Release"
}catch
{
    Write-Output "Error: $_"
}
}