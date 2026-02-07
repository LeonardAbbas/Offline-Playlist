# Offline-Playlist

## Windows Setup:

Install yt-dlp release of ffmpeg and copy ffmpeg.exe, ffplay.exe, and ffprobe.exe into "Offline-Playlist" folder. Download mp3gain.exe and copy into "Offline-Playlist" folder also.

## Linux Setup:

1. Install ffmpeg, mp3gain, and deno.

```
sudo apt install ffmpeg mp3gain -y
curl -fsSL https://deno.land/install.sh | sh
```

2. Set up the virtual environment inside Visual Studio Code.

```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Playlist Rules:

1. Songs should not be too long or too short (between 30s to 7min roughly)
2. No duplicate songs
3. No age restricted videos
4. Song should be the best version of that song
5. Try to add the song version of the video from Youtube Music or a channel that ends with "Topic"
6. Avoid adding Nintendo music because they keep taking them down
7. Based songs only
