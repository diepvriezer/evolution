module vis::Playground
import Set;
import IO;
import List;
import util::Resources;

Resource getPrj() {
	return getProject(|project://hsqldb|);
}
Resource parseR(Resource r) {
	switch(r) {
		case project(l, c): {
			return project(l, parseR(c));
		}
		case folder(l, c): {
			return folder(l, parseR(c));
		}
		case file(l): {
			if(l.extension=="java") {
				return file(l);
			}
			return folder(l, {}); // because you cannot create a empty file, or pattern match on the location.
		}
	}
}
set[Resource] parseR(set[Resource] rs) {
	R = for(r <- rs) {
		p = parseR(r);
		if(folder(_, {}) := p) {
			continue;
		}
		append p;
	}
	return toSet(R);
}

Resource removeNonJava(p:project(l, cs)) {
	cs = removeNonjava(cs);
	if (cs == {}) throw "empty proj";
	return project(l, cs);
}
set[Resource] removeNonJava(f:folder(l, cs)) {
	if (cs != {}) {
		cs = removeNonjava(cs);
	}
	if (cs == {}) return {};
	return {folder(l, cs)};
}
set[Resource] removeNonJava(f:file(l)) = l.extension == "java" ? {f} : {};
set[Resource] removeNonjava(set[Resource] rs) = flatten({ removeNonJava(r) | r <- rs });
set[Resource] flatten(set[set[Resource]] s) {
	r = {};
	for (ss <- s) {
		for (sss <- ss) {
			r += sss;
		}
	}
	return r;
}