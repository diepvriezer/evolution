module util::Measures

public int calculateLOC(str i) {
	return (0 | it + 1 | /^.+(\r?\n)?/m := i);
}