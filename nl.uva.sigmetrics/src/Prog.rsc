module Prog

import Prelude;
import lang::java::jdt::Project;
import lang::java::m3::AST;
import metrics::CloneDetection;
import metrics::SIG;
import metrics::UnitComplexity;
import util::Input;
import util::Math;
import util::Resources;

void calcMetrics(loc projPath) {
	
	println("SIG Maintainability Index Calculator");
	println(" By Floris den Heijer & Jordy Heemskerk");
	println();
	
	// Get files, could be simpler but we want treeeees.
	Resource proj = getProject(projPath);
	set[loc] files = {};
	for (/file(l) := proj, l.extension=="java") files += l;
	println("Project: <projPath>, <size(files)> files\n");
	
	// Compute unit and file metrics for all source files.
	println("Computing LOC, unit CC and unit LOC");
	map[loc, FileInfo] info = ( f : processFile(f) | f <- files);
	println();
	
	// Metric: Volume.
	list[Line] lines = ([] | it + f.srcLines | f <- range(info));
	int totalLoc = size(lines);
	println("Total LOC: <totalLoc>");
	
	// Metric: Duplication, annotate files.
	println("Finding duplicate lines...");
	set[Line] dupLines = findDuplicates(stripClosingCurlies(lines));
	for (l <- dupLines) {
		info[l.file]@dupLines += 1;
	}
	
	int totalLocDup = size(dupLines);
	int dupPercentage = round((totalLocDup / (totalLoc * 1.0)) * 100);
	println("Duplication: <totalLocDup> of <totalLoc> lines, <dupPercentage>%");
	
	// Compute risk maps, SIG and ISO metrics.
	<ccMap, sizeMap> = countUnitCcAndSize(totalLoc, range(info));
	
	sRating = sig(rankLoc(totalLoc), rankRisk(ccMap), rankRisk(sizeMap), rankDuplication(dupPercentage));
	iRating = sigToIso(sRating);
	
	printSig(sRating);
	printIso(iRating);
}

@doc{ Processes a file and returns it's stripped source lines and file info. } 
FileInfo processFile(loc l) {
	print(".");
	src = readFile(l);
	stripped = getStrippedLines(l, src=src);
	ast = createAstFromString(l, src, false); // no bindings.
	
	// For each method in the file's AST, calculate LOC and CC.
	list[Unit] units = [];
	visit(ast) {
		case Declaration d : method(_,name,_,_,_): {
			unitLines = size(splitLines(readFile(d@src)));
			unitCc = cc(d);
			units += unit(name, unitLines, unitCc, categorizeUnitLoc(unitLines), categorizeCc(unitCc));
		}
	}
	
	return fileInfo(stripped, size(stripped), units);
}