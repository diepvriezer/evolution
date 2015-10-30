module util::Measures

public int calculateLOC(str i) {
	return (1 | it + 1 | /^<line:.*>(\r?\n)?/m := i);
}