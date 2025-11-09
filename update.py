from glob import glob
import shutil
import subprocess
import os

from yt_dlp import YoutubeDL
from mutagen.easyid3 import EasyID3
from mutagen.mp3 import MP3

PARENT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MUSIC_DIR = os.path.join(PARENT_DIR, "Music")
MUSIC_GLOB = os.path.join(MUSIC_DIR, "*.mp3")


def main():
    while True:
        user_input = input("Do you want to unsort? (y/n): ").strip().lower()
        if user_input in ["yes", "y"]:
            user_choice = True
            break
        elif user_input in ["no", "n"]:
            user_choice = False
            break
        else:
            print("Invalid input. Please enter 'y' or 'n'.")

    if user_choice:
        print("Start unsorting")
        if not os.path.exists(MUSIC_DIR):
            os.makedirs(MUSIC_DIR)

        # Move all mp3 files not already in 'Music' into 'Music'
        for root, _, files in os.walk(PARENT_DIR):
            for file in files:
                if file.lower().endswith(".mp3"):
                    src_path = os.path.join(root, file)
                    # Skip files already in 'Music'
                    if os.path.basename(root).lower() != "music":
                        shutil.move(src_path, os.path.join(MUSIC_DIR, file))

        # Remove all empty folders in parent_dir
        for root, dirs, _ in os.walk(PARENT_DIR, topdown=False):
            for dir_name in dirs:
                dir_path = os.path.join(root, dir_name)
                if (
                    os.path.isdir(dir_path)
                    and os.path.basename(dir_path).startswith("Music ")
                    and not os.listdir(dir_path)
                ):
                    os.rmdir(dir_path)

    print("Getting offline videos")
    with open("videos_offline.txt", "w", encoding="utf-8") as out_file:
        for filename in os.listdir(MUSIC_DIR):
            if filename.lower().endswith(".mp3"):
                file_path = os.path.join(MUSIC_DIR, filename)
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

    print("Getting online videos")
    playlist = (
        "https://www.youtube.com/playlist?list=PLLrZ_MgFFAB_yF8QNecKLEmBiVfXM4L2H"
    )
    ydl_opts = {
        "extract_flat": True,
        "skip_download": True,
        "quiet": True,
    }
    with YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(playlist, download=False)
    entries = info.get("entries")
    entries = entries[::-1]
    with open("videos_online.txt", "w", encoding="utf-8") as f:
        for entry in entries:
            f.write(entry.get("id", "") + "\n")

    # Read offline and online videos
    with open("videos_offline.txt", encoding="utf-8") as f:
        videos_offline = [line.strip().split("\t") for line in f if line.strip()]
    with open("videos_online.txt", encoding="utf-8") as f:
        videos_online = [line.strip() for line in f if line.strip()]

    for video in videos_offline:
        if len(video) < 3:
            continue
        file_name, title, id_full = video
        video_id = id_full[-11:] if len(id_full) >= 11 else id_full

        matches = [
            i for i, v_id in enumerate(videos_online, start=1) if v_id == video_id
        ]

        file_path = os.path.join(MUSIC_DIR, file_name)

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
        new_path = os.path.join(MUSIC_DIR, new_name)

        os.rename(file_path, new_path)

    # Remove leading 't' from renamed files
    for fname in os.listdir(MUSIC_DIR):
        if fname.startswith("t") and fname.endswith(".mp3"):
            src = os.path.join(MUSIC_DIR, fname)
            dst = os.path.join(MUSIC_DIR, fname[1:])
            os.rename(src, dst)

    print("Downloading videos")
    # Read video IDs
    with open("videos_online.txt", "r") as f:
        video_ids = [line.strip() for line in f if line.strip()]

    num = 1
    for video_id in video_ids:
        padded_num = f"{num:04d}"
        final_path = os.path.join(f"{MUSIC_DIR}", f"{padded_num}.mp3")
        mp3_path = os.path.join(f"{MUSIC_DIR}", f"{padded_num}.%(ext)s")
        if not os.path.exists(final_path):
            print(f"Downloading {padded_num} {video_id}")

            ydl_opts = {
                "format": "bestaudio/best",
                "outtmpl": mp3_path,
                "quiet": True,
                "postprocessors": [
                    {
                        "key": "FFmpegExtractAudio",
                        "preferredcodec": "mp3",
                        "preferredquality": "192",
                    },
                    {"key": "FFmpegMetadata"},
                ],
                "embed_metadata": True,
                "encoding": "utf-8",
                "parse_metadata": "%(uploader|)s:%(meta_artist)s",
                "extractor_args": {"youtube": "lang=en"},
            }

            with YoutubeDL(ydl_opts) as ydl:
                ydl.download([video_id])
        num += 1

    if os.path.exists("videos_offline.txt"):
        os.remove("videos_offline.txt")
    if os.path.exists("videos_online.txt"):
        os.remove("videos_online.txt")

    print("Adjusting gain")
    if os.name == "posix":  # Linux or MacOS
        subprocess.run(
            ["mp3gain", "/r", "/c", "/q", *glob(MUSIC_GLOB)],
            stdout=subprocess.DEVNULL,
        )
    else:  # Windows
        subprocess.run(
            ["mp3gain", "/r", "/c", "/q", MUSIC_GLOB],
            stdout=subprocess.DEVNULL,
        )


if __name__ == "__main__":
    main()
