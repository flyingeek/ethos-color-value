#!/usr/bin/env python3

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
RELEASES_MD = REPO_ROOT / "Releases.md"
MANIFEST_JSON = REPO_ROOT / "ethos_lua_manifest.json"

CUSTOM_MARKDOWN = """

## Download ![Dynamic JSON Badge]## Download ![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgithub.com%2Fflyingeek%2Fethos-color-value%2Freleases%2Flatest%2Fdownload%2Fversion.json&query=%24.version&prefix=v&label=stable&color=darkgreen) ![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fflyingeek%2Fethos-color-value%2Frefs%2Fheads%2Fdev%2Fethos_lua_manifest.json&query=%24.version&label=latest)

You can download the latest version on the [latest stable release page](https://github.com/flyingeek/ethos-color-value/releases/latest), or browse all available [releases](https://github.com/flyingeek/ethos-color-value/releases).
"""


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
    manifest["releaseNotes"]["content"] = content + CUSTOM_MARKDOWN

    with open(MANIFEST_JSON, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=4, ensure_ascii=False)
        f.write("\n")

    print(f"Updated manifest: version={version}")


if __name__ == "__main__":
    main()
