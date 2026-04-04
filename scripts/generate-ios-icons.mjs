#!/usr/bin/env node
// Generate all required iOS AppIcon PNGs from the SVG source.
// Run: node scripts/generate-ios-icons.mjs

import sharp from "sharp";
import { readFileSync } from "fs";
import { join } from "path";

const ICON_DIR = join(
  process.cwd(),
  "malsat_app/ios/Runner/Assets.xcassets/AppIcon.appiconset"
);
const SOURCE = join(ICON_DIR, "icon-source.svg");

// iPhone + iPad + App Store marketing icon sizes (pixels).
const ICONS = [
  // iPhone
  { file: "Icon-App-20x20@2x.png", size: 40 },
  { file: "Icon-App-20x20@3x.png", size: 60 },
  { file: "Icon-App-29x29@1x.png", size: 29 },
  { file: "Icon-App-29x29@2x.png", size: 58 },
  { file: "Icon-App-29x29@3x.png", size: 87 },
  { file: "Icon-App-40x40@2x.png", size: 80 },
  { file: "Icon-App-40x40@3x.png", size: 120 },
  { file: "Icon-App-60x60@2x.png", size: 120 },
  { file: "Icon-App-60x60@3x.png", size: 180 },
  // iPad
  { file: "Icon-App-20x20@1x.png", size: 20 },
  { file: "Icon-App-40x40@1x.png", size: 40 },
  { file: "Icon-App-76x76@1x.png", size: 76 },
  { file: "Icon-App-76x76@2x.png", size: 152 },
  { file: "Icon-App-83.5x83.5@2x.png", size: 167 },
  // App Store
  { file: "Icon-App-1024x1024@1x.png", size: 1024 },
];

const svg = readFileSync(SOURCE);

for (const { file, size } of ICONS) {
  // Cap density so very-large sizes don't overflow sharp's pixel limit.
  const density = Math.min(600, Math.ceil((size / 1024) * 300 * 2));
  await sharp(svg, { density })
    .resize(size, size)
    // iOS marketing icon (1024) must NOT have alpha.
    .flatten({ background: { r: 27, g: 67, b: 50 } })
    .png({ compressionLevel: 9 })
    .toFile(join(ICON_DIR, file));
  console.log(`✓ ${file} (${size}×${size})`);
}

console.log(`\nGenerated ${ICONS.length} icons → ${ICON_DIR}`);
