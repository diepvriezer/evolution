module StringStripper

import IO;
import String;


// \/\/.*\r?\n|"[^(\\")]*"
public str strip(str i) {
	return trim(visit(i) {
		case /\/\/.*<linebreak:\r?\n>|<string:".+?[^\\]">|<multi:\/\*(.*?\r?\n?)+?\*\/>|<imp:[ \t]*?import.*>|<newLines:(\r?\n){3,}>/i => string != "" ? string : linebreak != "" ? linebreak : newLines != "" ? "\n" : "" 
	});
}