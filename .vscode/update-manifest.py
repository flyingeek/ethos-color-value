#!/usr/bin/env python3

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
RELEASES_MD = REPO_ROOT / "Releases.md"
MANIFEST_JSON = REPO_ROOT / "ethos_lua_manifest.json"


def parse_releases(path):
    lines = []
    version = None
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\r\n")
            if line.startswith("---") or line.startswith("***"):
                break
            if version is None and line.startswith("# "):
                version = line[2:].strip()
            lines.append(line)
    # strip trailing blank lines
    while lines and lines[-1] == "":
        lines.pop()
    return version, "\n".join(lines)


def main():
    version, content = parse_releases(RELEASES_MD)
    if version is None:
        print("Error: could not find version in Releases.md", file=sys.stderr)
        sys.exit(1)

    with open(MANIFEST_JSON, encoding="utf-8") as f:
        manifest = json.load(f)

    manifest["version"] = version
    manifest["releaseNotes"]["content"] = content

    with open(MANIFEST_JSON, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=4, ensure_ascii=False)
        f.write("\n")

    print(f"Updated manifest: version={version}")


if __name__ == "__main__":
    main()
