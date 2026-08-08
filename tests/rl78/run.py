#!/usr/bin/env python3
"""Run RL78 guest .abs images on the tlib instruction-test harness."""

from __future__ import annotations

import argparse
import glob
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Optional

RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RESET = "\033[0m"

REPORT_RE = re.compile(
    r"status=(?P<status>\d+)\s+"
    r"test_id=(?P<test_id>\d+)\s+"
    r"assert_id=(?P<assert_id>\d+)\s+"
    r"expect=0x(?P<expect>[0-9a-fA-F]+)\s+"
    r"actual=0x(?P<actual>[0-9a-fA-F]+)\s+"
    r"ignored=(?P<ignored>\d+)"
)

DEFAULT_ABS_DIR = Path("tests/rl78/out")


@dataclass
class TestResult:
    path: Path
    exit_code: int
    status: Optional[int] = None
    test_id: Optional[int] = None
    assert_id: Optional[int] = None
    expect: Optional[int] = None
    actual: Optional[int] = None
    ignored: Optional[int] = None
    stderr: str = ""

    def show(self) -> str:
        if self.exit_code == 0 and self.status == 0:
            if self.ignored:
                return f"{YELLOW}PASS{RESET}[{self.ignored} tests ignored]"
            return f"{GREEN}PASS{RESET}"
        if self.exit_code == 1 or (self.status is not None and self.status != 0):
            return (
                f"{RED}FAIL{RESET}[test: {self.test_id} assert: {self.assert_id}] "
                f"expect: 0x{(self.expect or 0):04x} != actual: 0x{(self.actual or 0):04x}"
            )
        return f"{RED}ERROR{RESET}[exit={self.exit_code}]"


def find_harness(explicit: Optional[Path]) -> Path:
    if explicit is not None:
        return explicit
    env = os.environ.get("TLIB_HARNESS")
    if env:
        return Path(env)
    candidates = [
        Path("build/tlib-harness"),
        Path("../build/tlib-harness"),
        Path("../../build/tlib-harness"),
    ]
    for cand in candidates:
        if cand.is_file():
            return cand
    raise SystemExit("tlib-harness not found; pass --harness or set TLIB_HARNESS")


def collect_abs(abs_dir: Path, pattern: str = "*.abs") -> List[Path]:
    files = sorted(Path(p) for p in glob.glob(str(abs_dir / "**" / pattern), recursive=True))
    if not files:
        raise SystemExit(f"no files matching {pattern!r} under {abs_dir} (run tests/rl78/fetch.py first)")
    return files


def run_one(harness: Path, abs_path: Path, max_insns: Optional[int]) -> TestResult:
    cmd = [str(harness), str(abs_path)]
    if max_insns is not None:
        cmd.extend(["--max-insns", str(max_insns)])
    proc = subprocess.run(cmd, capture_output=True, text=True)
    stderr = proc.stderr or ""
    result = TestResult(path=abs_path, exit_code=proc.returncode, stderr=stderr)
    match = REPORT_RE.search(stderr)
    if match:
        result.status = int(match.group("status"))
        result.test_id = int(match.group("test_id"))
        result.assert_id = int(match.group("assert_id"))
        result.expect = int(match.group("expect"), 16)
        result.actual = int(match.group("actual"), 16)
        result.ignored = int(match.group("ignored"))
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--abs-dir",
        type=Path,
        default=DEFAULT_ABS_DIR,
        help=f"directory containing *.abs guests (default: {DEFAULT_ABS_DIR})",
    )
    parser.add_argument(
        "--glob",
        dest="glob_pattern",
        default="*.abs",
        help="glob for guest images under --abs-dir (default: *.abs)",
    )
    parser.add_argument("--harness", type=Path, default=None, help="path to tlib-harness")
    parser.add_argument("--max-insns", type=int, default=None, help="per-guest instruction limit")
    args = parser.parse_args()

    harness = find_harness(args.harness)
    abs_files = collect_abs(args.abs_dir, args.glob_pattern)

    failures = 0
    for abs_path in abs_files:
        result = run_one(harness, abs_path, args.max_insns)
        print(f"{result.path}: {result.show()}")
        if result.exit_code != 0:
            failures += 1
            if result.stderr and result.status is None:
                sys.stderr.write(result.stderr)
                if not result.stderr.endswith("\n"):
                    sys.stderr.write("\n")

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
