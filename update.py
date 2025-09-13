import shutil
import subprocess
import os


def run_batch(filename):
    subprocess.run([filename], shell=True)


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
    subprocess.run(
        "Offline-Playlist\\exiftool -T -filename -title -purl Music\\*.mp3",
        stdout=open("Offline-Playlist\\videos_offline.txt", "w"),
    )
    os.chdir("Offline-Playlist")

    print("Getting online videos")
    subprocess.run(
        "yt-dlp PLLrZ_MgFFAB_yF8QNecKLEmBiVfXM4L2H -U --flat-playlist --print id -I ::-1",
        stdout=open("videos_online.txt", "w"),
    )

    run_powershell("check_playlist.ps1")

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
            subprocess.run(
                f"Offline-Playlist\\yt-dlp {video_id} -o {mp3_path}"
            )
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
