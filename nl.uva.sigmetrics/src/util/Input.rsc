module util::Input

import Prelude;

data Line = line(str s, loc file, int row);

@doc{ Returns a list of stripped lines for a given file. Comment lines are replaced with blanks. } 
public list[Line] getStrippedLines(loc path, str src="") {
	if (src == "") src = readFile(path);
	s = stripComments(src);
	lines = ([] | it + l | /^<l:.*>(\r?\n)?/m := s);
	int i = 0;
	return for (l <- lines) {
		i += 1;
		l = trim(l);
		if (l != "") append(line(l, path, i));
	}
}

@doc{ Because closing curlies count towards LOC but are useless for duplicate detection, we strip 'em. }
public list[Line] stripClosingCurlies(list[Line] lines) = [ l | l <- lines, l.s != "}" ]; // already trimmed.

@javaClass{nl.uva.sigmetrics.RegexUtils}
public java str stripComments(str s);

@javaClass{nl.uva.sigmetrics.RegexUtils}
public java list[str] splitLines(str s);