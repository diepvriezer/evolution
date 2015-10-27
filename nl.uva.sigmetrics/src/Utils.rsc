module Utils

import IO;
import String;
import util::Resources;

// Returns a list of files with a specific extension for project resources and paths. Lookup sourceFilesForProject
list[loc] findFiles(str ext, file(file)) = file.extension == ext ? [file] : [];
list[loc] findFiles(str ext, folder(_, contents)) = findFiles(ext, contents);
list[loc] findFiles(str ext, project(_, contents)) = findFiles(ext, contents);
list[loc] findFiles(str ext, loc path) = [] when !exists(path);
list[loc] findFiles(str ext, loc path) = findFiles(ext, file(path)) when isFile(path);
list[loc] findFiles(str ext, loc path) = findFiles(ext, [ path + p | p <- listEntries(path)]) when isDirectory(path);
list[loc] findFiles(str ext, &T contents) = ([] | it + findFiles(ext, c) | c <- contents);


// Comment stripper, easier than SystemAPI
@javaClass{nl.uva.sigmetrics.helpers.RegexUtils}
public java str stripComments(str s);
private test bool t_strip1() = stripComments("int hi = 5; //random\r\n") == "int hi = 5; \r\n"; // single lines need a (CR)LF for it to work.
private test bool t_strip2() = stripComments("/* /*\n /* bite me\n */var x = \"//yes\"; /* haha /*\n/*\r\n asdf/**/") == "var x = \"//yes\"; "; // the line from hell


// Line splitter
@javaClass{nl.uva.sigmetrics.helpers.RegexUtils}
public java list[str] splitLines(str s);