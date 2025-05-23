$videosOffline = Get-Content "$PSScriptRoot\videos_offline.txt" -Encoding UTF8
$videosOnline = Get-Content "$PSScriptRoot\videos_online.txt"

Write-Output (Get-Item $PSScriptRoot).Parent.FullName

Set-Location -Path (Get-Item $PSScriptRoot).Parent.FullName

foreach ($video in $videosOffline) {
    $video = $video -split "`t"

    $fileName = $video[0]

    $title = $video[1]

    $id = $video[2]
    $id = $id.Substring($id.Length - 11)

    $match = $videosOnline | Select-String -Pattern "$id"

    if (-not $match) {
        Write-Output "Not found $fileName $title $id"
        Remove-Item -Path "Music\$fileName"
        continue
    }

    if ($match.Count -gt 1) {
        Write-Output "Multiple matches for $fileName $title $id"
        Write-Output $match.LineNumber
        Remove-Item -Path "Music\$fileName"
        continue
    }
    
    $matchLineNumber = $match.LineNumber
        
    if ($fileName -ne "$matchLineNumber.mp3") {
        if (Test-Path -Path "Music\t$matchLineNumber.mp3") {
            Write-Output "t$matchLineNumber.mp3 already exists"
            Remove-Item -Path "Music\$fileName"
            continue
        }
        Rename-Item -Path "Music\$fileName" -NewName "t$matchLineNumber.mp3"
    }
}

Get-ChildItem -Path "Music" -Filter "t*.mp3" | ForEach-Object {
    $newName = $_.Name.Substring(1)
    Rename-Item -Path $_.FullName -NewName $newName
}