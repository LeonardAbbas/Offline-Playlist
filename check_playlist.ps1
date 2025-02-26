$videosOffline = Get-Content -Path "videos_offline.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }
$videosOnline = Get-Content -Path "videos_online.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

foreach ($video in $videosOffline) {
    $videoNumber = $video.Substring(0, 4)
    $videoTitle = $video.Substring(9)
    $escapedVideo = [regex]::Escape($videoTitle)
    $match = $videosOnline | Select-String -Pattern "^$escapedVideo$"
    
    if ($match.Count -gt 1) {
        $match = $match | Sort-Object { [math]::Abs($videoNumber - $_.LineNumber) } | Select-Object -First 1
    }

    if ($match) {
        $videoNumberPadded = $match.LineNumber.ToString("D4")

        if ($videoNumber -ne $videoNumberPadded) {
            if (Test-Path -Path "temp\t$videoNumber.mp3") {
                Remove-Item -Path "temp\t$videoNumber.mp3"
            }
            Rename-Item -Path "temp\$videoNumber.mp3" -NewName "t$videoNumberPadded.mp3"
        }
    }
    else {
        Write-Output "Not found $videoNumber - $videoTitle"
        Remove-Item -Path "temp\$videoNumber.mp3"
    }
}

Get-ChildItem -Path "temp" -Filter "t*.mp3" | ForEach-Object {
    $newName = $_.Name.Substring(1)
    if (Test-Path -Path "temp\$newName") {
        Remove-Item -Path "temp\$newName"
    }
    Rename-Item -Path $_.FullName -NewName $newName
}