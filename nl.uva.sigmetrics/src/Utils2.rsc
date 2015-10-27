module Utils2


//First stripStrings, for they can also contain comment symbols.
public str stripStringsR(str input) {
	return visit(input) {
		case /^<jString:".*[^\\"]">/i => "\"\""
	}
}

public str stripInlineComments(str input) {
	return visit(input) {
		case /^\/\/.*<linebreak:\r?\n>/i => linebreak
	}
}

public str stripMultilineComments(str input) {
	return visit(input) {
		case /^<multiLine:\/\*(.*\r?\n?)*\*\/>/i => ""
	}
}

public str stripBloat(str input) {
	return stripMultilineComments(
		stripInlineComments(
			stripStringsR(input)
		)
	);
}

private test bool t_strip1() = stripBloat("int hi = 5; //random\r\n") == "int hi = 5; \r\n"; // single lines need a (CR)LF for it to work.
private test bool t_strip2() = stripBloat("/* /*\n /* bite me\n */var x = \"//yes\"; /* haha /*\n/*\r\n asdf/**/") == "var x = \"//yes\"; "; // the line from hell
