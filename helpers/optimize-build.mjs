import { buildOptimizedProject, getConfig } from "@markw65/monkeyc-optimizer";
import { optimizeProgram } from "@markw65/monkeyc-optimizer/sdk-util.js";
import * as path from "node:path";
import * as fs from "node:fs";

const args = process.argv.slice(2);
if (args.length < 2) {
  console.error("Usage: node optimize-build.mjs <device|iq> <outputDir> [developerKeyPath]");
  console.error("  'iq' builds the universal .iq file (no device-specific .prg)");
  process.exit(1);
}

const target = args[0];
const outputDir = path.resolve(args[1]);
const developerKeyPath = args[2] ? path.resolve(args[2]) : undefined;
const buildIqOnly = target === "iq";

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
  allowForbiddenOpts: false,
};

const configuredOptions = await getConfig(options);

if (buildIqOnly) {
  // Build .iq (universal, null device = .iq export)
  const iqResult = await buildOptimizedProject(null, configuredOptions);
  console.log(`Built IQ: ${iqResult.program}`);

  const iqOutput = path.join(outputDir, `DungeonCrawler.iq`);
  fs.copyFileSync(iqResult.program, iqOutput);
  console.log(`Copied IQ to: ${iqOutput}`);
} else {
  // Build .prg (device-specific)
  const prgResult = await buildOptimizedProject(target, configuredOptions);
  console.log(`Built PRG: ${prgResult.program}`);

  const prgOptimized = await optimizeProgram(
    prgResult.program,
    configuredOptions.developerKeyPath,
    undefined,
    configuredOptions
  );

  const prgOutput = path.join(outputDir, `DungeonCrawler-${target}.prg`);
  fs.copyFileSync(prgOptimized.output, prgOutput);
  console.log(`Copied PRG to: ${prgOutput}`);
}
