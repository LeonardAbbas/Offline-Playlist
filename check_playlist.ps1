# Read video titles from the text file
$videos = Get-Content -Path "videos.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

# Read all lines from DownloadedVideos.txt
$downloadedVideos = Get-Content -Path "DownloadedVideos.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

$downloadedCount = 0
$notDownloadedCount = 0
$videoNumber = 1

# Loop through each line in videos.txt
foreach ($video in $videos) {
    $escapedVideo = [regex]::Escape($video)
    $match = $downloadedVideos | Select-String -Pattern "^*mp3: $escapedVideo$" | Select-Object -First 1
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
    }

    $videoNumber++
}

Write-Output "Downloaded: $downloadedCount"
Write-Output "Not downloaded: $notDownloadedCount"
