import json
import shutil
import struct
import sys
from pathlib import Path


def read_message():
    raw_length = sys.stdin.buffer.read(4)

    if len(raw_length) == 0:
        return None

    if len(raw_length) != 4:
        raise RuntimeError("メッセージ長を読み取れませんでした")

    message_length = struct.unpack("<I", raw_length)[0]
    message_bytes = sys.stdin.buffer.read(message_length)

    if len(message_bytes) != message_length:
        raise RuntimeError("メッセージ本体を読み取れませんでした")

    return json.loads(message_bytes.decode("utf-8"))


def send_message(message):
    encoded = json.dumps(
        message,
        ensure_ascii=False
    ).encode("utf-8")

    sys.stdout.buffer.write(struct.pack("<I", len(encoded)))
    sys.stdout.buffer.write(encoded)
    sys.stdout.buffer.flush()


def create_unique_path(destination):
    if not destination.exists():
        return destination

    stem = destination.stem
    suffix = destination.suffix
    parent = destination.parent
    number = 1

    while True:
        candidate = parent / f"{stem} ({number}){suffix}"

        if not candidate.exists():
            return candidate

        number += 1


def move_file(source_path, destination_folder):
    source = Path(source_path)
    folder = Path(destination_folder)

    if not source.exists():
        raise FileNotFoundError(f"移動元ファイルがありません: {source}")

    if not source.is_file():
        raise ValueError(f"移動元がファイルではありません: {source}")

    folder.mkdir(parents=True, exist_ok=True)

    destination = create_unique_path(folder / source.name)
    shutil.move(str(source), str(destination))

    return str(destination)


def main():
    message = read_message()

    if message is None:
        return

    action = message.get("action")

    if action == "connection_test":
        send_message({
            "success": True,
            "message": "Pythonとの通信に成功しました"
        })
        return

    if action == "move_file":
        moved_path = move_file(
            message["sourcePath"],
            message["destination"]
        )

        send_message({
            "success": True,
            "message": "ファイルを移動しました",
            "movedPath": moved_path
        })
        return

    send_message({
        "success": False,
        "error": f"不明なactionです: {action}"
    })


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        send_message({
            "success": False,
            "error": str(error)
        })