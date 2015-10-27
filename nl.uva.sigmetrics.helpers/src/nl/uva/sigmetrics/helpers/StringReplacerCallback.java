package nl.uva.sigmetrics.helpers;

import java.util.regex.Matcher;

/* From https://stackoverflow.com/questions/19737653/what-is-the-equivalent-of-regex-replace-with-function-evaluation-in-java-7 */
public interface StringReplacerCallback {
    public String replace(Matcher match);
}