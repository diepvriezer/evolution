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
	
	// Final ratings.
	Rating rLoc, rComplex, rUnit, rClone;
	
	// Compile a list of source files, accumulate stripped lines.
	list[loc] files = findFiles("java", getProject(project));
	list[Line] lines = [];
	for (f <- files) {
		lines = lines + getStrippedLines(f);
	}
	
	
	M3 model = createM3FromEclipseProject(project);
		
	// Metric 1: volume.
	int linesOfCode = size(lines);
	rLoc = rankLoc(linesOfCode);
	
	println("Lines of code: <linesOfCode>");
	
	// Metric 2&3: complexity, unit.
	<rComplex, rUnit> = calculateUnitComplexity(model, linesOfCode);
	
	// Metric 4: code duplication.
	dups = calcDuplicates(lines);
	rClone = rankDuplication(dups.percentage);
	
	println("Code duplication: <dups.percentage> of <linesOfCode> lines");
	
	println();
	println("Ratings");
	println("  Volume:      <rLoc>");
	println("  Complexity:  <rComplex>");
	println("  Unit size:   <rUnit>");
	println("  Duplication: <rClone>");
}