$videosOffline = Get-Content -Path "videos_offline.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }
$videosOnline = Get-Content -Path "videos_online.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

foreach ($video in $videosOffline) {
    $videoNumber = $video.Substring(0, 4)
    $video = $video.Substring(9)
    $escapedVideo = [regex]::Escape($video)
    $match = $videosOnline | Select-String -Pattern "^$escapedVideo$"
    
    if ($match.Count -gt 1) {
        Write-Output "Multiple matches found for $videoNumber.mp3 $video"
        $match.LineNumber
        $match = $match | Sort-Object { [math]::Abs($videoNumber - $_.LineNumber) } | Select-Object -First 1
    }

    if ($match) {
        $videoNumberPadded = $match.LineNumber.ToString("D4")

        $oldName = "$videoNumber.mp3"
        $newName = "$videoNumberPadded.mp3"
        if ($oldName -ne $newName) {
            if (Test-Path -Path "temp\$newName") {
                Remove-Item -Path "temp\$newName"
            }
            Rename-Item -Path "temp\$oldName" -NewName $newName
        }
    }
    else {
        Write-Output "Not found: $video"
        Remove-Item -Path "temp\$videoNumber.mp3"
    }
}
