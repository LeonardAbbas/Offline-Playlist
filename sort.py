import os
import shutil


PARENT_DIR = os.path.abspath(os.path.join(os.getcwd(), ".."))
MUSIC_DIR = os.path.join(PARENT_DIR, "Music")

def main():
    print("Start sorting")

    # Collect all mp3 files recursively
    mp3_files = []
    for root, _, files in os.walk(PARENT_DIR):
        for file in files:
            if file.lower().endswith(".mp3"):
                mp3_files.append(os.path.join(root, file))

    for mp3_file in mp3_files:
        name = os.path.splitext(os.path.basename(mp3_file))[0]
        name_no_zeros = name.lstrip("0")
        try:
            name_num = int(name_no_zeros)
        except ValueError:
            name_num = 1  # Default to folder 1 if not a number

        folder_num = 1
        end = 256
        while name_num > end:
            end += 256
            folder_num += 1

        folder_name = f"Music {folder_num}"
        folder_path = os.path.join(PARENT_DIR, folder_name)

        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
        shutil.move(mp3_file, os.path.join(folder_path, os.path.basename(mp3_file)))

    # Remove the original Music directory
    if os.path.exists(MUSIC_DIR):
        shutil.rmtree(MUSIC_DIR, ignore_errors=True)


if __name__ == "__main__":
    main()
