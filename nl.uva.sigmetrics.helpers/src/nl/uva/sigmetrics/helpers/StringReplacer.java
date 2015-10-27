package nl.uva.sigmetrics.helpers;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/* From https://stackoverflow.com/questions/19737653/what-is-the-equivalent-of-regex-replace-with-function-evaluation-in-java-7 */
public class StringReplacer {
    public static String replace(String input, Pattern regex, StringReplacerCallback callback) {
        StringBuffer resultString = new StringBuffer();
        Matcher regexMatcher = regex.matcher(input);
        while (regexMatcher.find()) {
            regexMatcher.appendReplacement(resultString, callback.replace(regexMatcher));
        }
        regexMatcher.appendTail(resultString);

        return resultString.toString();
    }
}