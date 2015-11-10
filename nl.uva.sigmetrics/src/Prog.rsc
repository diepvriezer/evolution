module Prog

import Prelude;
import metrics::UnitTest;
import metrics::CloneDetection;
import metrics::SIG;
import metrics::UnitComplexity;
import vis::Render;
import lang::java::jdt::Project;
import lang::java::m3::AST;
import util::Math;
import util::Resources;
import util::Charts;
import util::Input;
import vis::TreeMaps;

bool verbose = false; // verbose

void calcMetrics(loc projPath) {
	
	println("SIG Maintainability Index Calculator");
	println(" By Floris den Heijer & Jordy Heemskerk");
	println();
	
	// Get files, could be simpler but we want treeeees.
	Resource proj = getProject(projPath);
	Resource javaFileTree = filterResourceTree(proj);
	set[loc] files = ({} | it + l | /file(l) := javaFileTree);
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
		info[l.file].dupLines += 1;
	}
	
	int totalLocDup = size(dupLines);
	int dupPercentage = round((totalLocDup / (totalLoc * 1.0)) * 100);
	println("Duplication: <totalLocDup> of <totalLoc> lines, <dupPercentage>%");
	
	// Compute risk maps, SIG and ISO metrics.
	<ccMap, sizeMap, dupMap> = countUnitCcSizeDup(totalLoc, range(info));
	
	sRating = sig(rankLoc(totalLoc), rankRisk(ccMap), rankRisk(sizeMap), rankDuplication(dupPercentage));
	iRating = sigToIso(sRating);
	
	printSig(sRating);
	printIso(iRating);

	// Draw TreeMapLoc.
	
	annotatedResourceTree = annotateResourceTree(javaFileTree, info);
	render(resourceTreeToTreeMap(annotatedResourceTree));

	// Render figures and more detailed output.
	println("\n----------------------------------\n");
	plotPrintMap("Cyclomatic Complexity", sRating.complexity, ccMap);
	plotPrintMap("Unit Size", sRating.unitSize, sizeMap);
	plotPrintMap("Duplication", sRating.duplication, dupMap);

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
			unitLines = size(getStrippedLines(d@src));
			unitCc = cc(d);
			units += unit(name, unitLines, unitCc, categorizeUnitLoc(unitLines), categorizeCc(unitCc));
		}
	}
	
	return fileInfo(stripped, size(stripped), 0, units);
}

@doc { Plot/print combinator. }
void plotPrintMap(str title, Rating r, map[&T, num] m) {
	displayTitle = "<title> (<r>)";
	printRMap(displayTitle, m);
	plotRMap(title, displayTitle, m);	
}

private list[Color] plotColors = [ color(c) | c <- ["green", "mediumseagreen", "gold", "salmon", "crimson"]];

@doc { Plots a rating map. }
void plotRMap(str title, str displayTitle, map[Rating, num] m) {
	y = axis("Percentage", max(range(m)));
	s = [series("++", [m["++"]], col=plotColors[0]),
	     series("+", [m["+"]], col=plotColors[1]),
	     series("o", [m["o"]], col=plotColors[2]),
	     series("-", [m["-"]], col=plotColors[3]),
	     series("--", [m["--"]], col=plotColors[4])];
	render(title, barChart(y,s,title=displayTitle));
}

@doc { Plots a risk map. }
void plotRMap(str title, str displayTitle, map[Risk, num] m) {
	y = axis("Percentage", max(range(m)));
	s = [series("Low", [m[0]], col=plotColors[0]),
	     series("Moderate", [m[1]], col=plotColors[2]),
	     series("High", [m[2]], col=plotColors[3]),
	     series("Very high", [m[3]], col=plotColors[4])];
	render(title, barChart(y,s,title=displayTitle));
}