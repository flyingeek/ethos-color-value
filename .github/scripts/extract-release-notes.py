#!/usr/bin/python3

import os
import sys

def main():
    release = os.environ["GIT_VER"]
    release_type = os.environ["GH_TYPE"]
    inputfile = os.environ["RELEASES_MD"]

    found = False
    delimiter = '***' if release_type == 'Release' else '---'

    with open(inputfile) as input:
        lines = []
        for line in input:
            line = line.rstrip("\r\n")
            if line.startswith('# '):
                found = True
                line = '# ' + release
            elif line.startswith(delimiter):
                break
            elif found:
                lines.append(line)
    # strip trailing blank lines
    while lines and lines[-1] == "":
        lines.pop()
    # output the release notes to stdout
    sys.stdout.write("\n".join(lines) + "\n")


if __name__ == '__main__': main()
