#!/usr/bin/env python3
"""
analyse_log.py — Parse Ethos malloc debug output and report memory usage.

Usage:
    python3 analyse_log.py [options] [logfile]

Arguments:
    logfile         Path to the log file (default: ./Ethos Logs.log)

Options:
    -s, --sort      Sort output by value ascending (lowest first)
    -r, --reverse   Sort output by value descending (highest first)
    -a, --absolute  Show raw total bytes instead of diff from baseline
    -S, --summary   Show summary statistics only
    --all-sessions  Include all sessions (default: last session only)
    -h, --help      Show this help message and exit
"""

import re
import argparse

UINT32 = 4294967296
PATTERN = re.compile(r'\[info\]\s+(\d+)\s+(?:ALLOC|FREE).*total=(\d+)')


def parse_log(log_file):
    """Return list of sessions. Each session is a list of (frame, total) in chronological order."""
    sessions = []
    current = []
    prev_frame = None

    with open(log_file) as f:
        for line in f:
            m = PATTERN.search(line)
            if m:
                frame = int(m.group(1))
                total = int(m.group(2))
                # Detect session restart: frame counter reset to near 0
                if prev_frame is not None and frame < prev_frame - 10000:
                    if current:
                        sessions.append(current)
                    current = []
                if not current or current[-1][0] != frame:
                    current.append((frame, total))
                prev_frame = frame

    if current:
        sessions.append(current)
    return sessions


def to_signed_diff(diff):
    while diff >  2147483647: diff -= UINT32
    while diff < -2147483648: diff += UINT32
    return diff


def analyze(frames):
    sorted_frames = sorted(frames, key=lambda x: x[0])
    base_frame, base_total = sorted_frames[0]
    diffs = [to_signed_diff(total - base_total) for _, total in sorted_frames]
    return sorted_frames, base_frame, base_total, diffs


def main():
    parser = argparse.ArgumentParser(
        description="Parse Ethos malloc debug output and report memory usage.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=(
            "Examples:\n"
            "  python3 analyse_log.py                  # diff from baseline, last session\n"
            "  python3 analyse_log.py --summary        # summary stats only\n"
            "  python3 analyse_log.py --absolute       # raw bytes per frame\n"
            "  python3 analyse_log.py --all-sessions   # include all sessions\n"
            "  python3 analyse_log.py --sort           # diff, sorted ascending\n"
        )
    )
    parser.add_argument("logfile", nargs="?", default="./Ethos Logs.log",
                        help="path to the log file (default: './Ethos Logs.log')")
    sort_group = parser.add_mutually_exclusive_group()
    sort_group.add_argument("-s", "--sort", action="store_true",
                            help="sort by value ascending (lowest first)")
    sort_group.add_argument("-r", "--reverse", action="store_true",
                            help="sort by value descending (highest first)")
    parser.add_argument("-a", "--absolute", action="store_true",
                        help="show raw total bytes instead of diff from baseline")
    parser.add_argument("-S", "--summary", action="store_true",
                        help="show summary statistics only")
    parser.add_argument("--all-sessions", action="store_true",
                        help="include all sessions (default: last session only)")
    args = parser.parse_args()

    sessions = parse_log(args.logfile)
    if not sessions:
        print("No ALLOC/FREE entries found.")
        return

    if not args.all_sessions:
        sessions = [sessions[-1]]

    for idx, session_frames in enumerate(sessions):
        sorted_frames, base_frame, base_total, diffs = analyze(session_frames)
        last_frame, last_total = sorted_frames[-1]
        last_diff = to_signed_diff(last_total - base_total)

        if len(sessions) > 1:
            print(f"\n--- Session {idx + 1} ---")

        if args.summary:
            print(f"Frames recorded : {len(sorted_frames)}")
            print(f"Baseline frame  : {base_frame}  ({base_total:,} bytes absolute)")
            print(f"Last frame      : {last_frame}  ({last_diff:+,} bytes from baseline)")
            print(f"Peak above base : {max(diffs):+,} bytes")
            print(f"Peak below base : {min(diffs):+,} bytes  (GC low-water mark)")
            trend = last_diff - diffs[0]
            print(f"Trend           : {trend:+,} bytes  ({'growing' if trend > 1024 else 'stable/shrinking'})")
            continue

        if args.absolute:
            results = sorted_frames
            header  = f"{'frame':>8}  {'total_bytes':>12}"
            fmt     = lambda f, v: f"{f:8d}  {v:12,}"
        else:
            results = [(f, d) for (f, _), d in zip(sorted_frames, diffs)]
            header  = f"{'frame':>8}  {'diff_bytes':>12}  (baseline: frame {base_frame}, {base_total:,} bytes)"
            fmt     = lambda f, v: f"{f:8d}  {v:+12,}"

        if args.sort:
            results.sort(key=lambda x: x[1])
        elif args.reverse:
            results.sort(key=lambda x: x[1], reverse=True)

        print(header)
        for frame, value in results:
            print(fmt(frame, value))


if __name__ == "__main__":
    main()
