package nl.uva.sigmetrics.helpers;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.rascalmpl.value.IList;
import org.rascalmpl.value.IListWriter;
import org.rascalmpl.value.IString;
import org.rascalmpl.value.IValue;
import org.rascalmpl.value.IValueFactory;

/*
 * Wrapper for regular expression flexibility not found in Rascal.
 */
public class RegexUtils {
	
	protected final IValueFactory values;
	
	// Regex magic from https://stackoverflow.com/questions/3524317/regex-to-strip-line-comments-from-c-sharp/3524689#3524689
	private static final String blockComments = "/\\*(.*?)\\*/";
	private static final String lineComments = "//(.*?)\\r?\\n";
	private static final String strings = "\"((\\\\[^\\n]|[^\"\"\\n])*)\"";
	private static final Pattern regex = Pattern.compile(blockComments + "|" + lineComments + "|" + strings, Pattern.DOTALL);
	
	public RegexUtils(IValueFactory values){
		this.values = values;
	}
	
	// This whole ordeal is the easiest way to strip multi and single line comments
	// while still allowing comment characters in string constants. Testing done in Rascal.
	public IValue stripComments(IString src) {
		String result = StringReplacer.replace(src.getValue(), regex, (Matcher m) -> {
			String val = m.group();
			if (val.startsWith("/*") || val.startsWith("//"))
				return val.startsWith("//") ? System.lineSeparator() : "";
			
		    return val;
		});
		return values.string(result);
	}
	
	// Rascals split wraps the Java call, but quotes the pattern.
	public IList splitLines(IString src) {
		String[] lst = src.getValue().split("\\r?\\n");
		IListWriter lw = values.listWriter();
		for (String s : lst) {
			lw.append(values.string(s));
		}
		return lw.done();
	}
}