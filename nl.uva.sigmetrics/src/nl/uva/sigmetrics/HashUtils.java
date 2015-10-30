package nl.uva.sigmetrics;

import org.rascalmpl.value.IString;
import org.rascalmpl.value.IValue;
import org.rascalmpl.value.IValueFactory;

// Wraps the hashcode() for strings, https://en.wikipedia.org/wiki/Java_hashCode%28%29
public class HashUtils {
	
	protected final IValueFactory values;
	
	public HashUtils(IValueFactory values) {
		this.values = values;
	}
	
	public IValue hashCode(IString source) {
		return values.integer(source.getValue().hashCode());
	}
}
