# Zips the addon for release as ..\ForeverCCG.zip (next to this folder), every file under a
# top-level ForeverCCG/ folder. Leaves out .git, .gitignore, .gitattributes and this script.
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File .\make-zip.ps1

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root    = $PSScriptRoot
$name    = Split-Path $root -Leaf
$zipPath = Join-Path (Split-Path $root -Parent) "$name.zip"
$skip    = @(".git", ".gitignore", ".gitattributes", (Split-Path $PSCommandPath -Leaf))

if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
$count = 0
try {
    Get-ChildItem -LiteralPath $root -Recurse -File -Force | ForEach-Object {
        $rel = $_.FullName.Substring($root.Length).TrimStart("\")
        if ($skip -contains $rel.Split("\")[0]) { return }
        # Forward slashes, so every unzipper (and the CurseForge / Wago uploaders) reads the folders
        $entry = "$name/" + ($rel -replace "\\", "/")
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $entry,
            [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
        $count++
    }
} finally {
    $zip.Dispose()
}

$size = "{0:N0} KB" -f ((Get-Item $zipPath).Length / 1KB)
Write-Host "Zipped $count files into $zipPath ($size)"
