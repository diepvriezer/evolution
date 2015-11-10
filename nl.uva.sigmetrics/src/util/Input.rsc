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

bool extensionFilter(f:file(l), set[str] acceptedFiles) = l.extension in acceptedFiles;
bool javaFileFilter(f:file(l)) = extensionFilter(f, {"java"});

set[Resource] filterToplevelFiles(set[Resource] rs, bool (Resource) fltr) = (rs | it - f | f:file(l) <- rs, !fltr(f));

Resource filterResourceTree(Resource tree, bool (Resource) fltr=javaFileFilter) {
	
	return innermost visit(tree) {
		case project(l,{folder(_,{}),*r}): insert project(l, r);
		case folder(l,{folder(_,{}),*r}):  insert folder(l, r);
		case project(l, fs):               { nfs = filterToplevelFiles(fs, fltr); if(nfs != fs) insert project(l,nfs); else fail; }
		case folder(l, fs):                { nfs = filterToplevelFiles(fs, fltr); if(nfs != fs) insert folder(l,nfs); else fail; }
	}
}

@doc{ Because closing curlies count towards LOC but are useless for duplicate detection, we strip 'em. }
public list[Line] stripClosingCurlies(list[Line] lines) = [ l | l <- lines, l.s != "}" ]; // already trimmed.

@javaClass{nl.uva.sigmetrics.RegexUtils}
public java str stripComments(str s);

@javaClass{nl.uva.sigmetrics.RegexUtils}
public java list[str] splitLines(str s);

