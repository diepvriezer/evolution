module metrics::UnitTest


import util::IO;

import Prelude;

import util::Resources;
import util::Math;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public loc smallsql = |project://smallsql|;

public real calculateUnitTestPenetration(loc project) = calculateUnitTestPenetration(createM3FromEclipseProject(project));
public real calculateUnitTestPenetration(M3 model) {
	
	allClasses = classes(model);
	trclExtends = model@extends+;
	testClasses = domain(rangeR(trclExtends, {|java+class:///junit/framework/TestCase|}));
	toTestClasses = allClasses - testClasses;
	allMethods = declaredMethods(model);
	toTestMethods = range(domainR(allMethods, toTestClasses)); 
	testingMethods = range(allMethods) - toTestMethods;
	methodInvocation = model@methodInvocation;
	trclMethodInvocation = methodInvocation+;
	trclTestingMethodInvocation = domainR(trclMethodInvocation, testingMethods);
	filteredTrclTestingMethodInvocation = { mi | mi <- trclTestingMethodInvocation, /^\/(java|junit)/ !:= mi[1].path};
	testedMethods = range(filteredTrclTestingMethodInvocation) - testingMethods;
	untestedMethods = toTestMethods - testedMethods;
	
	iprintln("<size(testedMethods)> <size(untestedMethods)> <size(toTestMethods)>");
	
	return toReal(size(testedMethods)) / size(untestedMethods);
}

public rel[loc, loc] declaredMethodsAndConstructors(M3 m, set[Modifier] checkModifiers = {}) {
    declaredClasses = classes(m);
    methodModifiersMap = toMap(m@modifiers);
    
    return {e | tuple[loc lhs, loc rhs] e <- domainR(m@containment, declaredClasses), isMethod(e.rhs) || isConstructor(e.rhs), checkModifiers <= (methodModifiersMap[e.rhs]? ? methodModifiersMap[e.rhs] : {}) };
}
