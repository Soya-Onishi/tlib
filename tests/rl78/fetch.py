#!/usr/bin/env python3
"""Fetch prebuilt RL78 .abs guests from Soya-Onishi/rl78-qemu-tests (zip archive)."""

from __future__ import annotations

import argparse
import shutil
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path

DEFAULT_ZIP_URL = "https://github.com/Soya-Onishi/rl78-qemu-tests/archive/refs/heads/main.zip"
DEFAULT_REMOTE_DIR = "out/tests"
DEFAULT_ABS_DIR = Path("tests/rl78/out")


def fetch_abs(dest: Path = DEFAULT_ABS_DIR) -> list[Path]:
    """Clear dest, download the archive zip, and copy out/tests/*.abs into dest."""
    dest = dest.resolve()
    if dest.exists():
        shutil.rmtree(dest)
    dest.mkdir(parents=True)
    remote_dir = DEFAULT_REMOTE_DIR.strip("/")

    with tempfile.TemporaryDirectory(prefix="rl78-qemu-tests-") as tmp:
        tmp_path = Path(tmp)
        zip_path = tmp_path / "archive.zip"
        extract_root = tmp_path / "extract"

        with urllib.request.urlopen(DEFAULT_ZIP_URL) as response, zip_path.open("wb") as out:
            shutil.copyfileobj(response, out)

        with zipfile.ZipFile(zip_path) as zf:
            zf.extractall(extract_root)

        # GitHub archives unpack to <repo>-<ref>/...
        matches = sorted(extract_root.glob(f"*/{remote_dir}/*.abs"))
        if not matches:
            raise SystemExit(f"no .abs files under */{remote_dir}/ in {DEFAULT_ZIP_URL}")

        for src_path in matches:
            shutil.copy2(src_path, dest / src_path.name)

    return sorted(dest.glob("*.abs"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dest",
        type=Path,
        default=DEFAULT_ABS_DIR,
        help=f"directory to place downloaded *.abs (default: {DEFAULT_ABS_DIR})",
    )
    args = parser.parse_args()

    files = fetch_abs(args.dest)
    print(f"fetched {len(files)} .abs file(s) into {args.dest.resolve()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
