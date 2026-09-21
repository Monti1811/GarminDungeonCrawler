import { buildOptimizedProject, getConfig } from "@markw65/monkeyc-optimizer";
import { optimizeProgram } from "@markw65/monkeyc-optimizer/sdk-util.js";
import * as path from "node:path";
import * as fs from "node:fs";

const args = process.argv.slice(2);
if (args.length < 2) {
  console.error("Usage: node optimize-build.mjs <device> <outputDir> [developerKeyPath]");
  process.exit(1);
}

const device = args[0];
const outputDir = path.resolve(args[1]);
const developerKeyPath = args[2] ? path.resolve(args[2]) : undefined;

const cwd = process.cwd();
const jungleFiles = path.resolve(cwd, "monkey.jungle");
const workspace = path.dirname(jungleFiles);

fs.mkdirSync(outputDir, { recursive: true });

const options = {
  workspace,
  buildDir: "bin",
  outputPath: "bin/optimized",
  jungleFiles,
  developerKeyPath,
  returnCommand: false,
  // For export/App Store builds, forbidden opts are disabled
  allowForbiddenOpts: false,
};

const configuredOptions = await getConfig(options);

const result = await buildOptimizedProject(device, configuredOptions);
console.log(`Built: ${result.program}`);

const optimized = await optimizeProgram(
  result.program,
  configuredOptions.developerKeyPath,
  undefined,
  configuredOptions
);

console.log(`Optimized: ${optimized.output}`);

// Copy optimized output to the desired output directory with a clean name
const ext = path.extname(optimized.output);
const baseName = `DungeonCrawler-${device}`;
const finalOutput = path.join(outputDir, `${baseName}${ext}`);
fs.copyFileSync(optimized.output, finalOutput);
console.log(`Copied to: ${finalOutput}`);
