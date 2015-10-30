module util::IO

import IO;
import String;
import util::Resources;

data Line = line(str s, loc file, int row);

@doc{ Returns a list of files with a specific extension for project resources and paths. }
public list[loc] findFiles(str ext, file(file)) = file.extension == ext ? [file] : [];
public list[loc] findFiles(str ext, folder(_, contents)) = findFiles(ext, contents);
public list[loc] findFiles(str ext, project(_, contents)) = findFiles(ext, contents);
public list[loc] findFiles(str ext, loc path) = [] when !exists(path);
public list[loc] findFiles(str ext, loc path) = findFiles(ext, file(path)) when isFile(path);
public list[loc] findFiles(str ext, loc path) = findFiles(ext, [ path + p | p <- listEntries(path)]) when isDirectory(path);
public list[loc] findFiles(str ext, &T contents) = ([] | it + findFiles(ext, c) | c <- contents);

@doc{ Returns a list of stripped lines for a given file. Comment lines are replaced with blanks. } 
public list[Line] getStrippedLines(loc path) {
	s = stripComments(readFile(path));
	lines = ([] | it + l | /^<l:.*>(\r?\n)?/m := s);
	int i = 0;
	return for (l <- lines) {
		i += 1;
		l = trim(l);
		if (l != "") append(line(l, path, i));
	}
}

@javaClass{nl.uva.sigmetrics.RegexUtils}
public java str stripComments(str s);

@javaClass{nl.uva.sigmetrics.RegexUtils}
public java list[str] splitLines(str s);