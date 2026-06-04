#!/usr/bin/env python3

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).parent.parent
RELEASES_MD = REPO_ROOT / "Releases.md"
MANIFEST_JSON = REPO_ROOT / "ethos_lua_manifest.json"

CUSTOM_MARKDOWN_TEMPLATE = """

## Download ![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fgithub.com%2Fflyingeek%2F{repo_slug}%2Freleases%2Flatest%2Fdownload%2Fversion.json&query=%24.version&prefix=v&label=stable&color=darkgreen) ![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fflyingeek%2F{repo_slug}%2Frefs%2Fheads%2Fdev%2Fethos_lua_manifest.json&query=%24.version&prefix=v&label=latest)

You can download the latest version on the [latest stable release page](https://github.com/flyingeek/{repo_slug}/releases/latest), or browse all available [releases](https://github.com/flyingeek/{repo_slug}/releases).
"""
#

def infer_app_name() -> str:
    app_dirs = [p.name for p in REPO_ROOT.iterdir() if p.is_dir() and (p / "main.lua").exists()]
    if app_dirs:
        return app_dirs[0]
    return "color-value"


def repo_slug_from_app(app: str) -> str:
    if app.startswith("ethos-"):
        return app
    return f"ethos-{app}"


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
    if len(sys.argv) > 1 and sys.argv[1] in ("-h", "--help"):
        print("Usage: python3 .vscode/update-manifest.py [app]")
        print("Example: python3 .vscode/update-manifest.py color-value")
        sys.exit(0)

    app = sys.argv[1] if len(sys.argv) > 1 else infer_app_name()
    repo_slug = repo_slug_from_app(app)
    custom_markdown = CUSTOM_MARKDOWN_TEMPLATE.format(repo_slug=repo_slug)

    version, content = parse_releases(RELEASES_MD)
    if version is None:
        print("Error: could not find version in Releases.md", file=sys.stderr)
        sys.exit(1)

    with open(MANIFEST_JSON, encoding="utf-8") as f:
        manifest = json.load(f)

    manifest["version"] = version
    manifest["releaseNotes"]["content"] = content + custom_markdown

    with open(MANIFEST_JSON, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=4, ensure_ascii=False)
        f.write("\n")

    print(f"Updated manifest: version={version}, app={app}")


if __name__ == "__main__":
    main()
