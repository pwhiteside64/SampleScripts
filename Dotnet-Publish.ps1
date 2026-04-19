Set-Location "Location of .csproj"

$ProjectPath = ".\ProjName.csproj"
$OutputFolder = ".\publish"
$Runtime = "win-x64"
$Configuration = "Release"

Write-Host "=== .NET Publish ==="

# Clean output folder
if (Test-Path $OutputFolder) {
    Write-Host "Cleaning existing publish folder..."
    Remove-Item -Recurse -Force $OutputFolder
}

# Ensure folder exists
New-Item -ItemType Directory -Path $OutputFolder | Out-Null

# Publish as single file (framework-dependent)
Write-Host "Publishing project..."
dotnet publish $ProjectPath `
    -c $Configuration `
    -r $Runtime `
    --self-contained false `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -o $OutputFolder

# Check result
if ($LASTEXITCODE -ne 0) {
    Write-Error "Publish failed!"
    exit 1
}

Write-Host "Publish complete!"

# List output
Write-Host "`nOutput files:"
Get-ChildItem $OutputFolder

Write-Host "`n=== Deployment package ready ==="