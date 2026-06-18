#!/usr/bin/env python3

import json
import os
from urllib.parse import quote

CUSTOM_MARKDOWN_TEMPLATE = """

## Download ![Release](https://img.shields.io/endpoint?url={url_release}) ![Preview](https://img.shields.io/endpoint?url={url_preview})

You can download the latest version on the [latest stable release page](https://github.com/{repo_owner}/{repo_slug}/releases/latest), or browse all available [releases and previews](https://github.com/{repo_owner}/{repo_slug}/releases).
"""


def main():
    git_ver = os.environ["GIT_VER"]
    repo_name = os.environ["REPO_NAME"]
    repo_owner = os.environ["REPO_OWNER"]
    manifest_json = os.environ["MANIFEST_FILE"]
    releases_md = os.environ["RELEASES_MD"]

    url_release = quote(f"https://{repo_owner}.github.io/{repo_name}/release.json", safe='')
    url_preview = quote(f"https://{repo_owner}.github.io/{repo_name}/preview.json", safe='')
    custom_markdown = CUSTOM_MARKDOWN_TEMPLATE.format(
        repo_owner=repo_owner,
        repo_slug=repo_name,
        url_release=url_release,
        url_preview=url_preview,
    )

    lines = []
    with open(releases_md, encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\r\n")
            if line.startswith("---") or line.startswith("***"):
                break
            if line.startswith("# "):
                line = f"# {git_ver}"
            lines.append(line)

    # strip trailing blank lines
    while lines and lines[-1] == "":
        lines.pop()

    content = "\n".join(lines) + custom_markdown

    with open(manifest_json, encoding="utf-8") as f:
        manifest = json.load(f)

    manifest["version"] = git_ver
    manifest["releaseNotes"]["content"] = content

    with open(manifest_json, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=4, ensure_ascii=False)
        f.write("\n")

    print(f"Updated manifest: version={git_ver}, repo={repo_name}")


if __name__ == "__main__":
    main()
