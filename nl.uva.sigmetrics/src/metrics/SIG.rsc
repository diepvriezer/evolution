module metrics::SIG

import Prelude;
import util::Input;
import util::Math;
import util::Resources;

alias Rating = str; // ++, +, o, -, --
alias Risk = int; // 0 = lowest, 1, 2, 3 = highest

data SigRating = sig(Rating volume, Rating complexity, Rating unitSize, Rating duplication);
data IsoRating = iso(Rating analysability, Rating changeability, Rating testability);

@doc{ Core risk and metrics for files and units. }
data Unit = unit(str name, int lines, int cc, Risk lineRisk, Risk ccRisk);
data FileInfo = fileInfo(list[Line] srcLines, int lines, int dupLines, list[Unit] units);

@doc { Rate LOC. }
Rating rankLoc(int n) {
	n /= 1000;
	if (n < 66) return "++";
	if (n < 246) return "+";
	if (n < 665) return "o";
	if (n < 1310) return "-";
	return "--";
}

@doc {
	Risks are given in whole percentages, we use rounding as a strict boundary 
	doesn't make sense for larger system. Example: very complex state machine,
	not easily refactored or already minimal and should not result in a (-) rank
	by default.
}
Rating rankRisk(map[Risk, num] riskMap) {
	moderate = round(riskMap[1] * 100);
	high = round(riskMap[2] * 100);
	veryHigh = round(riskMap[3] * 100);
	
	if (moderate <= 25 && high <= 0 && veryHigh <= 0) return "++";
	if (moderate <= 30 && high <= 5 && veryHigh <= 0) return "+";
	if (moderate <= 40 && high <= 10 && veryHigh <= 0) return "o";
	if (moderate <= 50 && high <= 15 && veryHigh <= 5) return "-";
	return "--";
}

Rating rankDuplication(int p) {
	if (p <= 3) return "++";
	if (p <= 5) return "+";
	if (p <= 10) return "o";
	if (p <= 20) return "-";
	return "--";
}

@doc { Profile cyclomatic complexity. }
Risk categorizeCc(int n) {
	if (n <= 10) return 0;
	if (n <= 20) return 1;
	if (n <= 50) return 2;
	return 3;
}

@doc { Profile unit size. }
Risk categorizeUnitLoc(int n) {
	if (n <= 20) return 0;
	if (n <= 50) return 1;
	if (n <= 100) return 2;
	return 3;
}

@doc { Categorize risks for unit CC, size and duplication. }
tuple[map[Risk, num], map[Risk, num], map[Rating, num]] countUnitCcSizeDup(int totalLoc, set[FileInfo] infos) {
	map[Risk, num] ccMap = (0:0, 1:0, 2:0, 3:0);
	map[Risk, num] locMap = (0:0, 1:0, 2:0, 3:0);
	map[Rating, num] rMap = ("++":0, "+":0, "o":0, "-":0, "--":0);
	for (i <- infos) {
		if (i.dupLines == 0) {
			rMap["++"] += 1;
		} else {
			percentage = round(i.dupLines / (1.0 * i.lines) * 100);
			rMap[rankDuplication(percentage)] += 1;
		}
		
		for (u <- i.units) {
			ccMap[u.ccRisk] += u.lines;
			locMap[u.lineRisk] += u.lines;
		}
	}
	
	ccMap = (risk : ccMap[risk]/totalLoc | risk <- ccMap);
	locMap = (risk : locMap[risk]/totalLoc | risk <- locMap);
	rMap = (rating : rMap[rating]/size(infos) | rating <- rMap);
		
	return <ccMap, locMap, rMap>;
}

@doc { Does what it says. }
IsoRating sigToIso(SigRating s) {
	real v = rtoi(s.volume);
	real cc = rtoi(s.complexity);
	real dup = rtoi(s.duplication);
	real sz = rtoi(s.unitSize);
	
	real ana = (v + dup + sz) / 3;
	real cha = (cc + dup) / 2;
	real tes = (cc + sz) / 2;
	
	return iso(itor(ana), itor(cha), itor(tes));
}

// Print helpers.
public void printSig(SigRating sigScore) {
	println("\nSIG Ratings");
	println("  Volume:         <sigScore.volume>");
	println("  Complexity:     <sigScore.complexity>");
	println("  Duplication:    <sigScore.duplication>");
	println("  Unit size:      <sigScore.unitSize>");
	println("  Unit testing:   [not implemented]");  
}

public void printIso(IsoRating isoScore) {
	println("\nISO 9126 Ratings");
	println("  Analysability:  <isoScore.analysability>");
	println("  Changeability:  <isoScore.changeability>");
	println("  Stability:      [not implemented]");
	println("  Testability:    <isoScore.testability>");
}

public void printRMap(str title, map[Rating, num] m) {
	println("<title>");
	println("  ++         <round(m["++"] * 100)> %");
	println("  +          <round(m["+"] * 100)> %");
	println("  o          <round(m["o"] * 100)> %");
	println("  -          <round(m["-"] * 100)> %");
	println("  --         <round(m["--"] * 100)> %\n");
}

public void printRMap(str title, map[Risk, num] m) {
	println("<title>");
	println("  Low        <round(m[0] * 100)> %");
	println("  Moderate   <round(m[1] * 100)> %");
	println("  High       <round(m[2] * 100)> %");
	println("  Very high  <round(m[3] * 100)> %\n");
}

// Conversions.
private real rtoi(Rating r) {
	if (r == "++") return 4.0;
	if (r == "+") return 3.0;
	if (r == "o") return 2.0;
	if (r == "-") return 1.0;
	return 0.0;
}
private Rating itor(real r) {
	int i = round(r);
	if (r == 0) return "--";
	if (r == 1) return "-";
	if (r == 2) return "o";
	if (r == 3) return "+";
	return "++";
}