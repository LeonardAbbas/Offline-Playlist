$videosOfflineChannels = Get-Content -Path "videos_offline_channels.txt" -Encoding UTF8 | ForEach-Object { $_.TrimEnd() -replace '!', '' }
$videosOffline = Get-Content -Path "videos_offline.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }
$videosOnlineChannels = Get-Content -Path "videos_online_channels.txt" -Encoding UTF8 | ForEach-Object { $_.TrimEnd() -replace '!', '' }
$videosOnline = Get-Content -Path "videos_online.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

$mismatches = 0

foreach ($video in $videosOffline) {
    $videoNumber = $video.Substring(0, 4)
    $videoTitle = $video.Substring(9)
    $escapedVideo = [regex]::Escape($videoTitle)
    $match = $videosOnline | Select-String -Pattern "^$escapedVideo$"
    
    if ($match.Count -gt 1) {
        $match.LineNumber
        $match = $match | Sort-Object { [math]::Abs($videoNumber - $_.LineNumber) } | Select-Object -First 1
    }

    if ($match) {
        $videoOfflineIndex = [array]::IndexOf($videosOffline, $video)
        $videoOnlineIndex = [array]::IndexOf($videosOnline, $match.Line)

        $offlineAuthor = ($videosOfflineChannels)[$videoOfflineIndex]
        $onlineAuthor = ($videosOnlineChannels)[$videoOnlineIndex]
        if ($offlineAuthor -ne $onlineAuthor) {
            Write-Output "$offlineAuthor, $onlineAuthor mismatch for $videoNumber.mp3 $videoTitle"
            Remove-Item -Path "temp\$videoNumber.mp3"
            $mismatches++
        }
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
        Write-Output "Not found: $videoTitle"
        $mismatches++
        Remove-Item -Path "temp\$videoNumber.mp3"
    }
}

Write-Output "Mismatches: $mismatches"