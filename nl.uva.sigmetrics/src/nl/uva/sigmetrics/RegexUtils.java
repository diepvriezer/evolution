package nl.uva.sigmetrics;

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
	private static final Pattern blanks = Pattern.compile("(\\r?\\n)", Pattern.DOTALL);
	private static final Pattern regex = Pattern.compile(blockComments + "|" + lineComments + "|" + strings, Pattern.DOTALL);
	
	public RegexUtils(IValueFactory values){
		this.values = values;
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
	
	// This whole ordeal is the easiest way to strip multi and single line comments
	// while still allowing comment characters in string constants. Replaces multiline
	// comments with whitespace to maintain line no's.
	public IValue stripComments(IString src) {
		String s = src.getValue();		
		StringBuffer result = new StringBuffer();
		
		Matcher m = regex.matcher(s);
		while(m.find()) {
			String rep = m.group();
			try {
				m.appendReplacement(result, getReplacement(rep));
			} catch(IllegalArgumentException e) {
				// trust us, we need this. UTF8 + regex = €_Ã
				m.appendReplacement(result, getReplacement("\"Illegal Encoding!\""));
			}
		}
		m.appendTail(result);
		
		return values.string(result.toString());
	}
	
	private String getReplacement(String val) {
		if (val.startsWith("//")) {
			return System.lineSeparator();
		}
		if (val.startsWith("/*")) {
			StringBuffer sb = new StringBuffer();
			Matcher m2 = blanks.matcher(val);
			while(m2.find()) {
				sb.append(m2.group());
			}
			return sb.toString();
		}
		
	    return val;
	}
}