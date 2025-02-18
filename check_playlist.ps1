$videosOffline = Get-Content -Path "videos_offline.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }
$videosOnline = Get-Content -Path "videos_online.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

$downloadedCount = 0
$notDownloadedCount = 0
$videoNumber = 1

# Loop through each line in videosOnline.txt
foreach ($video in $videosOnline) {
    $escapedVideo = [regex]::Escape($video)
    $match = $videosOffline | Select-String -Pattern "^*mp3.$escapedVideo$"
    
    if ($match.Count -gt 1) {
        Write-Output "Multiple matches found for $video"
        $match.LineNumber
        $match = $match | Sort-Object { [math]::Abs([int]($_.Line.Substring(0, 4)) - $videoNumber) } | Select-Object -First 1
    }

    if ($match) {
        $downloadedCount++
        $videoNumberPadded = $videoNumber.ToString("D4")

        $oldName = "$($match.Line.Substring(0, 4)).mp3"
        $newName = "$videoNumberPadded.mp3"
        if ($oldName -ne $newName) {
            if (Test-Path -Path "temp\$newName") {
                Remove-Item -Path "temp\$newName"
            }
            Rename-Item -Path "temp\$oldName" -NewName $newName
        }
    }
    else {
        $notDownloadedCount++
        Write-Output "Not found: $video"
    }

    $videoNumber++
}

Write-Output "Downloaded: $downloadedCount"
Write-Output "Not downloaded: $notDownloadedCount"
