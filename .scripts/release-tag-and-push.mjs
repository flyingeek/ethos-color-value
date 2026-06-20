#!/usr/bin/env node

import { readFileSync } from 'fs';
import { execSync, spawnSync } from 'child_process';

const app = process.argv[2];
const tagInput = process.argv[3] ?? 'release/<scriptVersion>';

if (!app) {
  console.error('Usage: node release-tag-and-push.mjs <app> [releaseTag]');
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
const scriptVersion = versionMatch[1];
console.log(`scriptVersion    : ${scriptVersion}`);

// Check git working tree is clean
const gitStatus = execSync('git status --porcelain', { encoding: 'utf8' });
if (gitStatus.trim()) {
  console.error('Git working tree is not clean. Please commit or stash changes before running this script.');
  process.stderr.write(execSync('git status --short', { encoding: 'utf8' }));
  process.exit(1);
}

// Determine tag
const tag = (!tagInput.trim() || tagInput === 'release/<scriptVersion>')
  ? `release/${scriptVersion}`
  : tagInput.trim();

if (!tag) {
  console.error('Tag cannot be empty');
  process.exit(1);
}

// Check tag doesn't already exist locally
const checkResult = spawnSync('git', ['rev-parse', '-q', '--verify', `refs/tags/${tag}`], { stdio: 'pipe' });
if (checkResult.status === 0) {
  console.error(`Tag "${tag}" already exists locally`);
  console.error(`to delete: git tag -d "${tag}" && git push --delete origin "${tag}"`);
  process.exit(1);
}

// Create and push tag
console.log(`Creating tag "${tag}" for version "${scriptVersion}"...`);
const tagResult = spawnSync('git', ['tag', tag], { stdio: 'inherit' });
if (tagResult.status !== 0) process.exit(tagResult.status ?? 1);

const pushResult = spawnSync('git', ['push', 'origin', tag], { stdio: 'inherit' });
if (pushResult.status !== 0) process.exit(pushResult.status ?? 1);

console.log(`Pushed tag "${tag}" to origin`);
