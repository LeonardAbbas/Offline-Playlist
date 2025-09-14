import shutil
import subprocess
import os
import sys

try:
    from mutagen.easyid3 import EasyID3
    from mutagen.mp3 import MP3
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "mutagen"])
    from mutagen.easyid3 import EasyID3
    from mutagen.mp3 import MP3


def run_powershell(script):
    subprocess.run(["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", script])


def main():
    print("Start unsorting")
    parent_dir = os.path.abspath(os.path.join(os.getcwd(), ".."))
    music_dir = os.path.join(parent_dir, "Music")

    if not os.path.exists(music_dir):
        os.makedirs(music_dir)

    # Move all mp3 files not already in 'Music' into 'Music'
    for root, _, files in os.walk(parent_dir):
        for file in files:
            if file.lower().endswith(".mp3"):
                src_path = os.path.join(root, file)
                # Skip files already in 'Music'
                if os.path.basename(root).lower() != "music":
                    shutil.move(src_path, os.path.join(music_dir, file))

    # Remove all empty folders in parent_dir
    for root, dirs, _ in os.walk(parent_dir, topdown=False):
        for dir_name in dirs:
            dir_path = os.path.join(root, dir_name)
            if os.path.isdir(dir_path) and not os.listdir(dir_path):
                os.rmdir(dir_path)

    print("Getting offline videos")
    os.chdir("..")

    output_path = os.path.join("Offline-Playlist", "videos_offline.txt")
    music_dir = "Music"

    with open(output_path, "w", encoding="utf-8") as out_file:
        for filename in os.listdir(music_dir):
            if filename.lower().endswith(".mp3"):
                file_path = os.path.join(music_dir, filename)
                try:
                    audio = MP3(file_path, ID3=EasyID3)
                    title = audio.get("title", [""])[0]
                    # 'purl' is not a standard ID3 tag; try to read it from TXXX frame
                    from mutagen.id3 import ID3, TXXX

                    id3 = ID3(file_path)
                    purl = ""
                    for frame in id3.getall("TXXX"):
                        if frame.desc.lower() == "purl":
                            purl = frame.text[0] if frame.text else ""
                            break
                    out_file.write(f"{filename}\t{title}\t{purl}\n")
                except Exception:
                    out_file.write(f"{filename}\t\t\n")

    os.chdir("Offline-Playlist")

    print("Getting online videos")
    subprocess.run(
        "yt-dlp PLLrZ_MgFFAB_yF8QNecKLEmBiVfXM4L2H -U --flat-playlist --print id -I ::-1",
        stdout=open("videos_online.txt", "w"),
    )

    script_dir = os.path.dirname(os.path.abspath(__file__))
    parent_dir = os.path.abspath(os.path.join(script_dir, ".."))
    music_dir = os.path.join(parent_dir, "Music")

    # Read offline and online videos
    with open(os.path.join(script_dir, "videos_offline.txt"), encoding="utf-8") as f:
        videos_offline = [line.strip().split('\t') for line in f if line.strip()]
    with open(os.path.join(script_dir, "videos_online.txt"), encoding="utf-8") as f:
        videos_online = [line.strip() for line in f if line.strip()]

    # Build a lookup for online IDs
    online_id_to_index = {id: idx for idx, id in enumerate(videos_online, start=1)}

    for video in videos_offline:
        if len(video) < 3:
            continue
        file_name, title, id_full = video
        video_id = id_full[-11:] if len(id_full) >= 11 else id_full

        matches = [i for i, v_id in enumerate(videos_online, start=1) if v_id == video_id]

        file_path = os.path.join(music_dir, file_name)

        if not matches:
            print(f"Not found {file_name} {title} {video_id}")
            if os.path.exists(file_path):
                os.remove(file_path)
            continue

        if len(matches) > 1:
            print(f"Multiple matches for {file_name} {title} {video_id}")
            print(matches)
            if os.path.exists(file_path):
                os.remove(file_path)
            continue

        match_line_number = f"{matches[0]:04d}"
        new_name = f"t{match_line_number}.mp3"
        new_path = os.path.join(music_dir, new_name)

        if file_name != f"{match_line_number}.mp3":
            if os.path.exists(new_path):
                print(f"{new_name} already exists")
                if os.path.exists(file_path):
                    os.remove(file_path)
                continue
            if os.path.exists(file_path):
                os.rename(file_path, new_path)

    # Remove leading 't' from renamed files
    for fname in os.listdir(music_dir):
        if fname.startswith("t") and fname.endswith(".mp3"):
            src = os.path.join(music_dir, fname)
            dst = os.path.join(music_dir, fname[1:])
            os.rename(src, dst)

    print("Downloading videos")
    parent_dir = os.path.abspath(os.path.join(os.getcwd(), ".."))
    os.chdir(parent_dir)

    # Read video IDs
    with open("Offline-Playlist\\videos_online.txt", "r") as f:
        video_ids = [line.strip() for line in f if line.strip()]

    num = 1
    for video_id in video_ids:
        padded_num = f"{num:04d}"
        mp3_path = os.path.join("Music", f"{padded_num}.mp3")
        if not os.path.exists(mp3_path):
            print(f"Downloading {padded_num} {video_id}")
            subprocess.run(f"Offline-Playlist\\yt-dlp {video_id} -o {mp3_path}")
        num += 1

    offline_txt_path = os.path.join("Offline-Playlist", "videos_offline.txt")
    online_txt_path = os.path.join("Offline-Playlist", "videos_online.txt")
    if os.path.exists(offline_txt_path):
        os.remove(offline_txt_path)
    if os.path.exists(online_txt_path):
        os.remove(online_txt_path)

    print("Adjusting gain")
    subprocess.run(
        "Offline-Playlist\\mp3gain /r /c /q Music\\*.mp3",
        stdout=subprocess.DEVNULL,
    )


if __name__ == "__main__":
    main()
