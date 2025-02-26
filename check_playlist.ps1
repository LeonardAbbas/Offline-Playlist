$videosOffline = Get-Content -Path "videos_offline.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }
$videosOnline = Get-Content -Path "videos_online.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

foreach ($video in $videosOffline) {
    $number = $video.Substring(0, 4)
    $duration = $video.Substring(12, 4)
    if ($duration -match "(\d+):(\d{2})") {
        $duration = [int]$matches[1] * 60 + [int]$matches[2]
    }

    $title = $video.Substring(26)
    $escapedVideo = [regex]::Escape($title)
    $match = $videosOnline | Select-String -Pattern "^$escapedVideo$"
    
    if ($match.Count -gt 1) {
        $match = $match | Sort-Object { [math]::Abs($number - ($_.LineNumber + 1) / 2) } | Select-Object -First 1
    }

    if ($match) {
        $durationOnline = $videosOnline[$match.LineNumber]
        if ($durationOnline -match "(\d+):(\d{2})") {
            $durationOnline = [int]$matches[1] * 60 + [int]$matches[2] - 1
        }
        if ([math]::Abs($duration - $durationOnline) -le 2) {
            $matchLineNumber = ($match.LineNumber + 1) / 2
            $videoNumberPadded = $matchLineNumber.ToString("D4")
        
            if ($number -ne $videoNumberPadded) {
            if (Test-Path -Path "temp\t$number.mp3") {
                Remove-Item -Path "temp\t$number.mp3"
            }
            Rename-Item -Path "temp\$number.mp3" -NewName "t$videoNumberPadded.mp3"
            }
        }
        else {
            Write-Output "Duration mismatch $number - $title"
            Remove-Item -Path "temp\$number.mp3"
        }
        
    }
    else {
        Write-Output "Not found $number - $title"
        Remove-Item -Path "temp\$number.mp3"
    }
}

Get-ChildItem -Path "temp" -Filter "t*.mp3" | ForEach-Object {
    $newName = $_.Name.Substring(1)
    if (Test-Path -Path "temp\$newName") {
        Remove-Item -Path "temp\$newName"
    }
    Rename-Item -Path $_.FullName -NewName $newName
}