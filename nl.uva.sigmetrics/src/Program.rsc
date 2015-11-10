module Program

import metrics::CloneDetection;
import metrics::SIG;
import metrics::UnitComplexity;
import util::IO;
import vis::Playground;

import Prelude;
import util::Math;
import util::Resources;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import lang::java::jdt::Project;

public void run(loc projectPath) {

	println("SIG Maintainability Index Calculator");
	println(" By Floris den Heijer & Jordy Heemskerk");
	println();
	
	println("Target location: <projectPath>\n");
	
	// Project resource, which will be annotated with various ratings per file.
	Resource proj = getProject(projectPath);
	
	// Final ratings.
	Rating rLoc, rComplex, rUnit, rClone;
	
	// Compile a set of source files, accumulate stripped lines.
	set[loc] files = sourceFilesForProject(projectPath);
	int nFiles = size(files);
	
	println("Starting indexation of <nFiles> files...");
	list[Line] lines = [];
	for (f <- files) {
		lines += getStrippedLines(f);
	}
	
	// Metric: Volume.
	int linesOfCode = size(lines);
	rLoc = rankLoc(linesOfCode);
	
	println("Lines of code: <linesOfCode>");
	
	lines = stripClosingCurlies(lines);
	
	// Metric: Duplication.
	println("Finding duplicates...");
	set[Line] dups = findDuplicates(lines);
	int pDups = round((size(dups) / (linesOfCode * 1.0)) * 100);
	rClone = rankDuplication(pDups);
	
	println("Code duplication: <size(dups)> of <linesOfCode> lines (<pDups>%)");
	set[set[Line]] linesPerFile = group(dups, similarFile);

	// Metrics: Complexity & unit size.
	println("Calculating cyclomatic complexity & unit size...");
	<rComplex, rUnit> = calculateUnitComplexity(files, linesOfCode);

	println();
	println("SIG Ratings");
	println("  Volume:      <rLoc>");
	println("  Complexity:  <rComplex>");
	println("  Unit size:   <rUnit>");
	println("  Duplication: <rClone>");
}

bool similarFile(Line a, Line b) = a.file == b.file;