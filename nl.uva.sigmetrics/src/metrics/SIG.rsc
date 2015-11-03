module metrics::SIG

import util::IO;

import IO;
import util::Math;
import util::Resources;

alias Rating = str; // ++, +, o, -, --
alias Risk = int; // 0, 1, 2, 3

data SigRating = sig(Rating volume, Rating complexity, Rating unitSize, Rating duplication);
data IsoRating = iso(Rating analysability, Rating changeability, Rating testability);

@doc{ Core risk and metrics for files and units. }
data Unit = unit(str name, int lines, int cc, Risk lineRisk, Risk ccRisk);
data FileInfo = fileInfo(list[Line] srcLines, int lines, list[Unit] units);
anno int		FileInfo@dupLines;

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
Rating rankRisk(map[Risk, num] locMap) {
	moderate = round(locMap[1]);
	high = round(locMap[2]);
	veryHigh = round(locMap[3]);
	
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