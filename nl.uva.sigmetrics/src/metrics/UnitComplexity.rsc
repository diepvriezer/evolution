module metrics::UnitComplexity

import metrics::SIG;
import util::IO;

import IO;
import List;
import Set;
import lang::java::m3::AST;
import lang::java::m3::Core;

@doc { Computes the CC for a given (method) AST. }
int cc(Declaration ast) {
	int n = 1;
	visit(ast) {
		case \case(_) 				: n+=1;
		case \catch(_,_)			: n+=1;
		case \if(_,_)				: n+=1;
		case \if(_,_,_)				: n+=1;
		case \while(_,_)			: n+=1;
		case \for(_,_,_)			: n+=1;
		case \for(_,_,_,_)			: n+=1;
		case \foreach(_,_,_)		: n+=1;
		case \conditional(_,_,_)	: n+=1;
		case \infix(_,"||",_)		: n+=1;
		case \infix(_,"&&",_)		: n+=1;
	}
	return n;
}

@doc { Calculates the cyclomatic complexity and unit complexity metrics. }
public tuple[Rating, Rating] calculateUnitComplexity(set[loc] files, int lines) {

	// Map holding LOC and CC risk for each unit. 
	map[loc, tuple[int, Risk]] unitMap = ();
	map[Risk, num] ccMap = (0:0, 1:0, 2:0, 3:0);
	map[Risk, num] locMap = (0:0, 1:0, 2:0, 3:0);
	
	for (loc f <- files) {
		ast = createAstFromFile(f, false); // we don't need to collect types.
		
		visit(ast) {
			case Declaration d: {
				if (d is method) {
					loc m = d@src;
					
					nLoc = size(splitLines(readFile(m)));
					ccRisk = categorizeCc(cc(d));
					locRisk = categorizeUnitLoc(nLoc);
					
					unitMap[m] = <nLoc, ccRisk>;
					ccMap[ccRisk] += nLoc;
					locMap[locRisk] += nLoc;
				}
			}
		}
	}
		
	// Genius reuse of resources.
	ccMap = (risk : ccMap[risk]/lines | risk <- ccMap);
	locMap = (risk : locMap[risk]/lines | risk <- locMap);
	
	Rating complexity = rankRisk(ccMap);
	Rating unitSize = rankRisk(locMap);
	
	return <complexity, unitSize>; // Todo either normalize maps or calculate deviation from total.
}