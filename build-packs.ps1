param(
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputPath = Join-Path $projectRoot $OutputDir
$tempRoot = Join-Path $env:TEMP ("endernation-pack-build-" + [guid]::NewGuid().ToString("N"))
$javaStage = Join-Path $tempRoot "java"
$bedrockStage = Join-Path $tempRoot "bedrock"
$geyserStage = Join-Path $tempRoot "geyser"

$javaZip = Join-Path $outputPath "EnderNation-Resource-Pack-Java-1.21.11.zip"
$bedrockZip = Join-Path $outputPath "EnderNation-Resource-Pack-Bedrock-1.21.11.zip"
$bedrockMcpack = Join-Path $outputPath "EnderNation-Resource-Pack-Bedrock-1.21.11.mcpack"
$geyserZip = Join-Path $outputPath "EnderNation-Geyser-Config-1.21.11.zip"

try {
    if (Test-Path $outputPath) {
        Get-ChildItem $outputPath -File | Remove-Item -Force
    } else {
        New-Item -ItemType Directory -Path $outputPath | Out-Null
    }

    New-Item -ItemType Directory -Force -Path $javaStage, $bedrockStage, $geyserStage | Out-Null

    Copy-Item (Join-Path $projectRoot "pack.mcmeta") $javaStage -Force
    Copy-Item (Join-Path $projectRoot "pack.png") $javaStage -Force
    Copy-Item (Join-Path $projectRoot "assets") $javaStage -Recurse -Force

    Copy-Item (Join-Path $projectRoot "bedrock\*") $bedrockStage -Recurse -Force
    Copy-Item (Join-Path $projectRoot "geysermc\*") $geyserStage -Recurse -Force

    $javaItems = Get-ChildItem $javaStage -Force | ForEach-Object { $_.FullName }
    $bedrockItems = Get-ChildItem $bedrockStage -Force | ForEach-Object { $_.FullName }
    $geyserItems = Get-ChildItem $geyserStage -Force | ForEach-Object { $_.FullName }

    Compress-Archive -Path $javaItems -DestinationPath $javaZip -CompressionLevel Optimal
    Compress-Archive -Path $bedrockItems -DestinationPath $bedrockZip -CompressionLevel Optimal
    Compress-Archive -Path $geyserItems -DestinationPath $geyserZip -CompressionLevel Optimal

    if (Test-Path $bedrockMcpack) {
        Remove-Item $bedrockMcpack -Force
    }
    Move-Item -Path $bedrockZip -Destination $bedrockMcpack -Force

    [PSCustomObject]@{
        JavaZip = $javaZip
        BedrockMcpack = $bedrockMcpack
        GeyserZip = $geyserZip
    }
}
finally {
    if (Test-Path $tempRoot) {
        Remove-Item $tempRoot -Recurse -Force
    }
}

