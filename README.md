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

## Arch Installation:

Required packages `deno` `ffmpeg`, `git`, `mp3gain`(AUR), `python`, and `unzip`.
```
sudo pacman -Syu ffmpeg git python unzip
yay -Syu mp3gain
curl -fsSL https://deno.land/install.sh | sh
exit
```
### Installation
```
git clone https://github.com/LeonardAbbas/Offline-Playlist.git
cd Offline-Playlist/
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## To Update
```
git pull
source .venv/bin/activate
pip install --upgrade -r requirements.txt
```

## To Run

### Debian
```
source .venv/bin/activate
python3 update.py
```

### Arch
```
source .venv/bin/activate
python update.py
```

## Playlist Rules:

1. Songs should not be too long or too short (between 30s to 7min roughly)
2. No duplicate songs
3. No age restricted videos
4. Song should be the best version of that song
5. If the song is on YouTube Music it should be added from there because the metadata and audio quality will be better
6. Avoid adding Nintendo music because they keep taking them down
7. Based songs only
