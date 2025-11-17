#!/usr/bin/env node
/* eslint-disable no-console */

const fs = require('fs');
const path = require('path');

const argv = process.argv.slice(2);

const toList = (value) => {
  if (!value) return [];
  return String(value)
    .split(',')
    .map((segment) => segment.trim())
    .filter(Boolean);
};

const getArg = (flag) => {
  const index = argv.findIndex((arg) => arg === flag || arg.startsWith(`${flag}=`));
  if (index === -1) return undefined;

  if (argv[index].includes('=')) {
    return argv[index].split('=').slice(1).join('=');
  }

  const next = argv[index + 1];
  if (!next || next.startsWith('--')) return '';
  return next;
};

const boolFrom = (value, defaultValue) => {
  if (value === undefined) return defaultValue;
  const normalized = String(value).toLowerCase();
  if (['false', '0', 'no', 'off'].includes(normalized)) return false;
  if (['true', '1', 'yes', 'on'].includes(normalized)) return true;
  return defaultValue;
};

const numberFrom = (value, defaultValue) => {
  if (value === undefined) return defaultValue;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : defaultValue;
};

const baseUrl =
  process.env.VISUAL_VERIFY_BASE_URL || getArg('--base-url') || 'http://localhost:3000';
const urls = toList(process.env.VISUAL_VERIFY_URLS || getArg('--urls'));
if (urls.length === 0) {
  urls.push('/');
}

const outputDir = path.resolve(
  process.env.VISUAL_VERIFY_OUTPUT_DIR || getArg('--out-dir') || path.join('tmp', 'visual-verification'),
);
const width = numberFrom(process.env.VISUAL_VERIFY_WIDTH || getArg('--width'), 1280);
const height = numberFrom(process.env.VISUAL_VERIFY_HEIGHT || getArg('--height'), 720);
const waitMs = numberFrom(process.env.VISUAL_VERIFY_WAIT_MS || getArg('--wait-ms'), 500);
const fullPage = boolFrom(process.env.VISUAL_VERIFY_FULL_PAGE || getArg('--full-page'), true);
const headless = boolFrom(process.env.VISUAL_VERIFY_HEADLESS || getArg('--headless'), true);

const chromiumArgsRaw = process.env.VISUAL_VERIFY_CHROMIUM_ARGS || getArg('--chromium-args');
const chromiumArgs = chromiumArgsRaw
  ? chromiumArgsRaw.split(/\s+/).filter(Boolean)
  : ['--no-sandbox', '--disable-setuid-sandbox'];

const slugify = (input) => {
  const normalized = input.replace(/[^a-z0-9]+/gi, '-').replace(/^-+|-+$/g, '');
  return normalized || 'root';
};

const describeTarget = () => {
  console.log('Visual verification configuration:');
  console.log(`  Base URL: ${baseUrl}`);
  console.log(`  Target paths: ${urls.join(', ')}`);
  console.log(`  Output directory: ${outputDir}`);
  console.log(`  Viewport: ${width}x${height}`);
  console.log(`  Wait after load: ${waitMs}ms`);
  console.log(`  Full page screenshots: ${fullPage}`);
  console.log(`  Headless mode: ${headless}`);
  console.log(`  Chromium args: ${chromiumArgs.join(' ')}`);
};

const buildUrl = (targetPath) => {
  try {
    return new URL(targetPath, baseUrl).toString();
  } catch (error) {
    throw new Error(`Invalid URL segment "${targetPath}": ${error.message}`);
  }
};

const captureScreenshot = async (browser, targetPath, index) => {
  const url = buildUrl(targetPath);
  const page = await browser.newPage();
  await page.setViewport({ width, height, deviceScaleFactor: 1 });

  const safeName = `${String(index + 1).padStart(2, '0')}-${slugify(targetPath)}`;
  const filePath = path.join(outputDir, `${safeName}.png`);

  console.log(`Navigating to ${url}`);
  await page.goto(url, { waitUntil: 'networkidle0', timeout: 60_000 });

  if (waitMs > 0) {
    await new Promise((resolve) => setTimeout(resolve, waitMs));
  }

  await page.screenshot({ path: filePath, fullPage });
  await page.close();

  console.log(`  ✅ Saved screenshot -> ${filePath}`);
};

const run = async () => {
  const { default: puppeteer } = await import('puppeteer');

  describeTarget();
  fs.mkdirSync(outputDir, { recursive: true });

  const browser = await puppeteer.launch({
    headless: headless ? 'new' : false,
    args: chromiumArgs,
  });

  let failures = 0;
  for (let index = 0; index < urls.length; index += 1) {
    const targetPath = urls[index];
    try {
      await captureScreenshot(browser, targetPath, index);
    } catch (error) {
      failures += 1;
      console.error(`  ❌ Failed for ${targetPath}: ${error.message}`);
    }
  }

  await browser.close();

  if (failures > 0) {
    console.error(`Finished with ${failures} failure(s). See logs above.`);
    process.exit(1);
  } else {
    console.log('Visual verification completed successfully.');
  }
};

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
