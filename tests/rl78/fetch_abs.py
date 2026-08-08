#!/usr/bin/env python3
"""Fetch prebuilt RL78 .abs guests from Soya-Onishi/rl78-qemu-tests."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

DEFAULT_REPO = "https://github.com/Soya-Onishi/rl78-qemu-tests.git"
DEFAULT_REF = "main"
DEFAULT_REMOTE_DIR = "out/tests"


def run(cmd: list[str], **kwargs) -> None:
    subprocess.run(cmd, check=True, **kwargs)


def fetch_abs(
    dest: Path,
    *,
    repo: str = DEFAULT_REPO,
    ref: str = DEFAULT_REF,
    remote_dir: str = DEFAULT_REMOTE_DIR,
) -> list[Path]:
    dest = dest.resolve()
    dest.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="rl78-qemu-tests-") as tmp:
        clone = Path(tmp) / "repo"
        run(
            [
                "git",
                "clone",
                "--depth",
                "1",
                "--filter=blob:none",
                "--sparse",
                "--branch",
                ref,
                repo,
                str(clone),
            ]
        )
        run(["git", "-C", str(clone), "sparse-checkout", "set", remote_dir])

        src = clone / remote_dir
        if not src.is_dir():
            raise SystemExit(f"remote path missing after sparse checkout: {remote_dir}")

        abs_files = sorted(src.glob("*.abs"))
        if not abs_files:
            raise SystemExit(f"no .abs files under {remote_dir} at ref {ref}")

        for src_path in abs_files:
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
    parser.add_argument("--repo", default=DEFAULT_REPO, help="git URL of rl78-qemu-tests")
    parser.add_argument("--ref", default=DEFAULT_REF, help="branch, tag, or commit to fetch")
    parser.add_argument(
        "--remote-dir",
        default=DEFAULT_REMOTE_DIR,
        help="path inside the repo that holds *.abs (default: out/tests)",
    )
    args = parser.parse_args()

    files = fetch_abs(args.dest, repo=args.repo, ref=args.ref, remote_dir=args.remote_dir)
    print(f"fetched {len(files)} .abs file(s) into {args.dest.resolve()}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
