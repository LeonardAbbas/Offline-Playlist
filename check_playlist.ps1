$videosOffline = Get-Content -Path "videos_offline.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }
$videosOnline = Get-Content -Path "videos_online.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

foreach ($video in $videosOffline) {
    $video = $video -split "`t"

    $fileName = $video[0]

    $title = $video[1]

    $id = $video[2]
    $id = $id.Substring($id.Length - 11)

    $match = $videosOnline | Select-String -Pattern "$id"

    if (-not $match) {
        Write-Output "Not found $fileName $title $id"
        Remove-Item -Path "temp\$fileName"
        continue
    }

    if ($match.Count -gt 1) {
        Write-Output "Multiple matches for $fileName $title $id"
        Write-Output $match.LineNumber
        Remove-Item -Path "temp\$fileName"
    }
    
    $videoNumberPadded = $match.LineNumber.ToString("D4")
        
    if ($fileName -ne "$videoNumberPadded.mp3") {
        Rename-Item -Path "temp\$fileName" -NewName "t$videoNumberPadded.mp3"
    }
}

Get-ChildItem -Path "temp" -Filter "t*.mp3" | ForEach-Object {
    $newName = $_.Name.Substring(1)
    Rename-Item -Path $_.FullName -NewName $newName
}