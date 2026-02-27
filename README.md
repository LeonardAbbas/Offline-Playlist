# Offline-Playlist

## Debian Installation:

```
sudo apt install ffmpeg mp3gain python3.13-venv -y
curl -fsSL https://deno.land/install.sh | sh
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
exit
```

## To Run

```
source .venv/bin/activate
python3 update.py
```

## Playlist Rules:

1. Songs should not be too long or too short (between 30s to 7min roughly)
2. No duplicate songs
3. No age restricted videos
4. Song should be the best version of that song
5. Try to add the song version of the video from Youtube Music or a channel that ends with "Topic"
6. Avoid adding Nintendo music because they keep taking them down
7. Based songs only
