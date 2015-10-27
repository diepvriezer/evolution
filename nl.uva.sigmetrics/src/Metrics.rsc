module Metrics

import IO;
import String;
import Map;
import List;
import Tuple;
import Utils;
import util::Resources;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;


alias Rank = str; // ++, +, o, -, --
alias Risk = int; // 0, 1, 2, 3
data SIG = sig(Rank volume, Rank complexity, Rank duplication, Rank size, Rank testing);


// Lambda's are skipped by the Rascal parser so won't be accounted for in CC.





// Count lines of code, uses two Java functions for Regex simplicity. Investigate library/util/LOC.rsc
int countLoc(loc path) {
	str stripped = stripComments(readFile(path));
	return (0 | it + 1 | line <- splitLines(stripped), trim(line) != "");
}
int countLoc(list[loc] paths) = (0 | it + countLoc(p) | p <- paths);

// Ranking.
Rank rankLoc(int n) {
	n /= 1000;
	if (n < 66) return "++";
	if (n < 246) return "+";
	if (n < 665) return "o";
	if (n < 1310) return "-";
	return "--";
}

// Risks are given in whole percentages, we use rounding as a strict boundary 
// doesn't make sense for larger system. Example: very complex state machine,
// not easily refactored or already minimal and should not result in a (-) rank
// by default.
Rank rankRisk(map[Risk, num] locMap) {
	moderate = round(locMap[1]);
	high = round(locMap[2]);
	veryHigh = round(locMap[3]);
	
	if (moderate <= 25 && high <= 0 && veryHigh <= 0) return "++";
	if (moderate <= 30 && high <= 5 && veryHigh <= 0) return "+";
	if (moderate <= 40 && high <= 10 && veryHigh <= 0) return "o";
	if (moderate <= 50 && high <= 15 && veryHigh <= 5) return "-";
	return "--";
}


// Computes the CC for a given (method) AST.
int cc(Declaration ast) {
	int n = 1;
	visit(ast) {
		case \case(_) 		: n+=1;
		case \catch(_,_)	: n+=1;
		case \if(_,_)		: n+=1;
		case \if(_,_,_)		: n+=1;
		case \while(_,_)	: n+=1;
		case \for(_,_,_)	: n+=1;
		case \for(_,_,_,_)	: n+=1;
		case \foreach(_,_,_): n+=1;
	}
	return n;
}

Risk categorizeCc(int n) {
	if (n <= 10) return 0;
	if (n <= 20) return 1;
	if (n <= 50) return 2;
	return 3;
}

Risk categorizeUnitLoc(int n) {
	if (n <= 20) return 0;
	if (n <= 50) return 1;
	if (n <= 100) return 2;
	return 3;
}

public void getMetrics(str id) {
	loc proj = toLocation("project://" + id);
	list[loc] files = findFiles("java", getProject(proj));
	
	// Total volume.
	int lines = countLoc(files);
	Rank volume = rankLoc(lines);
	println("<lines> lines of code, <volume>");
	
	M3 model = createM3FromEclipseProject(proj);
	
	// Map holding LOC and CC risk for each unit. 
	map[loc, tuple[int, Risk]] unitMap = ();
	map[Risk, num] ccMap = (0:0, 1:0, 2:0, 3:0);
	map[Risk, num] locMap = (0:0, 1:0, 2:0, 3:0);
	for (loc m <- methods(model)) {
		ast = getMethodASTEclipse(m, model=model);
		nLoc = countLoc(m);
		ccRisk = categorizeCc(cc(ast));
		locRisk = categorizeUnitLoc(nLoc);
		unitMap[m] = <nLoc, ccRisk>;
		ccMap[ccRisk] += nLoc;
		locMap[locRisk] += nLoc;
	}
	
	// Genius reuse of resources.
	ccMap = (risk : ccMap[risk]/lines | risk <- ccMap);
	locMap = (risk : locMap[risk]/lines | risk <- locMap);
	
	Rank complexity = rankRisk(ccMap);
	println("complexity, <complexity>");
	
	Rank unitSize = rankRisk(locMap);
	println("unit size, <unitSize>");
	
	// Todo either normalize maps or calculate deviation from total.
	
	list[str] dupLines = [];
	for (path <- files) {
		for (l <- [trim(s) | s <- splitLines(stripComments(readFile(path)))]) {
			if (l == "" || startsWith(l, "import"))
				continue;
			dupLines += l;
		}
	}
	
	map[str, list[int]] dupMap = ();
	for (ix <- index(dupLines)) {
		l = dupLines[ix];
		if (l in dupMap) dupMap[l] += ix;
		else dupMap[l] = [ix];
	}
	
	map[str, list[int]] dupes = (l : dupMap[l] | l <- dupMap, size(dupMap[l]) > 1);
	
	println(dupes);
}

public void getExample() = getMetrics("tcpExample");