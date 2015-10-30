module Program

import List;

import metrics::CloneDetection;
import metrics::SIG;
import metrics::UnitComplexity;
import util::IO;

import IO;
import util::Resources;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public void run(loc project) {

	println("SIG Maintainability Index Calculator");
	println(" By Floris den Heijer & Jordy Heemskerk");
	println();
	
	println("Target location: <project>\n");
		
	// Final ratings.
	Rating rLoc, rComplex, rUnit, rClone;
	
	// Compile a list of source files, accumulate stripped lines.
	list[loc] files = findFiles("java", getProject(project));
	int nFiles = size(files);
	
	println("Starting indexation of <nFiles> files...");
	list[Line] lines = [];
	for (f <- files) {
		lines = lines + getStrippedLines(f);
	}
	
	// Metric: Volume.
	int linesOfCode = size(lines);
	rLoc = rankLoc(linesOfCode);
	
	println("Lines of code: <linesOfCode>");
	
	// Metric: Duplication.
	println("Finding duplicates...");
	dups = calcDuplicates(lines);
	rClone = rankDuplication(dups.percentage);
	
	println("Code duplication: <dups.percentage> of <linesOfCode> lines");
	
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