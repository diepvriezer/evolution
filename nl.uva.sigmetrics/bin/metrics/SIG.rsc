module metrics::SIG

import util::Math;

alias Rating = str; // ++, +, o, -, --
alias Risk = int; // 0, 1, 2, 3

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

Rating rankDuplication(real percentage) {
	int p = round(percentage * 100);
	
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
