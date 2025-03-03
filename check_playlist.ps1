$videosOffline = Get-Content -Path "videos_offline.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }
$videosOnline = Get-Content -Path "videos_online.txt" -Encoding UTF8 | ForEach-Object { $_ -replace '!', '' }

foreach ($video in $videosOffline) {
    $video = $video -split "`t"
    $fileName = $video[0]
    $duration = $video[1]
    $title = $video[2]

    $number = $fileName.Substring(0, $fileName.Length - 4)
    if (-not [int]::TryParse($number, [ref]$null)) {
        Write-Output "Invalid number format in $fileName"
        Remove-Item -Path "temp\$fileName"
        continue
    }

    $duration = $duration.Substring(3, 4)
    if ($duration -match "(\d+):(\d{2})") {
        $duration = [int]$matches[1] * 60 + [int]$matches[2]
    }

    $escapedTitle = [regex]::Escape($title)
    $match = $videosOnline | Select-String -Pattern "^$escapedTitle$"

    if (-not $match) {
        Write-Output "Not found $fileName - $title"
        Remove-Item -Path "temp\$fileName"
        continue
    }

    if ($match.Count -gt 1) {
        $match = $match | Sort-Object { [math]::Abs($number - ($_.LineNumber + 1) / 2) } | Select-Object -First 1
    }
    
    $durationOnline = $videosOnline[$match.LineNumber]
    if ($durationOnline -match "(\d+):(\d{2})") {
        $durationOnline = [int]$matches[1] * 60 + [int]$matches[2] - 1
    }

    if ([math]::Abs($duration - $durationOnline) -gt 2) {
        Write-Output "Duration mismatch $fileName - $title"
        Remove-Item -Path "temp\$fileName"
        continue
    }
    
    $matchLineNumber = ($match.LineNumber + 1) / 2
    $videoNumberPadded = $matchLineNumber.ToString("D4")
        
    if ($number -ne $videoNumberPadded) {
        if (Test-Path -Path "temp\t$videoNumberPadded.mp3") {
            Remove-Item -Path "temp\t$videoNumberPadded.mp3"
        }
        Rename-Item -Path "temp\$fileName" -NewName "t$videoNumberPadded.mp3"
    }
}

Get-ChildItem -Path "temp" -Filter "t*.mp3" | ForEach-Object {
    $newName = $_.Name.Substring(1)
    if (Test-Path -Path "temp\$newName") {
        Remove-Item -Path "temp\$newName"
    }
    Rename-Item -Path $_.FullName -NewName $newName
}