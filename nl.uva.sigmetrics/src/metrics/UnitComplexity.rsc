module metrics::UnitComplexity

import Prelude;
import lang::java::m3::AST;
import lang::java::m3::Core;
import metrics::SIG;
import util::Input;

@doc { Computes the CC for a given (method) AST. }
int cc(Declaration ast) {
	int n = 1;
	visit(ast) {
		case \assert(_)				: n+=1; // asserts are if/else internally
		case \assert(_,_)			: n+=1;
		case \case(_) 				: n+=1;
		case \catch(_,_)			: n+=1;
		case \if(_,_)				: n+=1;
		case \if(_,_,_)				: n+=1;
		case \while(_,_)			: n+=1;
		case \for(_,_,_)			: n+=1;
		case \for(_,_,_,_)			: n+=1;
		case \foreach(_,_,_)		: n+=1;
		case \conditional(_,_,_)	: n+=1;
		case \infix(_,"||",_)		: n+=1; // counted because of short circuit behavior
		case \infix(_,"&&",_)		: n+=1;
	}
	return n;
}

private bool testCc(int expected, str src) {
	wrapper = "public class TestMe {\n<src>\n}";
	ast = createAstFromString(|file:///C:/unknown.java|, wrapper, false);
	top-down-break visit(ast) {
		case Declaration d: method(_,_,_,_,_) : return cc(d) == expected;
	}
}

@doc { Should be 4, as recommended by McCabe. }
test bool t1() = testCc(4, "
int foo (int a, int b) {
        if (a \> 17 && b \< 42 && a+b \< 55) {
                return 1;
        }
        return 2;
}");
 
@doc { Following both have CC=5, which demonstrates the relative simplicity of the measure. }
test bool t2() = testCc(5, "
int sumOfNonPrimes(int limit) {
        int sum = 0;
        OUTER: for (int i = 0; i \< limit; ++i) {
                if (i \<= 2) {
                        continue;
                }
                for (int j = 2; j \< i; ++j) {
                        if (i % j == 0) {
                                continue OUTER;
                        }
                }
                sum += i;
        }
        return sum;
}");
 
 test bool t3() = testCc(5, "
 String getWeight(int i) {
        if (i \<= 0) {
                return \"no weight\";
        }
        if (i \< 10) {
                return \"light\";
        }
        if (i \< 20) {
                return \"medium\";
        }
        if (i \< 30) {
                return \"heavy\";
        }
        return \"very heavy\";
}");