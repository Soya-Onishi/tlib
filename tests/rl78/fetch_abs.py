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


def fetch_abs(
    dest: Path,
    *,
    zip_url: str = DEFAULT_ZIP_URL,
    remote_dir: str = DEFAULT_REMOTE_DIR,
) -> list[Path]:
    dest = dest.resolve()
    dest.mkdir(parents=True, exist_ok=True)
    remote_dir = remote_dir.strip("/")

    with tempfile.TemporaryDirectory(prefix="rl78-qemu-tests-") as tmp:
        tmp_path = Path(tmp)
        zip_path = tmp_path / "archive.zip"
        extract_root = tmp_path / "extract"

        with urllib.request.urlopen(zip_url) as response, zip_path.open("wb") as out:
            shutil.copyfileobj(response, out)

        with zipfile.ZipFile(zip_path) as zf:
            zf.extractall(extract_root)

        # GitHub archives unpack to <repo>-<ref>/...
        matches = sorted(extract_root.glob(f"*/{remote_dir}/*.abs"))
        if not matches:
            raise SystemExit(f"no .abs files under */{remote_dir}/ in {zip_url}")

        for src_path in matches:
            shutil.copy2(src_path, dest / src_path.name)

    return sorted(dest.glob("*.abs"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dest",
        type=Path,
        default=Path("tests/rl78/out"),
        help="directory to place downloaded *.abs (default: tests/rl78/out)",
    )
    parser.add_argument(
        "--url",
        default=DEFAULT_ZIP_URL,
        help=f"zip archive URL (default: {DEFAULT_ZIP_URL})",
    )
    parser.add_argument(
        "--remote-dir",
        default=DEFAULT_REMOTE_DIR,
        help="path inside the archive that holds *.abs (default: out/tests)",
    )
    args = parser.parse_args()

    files = fetch_abs(args.dest, zip_url=args.url, remote_dir=args.remote_dir)
    print(f"fetched {len(files)} .abs file(s) into {args.dest.resolve()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
