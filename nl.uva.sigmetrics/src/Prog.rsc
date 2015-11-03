module Prog

import util::IO;
import metrics::CloneDetection;
import metrics::SIG;
import metrics::UnitComplexity;
import vis::TreeMaps;

import IO;
import Set;
import List;
import Map;
import String;
import lang::java::jdt::Project;
import lang::java::m3::AST;
import util::Math;
import util::Resources;

bool verbose = false; // verbose

void calcMetrics(loc projPath) {
	
	println("SIG Maintainability Index Calculator");
	println(" By Floris den Heijer & Jordy Heemskerk");
	println();
	
	Resource proj = getProject(projPath);
	set[loc] files = {};
	for (/file(l) := proj, l.extension=="java") files += l;
	println("Project: <projPath>, <size(files)> files\n");
	
	// Compute unit and file metrics for all source files.
	println("Computing LOC, unit CC and unit LOC...");
	map[loc, FileInfo] info = ( f : processFile(f) | f <- files);
	
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
	
	// Calculate SIG and ISO metrics.
	sRating = calcSig(totalLoc, range(info), dupPercentage);
	iRating = sigToIso(sRating);
	
	printSig(sRating);
	printIso(iRating);
	
	// Draw figures.
	locRes = annoLoc(info, proj);
	renderResource(locRes);
}

@doc{ Processes a file and returns it's stripped source lines and file info. } 
FileInfo processFile(loc l) {
	printlnv("Processing <l.file>...");
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

@doc{ Helper which calculates the final SIG score. }
SigRating calcSig(int totalLoc, set[FileInfo] infos, int dupPercentage) {
	map[Risk, num] ccMap = (0:0, 1:0, 2:0, 3:0);
	map[Risk, num] locMap = (0:0, 1:0, 2:0, 3:0);
	for (i <- infos) {
		for (u <- i.units) {
			ccMap[u.ccRisk] += u.lines;
			locMap[u.lineRisk] += u.lines;
		}
	}
	
	ccMap = (risk : ccMap[risk]/totalLoc | risk <- ccMap);
	locMap = (risk : locMap[risk]/totalLoc | risk <- locMap);
	
	return sig(rankLoc(totalLoc), rankRisk(ccMap), rankRisk(locMap), rankDuplication(dupPercentage));
}

// (useless) print helpers.
void printlnv() { if (verbose) println(); }
void printlnv(str msg) { if (verbose) println(msg); }
void printv(str msg) { if (verbose) print(msg); }