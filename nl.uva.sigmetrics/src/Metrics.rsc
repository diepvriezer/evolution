module Metrics

import IO;
import String;
import List;
import Utils;
import util::Resources;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;


alias Rank = str; // ++, +, o, -, --
data SIG = sig(Rank volume, Rank complexity, Rank duplication, Rank size, Rank testing);


// Count lines of code, uses two Java functions for Regex simplicity. Investigate library/util/LOC.rsc
int countLoc(loc path) {
	str stripped = stripComments(readFile(path));
	return (0 | it + 1 | line <- splitLines(stripped), trim(line) != "");
}
int countLoc(list[loc] paths) = (0 | it + countLoc(p) | p <- paths);

// Rank lines of code according to SIG model for Java.
Rank rankLoc(int n) {
	n /= 1000;
	if (n < 66) return "++";
	if (n < 246) return "+";
	if (n < 665) return "o";
	if (n < 1310) return "-";
	return "--";
}



public M3 getMetrics(str id) {
	loc proj = toLocation("project://" + id);
	list[loc] files = findFiles("java", getProject(proj));
	
	// Calculate lines of code.
	int lines = countLoc(files);
	Rank volume = rankLoc(lines);
	println("<lines> lines of code, <volume>");
	
	// Calculate m3 model.
	M3 model = createM3FromEclipseProject(proj);
	
	return model;
}


// Sample wrappers.
public M3 getExample() = getMetrics("tcpExample");