#!/usr/bin/env node

import { readFileSync, copyFileSync, unlinkSync } from 'fs';
import { execSync, spawnSync } from 'child_process';
import { createInterface } from 'readline/promises';
import { tmpdir } from 'os';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { randomBytes } from 'crypto';

const __dirname = dirname(fileURLToPath(import.meta.url));

function getPythonCmd() {
  for (const cmd of ['python3', 'python']) {
    const r = spawnSync(cmd, ['--version'], { stdio: 'pipe' });
    if (r.status === 0) return cmd;
  }
  console.error('Python not found. Please install Python 3.');
  process.exit(1);
}

async function main() {
  const app = process.argv[2];
  const releaseTag = process.argv[3] ?? '';

  if (!app) {
    console.error('Usage: node preview-manifest-and-release.mjs <app> [releaseTag]');
    process.exit(1);
  }

  // Read scriptVersion from {app}/main.lua
  let luaContent;
  try {
    luaContent = readFileSync(`${app}/main.lua`, 'utf8');
  } catch (err) {
    console.error(`Error reading ${app}/main.lua: ${err.message}`);
    process.exit(1);
  }

  const versionMatch = luaContent.match(/local scriptVersion\s*=\s*"([^"]+)"/);
  if (!versionMatch) {
    console.error('Could not find scriptVersion in main.lua');
    process.exit(1);
  }
  const gitVer = versionMatch[1];
  console.log(`scriptVersion    : ${gitVer}`);

  // Get git remote URL and parse REPO_OWNER / REPO_NAME
  const remoteUrl = execSync('git remote get-url origin', { encoding: 'utf8' }).trim();
  const repoMatch = remoteUrl.match(/github\.com[:/]([^/]+)\/([^/]+?)(?:\.git)?$/);
  if (!repoMatch) {
    console.error(`Could not parse GitHub remote URL: ${remoteUrl}`);
    process.exit(1);
  }
  const [, repoOwner, repoName] = repoMatch;
  console.log(`Repo             : ${repoOwner}/${repoName}`);

  // Copy manifest to a temp file
  const tempManifest = join(tmpdir(), `ethos_lua_manifest_${randomBytes(6).toString('hex')}.json`);
  copyFileSync('ethos_lua_manifest.json', tempManifest);

  try {
    // Run update-manifest.py against the temp file
    const pythonResult = spawnSync(getPythonCmd(), ['.github/scripts/update-manifest.py'], {
      stdio: 'inherit',
      env: {
        ...process.env,
        GIT_VER: gitVer,
        REPO_OWNER: repoOwner,
        REPO_NAME: repoName,
        RELEASES_MD: 'Releases.md',
        MANIFEST_FILE: tempManifest,
      },
    });
    if (pythonResult.status !== 0) {
      process.exit(pythonResult.status ?? 1);
    }

    // Display releaseNotes.content from the updated temp manifest
    const manifest = JSON.parse(readFileSync(tempManifest, 'utf8'));
    console.log('\n=== Preview of manifest releaseNotes.content ===\n');
    console.log(manifest.releaseNotes.content);
    console.log('=================================================\n');

    // Prompt to confirm
    const rl = createInterface({ input: process.stdin, output: process.stdout });
    let answer;
    try {
      answer = await rl.question('Continue with release? [y/N] ');
    } finally {
      rl.close();
    }

    if (answer.toLowerCase() !== 'y') {
      console.log('Aborted.');
      return;
    }

    // Proceed with the actual release
    const tagPushScript = join(__dirname, 'release-tag-and-push.mjs');
    const result = spawnSync(process.execPath, [tagPushScript, app, releaseTag], { stdio: 'inherit' });
    process.exitCode = result.status ?? 0;
  } finally {
    try { unlinkSync(tempManifest); } catch { /* already gone */ }
  }
}

main().catch((err) => {
  console.error(err.message);
  process.exit(1);
});
