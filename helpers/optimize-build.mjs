import { buildOptimizedProject, getConfig } from "@markw65/monkeyc-optimizer";
import { optimizeProgram } from "@markw65/monkeyc-optimizer/sdk-util.js";
import * as path from "node:path";
import * as fs from "node:fs";

const args = process.argv.slice(2);
if (args.length < 2) {
  console.error(
    "Usage: node optimize-build.mjs <device|iq> <outputDir> [developerKeyPath] [sourceWorkspace]"
  );
  console.error("  'iq' builds the universal .iq file (no device-specific .prg)");
  console.error(
    "  sourceWorkspace: optional folder with the sources to build (defaults to cwd)"
  );
  process.exit(1);
}

const target = args[0];
const outputDir = path.resolve(args[1]);
const developerKeyPath = args[2] ? path.resolve(args[2]) : undefined;
const buildIqOnly = target === "iq";

const workspace = args[3] ? path.resolve(args[3]) : process.cwd();
const jungleFiles = path.join(workspace, "monkey.jungle");
if (!fs.existsSync(jungleFiles)) {
  console.error(`monkey.jungle not found in workspace: ${workspace}`);
  process.exit(1);
}

fs.mkdirSync(outputDir, { recursive: true });

const options = {
  workspace,
  buildDir: "bin",
  outputPath: "bin/optimized",
  jungleFiles,
  developerKeyPath,
  returnCommand: false,
  allowForbiddenOpts: false,
  releaseBuild: true,
  simulatorBuild: false,
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
