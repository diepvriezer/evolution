module StringStripper

import IO;
import String;

public str strip(str i) {
	return
		stripEmptyLines(
			stripClosingBrackets(
				stripImports(
					stripComments(i)
				)
			)
		);
}


// Strips comments
public str stripComments(str i) {
	str output = visit(i) {
		case /\/\/.*<linebreak:\r?\n>|<string:".+?[^\\]">|<multi:\/\*(.*?\r?\n?)+?\*\/>/i => string != "" ? string : linebreak != "" ? linebreak : "" 
	};
	return stripEmptyLines(output);
}

// Strips empty lines
public str stripEmptyLines(str i) {
	return trim(visit(i) {
		case /\r?\n\s*\r?\n/ => "\n"
	});
}

// Strips import declarations
public str stripImports(str i) {
	return visit(i) {
		case /<imp:[ \t]*?import.*\r?\n>/ => ""
	}
}

// Stips single closing brackets
public str stripClosingBrackets(str i) {
	return visit(i) {
		case /<closingBracket:\s*\}\s*?\r?\n?>/ => "\n"
	}
}